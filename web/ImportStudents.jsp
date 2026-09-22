<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="db.DBConnection"%>
<%@page import="java.util.zip.ZipFile"%>
<%@page import="java.util.zip.ZipEntry"%>
<%@page import="javax.xml.parsers.DocumentBuilderFactory"%>
<%@page import="javax.xml.parsers.DocumentBuilder"%>
<%@page import="org.w3c.dom.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
private static class UploadedFile {
    String fileName;
    byte[] bytes;

    UploadedFile(String fileName, byte[] bytes) {
        this.fileName = fileName;
        this.bytes = bytes;
    }
}

private String getXmlText(Element element) {
    if (element == null) return "";
    String text = element.getTextContent();
    return text == null ? "" : text.trim();
}

private String getCellValue(ZipFile zip, Element cell, List<String> sharedStrings) throws Exception {
    if (cell == null) return "";

    NodeList values = cell.getElementsByTagNameNS("*", "v");
    String value = values.getLength() > 0 ? getXmlText((Element) values.item(0)) : "";
    String type = cell.getAttribute("t");

    if ("s".equals(type)) {
        if (value.isEmpty()) return "";
        int index = Integer.parseInt(value);
        if (index >= 0 && index < sharedStrings.size()) return sharedStrings.get(index);
        return "";
    }

    if ("inlineStr".equals(type)) {
        NodeList textNodes = cell.getElementsByTagNameNS("*", "t");
        StringBuilder text = new StringBuilder();

        for (int i = 0; i < textNodes.getLength(); i++) {
            text.append(getXmlText((Element) textNodes.item(i)));
        }

        return text.toString().trim();
    }

    return value.trim();
}

private List<String> readSharedStrings(ZipFile zip) throws Exception {
    List<String> sharedStrings = new ArrayList<String>();
    ZipEntry entry = zip.getEntry("xl/sharedStrings.xml");

    if (entry == null) return sharedStrings;

    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    factory.setNamespaceAware(true);
    DocumentBuilder builder = factory.newDocumentBuilder();

    try (InputStream input = zip.getInputStream(entry)) {
        Document document = builder.parse(input);
        NodeList stringNodes = document.getElementsByTagNameNS("*", "si");

        for (int i = 0; i < stringNodes.getLength(); i++) {
            Element si = (Element) stringNodes.item(i);
            NodeList textNodes = si.getElementsByTagNameNS("*", "t");
            StringBuilder text = new StringBuilder();

            for (int j = 0; j < textNodes.getLength(); j++) {
                text.append(getXmlText((Element) textNodes.item(j)));
            }

            sharedStrings.add(text.toString());
        }
    }

    return sharedStrings;
}

private String getColumnReference(Element cell) {
    String reference = cell.getAttribute("r");
    StringBuilder column = new StringBuilder();

    for (int i = 0; i < reference.length(); i++) {
        char c = reference.charAt(i);
        if (Character.isLetter(c)) column.append(Character.toUpperCase(c));
        else break;
    }

    return column.toString();
}

private String getCellByColumn(ZipFile zip, Element row, String column, List<String> sharedStrings) throws Exception {
    NodeList cells = row.getElementsByTagNameNS("*", "c");

    for (int i = 0; i < cells.getLength(); i++) {
        Element cell = (Element) cells.item(i);

        if (column.equals(getColumnReference(cell))) {
            return getCellValue(zip, cell, sharedStrings);
        }
    }

    return "";
}

private Document readSheetDocument(ZipFile zip) throws Exception {
    ZipEntry entry = zip.getEntry("xl/worksheets/sheet1.xml");

    if (entry == null) {
        throw new Exception("ไม่พบ Sheet แรกในไฟล์ Excel");
    }

    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    factory.setNamespaceAware(true);
    DocumentBuilder builder = factory.newDocumentBuilder();

    try (InputStream input = zip.getInputStream(entry)) {
        return builder.parse(input);
    }
}

