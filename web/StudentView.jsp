<%@page import="java.sql.*"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag"%>

<%
    String message = "";
    String messageType = "";
    String action = request.getParameter("action");

    Connection actionCon = null;
    PreparedStatement actionPs = null;

    try {
        if (action != null) {
            actionCon = DBConnection.getConnection();

            /* ========================= DELETE STUDENT ========================= */
            if ("delete".equals(action)) {
                String userId = request.getParameter("user_id");

                if (userId == null || userId.trim().isEmpty()) {
                    throw new Exception("ไม่พบรหัสนักศึกษาที่ต้องการลบ");
                }

                String sql = "DELETE FROM users WHERE id = ? AND role = 'student'";

                actionPs = actionCon.prepareStatement(sql);
                actionPs.setInt(1, Integer.parseInt(userId));

                int result = actionPs.executeUpdate();

                actionPs.close();
                actionPs = null;

                if (result > 0) {
                    response.sendRedirect(request.getRequestURI() + "?success=deleted");
                } else {
                    response.sendRedirect(request.getRequestURI() + "?success=delete_failed");
                }
                return;
            }

            /* ========================= RESET PASSWORD ========================= */
            if ("resetPassword".equals(action)) {
                String userId = request.getParameter("user_id");

                if (userId == null || userId.trim().isEmpty()) {
                    throw new Exception("ไม่พบข้อมูลนักศึกษาที่ต้องการรีเซ็ตรหัสผ่าน");
                }

                String sql = "UPDATE users SET password = ? WHERE id = ? AND role = 'student'";

                actionPs = actionCon.prepareStatement(sql);
                actionPs.setString(1, "123456");
                actionPs.setInt(2, Integer.parseInt(userId));

                int result = actionPs.executeUpdate();

                actionPs.close();
                actionPs = null;

                if (result > 0) {
                    response.sendRedirect(request.getRequestURI() + "?success=reset");
                } else {
                    response.sendRedirect(request.getRequestURI() + "?success=reset_failed");
                }
                return;
            }
        }

    } catch (Exception e) {
        message = e.getMessage();
        messageType = "danger";
    } finally {
        if (actionPs != null) {
            try {
                actionPs.close();
            } catch (Exception e) {}
        }

        if (actionCon != null) {
            try {
                actionCon.close();
            } catch (Exception e) {}
        }
    }

    String success = request.getParameter("success");

    if ("deleted".equals(success)) {
        message = "ลบข้อมูลนักศึกษาเรียบร้อยแล้ว";
        messageType = "success";
    } else if ("delete_failed".equals(success)) {
        message = "ไม่พบข้อมูลนักศึกษาที่ต้องการลบ";
        messageType = "danger";
    } else if ("reset".equals(success)) {
        message = "รีเซ็ตรหัสผ่านเรียบร้อยแล้ว รหัสผ่านใหม่คือ 123456";
        messageType = "success";
    } else if ("reset_failed".equals(success)) {
        message = "ไม่พบข้อมูลนักศึกษาที่ต้องการรีเซ็ตรหัสผ่าน";
        messageType = "danger";
    }
%>

<mytag:ReadFile />
<mytag:header menu="4"/>
<mytag:check_login />

<!DOCTYPE html>
<html lang="th">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>จัดการนักศึกษา</title>

    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Sarabun:wght@300;400;500;600;700&display=swap">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet"href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <!-- Bootstrap -->
    <link rel="stylesheet"href="${pageContext.request.contextPath}/css/bootstrap.min.css">

    <!-- Global CSS -->
    <link rel="stylesheet"href="${pageContext.request.contextPath}/css/global.css">

    <!-- StudentView CSS -->
    <link rel="stylesheet"href="${pageContext.request.contextPath}/css/pages/StudentView.css?v=4">
</head>

