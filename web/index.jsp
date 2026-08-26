<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<!--อ่านข้อมูลจาก config-->
<mytag:ReadFile />

<!--header หรือ rooter ให้ใช้ mytag-->
<mytag:header menu="1" />

<!-- CSS Custom & Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link rel="stylesheet" href="css/global.css">
<link rel="stylesheet" href="css/pages/Index.css">


<!--Login UI-->
<div class="container login-wrapper">
    <!-- Brand Header
    <div class="brand-title">
        <i class="bi bi-database-fill-gear"></i> ER Diagram System
    </div> -->

    <!-- Main Card -->
    <div class="card login-card">
        <div class="icon-badge">
            <i class="bi bi-lock"></i>
        </div>

        <h3 class="text-center fw-bold text-dark mb-1">เข้าสู่ระบบ</h3>
        <p class="text-center text-muted small mb-4">กรุณาเข้าสู่ระบบเพื่อใช้งาน</p>

        <!-- แสดง Alert ในกรณี Login ล้มเหลว -->
        <%
            String error = request.getParameter("error");
            if ("1".equals(error)) {
        %>
            <div class="alert alert-danger text-center small py-2 mb-3" role="alert">
                ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง!
            </div>
        <%
            }
        %>

        <form action="check_login.jsp" method="post">
            <!-- Username -->
            <div class="mb-3">
                <label for="username" class="form-label fw-semibold small text-dark">Username</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-person"></i></span>
                    <input type="text" class="form-control" id="username" name="username" placeholder="กรอกชื่อผู้ใช้งาน" required>
                </div>
            </div>

            <!-- Password -->
            <div class="mb-2">
                <label for="password" class="form-label fw-semibold small text-dark">Password</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                    <input type="password" class="form-control" id="password" name="password" placeholder="กรอกรหัสผ่าน" required>
                </div>
            </div>

            <!-- Forgot Password -->
            <div class="text-end mb-4">
                <a href="#" class="text-decoration-none small fw-semibold text-primary">ลืมรหัสผ่าน?</a>
            </div>

            <!-- Submit Button -->
            <div class="d-flex justify-content-center mb-3">
                <button type="submit" class="btn btn-primary btn-login">
                    <i class="bi bi-box-arrow-in-right me-1"></i> เข้าสู่ระบบ
                </button>
            </div>
        </form>

    </div>

    <!-- Footer -->
    <div class="text-center text-muted small mt-4">
        &copy; 2026 ER Diagram System. All rights reserved.
    </div>
</div>