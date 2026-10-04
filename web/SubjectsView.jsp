
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

    String message = "";
    String messageType = "";

    String subjectMessage =
            (String) session.getAttribute("subjectMessage");
    String subjectMessageType =
            (String) session.getAttribute("subjectMessageType");

    if (subjectMessage != null) {
        message = subjectMessage;
        messageType = subjectMessageType;

        session.removeAttribute("subjectMessage");
        session.removeAttribute("subjectMessageType");
    }

    String success = request.getParameter("success");

    if ("added".equals(success)) {
        message = "เพิ่มโจทย์เรียบร้อยแล้ว";
        messageType = "success";
    } else if ("updated".equals(success)) {
        message = "อัปเดตข้อมูลเรียบร้อยแล้ว";
        messageType = "success";
    } else if ("deleted".equals(success)) {
        message = "ลบโจทย์เรียบร้อยแล้ว";
        messageType = "success";
    }

    List<String> sections = new ArrayList<String>();

    Connection secCon = null;
    PreparedStatement secPs = null;
    ResultSet secRs = null;

    try {
        secCon = DBConnection.getConnection();

        String secSql =
                "SELECT DISTINCT sec FROM questions "
                + "WHERE sec IS NOT NULL AND sec <> ''";

        secPs = secCon.prepareStatement(secSql);
        secRs = secPs.executeQuery();

        while (secRs.next()) {
            String secValue = secRs.getString("sec");

            if (secValue == null || secValue.trim().isEmpty()) {
                continue;
            }

            String[] secList = secValue.split(",");

            for (String sec : secList) {
                sec = sec.trim();

                if (!sec.isEmpty() && !sections.contains(sec)) {
                    sections.add(sec);
                }
            }
        }

        Collections.sort(sections, new Comparator<String>() {
            @Override
            public int compare(String a, String b) {
                try {
                    return Integer.compare(
                            Integer.parseInt(a),
                            Integer.parseInt(b)
                    );
                } catch (Exception e) {
                    return a.compareTo(b);
                }
            }
        });

    } catch (Exception e) {
        application.log("SubjectsView.jsp section query error", e);
        sections.clear();

        if (message.isEmpty()) {
            message = "ไม่สามารถโหลดข้อมูลเซคชันได้";
            messageType = "danger";
        }
    } finally {
        if (secRs != null) {
            try { secRs.close(); } catch (Exception e) {}
        }
        if (secPs != null) {
            try { secPs.close(); } catch (Exception e) {}
        }
        if (secCon != null) {
            try { secCon.close(); } catch (Exception e) {}
        }
    }

    int totalSubjects = 0;

    Connection countCon = null;
    PreparedStatement countPs = null;
    ResultSet countRs = null;

    try {
        countCon = DBConnection.getConnection();
        countPs = countCon.prepareStatement(
                "SELECT COUNT(*) FROM questions"
        );
        countRs = countPs.executeQuery();

        if (countRs.next()) {
            totalSubjects = countRs.getInt(1);
        }
    } catch (Exception e) {
        application.log("SubjectsView.jsp count query error", e);
    } finally {
        if (countRs != null) {
            try { countRs.close(); } catch (Exception e) {}
        }
        if (countPs != null) {
            try { countPs.close(); } catch (Exception e) {}
        }
        if (countCon != null) {
            try { countCon.close(); } catch (Exception e) {}
        }
    }
%>

<mytag:ReadFile />
<mytag:header menu="5"/>
<mytag:check_login />

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>จัดการโจทย์ - ER Diagram System</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Sarabun:wght@300;400;500;600;700&display=swap">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/bootstrap.min.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/global.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/pages/SubjectsView.css?v=3">
</head>

<body>

