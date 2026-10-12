<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag"%>

<%!
    // ป้องกันอักขระ HTML จากข้อมูลในฐานข้อมูล
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    String selectedSec = request.getParameter("section");
    if (selectedSec == null) {
        selectedSec = "";
    }

    // 1. โหลดรายชื่อเซคชันทั้งหมดจากตาราง users และ questions เพื่อนำมาใส่ Dropdown แบบปลอดภัย
    List<String> sections = new ArrayList<String>();
    Connection secCon = null;
    PreparedStatement secPs = null;
    ResultSet secRs = null;

    try {
        secCon = DBConnection.getConnection();
        // ดึงเซคชันจากตาราง users
        String secSql = "SELECT DISTINCT sec FROM users WHERE role = 'student' AND sec IS NOT NULL";
        secPs = secCon.prepareStatement(secSql);
        secRs = secPs.executeQuery();

        while (secRs.next()) {
            String secVal = secRs.getString("sec");
            if (secVal != null && !secVal.trim().isEmpty() && !sections.contains(secVal)) {
                sections.add(secVal.trim());
            }
        }
    } catch (Exception e) {
        application.log("StudentScoresView.jsp section query error", e);
    } finally {
        if (secRs != null) try { secRs.close(); } catch (Exception e) {}
        if (secPs != null) try { secPs.close(); } catch (Exception e) {}
        if (secCon != null) try { secCon.close(); } catch (Exception e) {}
    }

    // เรียงลำดับเซคชัน
    Collections.sort(sections, new Comparator<String>() {
        @Override
        public int compare(String a, String b) {
            try {
                return Integer.compare(Integer.parseInt(a), Integer.parseInt(b));
            } catch (Exception e) {
                return a.compareTo(b);
            }
        }
    });

    if (selectedSec.isEmpty() && !sections.isEmpty()) {
        selectedSec = sections.get(0);
    }
%>

<mytag:ReadFile />
<mytag:header menu="7"/>
<mytag:check_login />  

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>คะแนนนักศึกษา - ER Diagram System</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Sarabun:wght@300;400;500;600;700&display=swap">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/pages/SubjectsView.css?v=3">
</head>
<body>

