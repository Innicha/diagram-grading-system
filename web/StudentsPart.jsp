<%@page import="java.sql.*"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>
<%
    Integer studentId = (Integer) session.getAttribute("UserId");
    String role = (String) session.getAttribute("Role");
    Integer sec = (Integer) session.getAttribute("Sec");

    if (studentId == null || !"student".equals(role)) {
        response.sendRedirect("index.jsp?error=1");
        return;
    }
%>
<mytag:ReadFile />
<mytag:header menu="6"/>
<mytag:check_login />

<%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String currentUsername = (String) session.getAttribute("User");
    int totalQuestions = 0;
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <title>แบบฝึกหัด / โจทย์</title>

    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <!-- Google Font -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Bootstrap & Stylesheets -->
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/global.css">
    <link rel="stylesheet" href="css/pages/StudentsPart.css">
</head>
<body>

<div class="student-page">

    <!-- PAGE HEADER -->
    <div class="page-header">
        <div class="page-title-area">
            <div class="page-icon">
                <i class="fa-regular fa-rectangle-list"></i>
            </div>
            <div>
                <h1>แบบฝึกหัด / โจทย์</h1>
                <p>เลือกโจทย์เพื่อทำแบบฝึกหัด และตรวจสอบคะแนนของคุณ</p>
            </div>
        </div>
    </div>

    <!-- EXERCISE CONTAINER -->
    <div class="exercise-container">

        <!-- FILTER BAR -->
        <div class="filter-bar">
            <div class="filter-left">
                <div class="question-count">
                    <i class="fa-solid fa-list"></i>
                    <span>
                        <%
                            try {
                                con = DBConnection.getConnection();
                                String countSql = "SELECT COUNT(*) FROM subjects s " +
                                                  "INNER JOIN users u ON u.username = ? " +
                                                  "WHERE s.status = 'ON' " +
                                                  "AND FIND_IN_SET(CAST(u.sec AS CHAR), REPLACE(s.sec, ' ', '')) > 0";
                                ps = con.prepareStatement(countSql);
                                ps.setString(1, currentUsername);
                                rs = ps.executeQuery();

                                if (rs.next()) {
                                    totalQuestions = rs.getInt(1);
                                }
                            } catch (Exception e) {
                                totalQuestions = 0;
                            } finally {
                                if (rs != null) { try { rs.close(); } catch (Exception e) {} }
                                if (ps != null) { try { ps.close(); } catch (Exception e) {} }
                                if (con != null) { try { con.close(); } catch (Exception e) {} }
                            }
                        %>
                        ทั้งหมด <%= totalQuestions %> รายการ
                    </span>
                </div>
            </div>
        </div>

        <!-- TABLE -->
        <div class="table-wrapper">
            <table class="exercise-table">
                <thead>
                    <tr>
                        <th class="col-name">ชื่อโจทย์</th>
                        <th class="col-score">คะแนนเต็ม</th>
                        <th class="col-score">คะแนนที่ได้</th>
                        <th class="col-status">สถานะ</th>
                        <th class="col-action">จัดการ</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    Connection tableCon = null;
                    PreparedStatement tablePs = null;
                    ResultSet tableRs = null;

                    try {
                        tableCon = DBConnection.getConnection();
                        String sql = "SELECT s.id AS subject_id, s.name AS subject_name, s.point AS max_point, " +
                                     "ss.score AS earned_score, ss.status AS submission_status " +
                                     "FROM subjects s " +
                                     "INNER JOIN users u ON u.username = ? " +
                                     "LEFT JOIN student_submissions ss ON ss.subject_id = s.id AND ss.student_id = u.id " +
                                     "WHERE s.status = 'ON' " +
                                     "AND FIND_IN_SET(CAST(u.sec AS CHAR), REPLACE(s.sec, ' ', '')) > 0 " +
                                     "ORDER BY s.id ASC";

                        tablePs = tableCon.prepareStatement(sql);
                        tablePs.setString(1, currentUsername);
                        tableRs = tablePs.executeQuery();

                        while (tableRs.next()) {
                            int subjectId = tableRs.getInt("subject_id");
                            String subjectName = tableRs.getString("subject_name");
                            int maxPoint = tableRs.getInt("max_point");
                            Object earnedScoreObj = tableRs.getObject("earned_score");
                            String submissionStatus = tableRs.getString("submission_status");

                            boolean submitted = "SUBMITTED".equals(submissionStatus) || "GRADED".equals(submissionStatus);
                %>
                    <tr>
                        <!-- QUESTION NAME -->
                        <td>
                            <div class="question-name"><%= subjectName %></div>
                        </td>

                        <!-- MAX SCORE -->
                        <td><%= maxPoint %></td>

                        <!-- EARNED SCORE -->
                        <td class="<%= earnedScoreObj != null ? "score-earned" : "score-empty" %>">
                            <%= earnedScoreObj != null ? earnedScoreObj : "-" %>
                        </td>

                        <!-- STATUS -->
                        <td>
                            <% if (submitted) { %>
                                <span class="status submitted">
                                    <i class="fa-solid fa-check"></i> ส่งแล้ว
                                </span>
                            <% } else { %>
                                <span class="status not-started">
                                    <i class="fa-regular fa-clock"></i> ยังไม่ได้ทำ
                                </span>
                            <% } %>
                        </td>

                        <!-- ACTION -->
                        <td>
                            <% if (submitted) { %>
                                <button type="button" class="btn-action btn-view" onclick="viewAnswer(<%= subjectId %>)">
                                    <i class="fa-solid fa-eye"></i> ดูคำตอบ
                                </button>
                            <% } else { %>
                                <button type="button" class="btn-action btn-start" onclick="startQuestion(<%= subjectId %>)">
                                    <i class="fa-solid fa-pen"></i> เริ่มทำ
                                </button>
                            <% } %>
                        </td>
                    </tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                    <tr>
                        <td colspan="5" style="text-align:center; padding:30px; color:#dc3545;">
                            เกิดข้อผิดพลาดในการโหลดข้อมูล: <%= e.getMessage() %>
                        </td>
                    </tr>
                <%
                    } finally {
                        if (tableRs != null) { try { tableRs.close(); } catch (Exception e) {} }
                        if (tablePs != null) { try { tablePs.close(); } catch (Exception e) {} }
                        if (tableCon != null) { try { tableCon.close(); } catch (Exception e) {} }
                    }
                %>
                </tbody>
            </table>
        </div>

    </div>

</div>

<script>
    function startQuestion(subjectId) {
        window.location.href = "Question.jsp?subjectId=" + subjectId;
    }

    function viewAnswer(subjectId) {
        window.location.href = "Question.jsp?subjectId=" + subjectId;
    }
</script>

</body>
</html>