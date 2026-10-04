<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.Statement"
         import="java.io.File,java.io.FileOutputStream,java.io.InputStream,java.io.ByteArrayOutputStream"
         import="java.util.UUID,java.util.List,java.util.ArrayList,java.util.Map,java.util.HashMap"
         import="java.nio.charset.StandardCharsets"
         import="db.DBConnection" %>

<%!
    public static class MultipartItem {
        public String name;
        public String fileName;
        public String contentType;
        public byte[] data;

        public MultipartItem(String name, String fileName,
                             String contentType, byte[] data) {
            this.name = name;
            this.fileName = fileName;
            this.contentType = contentType;
            this.data = data;
        }

        public String getText() {
            return new String(data, StandardCharsets.UTF_8);
        }
    }

    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;");
    }

    private String getHeaderValue(String headers, String headerName) {
        String[] lines = headers.split("\r\n");

        for (int i = 0; i < lines.length; i++) {
            int colon = lines[i].indexOf(':');

            if (colon > 0 &&
                lines[i].substring(0, colon).trim()
                        .equalsIgnoreCase(headerName)) {
                return lines[i].substring(colon + 1).trim();
            }
        }

        return "";
    }

    private String getDispositionValue(String disposition, String key) {
        String[] parts = disposition.split(";");

        for (int i = 0; i < parts.length; i++) {
            String part = parts[i].trim();
            String prefix = key + "=";

            if (part.toLowerCase().startsWith(prefix.toLowerCase())) {
                String value = part.substring(prefix.length()).trim();

                if (value.startsWith("\"") && value.endsWith("\"")
                        && value.length() >= 2) {
                    value = value.substring(1, value.length() - 1);
                }

                return value;
            }
        }

        return "";
    }

    private Map<String, List<MultipartItem>> parseMultipart(
            javax.servlet.http.HttpServletRequest request) throws Exception {

        String contentType = request.getContentType();

        if (contentType == null ||
            !contentType.toLowerCase().startsWith("multipart/form-data")) {
            throw new Exception("ฟอร์มไม่ได้ส่งข้อมูลแบบ multipart/form-data");
        }

        String boundary = null;
        String[] contentTypeParts = contentType.split(";");

        for (int i = 0; i < contentTypeParts.length; i++) {
            String part = contentTypeParts[i].trim();

            if (part.toLowerCase().startsWith("boundary=")) {
                boundary = part.substring("boundary=".length()).trim();

                if (boundary.startsWith("\"") && boundary.endsWith("\"")) {
                    boundary = boundary.substring(1, boundary.length() - 1);
                }

                break;
            }
        }

        if (boundary == null || boundary.length() == 0) {
            throw new Exception("ไม่พบ boundary ของข้อมูลที่ส่งมา");
        }

        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        InputStream input = request.getInputStream();
        byte[] chunk = new byte[8192];
        int count;
        int maxRequestSize = 12 * 1024 * 1024;

        while ((count = input.read(chunk)) != -1) {
            if (buffer.size() + count > maxRequestSize) {
                throw new Exception("ข้อมูลที่ส่งมามีขนาดใหญ่เกินกำหนด");
            }

            buffer.write(chunk, 0, count);
        }

        String raw = new String(
                buffer.toByteArray(),
                StandardCharsets.ISO_8859_1
        );

        String marker = "--" + boundary;

        Map<String, List<MultipartItem>> result =
                new HashMap<String, List<MultipartItem>>();

        int position = 0;

        while (true) {
            int boundaryStart = raw.indexOf(marker, position);

            if (boundaryStart < 0) break;

            int afterBoundary = boundaryStart + marker.length();

            if (raw.startsWith("--", afterBoundary)) break;

            if (raw.startsWith("\r\n", afterBoundary)) {
                afterBoundary += 2;
            }

            int headerEnd = raw.indexOf("\r\n\r\n", afterBoundary);

            if (headerEnd < 0) break;

            String headers = raw.substring(afterBoundary, headerEnd);
            int dataStart = headerEnd + 4;

            int nextBoundary = raw.indexOf(marker, dataStart);

            if (nextBoundary < 0) break;

            int dataEnd = nextBoundary;

            if (dataEnd >= 2 &&
                raw.substring(dataEnd - 2, dataEnd).equals("\r\n")) {
                dataEnd -= 2;
            }

            String disposition =
                    getHeaderValue(headers, "Content-Disposition");

            String fieldName =
                    getDispositionValue(disposition, "name");

            String fileName =
                    getDispositionValue(disposition, "filename");

            String partContentType =
                    getHeaderValue(headers, "Content-Type");

            if (fieldName.length() > 0 && dataEnd >= dataStart) {
                String dataString = raw.substring(dataStart, dataEnd);

                byte[] data =
                        dataString.getBytes(StandardCharsets.ISO_8859_1);

                MultipartItem item = new MultipartItem(
                        fieldName,
                        fileName,
                        partContentType,
                        data
                );

                List<MultipartItem> items = result.get(fieldName);

                if (items == null) {
                    items = new ArrayList<MultipartItem>();
                    result.put(fieldName, items);
                }

                items.add(item);
            }

            position = nextBoundary;
        }

        return result;
    }

    private String getField(
            Map<String, List<MultipartItem>> parts,
            String fieldName) {

        List<MultipartItem> items = parts.get(fieldName);

        if (items == null || items.size() == 0) return null;

        return items.get(0).getText();
    }

    private String[] getFields(
            Map<String, List<MultipartItem>> parts,
            String fieldName) {

        List<MultipartItem> items = parts.get(fieldName);

        if (items == null || items.size() == 0) return null;

        String[] values = new String[items.size()];

        for (int i = 0; i < items.size(); i++) {
            values[i] = items.get(i).getText();
        }

        return values;
    }