private Map<String, Object> parseMultipartRequest(InputStream input, String contentType) throws Exception {
    Map<String, Object> result = new HashMap<String, Object>();

    if (contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith("multipart/form-data")) {
        throw new Exception("Request ไม่ใช่ multipart/form-data");
    }

    String boundary = null;

    for (String part : contentType.split(";")) {
        String item = part.trim();

        if (item.toLowerCase(Locale.ROOT).startsWith("boundary=")) {
            boundary = item.substring("boundary=".length()).trim();

            if (boundary.startsWith("\"") && boundary.endsWith("\"") && boundary.length() >= 2) {
                boundary = boundary.substring(1, boundary.length() - 1);
            }

            break;
        }
    }

    if (boundary == null || boundary.isEmpty()) {
        throw new Exception("ไม่พบ boundary ของ multipart/form-data");
    }

    ByteArrayOutputStream requestBuffer = new ByteArrayOutputStream();
    byte[] buffer = new byte[8192];
    int n;

    while ((n = input.read(buffer)) != -1) {
        requestBuffer.write(buffer, 0, n);
    }

    byte[] data = requestBuffer.toByteArray();
    byte[] boundaryBytes = ("--" + boundary).getBytes("ISO-8859-1");
    byte[] nextBoundaryBytes = ("\r\n--" + boundary).getBytes("ISO-8859-1");
    byte[] headerEnd = "\r\n\r\n".getBytes("ISO-8859-1");

    int position = indexOfBytes(data, boundaryBytes, 0);

    while (position >= 0) {
        int partStart = position + boundaryBytes.length;

        if (partStart + 1 < data.length && data[partStart] == '-' && data[partStart + 1] == '-') {
            break;
        }

        if (partStart + 1 < data.length && data[partStart] == '\r' && data[partStart + 1] == '\n') {
            partStart += 2;
        }

        int headersEnd = indexOfBytes(data, headerEnd, partStart);
        if (headersEnd < 0) break;

        String headers = new String(data, partStart, headersEnd - partStart, "ISO-8859-1");
        int bodyStart = headersEnd + headerEnd.length;
        int bodyEnd = indexOfBytes(data, nextBoundaryBytes, bodyStart);

        if (bodyEnd < 0) break;

        String name = null;
        String fileName = null;

        for (String headerLine : headers.split("\r\n")) {
            if (!headerLine.toLowerCase(Locale.ROOT).startsWith("content-disposition:")) continue;

            for (String dispositionPart : headerLine.split(";")) {
                String item = dispositionPart.trim();

                if (item.toLowerCase(Locale.ROOT).startsWith("name=")) {
                    name = item.substring(5).trim();

                    if (name.startsWith("\"") && name.endsWith("\"") && name.length() >= 2) {
                        name = name.substring(1, name.length() - 1);
                    }
                } else if (item.toLowerCase(Locale.ROOT).startsWith("filename=")) {
                    fileName = item.substring(9).trim();

                    if (fileName.startsWith("\"") && fileName.endsWith("\"") && fileName.length() >= 2) {
                        fileName = fileName.substring(1, fileName.length() - 1);
                    }
                }
            }
        }

        byte[] body = Arrays.copyOfRange(data, bodyStart, bodyEnd);

        if (name != null) {
            if (fileName != null) {
                List<UploadedFile> files = (List<UploadedFile>) result.get(name);

                if (files == null) {
                    files = new ArrayList<UploadedFile>();
                    result.put(name, files);
                }

                files.add(new UploadedFile(fileName, body));
            } else {
                List<String> values = (List<String>) result.get(name);

                if (values == null) {
                    values = new ArrayList<String>();
                    result.put(name, values);
                }

                values.add(new String(body, "UTF-8").trim());
            }
        }

        position = bodyEnd + 2;
    }

    return result;
}

private String getFormValue(Map<String, Object> data, String name) {
    Object value = data.get(name);

    if (!(value instanceof List)) return "";

    List<?> values = (List<?>) value;

    if (values.isEmpty() || values.get(0) == null) return "";

    return values.get(0).toString().trim();
}

