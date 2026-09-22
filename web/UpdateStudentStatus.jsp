<%@page import="java.sql.*"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    String userId = request.getParameter("user_id");
    String status = request.getParameter("status");

    if (userId != null && status != null
            && ("ON".equals(status) || "OFF".equals(status))) {

        Connection con = null;
        PreparedStatement ps = null;

        try {

            con = DBConnection.getConnection();

            String sql = "UPDATE users SET status = ? "
                       + "WHERE id = ? AND role = 'student'";

            ps = con.prepareStatement(sql);

            ps.setString(1, status);
            ps.setInt(2, Integer.parseInt(userId));

            ps.executeUpdate();

            session.setAttribute("message", "เปลี่ยนสถานะนักศึกษาเรียบร้อยแล้ว");
            session.setAttribute("messageType", "success");

        } catch (Exception e) {

            e.printStackTrace();

            session.setAttribute("message",
                    "ไม่สามารถเปลี่ยนสถานะได้: " + e.getMessage());

            session.setAttribute("messageType", "danger");

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
    }

    response.sendRedirect("StudentView.jsp");
%>