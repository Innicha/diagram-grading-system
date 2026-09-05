<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>


<mytag:ReadFile />
<mytag:header menu="3" />

<mytag:check_login />  

<html>
    <head>
        <meta charset="UTF-8">
        <title>Create Answer Key ER Diagram</title>

        <!-- Google Font -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">

        <!-- Bootstrap -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="css/bootstrap.min.css">
        <!-- Global CSS -->
        <link rel="stylesheet" href="css/global.css">
        <!-- CSS -->
        <link rel="stylesheet" href="css/AnswerKeyPages/Assign_tasks.css">
    </head>
    
    <body>
    <div class="container py-5">
        <h2 class="text-center page-title mb-2">Create Answer Key</h2>
        <p class="text-center text-muted mb-5">เลือกประเภทของเฉลยที่ต้องการสร้าง</p>

        <div class="row g-4 justify-content-center">
            <!-- ER -->
            <div class="col-lg-4 col-md-6">
                <a href="CreateAnswerKey_ERDiagram.jsp" class="select-card">
                    <div class="card-body text-center p-5">
                        <div class="icon">
                            <i class="bi bi-diagram-3-fill"></i>
                        </div>
                        <h4 class="card-title">ER Diagram</h4>
                        <p class="card-text">
                            สร้างเฉลย ER Diagram
                        </p>
                    </div>
                </a>
            </div>

            <!-- Flowchart -->
            <div class="col-lg-4 col-md-6">
                <a href="CreateAnswerKey_Flowchart.jsp" class="select-card">
                    <div class="card-body text-center p-5">
                        <div class="icon">
                            <i class="bi bi-bezier2"></i>
                        </div>
                        <h4 class="card-title">Flowchart</h4>
                        <p class="card-text">
                            สร้างเฉลย Flowchart
                        </p>
                    </div>
                </a>
            </div>

            <!-- Pseudocode -->
            <div class="col-lg-4 col-md-6">
                <a href="CreateAnswerKey_Pseudocode.jsp" class="select-card">
                    <div class="card-body text-center p-5">
                        <div class="icon">
                            <i class="bi bi-code-slash"></i>
                        </div>
                        <h4 class="card-title">Pseudocode</h4>
                        <p class="card-text">
                            สร้างเฉลย Pseudocode
                        </p>
                    </div>
                </a>
            </div>
        </div>
    </div>

    </body>
</html>
