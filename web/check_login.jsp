<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="db.DBConnection"%>

<%
    request.setCharacterEncoding("UTF-8");
    
    String userParam = request.getParameter("username");
    String passParam = request.getParameter("password");

    if (userParam != null && passParam != null && !userParam.trim().isEmpty() && !passParam.trim().isEmpty()) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // เรียกใช้การเชื่อมต่อ Database จากแพ็กเกจ db.DBConnection
            con = DBConnection.getConnection();

            if (con != null) {
                // ค้นหาข้อมูลในตาราง users
                String sql = "SELECT id, username, role FROM users WHERE username = ? AND password = ?";
                pstmt = con.prepareStatement(sql);
                pstmt.setString(1, userParam);
                pstmt.setString(2, passParam);

                rs = pstmt.executeQuery();

                if (rs.next()) {
                    // ล็อกอินสำเร็จ: บันทึกข้อมูลลง Session
                    session.setAttribute("User", rs.getString("username"));
                    session.setAttribute("UserId", rs.getInt("id"));
                    session.setAttribute("Role", rs.getString("role"));

                    // Redirect ไปหน้าแรก/หน้า Dashboard
                    response.sendRedirect("main.jsp"); // เปลี่ยนเป็นหน้าปลายทางที่ต้องการ
                } else {
                    // ล็อกอินไม่สำเร็จ (ชื่อผู้ใช้หรือรหัสผ่านผิด)
                    response.sendRedirect("index.jsp?error=1");
                }
            } else {
                out.println("ไม่สามารถเชื่อมต่อฐานข้อมูลได้");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=1");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (con != null) try { con.close(); } catch (Exception e) {}
        }
    } else {
        response.sendRedirect("index.jsp?error=1");
    }
%>