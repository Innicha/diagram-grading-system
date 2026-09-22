<%@page import="java.sql.*"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    String studentId = request.getParameter("student_id");
    String fullName = request.getParameter("full_name");
    String secText = request.getParameter("sec");

    // ตรวจสอบข้อมูล
    if (studentId == null || fullName == null || secText == null
            || studentId.trim().isEmpty()
            || fullName.trim().isEmpty()
            || secText.trim().isEmpty()) {

        session.setAttribute(
                "message",
                "กรุณากรอกข้อมูลให้ครบถ้วน"
        );
        session.setAttribute(
                "messageType",
                "danger"
        );

        response.sendRedirect("StudentView.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement checkUser = null;
    PreparedStatement insertUser = null;
    ResultSet rs = null;

    try {

        // SEC ต้องเป็นตัวเลข
        int sec = Integer.parseInt(secText.trim());

        con = DBConnection.getConnection();

        if (con == null) {
            throw new Exception(
                    "ไม่สามารถเชื่อมต่อ Database ได้"
            );
        }

        // ตรวจสอบรหัสนักศึกษาซ้ำ
        String checkSql =
                "SELECT id FROM users "
                + "WHERE username = ? "
                + "LIMIT 1";

        checkUser = con.prepareStatement(checkSql);

        checkUser.setString(
                1,
                studentId.trim()
        );

        rs = checkUser.executeQuery();

        if (rs.next()) {

            session.setAttribute(
                    "message",
                    "รหัสนักศึกษา "
                    + studentId
                    + " มีอยู่ในระบบแล้ว"
            );

            session.setAttribute(
                    "messageType",
                    "danger"
            );

        } else {

            /*
             * username = รหัสนักศึกษา
             * password = รหัสนักศึกษา
             * role     = student
             * sec      = SEC ที่ครูกรอก
             * status   = ON
             */

            String insertSql =
                    "INSERT INTO users "
                    + "(username, password, full_name, role, sec, status) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";

            insertUser =
                    con.prepareStatement(insertSql);

            // username
            insertUser.setString(
                    1,
                    studentId.trim()
            );

            // password = รหัสนักศึกษา
            insertUser.setString(
                    2,
                    studentId.trim()
            );

            // ชื่อ-นามสกุล
            insertUser.setString(
                    3,
                    fullName.trim()
            );

            // role
            insertUser.setString(
                    4,
                    "student"
            );

            // SEC
            insertUser.setInt(
                    5,
                    sec
            );

            // สถานะเริ่มต้น
            insertUser.setString(
                    6,
                    "ON"
            );

            insertUser.executeUpdate();

            session.setAttribute(
                    "message",
                    "เพิ่มนักศึกษา "
                    + fullName.trim()
                    + " สำเร็จ"
            );

            session.setAttribute(
                    "messageType",
                    "success"
            );
        }

    } catch (NumberFormatException e) {

        session.setAttribute(
                "message",
                "SEC ต้องเป็นตัวเลขเท่านั้น"
        );

        session.setAttribute(
                "messageType",
                "danger"
        );

    } catch (Exception e) {

        e.printStackTrace();

        session.setAttribute(
                "message",
                "เกิดข้อผิดพลาด: "
                + e.getMessage()
        );

        session.setAttribute(
                "messageType",
                "danger"
        );

    } finally {

        if (rs != null) {
            try {
                rs.close();
            } catch (Exception e) {
            }
        }

        if (checkUser != null) {
            try {
                checkUser.close();
            } catch (Exception e) {
            }
        }

        if (insertUser != null) {
            try {
                insertUser.close();
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

    response.sendRedirect("StudentView.jsp");
%>