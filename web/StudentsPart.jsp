<%@page import="java.sql.*"%>
<%@page import="db.DBConnection"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    Object userIdObj = session.getAttribute("UserId");
    Object roleObj = session.getAttribute("Role");

    Integer studentId = null;
    String role = roleObj == null ? "" : roleObj.toString();

    try {
        if (userIdObj != null) {
            studentId = Integer.valueOf(userIdObj.toString());
        }
    } catch (NumberFormatException e) {
        studentId = null;
    }

    if (studentId == null || !"student".equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp?error=1");
        return;
    }

    int totalQuestions = 0;
    String errorMessage = "";

    // นับจำนวนโจทย์จาก Section ของนักศึกษา
    String countSql =
        "SELECT COUNT(*) " +
        "FROM questions q " +
        "INNER JOIN users u ON u.id = ? " +
        "WHERE u.role = 'student' " +
        "AND u.status = 'ON' " +
        "AND u.sec IS NOT NULL " +
        "AND q.status = 'ON' " +
        "AND FIND_IN_SET(" +
        "CAST(u.sec AS CHAR), " +
        "REPLACE(CAST(q.sec AS CHAR), ' ', '')" +
        ") > 0";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(countSql)) {

        ps.setInt(1, studentId);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                totalQuestions = rs.getInt(1);
            }
        }

    } catch (Exception e) {
        application.log("StudentsPart count query error", e);
        errorMessage = "ไม่สามารถโหลดจำนวนโจทย์ได้";
    }
%>