<div class="container teacher-page py-4">

    <!-- Page Header -->
    <div class="page-header">
        <div class="page-header-left">
            <div class="icon-box-header">
                <i class="bi bi-file-earmark-text"></i>
            </div>

            <div>
                <h3 class="header-title">จัดการโจทย์ (Subject)</h3>
                <p class="header-subtitle">
                    เพิ่ม ลบ และกำหนดการแสดงผลโจทย์สำหรับแต่ละเซคชัน
                </p>
            </div>
        </div>
    </div>

    <!-- Message -->
    <% if (message != null && !message.isEmpty()) { %>
        <div class="alert alert-<%= escapeHtml(messageType) %> alert-dismissible fade show"
             role="alert">
            <%= escapeHtml(message) %>

            <button type="button"
                    class="btn-close"
                    data-bs-dismiss="alert"
                    aria-label="Close">
            </button>
        </div>
    <% } %>

    <!-- Add Subject -->
    <div class="main-card add-subject-card">

        <div class="add-subject-header">
            <div class="add-icon">
                <i class="bi bi-plus-lg"></i>
            </div>

            <div>
                <h4>เพิ่มโจทย์ใหม่</h4>
                <p>เลือกประเภทโจทย์เพื่อไปยังหน้าสร้างโจทย์</p>
            </div>
        </div>

        <div class="subject-form-row">

            <div class="subject-form-group">
                <label for="questionType">ประเภทโจทย์</label>

                <select id="questionType"
                        class="subject-input"
                        required>
                    <option value="">-- เลือกประเภทโจทย์ --</option>
                    <option value="ER">ER Diagram</option>
                    <option value="Flowchart">Flowchart</option>
                    <option value="Pseudocode">Pseudocode</option>
                </select>
            </div>

            <div class="subject-button-group">
                <button type="button"
                        class="btn-add-subject"
                        onclick="goToCreateQuestion()">
                    <i class="bi bi-plus-lg"></i>
                    เพิ่มโจทย์
                </button>
            </div>

        </div>
    </div>

    <!-- Subject Table -->
    <div class="main-card subject-card">

        <!-- Search and Filter -->
        <div class="controls-bar">

            <div class="controls-left">

                <div class="filter-group">
                    <i class="bi bi-funnel filter-icon"></i>

                    <span class="filter-label">
                        เลือกเซคชัน
                    </span>

                    <select class="custom-select" id="sectionFilter">
                        <option value="">ทั้งหมด</option>

                        <% for (String sec : sections) { %>
                            <option value="<%= escapeHtml(sec) %>">
                                Sec <%= escapeHtml(sec) %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="search-box">
                    <i class="bi bi-search search-icon"></i>

                    <input type="text"
                           class="custom-input"
                           id="searchInput"
                           placeholder="ค้นหาชื่อโจทย์...">
                </div>

            </div>

            <div class="total-badge">
                <i class="bi bi-list-ul"></i>
                <span>
                    ทั้งหมด <%= totalSubjects %> รายการ
                </span>
            </div>

        </div>

        <!-- Update Form
             ใช้ application/x-www-form-urlencoded ตาม SubjectAction.jsp
             จึงไม่ใส่ enctype="multipart/form-data"
        -->
        <form method="post"
              action="SubjectAction.jsp"
              id="subjectUpdateForm"
              accept-charset="UTF-8">

            <input type="hidden"
                   name="action"
                   value="updateAll">

            <div class="custom-table-container">

                <table class="custom-table">

                    <thead>
                        <tr>
                            <th style="width:5%;">#</th>
                            <th style="width:23%;">Name (ชื่อโจทย์)</th>
                            <th style="width:10%;">Point (คะแนน)</th>
                            <th style="width:17%;">Status</th>
                            <th style="width:15%;">Sec (เซคชัน)</th>
                            <th style="width:10%; text-align:center;">PDF</th>
                            <th style="width:12%; text-align:center;">RESET POINT</th>
                            <th style="width:8%; text-align:center;">Del</th>
                        </tr>
                    </thead>

                    <tbody id="subjectTableBody">

                    <%
                        Connection tableCon = null;
                        PreparedStatement tablePs = null;
                        ResultSet rs = null;

                        StringBuilder idListBuilder = new StringBuilder();

                        try {
                            tableCon = DBConnection.getConnection();

                            String sql =
                                    "SELECT id, name, point, status, sec, pdf_file, question_type "
                                    + "FROM questions "
                                    + "ORDER BY CAST(SUBSTRING_INDEX(sec, ',', 1) "
                                    + "AS UNSIGNED) ASC, id ASC";

                            tablePs = tableCon.prepareStatement(sql);
                            rs = tablePs.executeQuery();

                            int rowNumber = 1;

                            while (rs.next()) {
                                int id = rs.getInt("id");
                                String name = rs.getString("name");
                                int point = rs.getInt("point");
                                String status = rs.getString("status");
                                String sec = rs.getString("sec");
                                String pdfFile = rs.getString("pdf_file");
                                String questionType = rs.getString("question_type");

                                if (name == null) name = "";
                                if (status == null) status = "OFF";
                                if (sec == null) sec = "";

                                if (idListBuilder.length() > 0) {
                                    idListBuilder.append(",");
                                }
                                idListBuilder.append(id);

                                String editPage = "";

                                if ("FLOWCHART".equals(questionType)
                                        || "PSEUDOCODE".equals(questionType)) {
                                    editPage = "CreateAnswerKey_Flowchart.jsp";
                                } else if ("ER_DIAGRAM".equals(questionType)) {
                                    editPage = "Design_ERdiagram.jsp";
                                }
                    %>

                        <tr>

                            <!-- Number and ID -->
                            <td>
                                <input type="hidden"
                                       name="subjectIds"
                                       value="<%= id %>">

                                <%= rowNumber++ %>
                            </td>

                            <!-- Name -->
                            <td>
                                <input type="text"
                                       name="name_<%= id %>"
                                       class="subject-table-input"
                                       value="<%= escapeHtml(name) %>"
                                       maxlength="255"
                                       required>
                            </td>

                            <!-- Point -->
                            <td class="text-center">
                                <%= point %>

                                <input type="hidden"
                                       name="point_<%= id %>"
                                       value="<%= point %>">
                            </td>

                            <!-- Status -->
                            <td>
                                <div class="status-toggle">

                                    <label class="status-option">
                                        <input type="radio"
                                               name="status_<%= id %>"
                                               value="ON"
                                               <%= "ON".equals(status)
                                                   ? "checked" : "" %>>
                                        <span>On</span>
                                    </label>

                                    <label class="status-option">
                                        <input type="radio"
                                               name="status_<%= id %>"
                                               value="OFF"
                                               <%= "OFF".equals(status)
                                                   ? "checked" : "" %>>
                                        <span>Off</span>
                                    </label>

                                </div>
                            </td>

                            <!-- Section -->
                            <td>
                                <input type="text"
                                       name="sec_<%= id %>"
                                       class="subject-table-input"
                                       value="<%= escapeHtml(sec) %>"
                                       placeholder="เช่น 1,2,3"
                                       required>
                            </td>

                            <!-- Existing PDF link only -->
                            <td class="text-center">
                                <div class="pdf-actions"
                                     style="display:flex;align-items:center;justify-content:center;gap:8px;">

                                    <% if (pdfFile != null
                                            && !pdfFile.trim().isEmpty()) { %>

                                        <a href="<%= request.getContextPath() %>/<%= escapeHtml(pdfFile) %>"
                                           target="_blank"
                                           rel="noopener noreferrer"
                                           title="ดูไฟล์ PDF"
                                           style="color:#dc3545;font-size:1.3rem;">
                                            <i class="bi bi-file-earmark-pdf-fill"></i>
                                        </a>

                                    <% } else { %>

                                        <span class="text-muted"
                                              style="font-weight:bold;font-size:1.1rem;">
                                            -
                                        </span>

                                    <% } %>

                                </div>
                            </td>

                            <!-- Edit Question / Reset Point column -->
                            <td class="text-center">
                                <% if (!editPage.isEmpty()) { %>
                                    <a href="<%= editPage %>?subjectId=<%= id %>&mode=edit"
                                       class="btn-edit-score"
                                       title="แก้ไขโจทย์">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>
                                <% } else { %>
                                    <span class="text-muted">-</span>
                                <% } %>
                            </td>

                            <!-- Delete -->
                            <td class="text-center">
                                <button type="button"
                                        class="btn-delete"
                                        title="ลบโจทย์"
                                        onclick="deleteSubject(<%= id %>)">
                                    <i class="bi bi-trash3"></i>
                                </button>
                            </td>

                        </tr>

                    <%
                            }

                        } catch (Exception e) {
                            application.log("SubjectsView.jsp table query error", e);
                    %>

                        <tr>
                            <td colspan="8"
                                class="error-state text-center text-danger py-3">
                                ไม่สามารถโหลดรายการโจทย์ได้
                            </td>
                        </tr>

                    <%
                        } finally {
                            if (rs != null) {
                                try { rs.close(); } catch (Exception e) {}
                            }
                            if (tablePs != null) {
                                try { tablePs.close(); } catch (Exception e) {}
                            }
                            if (tableCon != null) {
                                try { tableCon.close(); } catch (Exception e) {}
                            }
                        }
                    %>

                    </tbody>
                </table>
            </div>

            <!-- All Subject IDs -->
            <input type="hidden"
                   name="allSubjectIds"
                   value="<%= idListBuilder.toString() %>">

            <!-- Save -->
            <div class="text-center mt-4 mb-2">
                <button type="submit"
                        class="btn btn-primary px-4 py-2 shadow-sm">
                    <i class="bi bi-save me-2"></i>
                    บันทึกการเปลี่ยนแปลง
                </button>
            </div>

        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>

<script>
/* ========================= SEARCH & FILTER ========================= */

function applyFilters() {
    const searchElement = document.getElementById("searchInput");
    const sectionElement = document.getElementById("sectionFilter");

    const keyword = searchElement.value.toLowerCase().trim();
    const selectedSection = sectionElement.value;

    const rows = document.querySelectorAll("#subjectTableBody tr");

    rows.forEach(function(row) {
        const inputs = row.querySelectorAll(".subject-table-input");

        // ข้ามแถวข้อความแจ้งข้อผิดพลาด
        if (inputs.length < 2) {
            return;
        }

        const name = inputs[0].value.toLowerCase();
        const sectionValues = inputs[1].value.split(",").map(function(value) {
            return value.trim();
        });

        const matchName = name.includes(keyword);
        const matchSection =
            selectedSection === "" || sectionValues.includes(selectedSection);

        row.style.display = matchName && matchSection ? "" : "none";
    });
}

document.getElementById("searchInput")
    .addEventListener("input", applyFilters);

document.getElementById("sectionFilter")
    .addEventListener("change", applyFilters);


/* ========================= DELETE SUBJECT ========================= */

function deleteSubject(id) {
    if (!confirm("คุณต้องการลบโจทย์นี้ใช่หรือไม่?")) {
        return;
    }

    const form = document.createElement("form");
    form.method = "post";
    form.action = "SubjectAction.jsp";

    const actionInput = document.createElement("input");
    actionInput.type = "hidden";
    actionInput.name = "action";
    actionInput.value = "delete";

    const idInput = document.createElement("input");
    idInput.type = "hidden";
    idInput.name = "id";
    idInput.value = id;

    form.appendChild(actionInput);
    form.appendChild(idInput);

    document.body.appendChild(form);
    form.submit();
}


/* ========================= CREATE QUESTION ========================= */

function goToCreateQuestion() {
    const typeElement = document.getElementById("questionType");
    const type = typeElement.value;

    if (!type) {
        alert("กรุณาเลือกประเภทโจทย์");
        typeElement.focus();
        return;
    }

    let url;
    let questionType;

    if (type === "ER") {
        url = "CreateAnswerKey_ERDiagram.jsp";
        questionType = "ER_DIAGRAM";
    } else if (type === "Flowchart") {
        url = "CreateAnswerKey_Flowchart.jsp";
        questionType = "FLOWCHART";
    } else if (type === "Pseudocode") {
        url = "CreateAnswerKey_Flowchart.jsp";
        questionType = "PSEUDOCODE";
    } else {
        alert("ประเภทโจทย์ไม่ถูกต้อง");
        return;
    }

    window.location.href =
        url + "?questionType=" + encodeURIComponent(questionType);
}


/* ========================= FORM VALIDATION ========================= */

document.getElementById("subjectUpdateForm")
    .addEventListener("submit", function(event) {
        const rows = document.querySelectorAll(
            "#subjectTableBody tr"
        );

        for (const row of rows) {
            if (row.style.display === "none") {
                // แม้ซ่อนจากการค้นหา ก็ยังส่งข้อมูลทั้งหมดในฟอร์ม
                // จึงต้องตรวจสอบข้อมูลทุกแถวเช่นเดิม
            }

            const nameInput = row.querySelector(
                'input[name^="name_"]'
            );
            const secInput = row.querySelector(
                'input[name^="sec_"]'
            );

            // ข้ามแถวที่เป็นข้อความ error
            if (!nameInput || !secInput) {
                continue;
            }

            if (!nameInput.value.trim()) {
                event.preventDefault();
                alert("กรุณากรอกชื่อโจทย์ให้ครบทุกข้อ");
                nameInput.focus();
                return;
            }

            if (nameInput.value.trim().length > 255) {
                event.preventDefault();
                alert("ชื่อโจทย์ต้องไม่เกิน 255 ตัวอักษร");
                nameInput.focus();
                return;
            }

            if (!secInput.value.trim()) {
                event.preventDefault();
                alert("กรุณากรอกเซคชันให้ครบทุกข้อ");
                secInput.focus();
                return;
            }

            const id = nameInput.name.substring("name_".length);
            const checkedStatus = row.querySelector(
                'input[name="status_' + id + '"]:checked'
            );

            if (!checkedStatus) {
                event.preventDefault();
                alert("กรุณาเลือกสถานะของโจทย์");
                return;
            }
        }
    });
</script>

</body>
</html>