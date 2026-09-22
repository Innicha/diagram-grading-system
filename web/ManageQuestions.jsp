<%@page import="java.sql.*"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%--
    ManageQuestions.jsp
    --------------------
    Controller แยกออกมาจากโค้ดที่เคยฝังอยู่บนสุดของ TeacherView.jsp
    รับผิดชอบเฉพาะ: เพิ่ม/ลบโจทย์ และเปิด-ปิดโจทย์ต่อ section
    (action = delete_question | save_questions)
    ประมวลผลเสร็จแล้ว redirect กลับไปที่ TeacherView.jsp (Post-Redirect-Get)
--%>

<%
    // Controller นี้รับเฉพาะ POST เท่านั้น
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("TeacherView.jsp");
        return;
    }

    String message = null;
    String messageType = "success";
    String action = request.getParameter("action");

    // ---------- Action 1: ลบโจทย์ ----------
    if ("delete_question".equals(action)) {
        String deleteId = request.getParameter("delete_question_id");

        if (deleteId == null || deleteId.trim().isEmpty()) {
            message = "ไม่พบรหัสโจทย์ที่ต้องการลบ";
            messageType = "danger";
        } else {
            Connection con = null;
            PreparedStatement psDelQs = null;
            PreparedStatement psDelQ = null;

            try {
                int questionId = Integer.parseInt(deleteId.trim());

                con = DBConnection.getConnection();
                con.setAutoCommit(false);

                psDelQs = con.prepareStatement("DELETE FROM question_sections WHERE question_id = ?");
                psDelQs.setInt(1, questionId);
                psDelQs.executeUpdate();

                psDelQ = con.prepareStatement("DELETE FROM questions WHERE question_id = ?");
                psDelQ.setInt(1, questionId);
                psDelQ.executeUpdate();

                con.commit();
                message = "ลบโจทย์เรียบร้อยแล้ว";

            } catch (NumberFormatException nfe) {
                message = "รหัสโจทย์ไม่ถูกต้อง";
                messageType = "danger";
            } catch (Exception e) {
                if (con != null) {
                    try { con.rollback(); } catch (Exception rollbackError) { rollbackError.printStackTrace(); }
                }
                message = "เกิดข้อผิดพลาดในการลบ: " + e.getMessage();
                messageType = "danger";
                e.printStackTrace();
            } finally {
                if (psDelQs != null) try { psDelQs.close(); } catch (Exception e) {}
                if (psDelQ != null) try { psDelQ.close(); } catch (Exception e) {}
                if (con != null) {
                    try { con.setAutoCommit(true); } catch (Exception e) {}
                    try { con.close(); } catch (Exception e) {}
                }
            }
        }
    }

    // ---------- Action 2: บันทึกโจทย์ใหม่ และอัปเดตเปิด/ปิดโจทย์ตาม Section ----------
    if ("save_questions".equals(action)) {
        Connection con = null;
        PreparedStatement psQuestion = null;
        PreparedStatement psQuestionSection = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // เพิ่มโจทย์ใหม่ (ถ้ามีการกรอก)
            String questionName = request.getParameter("question_name");
            String questionType = request.getParameter("question_type");

            if (questionName != null && !questionName.trim().isEmpty()
                    && questionType != null && !questionType.trim().isEmpty()) {

                String insertQuestion = "INSERT INTO questions (question_name, question_type) VALUES (?, ?)";
                psQuestion = con.prepareStatement(insertQuestion, Statement.RETURN_GENERATED_KEYS);
                psQuestion.setString(1, questionName.trim());
                psQuestion.setString(2, questionType);
                psQuestion.executeUpdate();

                try (ResultSet generatedKeys = psQuestion.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int questionId = generatedKeys.getInt(1);

                        String insertQuestionSection =
                                "INSERT INTO question_sections (question_id, section_id, is_enabled) " +
                                "VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE is_enabled = ?";

                        psQuestionSection = con.prepareStatement(insertQuestionSection);

                        String[] sectionIds = request.getParameterValues("section_id");
                        if (sectionIds != null) {
                            for (String sectionIdString : sectionIds) {
                                int sectionId = Integer.parseInt(sectionIdString);
                                String enabledValue = request.getParameter("section_" + sectionId);
                                int isEnabled = "1".equals(enabledValue) ? 1 : 0;

                                psQuestionSection.setInt(1, questionId);
                                psQuestionSection.setInt(2, sectionId);
                                psQuestionSection.setInt(3, isEnabled);
                                psQuestionSection.setInt(4, isEnabled);
                                psQuestionSection.executeUpdate();
                            }
                        }
                    }
                }
            }

            // บันทึกสถานะเปิด/ปิด ของโจทย์ที่มีอยู่แล้ว
            String[] existingQuestionIds = request.getParameterValues("existing_question_id");
            if (existingQuestionIds != null) {
                String updateQuestionSection =
                        "INSERT INTO question_sections (question_id, section_id, is_enabled) " +
                        "VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE is_enabled = ?";

                if (psQuestionSection != null) {
                    try { psQuestionSection.close(); } catch (Exception e) {}
                }
                psQuestionSection = con.prepareStatement(updateQuestionSection);

                String[] sectionIds = request.getParameterValues("section_id");

                if (sectionIds != null) {
                    for (String questionIdString : existingQuestionIds) {
                        int questionId = Integer.parseInt(questionIdString);

                        for (String sectionIdString : sectionIds) {
                            int sectionId = Integer.parseInt(sectionIdString);
                            String enabledValue = request.getParameter("existing_" + questionId + "_" + sectionId);
                            int isEnabled = "1".equals(enabledValue) ? 1 : 0;

                            psQuestionSection.setInt(1, questionId);
                            psQuestionSection.setInt(2, sectionId);
                            psQuestionSection.setInt(3, isEnabled);
                            psQuestionSection.setInt(4, isEnabled);
                            psQuestionSection.executeUpdate();
                        }
                    }
                }
            }

            con.commit();
            message = "บันทึกข้อมูลเรียบร้อยแล้ว";
            messageType = "success";

        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception rollbackError) { rollbackError.printStackTrace(); }
            }
            message = "ไม่สามารถบันทึกข้อมูลได้: " + e.getMessage();
            messageType = "danger";
            e.printStackTrace();
        } finally {
            if (psQuestionSection != null) try { psQuestionSection.close(); } catch (Exception e) {}
            if (psQuestion != null) try { psQuestion.close(); } catch (Exception e) {}
            if (con != null) {
                try { con.setAutoCommit(true); } catch (Exception e) {}
                try { con.close(); } catch (Exception e) {}
            }
        }
    }

    session.setAttribute("message", message);
    session.setAttribute("messageType", messageType);
    response.sendRedirect("TeacherView.jsp");
%>