<body>
    <div class="container teacher-page py-4">

        <%-- Notification Message --%>
        <%
            String flashMessage = (String) session.getAttribute("message");
            String flashMessageType = (String) session.getAttribute("messageType");
            session.removeAttribute("message");
            session.removeAttribute("messageType");
        %>

        <% if (flashMessage != null) { %>
            <div class="alert alert-<%= flashMessageType == null ? "success" : flashMessageType %> alert-dismissible fade show" role="alert">
                <%= flashMessage %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                <%= message %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <!-- Header -->
        <div class="page-header">
            <div class="page-header-left">
                <div class="icon-box-header">
                    <i class="bi bi-people-fill"></i>
                </div>
                <div>
                    <h3 class="header-title">จัดการนักศึกษา</h3>
                    <p class="header-subtitle">ดูรายชื่อนักศึกษา จัดการเซกชัน รีเซ็ตรหัสผ่าน และนำเข้าข้อมูลนักศึกษา</p>
                </div>
            </div>
        </div>

        <!-- Student Table Card -->
        <div class="main-card student-card">

            <div class="controls-bar">
                <div class="controls-left">

                    <div class="filter-group">
                        <i class="bi bi-funnel filter-icon"></i>
                        <span class="filter-label">เลือกเซกชัน</span>
                        <select class="custom-select">
                            <option value="">ทั้งหมด</option>
                        </select>
                    </div>

                    <div class="search-box">
                        <i class="bi bi-search search-icon"></i>
                        <input type="text" class="custom-input" placeholder="ค้นหารหัสนักศึกษา / ชื่อ...">
                    </div>

                </div>

                <div class="total-badge">
                    <i class="bi bi-people-fill"></i>
                    <span>ทั้งหมด 35 รายการ</span>
                </div>
            </div>

            <div class="custom-table-container">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th style="width:20%;">ID (รหัสนักศึกษา)</th>
                            <th style="width:25%;">NAME (ชื่อ-นามสกุล)</th>
                            <th style="width:10%;">STATUS</th>
                            <th style="width:10%; text-align:center;">SEC</th>
                            <th style="width:10%; text-align:center;">DELETE</th>
                            <th style="width:18%; text-align:center;">RESET PASSWORD</th>
                            <th style="width:12%; text-align:center;">POINT</th>
                        </tr>
                    </thead>

                    <tbody>
                        <%
                            Connection con = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            int totalCount = 0;

                            try {
                                con = DBConnection.getConnection();

                                String sql = "SELECT u.id, u.username, u.full_name, u.status, u.sec "
                                        + "FROM users u "
                                        + "WHERE u.role = 'student' "
                                        + "ORDER BY u.sec ASC, u.username ASC";

                                ps = con.prepareStatement(sql);
                                rs = ps.executeQuery();

                                boolean hasData = false;

                                while (rs.next()) {
                                    hasData = true;
                                    totalCount++;

                                    int userId = rs.getInt("id");
                                    String username = rs.getString("username");
                                    String fullName = rs.getString("full_name");
                                    String secName = rs.getString("sec");

                                    String status = rs.getString("status");

                                    if (status == null) {
                                        status = "ON";
                                    }

                                    if (secName == null) {
                                        secName = "-";
                                    }
                        %>

                        <tr>
                            <td class="student-id"><%= username %></td>
                            <td class="student-name"><%= fullName %></td>

                            <td class="text-center">
                                <form action="UpdateStudentStatus.jsp" method="post">

                                    <input type="hidden" name="user_id" value="<%= userId %>">

                                    <div class="status-toggle">

                                        <label class="status-option">
                                            <input type="radio" name="status" value="ON" <%= "ON".equals(status) ? "checked" : "" %> onchange="this.form.submit()">
                                            <span>On</span>
                                        </label>

                                        <label class="status-option">
                                            <input type="radio" name="status" value="OFF" <%= "OFF".equals(status) ? "checked" : "" %> onchange="this.form.submit()">
                                            <span>Off</span>
                                        </label>

                                    </div>

                                </form>
                            </td>

                            <td class="text-center student-sec"><%= secName %></td>

                            <!-- DELETE -->
                            <td class="text-center">
                                <form method="post"
                                      action="<%= request.getRequestURI() %>"
                                      onsubmit="return confirm('คุณต้องการลบนักศึกษารายนี้ใช่หรือไม่?');"
                                      class="action-form">

                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="user_id" value="<%= userId %>">

                                    <button type="submit" class="btn-delete" title="ลบข้อมูล">
                                        <i class="bi bi-trash3"></i>
                                    </button>

                                </form>
                            </td>

                            <!-- RESET PASSWORD -->
                            <td class="text-center">
                                <form method="post"
                                      action="<%= request.getRequestURI() %>"
                                      onsubmit="return confirm('ต้องการรีเซ็ตรหัสผ่านใช่หรือไม่?');"
                                      class="action-form">

                                    <input type="hidden" name="action" value="resetPassword">
                                    <input type="hidden" name="user_id" value="<%= userId %>">

                                    <button type="submit" class="btn-reset-password">
                                        <i class="bi bi-key"></i> รีเซ็ตรหัสผ่าน
                                    </button>

                                </form>
                            </td>

                            <td class="text-center">
                                <input type="number" class="custom-input input-point" value="0">
                            </td>
                        </tr>

                        <%
                                }

                                if (!hasData) {
                        %>
                        <tr>
                            <td colspan="7" class="empty-state">ไม่พบข้อมูลนักศึกษาในระบบ</td>
                        </tr>
                        <%
                                }

                            } catch (Exception e) {
                                out.println("<tr><td colspan='7' class='error-state'>เกิดข้อผิดพลาด: " + e.getMessage() + "</td></tr>");
                            } finally {
                                if (rs != null) try { rs.close(); } catch (Exception e) {}
                                if (ps != null) try { ps.close(); } catch (Exception e) {}
                                if (con != null) try { con.close(); } catch (Exception e) {}
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <div class="table-footer">
                แสดง 1 - <%= totalCount %> จาก <%= totalCount %> รายการ
            </div>
        </div>

        <!-- Import & Manual Section -->
        <!-- Import & Manual Section -->
        <div class="main-card excel-card mt-4">
            <form action="ImportStudents.jsp" method="post" enctype="multipart/form-data">

                <!-- Excel Import Section -->
                <div class="import-section">
                    <div class="excel-left">
                        <div class="excel-badge-icon">
                            <i class="fa-solid fa-file-excel"></i>
                            <span class="badge-sub-icon"><i class="fa-solid fa-cloud-arrow-up"></i></span>
                        </div>

                        <div class="excel-info">
                            <h5>นำเข้าข้อมูลนักศึกษา (Excel Import)</h5>
                            <p>อัปโหลดไฟล์รายชื่อนักศึกษา (.xlsx)</p>
                            <small>รองรับเฉพาะไฟล์ .xlsx เท่านั้น</small>
                        </div>
                    </div>

                    <div class="excel-form">
                        <div class="file-picker">
                            <label for="excelFile" class="btn-choose-file">
                                <i class="fa-regular fa-folder-open"></i>
                                เลือกไฟล์
                            </label>

                            <span class="file-name" id="fileNameLabel">ไม่ได้เลือกไฟล์</span>

                            <input type="file"
                                   name="excel_file[]"
                                   id="excelFile"
                                   accept=".xlsx"
                                   class="d-none"
                                   onchange="document.getElementById('fileNameLabel').textContent = this.files[0] ? this.files[0].name : 'ไม่ได้เลือกไฟล์'">
                        </div>
                    </div>
                </div>

                <!-- Divider -->
                <div class="import-divider">
                    <span>หรือ</span>
                </div>

                <!-- Manual Import Section -->
                <div class="manual-section">
                    <div class="manual-title">
                        <div class="manual-icon">
                            <i class="fa-solid fa-user"></i>
                            <span class="badge-sub-icon"><i class="fa-solid fa-plus"></i></span>
                        </div>

                        <div class="manual-info">
                            <h5>เพิ่มนักศึกษา (Manual)</h5>
                            <small>กรอกข้อมูลนักศึกษาแล้วกดบันทึก</small>
                        </div>
                    </div>

                    <div class="manual-fields">
                        <div class="manual-input">
                            <label>รหัสนักศึกษา</label>
                            <div class="input-with-icon">
                                <i class="fa-solid fa-graduation-cap"></i>
                                <input type="text"
                                       name="student_id"
                                       placeholder="กรอกรหัสนักศึกษา">
                            </div>
                        </div>

                        <div class="manual-input">
                            <label>ชื่อ-นามสกุล</label>
                            <div class="input-with-icon">
                                <i class="fa-regular fa-user"></i>
                                <input type="text"
                                       name="full_name"
                                       placeholder="กรอกชื่อ-นามสกุล">
                            </div>
                        </div>

                        <div class="manual-input">
                            <label>SEC</label>
                            <div class="input-with-icon">
                                <i class="fa-solid fa-city"></i>
                                <input type="text"
                                       name="sec"
                                       placeholder="กรอก SEC">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Save Button -->
                <div class="save-row">
                    <button type="submit" class="btn-save-student">
                        <i class="fa-regular fa-floppy-disk"></i>
                        บันทึกข้อมูล
                    </button>
                </div>

            </form>
        </div>

    </div>

    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>