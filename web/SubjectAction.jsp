<%@page import="java.sql.*"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    // ตรวจสอบและแปลงรหัสโจทย์
    private int parseId(String value) throws Exception {
        if (value == null || !value.trim().matches("\\d+")) {
            throw new Exception("รหัสโจทย์ไม่ถูกต้อง");
        }

        try {
            int id = Integer.parseInt(value.trim());

            if (id <= 0) {
                throw new Exception("รหัสโจทย์ต้องมากกว่า 0");
            }

            return id;
        } catch (NumberFormatException e) {
            throw new Exception("รหัสโจทย์ไม่ถูกต้อง");
        }
    }
%>

<%
request.setCharacterEncoding("UTF-8");

String action = request.getParameter("action");

Connection con = null;
PreparedStatement ps = null;

try {
    con = DBConnection.getConnection();

    if (con == null) {
        throw new Exception("ไม่สามารถเชื่อมต่อ Database ได้");
    }

    /* =====================================================
       ADD SUBJECT
       ===================================================== */
    if ("add".equals(action)) {

        String name = request.getParameter("name");
        String pointText = request.getParameter("point");
        String status = request.getParameter("status");
        String sec = request.getParameter("sec");

        String questionType = request.getParameter("question_type");

        if (questionType == null || questionType.trim().isEmpty()) {
            questionType = request.getParameter("questionType");
        }

        if ("ER".equals(questionType)) {
            questionType = "ER_DIAGRAM";
        }

        if ("Flowchart".equals(questionType)) {
            questionType = "FLOWCHART";
        }

        if ("Pseudocode".equals(questionType)) {
            questionType = "PSEUDOCODE";
        }

        if (name == null || name.trim().isEmpty()) {
            throw new Exception("กรุณากรอกชื่อโจทย์");
        }

        if (name.trim().length() > 255) {
            throw new Exception("ชื่อโจทย์ต้องไม่เกิน 255 ตัวอักษร");
        }

        if (questionType == null
                || !("FLOWCHART".equals(questionType)
                || "PSEUDOCODE".equals(questionType)
                || "ER_DIAGRAM".equals(questionType))) {
            throw new Exception("กรุณาเลือกประเภทโจทย์ให้ถูกต้อง");
        }

        if (pointText == null || pointText.trim().isEmpty()) {
            throw new Exception("กรุณากรอกคะแนน");
        }

        if (sec == null || sec.trim().isEmpty()) {
            throw new Exception("กรุณากรอกเซคชัน");
        }

        int point;

        try {
            point = Integer.parseInt(pointText.trim());
        } catch (NumberFormatException e) {
            throw new Exception("คะแนนต้องเป็นจำนวนเต็ม");
        }

        if (point < 0) {
            throw new Exception("คะแนนต้องไม่ติดลบ");
        }

        if (status == null
                || (!"ON".equals(status) && !"OFF".equals(status))) {
            status = "ON";
        }

        String sql =
                "INSERT INTO questions "
                + "(question_type, name, point, status, sec) "
                + "VALUES (?, ?, ?, ?, ?)";

        ps = con.prepareStatement(sql);
        ps.setString(1, questionType);
        ps.setString(2, name.trim());
        ps.setInt(3, point);
        ps.setString(4, status);
        ps.setString(5, sec.trim());

        ps.executeUpdate();

        // ดึง ID ของโจทย์ที่เพิ่งเพิ่ม
        int questionId = 0;
        try (Statement idStmt = con.createStatement();
            ResultSet idRs = idStmt.executeQuery("SELECT LAST_INSERT_ID()")) {
            if (idRs.next()) {
                questionId = idRs.getInt(1);
            }
        }

        if (questionId > 0) {

            // ดึง ID ของอาจารย์ที่กำลังเข้าสู่ระบบ
            Object userIdObj = session.getAttribute("UserId");
            Integer assignedBy = null;

            if (userIdObj != null) {
                try {
                    assignedBy = Integer.valueOf(userIdObj.toString());
                } catch (NumberFormatException e) {
                    assignedBy = null;
                }
            }

            // มอบหมายโจทย์ทั้งหมดในระบบที่มีสถานะ ON ให้นักศึกษาที่ตรง Sec (รองรับกรณีโจทย์ระบุหลาย Sec คั่นด้วย comma)
            String assignSql =
                "INSERT IGNORE INTO student_questions " +
                "(question_id, student_id, assigned_by, assigned_at) " +
                "SELECT q.id, u.id, ?, NOW() " +
                "FROM questions q " +
                "JOIN users u ON u.role = 'student' " +
                "AND u.sec IS NOT NULL " +
                "AND FIND_IN_SET(" +
                "CAST(u.sec AS CHAR), " +
                "REPLACE(CAST(q.sec AS CHAR), ' ', '')" +
                ") > 0 " +
                "WHERE q.status = 'ON'";

            try (PreparedStatement assignPs =
                    con.prepareStatement(assignSql)) {

                if (assignedBy != null) {
                    assignPs.setInt(1, assignedBy);
                } else {
                    assignPs.setNull(1, java.sql.Types.INTEGER);
                }

                int assignedCount = assignPs.executeUpdate();

                System.out.println(
                    "Assigned questions to " + assignedCount + " student records"
                );
            }
        }

        response.sendRedirect("SubjectsView.jsp?success=added");
        return;
    }

    /* =====================================================
       UPDATE STATUS
       ===================================================== */
    if ("updateStatus".equals(action)) {

        String idText = request.getParameter("id");
        String status = request.getParameter("status");

        int id = parseId(idText);

        if (!"ON".equals(status) && !"OFF".equals(status)) {
            throw new Exception("สถานะไม่ถูกต้อง");
        }

        String sql =
                "UPDATE questions SET status = ? WHERE id = ?";

        ps = con.prepareStatement(sql);
        ps.setString(1, status);
        ps.setInt(2, id);

        int updated = ps.executeUpdate();

        if (updated == 0) {
            throw new Exception("ไม่พบโจทย์ที่ต้องการแก้ไข");
        }

        // ซิงค์การมอบหมายโจทย์ทั้งหมดอีกครั้ง
        Object userIdObj = session.getAttribute("UserId");
        Integer assignedBy = null;
        if (userIdObj != null) {
            try {
                assignedBy = Integer.valueOf(userIdObj.toString());
            } catch (NumberFormatException e) {
                assignedBy = null;
            }
        }

        String syncAssignSql =
            "INSERT IGNORE INTO student_questions " +
            "(question_id, student_id, assigned_by, assigned_at) " +
            "SELECT q.id, u.id, ?, NOW() " +
            "FROM questions q " +
            "JOIN users u ON u.role = 'student' " +
            "AND u.sec IS NOT NULL " +
            "AND FIND_IN_SET(" +
            "CAST(u.sec AS CHAR), " +
            "REPLACE(CAST(q.sec AS CHAR), ' ', '')" +
            ") > 0 " +
            "WHERE q.status = 'ON'";

        try (PreparedStatement syncPs = con.prepareStatement(syncAssignSql)) {
            if (assignedBy != null) {
                syncPs.setInt(1, assignedBy);
            } else {
                syncPs.setNull(1, java.sql.Types.INTEGER);
            }
            syncPs.executeUpdate();
        }

        response.sendRedirect("SubjectsView.jsp?success=updated");
        return;
    }

    /* =====================================================
       DELETE SUBJECT
       ===================================================== */
    if ("delete".equals(action)) {

        String idText = request.getParameter("id");
        int id = parseId(idText);

        String sql = "DELETE FROM questions WHERE id = ?";

        ps = con.prepareStatement(sql);
        ps.setInt(1, id);

        int deleted = ps.executeUpdate();

        if (deleted == 0) {
            throw new Exception("ไม่พบโจทย์ที่ต้องการลบ");
        }

        response.sendRedirect("SubjectsView.jsp?success=deleted");
        return;
    }

    /* =====================================================
       UPDATE SUBJECT
       แก้ไขชื่อโจทย์ สถานะ และเซคชัน
       รองรับฟอร์ม application/x-www-form-urlencoded
       ===================================================== */
    if ("updateAll".equals(action)) {

        List<String> idList = new ArrayList<String>();

        /*
         * รองรับรหัสโจทย์ที่ส่งมาเป็นข้อความคั่นด้วย comma
         * เช่น allSubjectIds=1,2,3
         */
        String idsCsv = request.getParameter("allSubjectIds");

        if (idsCsv != null && !idsCsv.trim().isEmpty()) {
            String[] ids = idsCsv.split(",");

            for (String id : ids) {
                id = id.trim();

                if (!id.isEmpty() && !idList.contains(id)) {
                    idList.add(id);
                }
            }
        }

        /*
         * รองรับกรณีส่ง subjectIds เป็น input หลายตัว
         */
        if (idList.isEmpty()) {
            String[] idsFromArray =
                    request.getParameterValues("subjectIds");

            if (idsFromArray != null) {
                for (String id : idsFromArray) {
                    if (id != null && !id.trim().isEmpty()
                            && !idList.contains(id.trim())) {
                        idList.add(id.trim());
                    }
                }
            }
        }

        if (idList.isEmpty()) {
            throw new Exception("ไม่พบข้อมูลโจทย์ที่จะบันทึก");
        }

        con.setAutoCommit(false);

        try {
            String updateSql =
                    "UPDATE questions "
                    + "SET name = ?, status = ?, sec = ? "
                    + "WHERE id = ?";

            try (PreparedStatement updatePs =
                    con.prepareStatement(updateSql)) {

                for (String idText : idList) {

                    int subjectId = parseId(idText);

                    /*
                     * ชื่อ input ต้องตรงกับฟอร์มใน SubjectsView.jsp
                     * เช่น name_1, status_1, sec_1
                     */
                    String name =
                            request.getParameter("name_" + idText);

                    String status =
                            request.getParameter("status_" + idText);

                    String sec =
                            request.getParameter("sec_" + idText);

                    if (name == null || name.trim().isEmpty()) {
                        throw new Exception(
                                "กรุณากรอกชื่อโจทย์ (ID " + idText + ")"
                        );
                    }

                    if (name.trim().length() > 255) {
                        throw new Exception(
                                "ชื่อโจทย์ต้องไม่เกิน 255 ตัวอักษร (ID "
                                + idText + ")"
                        );
                    }

                    if (sec == null || sec.trim().isEmpty()) {
                        throw new Exception(
                                "กรุณากรอกเซคชัน (ID " + idText + ")"
                        );
                    }

                    if (!"ON".equals(status) && !"OFF".equals(status)) {
                        throw new Exception(
                                "สถานะไม่ถูกต้อง (ID " + idText + ")"
                        );
                    }

                    updatePs.setString(1, name.trim());
                    updatePs.setString(2, status);
                    updatePs.setString(3, sec.trim());
                    updatePs.setInt(4, subjectId);

                    updatePs.addBatch();
                }

                updatePs.executeBatch();
            }

            // มอบหมายโจทย์ทั้งหมดให้สอดคล้องกับ Sec/Status ที่อัปเดตใหม่
            Object userIdObj = session.getAttribute("UserId");
            Integer assignedBy = null;
            if (userIdObj != null) {
                try {
                    assignedBy = Integer.valueOf(userIdObj.toString());
                } catch (NumberFormatException e) {
                    assignedBy = null;
                }
            }

            String syncAssignSql =
                "INSERT IGNORE INTO student_questions " +
                "(question_id, student_id, assigned_by, assigned_at) " +
                "SELECT q.id, u.id, ?, NOW() " +
                "FROM questions q " +
                "JOIN users u ON u.role = 'student' " +
                "AND u.sec IS NOT NULL " +
                "AND FIND_IN_SET(" +
                "CAST(u.sec AS CHAR), " +
                "REPLACE(CAST(q.sec AS CHAR), ' ', '')" +
                ") > 0 " +
                "WHERE q.status = 'ON'";

            try (PreparedStatement syncPs = con.prepareStatement(syncAssignSql)) {
                if (assignedBy != null) {
                    syncPs.setInt(1, assignedBy);
                } else {
                    syncPs.setNull(1, java.sql.Types.INTEGER);
                }
                syncPs.executeUpdate();
            }

            con.commit();

        } catch (Exception e) {
            try {
                con.rollback();
            } catch (Exception rollbackException) {
                application.log(
                        "ไม่สามารถ rollback การแก้ไข Subject ได้",
                        rollbackException
                );
            }

            throw e;

        } finally {
            try {
                con.setAutoCommit(true);
            } catch (Exception ignored) {
            }
        }

        response.sendRedirect("SubjectsView.jsp?success=updated");
        return;
    }

    throw new Exception(
            "ไม่พบ action ที่ถูกต้อง (action: " + action + ")"
    );

} catch (Exception e) {

    application.log("SubjectAction.jsp error", e);

    String detail = e.getMessage();

    if (detail == null || detail.trim().isEmpty()) {
        detail = "เกิดข้อผิดพลาดระหว่างดำเนินการ";
    }

    session.setAttribute(
            "subjectMessage",
            "เกิดข้อผิดพลาด: " + detail
    );

    session.setAttribute("subjectMessageType", "danger");

    response.sendRedirect("SubjectsView.jsp");
    return;

} finally {

    if (ps != null) {
        try {
            ps.close();
        } catch (Exception e) {
        }
    }

    if (con != null) {
        try {
            con.close();
        } catch (Exception e) {
        }
    }
}
%>