private int indexOfBytes(byte[] source, byte[] target, int start) {
    if (target.length == 0) return start;

    outer:
    for (int i = Math.max(0, start); i <= source.length - target.length; i++) {
        for (int j = 0; j < target.length; j++) {
            if (source[i + j] != target[j]) continue outer;
        }

        return i;
    }

    return -1;
}
%>

<%
if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect("StudentView.jsp");
    return;
}

String message = null;
String messageType = "success";
Map<String, Object> multipartData = new HashMap<String, Object>();

try {
    multipartData = parseMultipartRequest(request.getInputStream(), request.getContentType());
} catch (Exception e) {
    message = "ไม่สามารถรับข้อมูลจากฟอร์มได้: " + e.getMessage();
    messageType = "danger";
}

if (message == null) {
    List<UploadedFile> excelFiles = (List<UploadedFile>) multipartData.get("excel_file[]");

    String studentId = getFormValue(multipartData, "student_id");
    String fullName = getFormValue(multipartData, "full_name");
    String secText = getFormValue(multipartData, "sec");

    boolean hasExcel = excelFiles != null
            && !excelFiles.isEmpty()
            && excelFiles.get(0) != null
            && excelFiles.get(0).bytes != null
            && excelFiles.get(0).bytes.length > 0;

    boolean hasManual = !studentId.isEmpty()
            || !fullName.isEmpty()
            || !secText.isEmpty();

    if (hasExcel) {
        Connection con = null;
        PreparedStatement checkUser = null;
        PreparedStatement insertUser = null;

        int totalNewUsers = 0;
        int totalExistingUsers = 0;
        int totalInvalidRows = 0;

        try {
            con = DBConnection.getConnection();

            if (con == null) {
                throw new Exception("ไม่สามารถเชื่อมต่อ Database ได้");
            }

            con.setAutoCommit(false);

            checkUser = con.prepareStatement(
                    "SELECT id FROM users WHERE username = ? LIMIT 1"
            );

            insertUser = con.prepareStatement(
                    "INSERT INTO users (username, password, full_name, role, sec, status) VALUES (?, ?, ?, ?, ?, ?)"
            );

            for (UploadedFile fileObj : excelFiles) {
                if (fileObj == null || fileObj.bytes == null || fileObj.bytes.length == 0) continue;

                File tempExcel = File.createTempFile("student_import_", ".xlsx");

                try (OutputStream output = new FileOutputStream(tempExcel)) {
                    output.write(fileObj.bytes);
                }

                try (ZipFile zip = new ZipFile(tempExcel)) {
                    List<String> sharedStrings = readSharedStrings(zip);
                    Document sheetDocument = readSheetDocument(zip);
                    NodeList rows = sheetDocument.getElementsByTagNameNS("*", "row");

                    for (int rowIndex = 0; rowIndex < rows.getLength(); rowIndex++) {
                        Element row = (Element) rows.item(rowIndex);

                        String username = getCellByColumn(zip, row, "A", sharedStrings).trim();
                        String fullNameExcel = getCellByColumn(zip, row, "C", sharedStrings).trim();
                        String secTextExcel = getCellByColumn(zip, row, "D", sharedStrings).trim();

                        if (username.isEmpty() && fullNameExcel.isEmpty() && secTextExcel.isEmpty()) continue;

                        if (username.equalsIgnoreCase("รหัสนักศึกษา")
                                || username.equalsIgnoreCase("student_id")
                                || username.equalsIgnoreCase("username")) {
                            continue;
                        }

                        if (username.isEmpty() || fullNameExcel.isEmpty() || secTextExcel.isEmpty()) {
                            totalInvalidRows++;
                            continue;
                        }

                        int sec;

                        try {
                            sec = Integer.parseInt(secTextExcel);
                        } catch (NumberFormatException e) {
                            totalInvalidRows++;
                            continue;
                        }

                        if (sec <= 0) {
                            totalInvalidRows++;
                            continue;
                        }

                        checkUser.setString(1, username);

                        try (ResultSet rs = checkUser.executeQuery()) {
                            if (rs.next()) {
                                totalExistingUsers++;
                            } else {
                                insertUser.setString(1, username);
                                insertUser.setString(2, username);
                                insertUser.setString(3, fullNameExcel);
                                insertUser.setString(4, "student");
                                insertUser.setInt(5, sec);
                                insertUser.setString(6, "ON");
                                insertUser.executeUpdate();

                                totalNewUsers++;
                            }
                        }
                    }
                } finally {
                    if (!tempExcel.delete()) tempExcel.deleteOnExit();
                }
            }

            con.commit();

            message = "นำเข้าข้อมูลสำเร็จ! เพิ่มนักศึกษาใหม่ " + totalNewUsers + " คน";

            if (totalExistingUsers > 0) {
                message += " | รหัสซ้ำ " + totalExistingUsers + " คน";
            }

            if (totalInvalidRows > 0) {
                message += " | ข้อมูลไม่ถูกต้อง " + totalInvalidRows + " แถว";
            }

        } catch (Exception e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (Exception rollbackError) {
                    rollbackError.printStackTrace();
                }
            }

            message = "เกิดข้อผิดพลาด: " + e.getMessage();
            messageType = "danger";
            e.printStackTrace();

        } finally {
            if (checkUser != null) try {
                checkUser.close();
            } catch (Exception e) {}

            if (insertUser != null) try {
                insertUser.close();
            } catch (Exception e) {}

            if (con != null) {
                try {
                    con.setAutoCommit(true);
                } catch (Exception e) {}

                try {
                    con.close();
                } catch (Exception e) {}
            }
        }

    } else if (hasManual) {
        Connection con = null;
        PreparedStatement checkUser = null;
        PreparedStatement insertUser = null;
        ResultSet rs = null;

        try {
            if (studentId.isEmpty() || fullName.isEmpty() || secText.isEmpty()) {
                throw new Exception("กรุณากรอกข้อมูลนักศึกษาให้ครบถ้วน");
            }

            int sec = Integer.parseInt(secText);

            if (sec <= 0) {
                throw new Exception("SEC ต้องมากกว่า 0");
            }

            con = DBConnection.getConnection();

            if (con == null) {
                throw new Exception("ไม่สามารถเชื่อมต่อ Database ได้");
            }

            checkUser = con.prepareStatement(
                    "SELECT id FROM users WHERE username = ? LIMIT 1"
            );

            checkUser.setString(1, studentId);

            rs = checkUser.executeQuery();

            if (rs.next()) {
                message = "รหัสนักศึกษา " + studentId + " มีอยู่ในระบบแล้ว";
                messageType = "danger";
            } else {
                insertUser = con.prepareStatement(
                        "INSERT INTO users (username, password, full_name, role, sec, status) VALUES (?, ?, ?, ?, ?, ?)"
                );

                insertUser.setString(1, studentId);
                insertUser.setString(2, studentId);
                insertUser.setString(3, fullName);
                insertUser.setString(4, "student");
                insertUser.setInt(5, sec);
                insertUser.setString(6, "ON");
                insertUser.executeUpdate();

                message = "เพิ่มนักศึกษา " + fullName + " สำเร็จ";
                messageType = "success";
            }

        } catch (NumberFormatException e) {
            message = "SEC ต้องเป็นตัวเลขเท่านั้น";
            messageType = "danger";

        } catch (Exception e) {
            message = "เกิดข้อผิดพลาด: " + e.getMessage();
            messageType = "danger";
            e.printStackTrace();

        } finally {
            if (rs != null) try {
                rs.close();
            } catch (Exception e) {}

            if (checkUser != null) try {
                checkUser.close();
            } catch (Exception e) {}

            if (insertUser != null) try {
                insertUser.close();
            } catch (Exception e) {}

            if (con != null) try {
                con.close();
            } catch (Exception e) {}
        }

    } else {
        message = "กรุณาเลือกไฟล์ Excel หรือกรอกข้อมูลนักศึกษา";
        messageType = "danger";
    }
}

session.setAttribute("message", message);
session.setAttribute("messageType", messageType);
response.sendRedirect("StudentView.jsp");
%>
