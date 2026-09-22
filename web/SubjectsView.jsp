<%@page import="java.sql.*"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag"%>

<%
    String message = "";
    String messageType = "";

    String subjectMessage = (String) session.getAttribute("subjectMessage");
    String subjectMessageType = (String) session.getAttribute("subjectMessageType");

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
%>

<mytag:ReadFile />
<mytag:header menu="5"/>
<mytag:check_login />

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <title>จัดการโจทย์ - ER Diagram System</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Sarabun:wght@300;400;500;600;700&display=swap">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/global.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/pages/SubjectsView.css?v=2">
</head>

<body>
<div class="container teacher-page py-4">
    <div class="page-header">
        <div class="page-header-left">
            <div class="icon-box-header">
                <i class="bi bi-file-earmark-text"></i>
            </div>
            <div>
                <h3 class="header-title">จัดการโจทย์ (Subject)</h3>
                <p class="header-subtitle">เพิ่ม ลบ และกำหนดการแสดงผลโจทย์สำหรับแต่ละเซคชัน</p>
            </div>
        </div>
    </div>

    <% if (!message.isEmpty()) { %>
        <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
            <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <!-- ADD SUBJECT -->
    <div class="main-card add-subject-card">
        <form method="post" action="SubjectAction.jsp">
            <input type="hidden" name="action" value="add">

            <div class="add-subject-header">
                <div class="add-icon">
                    <i class="bi bi-plus-lg"></i>
                </div>
                <div>
                    <h4>เพิ่มโจทย์ใหม่</h4>
                    <p>กรอกข้อมูลโจทย์และกำหนดการแสดงผล</p>
                </div>
            </div>

            <div class="subject-form-row">
                <!-- NAME -->
                <div class="subject-form-group subject-name-group">
                    <label>ชื่อโจทย์ (Name)</label>
                    <input type="text" name="name" class="subject-input" placeholder="กรอกชื่อโจทย์ เช่น ER_01" required>
                </div>

                <!-- POINT -->
                <div class="subject-form-group">
                    <label>คะแนน (Point)</label>
                    <input type="number" name="point" class="subject-input" placeholder="กรอกคะแนน" min="0" required>
                </div>

                <!-- STATUS -->
                <div class="subject-form-group">
                    <label>สถานะ (Status)</label>
                    <div class="status-toggle">
                        <label class="status-option">
                            <input type="radio" name="status" value="ON" checked>
                            <span>On</span>
                        </label>
                        <label class="status-option">
                            <input type="radio" name="status" value="OFF">
                            <span>Off</span>
                        </label>
                    </div>
                </div>

                <!-- SEC -->
                <div class="subject-form-group">
                    <label>เซคชัน (Sec)</label>
                    <input type="text" name="sec" class="subject-input" placeholder="กรอกเลขเซค เช่น 1,2,3" required>
                </div>

                <!-- BUTTON -->
                <div class="subject-button-group">
                    <button type="submit" class="btn-add-subject">
                        <i class="bi bi-plus-lg"></i> เพิ่มโจทย์
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- SUBJECT TABLE -->
    <div class="main-card subject-card">
        <div class="controls-bar">
            <div class="controls-left">
                <!-- SECTION FILTER -->
                <div class="filter-group">
                    <i class="bi bi-funnel filter-icon"></i>
                    <span class="filter-label">เลือกเซคชัน</span>
                    <select class="custom-select" id="sectionFilter">
                        <option value="">ทั้งหมด</option>
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                    </select>
                </div>

                <!-- SEARCH -->
                <div class="search-box">
                    <i class="bi bi-search search-icon"></i>
                    <input type="text" class="custom-input" id="searchInput" placeholder="ค้นหาชื่อโจทย์...">
                </div>
            </div>

            <!-- TOTAL -->
            <div class="total-badge">
                <i class="bi bi-list-ul"></i>
                <span>
                    <%
                        int totalSubjects = 0;
                        Connection countCon = null;
                        PreparedStatement countPs = null;
                        ResultSet countRs = null;

                        try {
                            countCon = DBConnection.getConnection();
                            countPs = countCon.prepareStatement("SELECT COUNT(*) FROM subjects");
                            countRs = countPs.executeQuery();

                            if (countRs.next()) {
                                totalSubjects = countRs.getInt(1);
                            }
                        } catch (Exception e) {
                            totalSubjects = 0;
                        } finally {
                            if (countRs != null) { try { countRs.close(); } catch (Exception e) {} }
                            if (countPs != null) { try { countPs.close(); } catch (Exception e) {} }
                            if (countCon != null) { try { countCon.close(); } catch (Exception e) {} }
                        }
                    %>
                    ทั้งหมด <%= totalSubjects %> รายการ
                </span>
            </div>
        </div>

        <!-- TABLE FORM -->
        <form method="post" action="SubjectAction.jsp" id="subjectUpdateForm">
            <input type="hidden" name="action" value="updateAll">

            <div class="custom-table-container">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th style="width:7%;">#</th>
                            <th style="width:28%;">Name (ชื่อโจทย์)</th>
                            <th style="width:18%;">Point (คะแนน)</th>
                            <th style="width:20%;">Status</th>
                            <th style="width:19%;">Sec (เซคชัน)</th>
                            <th style="width:8%; text-align:center;">Del</th>
                        </tr>
                    </thead>
                    <tbody id="subjectTableBody">
                    <%
                        Connection tableCon = null;
                        PreparedStatement tablePs = null;
                        ResultSet rs = null;

                        try {
                            tableCon = DBConnection.getConnection();
                            String sql = "SELECT id, name, point, status, sec FROM subjects ORDER BY id ASC";
                            tablePs = tableCon.prepareStatement(sql);
                            rs = tablePs.executeQuery();

                            int rowNumber = 1;

                            while (rs.next()) {
                                int id = rs.getInt("id");
                                String name = rs.getString("name");
                                int point = rs.getInt("point");
                                String status = rs.getString("status");
                                String sec = rs.getString("sec");
                    %>
                        <tr>
                            <!-- SUBJECT ID -->
                            <input type="hidden" name="subjectIds" value="<%= id %>">

                            <!-- NUMBER -->
                            <td><%= rowNumber++ %></td>

                            <!-- NAME -->
                            <td>
                                <input type="text" name="name_<%= id %>" class="subject-table-input" value="<%= name %>" required>
                            </td>

                            <!-- POINT -->
                            <td>
                                <input type="number" name="point_<%= id %>" class="subject-table-input point-input" value="<%= point %>" min="0" required>
                            </td>

                            <!-- STATUS -->
                            <td>
                                <div class="status-toggle">
                                    <label class="status-option">
                                        <input type="radio" name="status_<%= id %>" value="ON" <%= "ON".equals(status) ? "checked" : "" %>>
                                        <span>On</span>
                                    </label>
                                    <label class="status-option">
                                        <input type="radio" name="status_<%= id %>" value="OFF" <%= "OFF".equals(status) ? "checked" : "" %>>
                                        <span>Off</span>
                                    </label>
                                </div>
                            </td>

                            <!-- SEC -->
                            <td>
                                <input type="text" name="sec_<%= id %>" class="subject-table-input" value="<%= sec %>" placeholder="เช่น 1,2,3" required>
                            </td>

                            <!-- DELETE -->
                            <td class="text-center">
                                <button type="button" class="btn-delete" title="ลบโจทย์" onclick="deleteSubject(<%= id %>)">
                                    <i class="bi bi-trash3"></i>
                                </button>
                            </td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) {
                    %>
                        <tr>
                            <td colspan="6" class="error-state">
                                เกิดข้อผิดพลาด: <%= e.getMessage() %>
                            </td>
                        </tr>
                    <%
                        } finally {
                            if (rs != null) { try { rs.close(); } catch (Exception e) {} }
                            if (tablePs != null) { try { tablePs.close(); } catch (Exception e) {} }
                            if (tableCon != null) { try { tableCon.close(); } catch (Exception e) {} }
                        }
                    %>
                    </tbody>
                </table>
            </div>

            <!-- SAVE BUTTON -->
            <div class="text-center mt-4 mb-2">
                <button type="submit" class="btn btn-primary px-4 py-2 shadow-sm">
                    <i class="bi bi-save me-2"></i>
                    บันทึกการเปลี่ยนแปลง
                </button>
            </div>
        </form>
    </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>

<script>
    /* ========================= SEARCH ========================= */
    document.getElementById("searchInput").addEventListener("input", function () {
        const keyword = this.value.toLowerCase();
        const rows = document.querySelectorAll("#subjectTableBody tr");

        rows.forEach(function (row) {
            const input = row.querySelector(".subject-table-input");
            if (!input) return;

            const name = input.value.toLowerCase();
            row.style.display = name.includes(keyword) ? "" : "none";
        });
    });

    /* ========================= SECTION FILTER ========================= */
    document.getElementById("sectionFilter").addEventListener("change", function () {
        const section = this.value;
        const rows = document.querySelectorAll("#subjectTableBody tr");

        rows.forEach(function (row) {
            const inputs = row.querySelectorAll(".subject-table-input");
            if (inputs.length < 3) return;

            const sec = inputs[2].value;
            if (section === "" || sec.split(",").map(function (s) { return s.trim(); }).includes(section)) {
                row.style.display = "";
            } else {
                row.style.display = "none";
            }
        });
    });

    /* ========================= DELETE ========================= */
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
</script>
</body>
</html>