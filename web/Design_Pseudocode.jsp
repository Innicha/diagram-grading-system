<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="2" />

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/pages/Pseudocode.css">

<!-- Check Login -->
<mytag:check_login />

<%
    String link = request.getAttribute("Loadfile5") != null ? request.getAttribute("Loadfile5").toString() : "";
    String questionId = request.getParameter("questionId");
    String mode = request.getParameter("mode");
%>

<div class="container-fluid p-4" style="min-height: 100vh; background-color: #f4f6f9;">
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
        <h3 class="mb-0 fw-bold" style="color: #1e3a8a;">
            สร้าง Pseudocode
        </h3>
        <button type="button" class="btn btn-outline-danger d-flex align-items-center gap-2" onclick="downloadExercisePDF()">
            <i class="fa-solid fa-file-pdf"></i> ดาวน์โหลด PDF
        </button>
    </div>

    <div class="card shadow-sm border-0 rounded-4 p-4 bg-white">
        <div class="d-flex align-items-center justify-content-between mb-3">
            <span class="fw-semibold text-secondary">
                <i class="bi bi-code-square me-1"></i> เขียนคำสั่ง Pseudocode ด้านล่างเพื่อแปลงและทดสอบกับ Test Cases
            </span>
        </div>

        <div class="flowchart-wrapper border rounded-3 p-3 bg-light" style="position: relative;">
            <div class="fc-canvas w-100">
                <div class="editor-container d-flex" style="height: 400px; border: 1px solid #ced4da; border-radius: 8px; background: #1e1e1e; overflow: hidden;">
                    <div class="line-number text-end pe-3 py-3 select-none text-muted bg-dark border-end border-secondary" id="lineNumber" style="width: 50px; font-family: 'Consolas', monospace; font-size: 14px; line-height: 1.5; color: #858585;">1</div>
                    <textarea id="pseudocode" class="flex-grow-1 bg-dark text-light border-0 p-3" style="font-family: 'Consolas', monospace; font-size: 14px; line-height: 1.5; resize: none; outline: none; white-space: pre; overflow-x: auto;" oninput="updateLineNumber()" onscroll="syncScroll()" spellcheck="false" placeholder="Begin&#10;    input A&#10;    input B&#10;    sum = A + B&#10;    print sum&#10;End"></textarea>
                </div>

                <form id="pseudocodeForm" action="Process_Flowchart.jsp" method="POST">
                    <input type="hidden" name="flowchartData" id="flowchartData">
                    <% if (questionId != null) { %>
                        <input type="hidden" name="questionId" value="<%= questionId %>">
                    <% } %>
                    <% if (mode != null) { %>
                        <input type="hidden" name="mode" value="<%= mode %>">
                    <% } %>

                    <div class="d-flex justify-content-end mt-3">
                        <button type="button" class="btn btn-success px-4 py-2 fw-bold shadow-sm" onclick="submitFlow()">
                            <i class="bi bi-send-fill me-1"></i> Submit & Test Cases
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function updateLineNumber(){
        const textarea = document.getElementById("pseudocode");
        const line = document.getElementById("lineNumber");
        let total = textarea.value.split("\n").length;
        let html = "";
        for(let i = 1; i <= total; i++){
            html += i + "<br>";
        }
        line.innerHTML = html;
    }

    function syncScroll(){
        document.getElementById("lineNumber").scrollTop = document.getElementById("pseudocode").scrollTop;
    }

    window.onload = function(){
        updateLineNumber();
    }

    function submitFlow(){
        const code = document.getElementById("pseudocode").value.trim();
        if(!code){
            alert("กรุณากรอกโค้ด Pseudocode ก่อนกดส่ง");
            return;
        }
        document.getElementById("flowchartData").value = code;
        document.getElementById("pseudocodeForm").submit();
    }
</script>