%>

<%
request.setCharacterEncoding("UTF-8");

String errorMessage = null;
Connection con = null;
File savedFile = null;
boolean transactionStarted = false;

try {
    Map<String, List<MultipartItem>> parts = parseMultipart(request);

    String subjectName = getField(parts, "subjectName");
    String questionType = getField(parts, "questionType");
    String mode = getField(parts, "mode");
    String idText = getField(parts, "subjectId");

    boolean isEdit = "edit".equals(mode);
    int questionId = 0;

    if (isEdit) {
        if (idText == null || !idText.matches("\\d+")) {
            throw new Exception("รหัสโจทย์ไม่ถูกต้อง");
        }

        questionId = Integer.parseInt(idText);

    } else if (!"add".equals(mode)) {
        throw new Exception("โหมดบันทึกไม่ถูกต้อง");
    }

    if (subjectName == null || subjectName.trim().isEmpty()) {
        throw new Exception("กรุณากรอกชื่อโจทย์");
    }

    subjectName = subjectName.trim();

    if (subjectName.length() > 255) {
        throw new Exception("ชื่อโจทย์ต้องไม่เกิน 255 ตัวอักษร");
    }

    if (questionType == null) {
        questionType = "";
    }

    questionType = questionType.trim().toUpperCase();

    if (!"FLOWCHART".equals(questionType)
            && !"PSEUDOCODE".equals(questionType)) {
        throw new Exception("ประเภทโจทย์ไม่ถูกต้อง");
    }

    String[] inputs = getFields(parts, "tc_input[]");
    String[] outputs = getFields(parts, "tc_expected[]");
    String[] scores = getFields(parts, "tc_score[]");

    if (inputs == null || outputs == null || scores == null
            || inputs.length == 0
            || inputs.length != outputs.length
            || inputs.length != scores.length) {
        throw new Exception(
                "กรุณากรอก Test Case อย่างน้อย 1 รายการให้ครบถ้วน"
        );
    }

    List<Integer> points = new ArrayList<Integer>();
    int total = 0;

    for (int i = 0; i < inputs.length; i++) {
        if (inputs[i] == null || inputs[i].trim().isEmpty()) {
            throw new Exception(
                    "กรุณากรอก Input ของ Test Case ที่ " + (i + 1)
            );
        }

        if (outputs[i] == null || outputs[i].trim().isEmpty()) {
            throw new Exception(
                    "กรุณากรอก Expected Output ของ Test Case ที่ " + (i + 1)
            );
        }

        inputs[i] = inputs[i].trim();
        outputs[i] = outputs[i].trim();

        int point;

        try {
            point = Integer.parseInt(
                    scores[i] == null ? "" : scores[i].trim()
            );
        } catch (NumberFormatException e) {
            throw new Exception(
                    "คะแนน Test Case ที่ " + (i + 1)
                    + " ต้องเป็นจำนวนเต็ม"
            );
        }

        if (point < 0 || total > Integer.MAX_VALUE - point) {
            throw new Exception(
                    "คะแนนไม่ถูกต้องหรือคะแนนรวมมากเกินไป"
            );
        }

        total += point;
        points.add(point);
    }

    if (total <= 0) {
        throw new Exception("คะแนนรวมต้องมากกว่า 0");
    }

    con = DBConnection.getConnection();

    if (con == null) {
        throw new Exception("ไม่สามารถเชื่อมต่อฐานข้อมูลได้");
    }

    con.setAutoCommit(false);
    transactionStarted = true;

    String oldPdf = null;

    if (isEdit) {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT pdf_file, question_type "
                + "FROM questions WHERE id = ? FOR UPDATE")) {

            ps.setInt(1, questionId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new Exception("ไม่พบโจทย์ที่ต้องการแก้ไข");
                }

                oldPdf = rs.getString("pdf_file");

                if (!questionType.equals(rs.getString("question_type"))) {
                    throw new Exception(
                            "ประเภทโจทย์ไม่ตรงกับข้อมูลเดิม"
                    );
                }
            }
        }
    }

    List<MultipartItem> pdfParts = parts.get("pdfFile");

    MultipartItem pdf =
            (pdfParts == null || pdfParts.isEmpty())
            ? null
            : pdfParts.get(0);

    boolean hasPdf = pdf != null
            && pdf.fileName != null
            && !pdf.fileName.trim().isEmpty();

    if (!isEdit && !hasPdf) {
        throw new Exception("กรุณาเลือกไฟล์ PDF");
    }

    String pdfPath = oldPdf;

    if (hasPdf) {
        String filename = pdf.fileName.replace("\\", "/");

        filename = filename.substring(
                filename.lastIndexOf("/") + 1
        );

        if (!filename.toLowerCase().endsWith(".pdf")) {
            throw new Exception("กรุณาเลือกไฟล์ PDF เท่านั้น");
        }

        if (pdf.data == null || pdf.data.length == 0
                || pdf.data.length > 10 * 1024 * 1024) {
            throw new Exception(
                    "ไฟล์ PDF ว่างเปล่าหรือมีขนาดเกิน 10 MB"
            );
        }

        if (pdf.data.length < 5
                || pdf.data[0] != '%'
                || pdf.data[1] != 'P'
                || pdf.data[2] != 'D'
                || pdf.data[3] != 'F'
                || pdf.data[4] != '-') {
            throw new Exception("ไฟล์ที่เลือกไม่ใช่ PDF ที่ถูกต้อง");
        }

        String dir = application.getRealPath("/uploads/algorithm");

        if (dir == null) {
            throw new Exception("ไม่สามารถระบุตำแหน่งจัดเก็บไฟล์ได้");
        }

        File folder = new File(dir);

        if (!folder.exists() && !folder.mkdirs()) {
            throw new Exception("สร้างโฟลเดอร์อัปโหลดไม่สำเร็จ");
        }

        String stored = UUID.randomUUID().toString() + ".pdf";

        savedFile = new File(folder, stored);

        try (FileOutputStream output = new FileOutputStream(savedFile)) {
            output.write(pdf.data);
        }

        pdfPath = "uploads/algorithm/" + stored;
    }

    if (isEdit) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE questions "
                + "SET name = ?, point = ?, pdf_file = ? "
                + "WHERE id = ?")) {

            ps.setString(1, subjectName);
            ps.setInt(2, total);
            ps.setString(3, pdfPath);
            ps.setInt(4, questionId);

            if (ps.executeUpdate() != 1) {
                throw new Exception("ไม่สามารถแก้ไขโจทย์ได้");
            }
        }

        try (PreparedStatement ps = con.prepareStatement(
                "DELETE FROM algorithm_test_cases WHERE question_id = ?")) {

            ps.setInt(1, questionId);
            ps.executeUpdate();
        }

    } else {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO questions "
                + "(question_type, name, point, pdf_file, status) "
                + "VALUES (?, ?, ?, ?, 'ON')",
                Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, questionType);
            ps.setString(2, subjectName);
            ps.setInt(3, total);
            ps.setString(4, pdfPath);

            if (ps.executeUpdate() != 1) {
                throw new Exception("ไม่สามารถบันทึกโจทย์ได้");
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new Exception("ไม่พบรหัสโจทย์");
                }

                questionId = keys.getInt(1);
            }
        }
    }

    try (PreparedStatement ps = con.prepareStatement(
            "INSERT INTO algorithm_test_cases "
            + "(question_id, case_no, input_data, expected_output, point) "
            + "VALUES (?, ?, ?, ?, ?)")) {

        for (int i = 0; i < inputs.length; i++) {
            ps.setInt(1, questionId);
            ps.setInt(2, i + 1);
            ps.setString(3, inputs[i]);
            ps.setString(4, outputs[i]);
            ps.setInt(5, points.get(i));
            ps.addBatch();
        }

        if (ps.executeBatch().length != inputs.length) {
            throw new Exception("บันทึก Test Case ไม่ครบ");
        }
    }

    con.commit();
    transactionStarted = false;

    response.sendRedirect(
            "SubjectsView.jsp?save=success&id=" + questionId
    );
    return;

} catch (Exception ex) {
    errorMessage = ex.getMessage();

    if (errorMessage == null || errorMessage.trim().isEmpty()) {
        errorMessage = "เกิดข้อผิดพลาดระหว่างบันทึกข้อมูล";
    }

    if (con != null && transactionStarted) {
        try {
            con.rollback();
        } catch (Exception e) {
            application.log("Rollback error", e);
        }
    }

    if (savedFile != null && savedFile.exists() && !savedFile.delete()) {
        application.log(
                "ไม่สามารถลบไฟล์ชั่วคราว: " + savedFile.getAbsolutePath()
        );
    }

    application.log("SaveAlgorithmQuestion.jsp error", ex);

} finally {
    if (con != null) {
        try {
            con.setAutoCommit(true);
        } catch (Exception ignored) {}

        try {
            con.close();
        } catch (Exception e) {
            application.log("Database close error", e);
        }
    }
}
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>บันทึกโจทย์ไม่สำเร็จ</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background: #f5f6fa;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 16px;
        }

        .message-box {
            background: #fff;
            padding: 30px;
            border-radius: 12px;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 4px 18px rgba(0,0,0,.08);
            text-align: center;
        }

        h2 {
            color: #c0392b;
        }

        p {
            color: #333;
            overflow-wrap: anywhere;
            line-height: 1.6;
        }

        a {
            display: inline-block;
            margin-top: 15px;
            padding: 10px 20px;
            color: #fff;
            background: #2563eb;
            border-radius: 7px;
            text-decoration: none;
        }

        a:hover {
            background: #1d4ed8;
        }
    </style>
</head>

<body>
    <div class="message-box">
        <h2>ไม่สามารถบันทึกโจทย์ได้</h2>
        <p><%= escapeHtml(errorMessage) %></p>
        <a href="javascript:history.back()">กลับไปแก้ไข</a>
    </div>
</body>
</html>