<mytag:ReadFile />
<mytag:header menu="6"/>
<mytag:check_login />

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>แบบฝึกหัด / โจทย์</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

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
                        ทั้งหมด <%= totalQuestions %> รายการ
                    </span>
                </div>
            </div>
        </div>

        <% if (!errorMessage.isEmpty()) { %>
            <div class="alert alert-danger">
                <%= escapeHtml(errorMessage) %>
            </div>
        <% } %>

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
                    // LEFT JOIN ตารางส่งคำตอบทั้ง 2 ประเภท เพื่อดึงคะแนนและสถานะส่งงาน
                    String sql =
                        "SELECT " +
                        "q.id AS question_id, " +
                        "q.question_type, " +
                        "q.name AS question_name, " +
                        "q.point AS max_point, " +
                        "q.sec, " +
                        "COALESCE(alg.score, er.score) AS earned_score, " +
                        "COALESCE(alg.status, er.status) AS sub_status " +
                        "FROM questions q " +
                        "INNER JOIN users u ON u.id = ? " +
                        "LEFT JOIN algorithm_submissions alg " +
                        "   ON q.id = alg.question_id AND alg.student_id = u.id " +
                        "LEFT JOIN er_diagram_submissions er " +
                        "   ON q.id = er.question_id AND er.student_id = u.id " +
                        "WHERE u.role = 'student' " +
                        "AND u.status = 'ON' " +
                        "AND u.sec IS NOT NULL " +
                        "AND q.status = 'ON' " +
                        "AND FIND_IN_SET(" +
                        "CAST(u.sec AS CHAR), " +
                        "REPLACE(CAST(q.sec AS CHAR), ' ', '')" +
                        ") > 0 " +
                        "ORDER BY q.created_at DESC, q.id DESC";

                    boolean hasRows = false;

                    try (Connection con = DBConnection.getConnection();
                         PreparedStatement ps = con.prepareStatement(sql)) {

                        ps.setInt(1, studentId);

                        try (ResultSet rs = ps.executeQuery()) {

                            while (rs.next()) {
                                hasRows = true;

                                int questionId =
                                    rs.getInt("question_id");

                                String questionType =
                                    rs.getString("question_type");

                                String questionName =
                                    rs.getString("question_name");

                                int maxPoint =
                                    rs.getInt("max_point");

                                // คะแนนที่ได้ และสถานะจาก DB
                                Object scoreObj = rs.getObject("earned_score");
                                String subStatus = rs.getString("sub_status");

                                String typeLabel = questionType;

                                if ("FLOWCHART".equalsIgnoreCase(questionType)) {
                                    typeLabel = "Flowchart";
                                } else if ("PSEUDOCODE".equalsIgnoreCase(questionType)) {
                                    typeLabel = "Pseudocode";
                                } else if ("ER_DIAGRAM".equalsIgnoreCase(questionType)) {
                                    typeLabel = "ER Diagram";
                                }

                                // กำหนดการแสดงผลคะแนน สถานะ และปุ่มกด
                                String scoreDisplay = "-";
                                String statusHtml = "";
                                String buttonText = "เริ่มทำ";

                                if (scoreObj != null || subStatus != null) {
                                    // มีการส่งงานแล้ว
                                    if (scoreObj != null) {
                                        scoreDisplay = String.valueOf(rs.getInt("earned_score"));
                                    } else {
                                        scoreDisplay = "0";
                                    }

                                    if ("GRADED".equalsIgnoreCase(subStatus)) {
                                        statusHtml = "<span class=\"status completed\"><i class=\"fa-solid fa-check\"></i> ตรวจแล้ว</span>";
                                    } else {
                                        statusHtml = "<span class=\"status in-progress\"><i class=\"fa-solid fa-spinner\"></i> ส่งแล้ว</span>";
                                    }

                                    buttonText = "ทำอีกครั้ง";
                                } else {
                                    // ยังไม่ได้ทำ
                                    statusHtml = "<span class=\"status not-started\"><i class=\"fa-regular fa-clock\"></i> ยังไม่ได้ทำ</span>";
                                    buttonText = "เริ่มทำ";
                                }
                %>

                    <tr>
                        <!-- QUESTION NAME -->
                        <td>
                            <div class="question-name">
                                <%= escapeHtml(questionName) %>
                            </div>

                            <small class="text-muted">
                                <%= escapeHtml(typeLabel) %>
                            </small>
                        </td>

                        <!-- MAX SCORE -->
                        <td>
                            <%= maxPoint %>
                        </td>

                        <!-- EARNED SCORE -->
                        <td class="<%= scoreObj != null ? "score-earned" : "score-empty" %>">
                            <%= scoreDisplay %>
                        </td>

                        <!-- STATUS -->
                        <td>
                            <%= statusHtml %>
                        </td>

                        <!-- ACTION -->
                        <td>
                            <button type="button"
                                    class="btn-action btn-start"
                                    onclick="startQuestion(
                                        <%= questionId %>,
                                        '<%= escapeHtml(questionType) %>'
                                    )">
                                <i class="fa-solid fa-pen"></i>
                                <%= buttonText %>
                            </button>
                        </td>
                    </tr>

                <%
                            }
                        }

                    } catch (Exception e) {
                        application.log("StudentsPart table query error", e);
                %>

                    <tr>
                        <td colspan="5"
                            style="text-align:center; padding:30px; color:#dc3545;">
                            เกิดข้อผิดพลาดในการโหลดข้อมูล
                        </td>
                    </tr>

                <%
                    }

                    if (!hasRows && errorMessage.isEmpty()) {
                %>

                    <tr>
                        <td colspan="5"
                            style="text-align:center; padding:30px;">
                            <i class="bi bi-inbox"
                               style="font-size:2rem;"></i>

                            <p class="mt-2 mb-0">
                                ยังไม่มีโจทย์ที่ได้รับมอบหมาย
                            </p>
                        </td>
                    </tr>

                <%
                    }
                %>

                </tbody>
            </table>
        </div>

    </div>
</div>

<script>

function startQuestion(questionId, questionType) {
    let page = "";

    if (questionType === "FLOWCHART") {
        page = "Design_Flowchart.jsp";
    } else if (questionType === "PSEUDOCODE") {
        page = "Design_Pseudocode.jsp";
     } else if (questionType === "ER_DIAGRAM") {
        page = "Design_ERDiagram.jsp";
    } else {
        alert("ไม่พบประเภทโจทย์นี้");
        return;
    }

    window.location.href = page
        + "?questionId=" + encodeURIComponent(questionId)
        + "&mode=student";
}

</script>

</body>
</html>