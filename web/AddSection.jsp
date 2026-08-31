<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="3" />
<mytag:check_login />  

<html>
    <head>
        <meta charset="UTF-8">
        <title>เลือกเซคชัน - Diagram Grading System</title>

        <!-- Google Font -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">

        <!-- Bootstrap & Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="css/bootstrap.min.css">
        <!-- Global CSS -->
        <link rel="stylesheet" href="css/global.css">
        <link rel="stylesheet" href="css/pages/AddSection.css">

    
    </head>
    
   <body>
        <nav class="navbar navbar-custom d-flex justify-content-between align-items-center mb-4 px-4 bg-white border-bottom">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-database-fill text-primary fs-4"></i>
                <span class="fw-bold text-primary fs-5">Diagram Grading System</span>
            </div>
        </nav>

        <div class="container my-4" style="max-width: 960px;">
            
            <div class="card border-0 shadow-sm rounded-4 p-4 p-md-5 bg-white">
                
                <div class="d-flex align-items-center gap-3 mb-4">
                    <div class="header-icon-box">
                        <i class="bi bi-grid-fill"></i>
                    </div>
                    <div>
                        <h3 class="fw-bold mb-1">เลือกเซคชัน</h3>
                        <p class="text-muted mb-0">เลือกเซคชันเพื่อเพิ่มรายชื่อนักศึกษา</p>
                    </div>
                </div>

                <div class="row g-3 mb-4 align-items-center">
                    <div class="col-8 col-md-9">
                        <div class="input-group">
                            <input type="text" class="form-control border-start-0 ps-0 py-2" placeholder="ค้นหาเซคชัน...">
                            <span class="input-group-text bg-white border-end-0 text-muted ps-3">
                                <i class="bi bi-search"></i>
                            </span>
                        </div>
                    </div>
                    
                    <div class="col-4 col-md-3">
                        <button class="btn btn-primary w-100 d-flex align-items-center justify-content-center gap-2 py-2 fw-medium">
                            <i class="bi bi-plus-lg"></i>
                            <span class="d-none d-sm-inline">เพิ่มเซคชัน</span>
                        </button>
                    </div>
                </div>

                <div class="d-flex flex-column gap-3">
                    
                    <a href="#" class="section-card">
                        <div class="d-flex align-items-center gap-3">
                            <div class="folder-icon-box">
                                <i class="bi bi-folder-fill"></i>
                            </div>
                            <div>
                                <h5 class="fw-bold mb-1">Section 1</h5>
                                <div class="meta-info">
                                    <p class="text-muted small mb-2">Computer Programing I</p>
                                    <span><i class="bi bi-person"></i> 12 ผู้ใช้</span>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <span class="badge-updated">อัปเดตล่าสุด 20/05/2568</span>
                            <i class="bi bi-chevron-right text-muted"></i>
                        </div>
                    </a>

                    <a href="#" class="section-card">
                        <div class="d-flex align-items-center gap-3">
                            <div class="folder-icon-box">
                                <i class="bi bi-folder-fill"></i>
                            </div>
                            <div>
                                <h5 class="fw-bold mb-1">Section 2</h5>
                                <div class="meta-info">
                                    <p class="text-muted small mb-2">Computer Programing I</p>
                                    <span><i class="bi bi-person"></i> 9 ผู้ใช้</span>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <span class="badge-updated">อัปเดตล่าสุด 18/05/2568</span>
                            <i class="bi bi-chevron-right text-muted"></i>
                        </div>
                    </a>

                    <a href="#" class="section-card">
                        <div class="d-flex align-items-center gap-3">
                            <div class="folder-icon-box">
                                <i class="bi bi-folder-fill"></i>
                            </div>
                            <div>
                                <h5 class="fw-bold mb-1">Section 3</h5>
                                <div class="meta-info">
                                    <p class="text-muted small mb-2">Database</p>
                                    <span><i class="bi bi-person"></i> 14 ผู้ใช้</span>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <span class="badge-updated">อัปเดตล่าสุด 15/05/2568</span>
                            <i class="bi bi-chevron-right text-muted"></i>
                        </div>
                    </a>
                </div>
            </div>

            <div class="text-center text-muted small mt-4 mb-3">
                © 2025 ER Diagram System. All rights reserved.
            </div>
        </div>
    </body>
</html>