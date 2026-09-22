<%@page import="java.sql.*"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

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

        /* ========================= ADD SUBJECT ========================= */
        if ("add".equals(action)) {
            String name = request.getParameter("name");
            String pointText = request.getParameter("point");
            String status = request.getParameter("status");
            String sec = request.getParameter("sec");

            if (name == null || name.trim().isEmpty()) {
                throw new Exception("กรุณากรอกชื่อโจทย์");
            }

            if (pointText == null || pointText.trim().isEmpty()) {
                throw new Exception("กรุณากรอกคะแนน");
            }

            if (sec == null || sec.trim().isEmpty()) {
                throw new Exception("กรุณากรอกเซคชัน");
            }

            int point = Integer.parseInt(pointText);

            String sql = "INSERT INTO subjects (name, point, status, sec) VALUES (?, ?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, name.trim());
            ps.setInt(2, point);
            ps.setString(3, status);
            ps.setString(4, sec.trim());

            ps.executeUpdate();

            response.sendRedirect("SubjectsView.jsp?success=added");
            return;
        }

        /* ========================= UPDATE STATUS ========================= */
        if ("updateStatus".equals(action)) {
            String id = request.getParameter("id");
            String status = request.getParameter("status");

            if (id == null || id.trim().isEmpty()) {
                throw new Exception("ไม่พบ ID ของโจทย์");
            }

            String sql = "UPDATE subjects SET status = ? WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, Integer.parseInt(id));

            ps.executeUpdate();

            response.sendRedirect("SubjectsView.jsp?success=updated");
            return;
        }

        /* ========================= DELETE SUBJECT ========================= */
        if ("delete".equals(action)) {
            String id = request.getParameter("id");

            if (id == null || id.trim().isEmpty()) {
                throw new Exception("ไม่พบ ID ของโจทย์");
            }

            String sql = "DELETE FROM subjects WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(id));

            ps.executeUpdate();

            response.sendRedirect("SubjectsView.jsp?success=deleted");
            return;
        }

        /* ========================= UPDATE ALL ========================= */
        if ("updateAll".equals(action)) {
            String[] ids = request.getParameterValues("subjectIds");

            if (ids != null && ids.length > 0) {
                con.setAutoCommit(false);

                try {
                    String sql = "UPDATE subjects SET name = ?, point = ?, status = ?, sec = ? WHERE id = ?";
                    ps = con.prepareStatement(sql);

                    for (String id : ids) {
                        String name = request.getParameter("name_" + id);
                        String pointText = request.getParameter("point_" + id);
                        String status = request.getParameter("status_" + id);
                        String sec = request.getParameter("sec_" + id);

                        if (name == null || name.trim().isEmpty()) {
                            throw new Exception("กรุณากรอกชื่อโจทย์");
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
                            throw new Exception("คะแนนต้องเป็นตัวเลข");
                        }

                        if (!"ON".equals(status) && !"OFF".equals(status)) {
                            throw new Exception("สถานะไม่ถูกต้อง");
                        }

                        ps.setString(1, name.trim());
                        ps.setInt(2, point);
                        ps.setString(3, status);
                        ps.setString(4, sec.trim());
                        ps.setInt(5, Integer.parseInt(id));

                        ps.addBatch();
                    }

                    ps.executeBatch();
                    con.commit();

                } catch (Exception e) {
                    try {
                        con.rollback();
                    } catch (Exception rollbackException) {
                        // ignore rollback exception
                    }
                    throw e;

                } finally {
                    try {
                        con.setAutoCommit(true);
                    } catch (Exception e) {
                        // ignore setAutoCommit exception
                    }
                }
            }

            response.sendRedirect("SubjectsView.jsp?success=updated");
            return;
        }

        throw new Exception("ไม่พบ action ที่ถูกต้อง");

    } catch (Exception e) {
        session.setAttribute("subjectMessage", "เกิดข้อผิดพลาด: " + e.getMessage());
        session.setAttribute("subjectMessageType", "danger");
        response.sendRedirect("SubjectsView.jsp");
        return;

    } finally {
        if (ps != null) {
            try {
                ps.close();
            } catch (Exception e) {
                // ignore close exception
            }
        }

        if (con != null) {
            try {
                con.close();
            } catch (Exception e) {
                // ignore close exception
            }
        }
    }
%>