<div class="container teacher-page py-4">

    <!-- Page Header -->
    <div class="page-header">
        <div class="page-header-left">
            <div class="icon-box-header">
                <i class="bi bi-bar-chart-fill"></i>
            </div>
            <div>
                <h3 class="header-title">คะแนนนักศึกษา</h3>
                <p class="header-subtitle">
                    ตรวจสอบคะแนนของนักศึกษาแต่ละโจทย์ตามเซคชันที่ได้รับมอบหมาย
                </p>
            </div>
        </div>
    </div>

    <!-- Main Card -->
    <div class="main-card subject-card">

        <!-- Controls Bar: Dropdown Section & Search -->
        <div class="controls-bar">
            <div class="controls-left">
                <div class="filter-group">
                    <i class="bi bi-funnel filter-icon"></i>
                    <span class="filter-label">เลือกเซคชัน</span>
                    
                    <form method="get" action="ScoreView.jsp" id="sectionForm" style="display:inline;">
                        <select class="custom-select" name="section" id="sectionFilter" onchange="document.getElementById('sectionForm').submit();">
                            <% for (String sec : sections) { %>
                                <option value="<%= escapeHtml(sec) %>" <%= sec.equals(selectedSec) ? "selected" : "" %>>
                                    Sec <%= escapeHtml(sec) %>
                                </option>
                            <% } %>
                        </select>
                    </form>
                </div>

                <div class="search-box">
                    <i class="bi bi-search search-icon"></i>
                    <input type="text"
                           class="custom-input"
                           id="searchInput"
                           placeholder="ค้นหาชื่อนักศึกษา / รหัสนักศึกษา...">
                </div>
            </div>
        </div>

        <!-- Score Table -->
        <div class="custom-table-container">
            <table class="custom-table" id="scoreTable">
                <thead>
                    <tr>
                        <th style="width: 5%;">#</th>
                        <th style="width: 15%;">รหัสนักศึกษา</th>
                        <th style="width: 25%;">ชื่อ-นามสกุล</th>
                        
                        <%
                            // 2. ดึงรายการโจทย์ที่เกี่ยวข้องกับเซคชันนี้ (แสดงทั้งโจทย์ที่เปิดอยู่ หรือโจทย์ที่เคยถูกปิดแต่มีคะแนนของนักศึกษาในเซคนี้)
                            List<Map<String, Object>> questionsList = new ArrayList<Map<String, Object>>();
                            Connection qCon = null;
                            PreparedStatement qPs = null;
                            ResultSet qRs = null;

                            try {
                                qCon = DBConnection.getConnection();
                                // ดึงโจทย์ที่ตรงกับเซคชัน หรือมีนักศึกษาในเซคชันนี้เคยส่งงานแล้ว แม้สถานะโจทย์จะเป็น OFF
                                String qSql = "SELECT DISTINCT q.id, q.name, q.point, q.question_type " +
                                              "FROM questions q " +
                                              "LEFT JOIN er_diagram_submissions ers ON q.id = ers.question_id " +
                                              "LEFT JOIN algorithm_submissions als ON q.id = als.question_id " +
                                              "LEFT JOIN users u ON (ers.student_id = u.id OR als.student_id = u.id) " +
                                              "WHERE (q.sec = ? OR q.sec LIKE ? OR q.sec LIKE ? OR q.sec LIKE ? OR u.sec = ?) " +
                                              "ORDER BY q.id ASC";
                                              
                                qPs = qCon.prepareStatement(qSql);
                                qPs.setString(1, selectedSec);
                                qPs.setString(2, selectedSec + ",%");
                                qPs.setString(3, "%," + selectedSec + ",%");
                                qPs.setString(4, "%," + selectedSec);
                                qPs.setString(5, selectedSec);
                                
                                qRs = qPs.executeQuery();
                                while (qRs.next()) {
                                    Map<String, Object> qMap = new HashMap<String, Object>();
                                    qMap.put("id", qRs.getInt("id"));
                                    qMap.put("name", qRs.getString("name"));
                                    qMap.put("point", qRs.getInt("point"));
                                    qMap.put("question_type", qRs.getString("question_type"));
                                    questionsList.add(qMap);
                                }
                            } catch (Exception e) {
                                application.log("ScoreView.jsp questions query error", e);
                            } finally {
                                if (qRs != null) try { qRs.close(); } catch (Exception e) {}
                                if (qPs != null) try { qPs.close(); } catch (Exception e) {}
                                if (qCon != null) try { qCon.close(); } catch (Exception e) {}
                            }

                            for (Map<String, Object> q : questionsList) {
                        %>
                            <th class="text-center" style="min-width: 90px;">
                                <%= escapeHtml((String)q.get("name")) %>
                                <div style="font-size: 0.8rem; font-weight: normal; color: #6c757d;">
                                    (<%= q.get("point") %>)
                                </div>
                            </th>
                        <% } %>
                    </tr>
                </thead>
                <tbody id="scoreTableBody">
                    <%
                        // 3. ดึงรายชื่อนักศึกษาในเซคชันที่เลือก
                        Connection sCon = null;
                        PreparedStatement sPs = null;
                        ResultSet sRs = null;

                        try {
                            sCon = DBConnection.getConnection();
                            String studentSql = "SELECT id, username, full_name FROM users WHERE role = 'student' AND sec = ? ORDER BY username ASC";
                            sPs = sCon.prepareStatement(studentSql);
                            sPs.setString(1, selectedSec);
                            sRs = sPs.executeQuery();

                            int rowNum = 1;
                            boolean hasStudent = false;

                            while (sRs.next()) {
                                hasStudent = true;
                                int studentDbId = sRs.getInt("id");
                                String username = sRs.getString("username");
                                String fullName = sRs.getString("full_name");
                    %>
                        <tr>
                            <td><%= rowNum++ %></td>
                            <td><%= escapeHtml(username) %></td>
                            <td><%= escapeHtml(fullName) %></td>

                            <%
                                // ดึงคะแนนของแต่ละโจทย์
                                for (Map<String, Object> q : questionsList) {
                                    int qId = (Integer) q.get("id");
                                    String qType = (String) q.get("question_type");
                                    String scoreValue = "-";

                                    Connection scoreCon = null;
                                    PreparedStatement scorePs = null;
                                    ResultSet scoreRs = null;

                                    try {
                                        scoreCon = DBConnection.getConnection();
                                        String scoreSql = "";
                                        
                                        if ("ER_DIAGRAM".equals(qType)) {
                                            scoreSql = "SELECT score FROM er_diagram_submissions WHERE student_id = ? AND question_id = ?";
                                        } else {
                                            scoreSql = "SELECT score FROM algorithm_submissions WHERE student_id = ? AND question_id = ?";
                                        }

                                        scorePs = scoreCon.prepareStatement(scoreSql);
                                        scorePs.setInt(1, studentDbId);
                                        scorePs.setInt(2, qId);
                                        scoreRs = scorePs.executeQuery();

                                        if (scoreRs.next()) {
                                            Integer sc = scoreRs.getObject("score") != null ? scoreRs.getInt("score") : null;
                                            if (sc != null) {
                                                scoreValue = String.valueOf(sc);
                                            }
                                        }
                                    } catch (Exception e) {
                                        // ข้ามกรณีไม่มีตารางหรือข้อมูล
                                    } finally {
                                        if (scoreRs != null) try { scoreRs.close(); } catch (Exception e) {}
                                        if (scorePs != null) try { scorePs.close(); } catch (Exception e) {}
                                        if (scoreCon != null) try { scoreCon.close(); } catch (Exception e) {}
                                    }
                            %>
                                <td class="text-center"><%= scoreValue %></td>
                            <% } %>
                        </tr>
                    <%
                            }
                            if (!hasStudent) {
                                int totalCols = 3 + questionsList.size();
                    %>
                        <tr>
                            <td colspan="<%= totalCols %>" class="text-center text-muted py-4">
                                ไม่พบข้อมูลนักศึกษาในเซคชันนี้
                            </td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) {
                            application.log("ScoreView.jsp student query error", e);
                    %>
                        <tr>
                            <td colspan="10" class="text-center text-danger py-3">
                                ไม่สามารถโหลดข้อมูลคะแนนนักศึกษาได้
                            </td>
                        </tr>
                    <%
                        } finally {
                            if (sRs != null) try { sRs.close(); } catch (Exception e) {}
                            if (sPs != null) try { sPs.close(); } catch (Exception e) {}
                            if (sCon != null) try { sCon.close(); } catch (Exception e) {}
                        }
                    %>
                </tbody>
            </table>
        </div>

    </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById("searchInput").addEventListener("input", function() {
        const keyword = this.value.toLowerCase().trim();
        const rows = document.querySelectorAll("#scoreTableBody tr");

        rows.forEach(function(row) {
            const cells = row.querySelectorAll("td");
            if (cells.length < 3) return;

            const studentId = cells[1].textContent.toLowerCase();
            const studentName = cells[2].textContent.toLowerCase();

            const match = studentId.includes(keyword) || studentName.includes(keyword);
            row.style.display = match ? "" : "none";
        });
    });
</script>

</body>
</html>