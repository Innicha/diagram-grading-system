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
    
    <div class="page-header mb-4 text-start">
        <h3 class="fw-bold mb-2" style="color: #1e3a8a;">
            สร้าง Pseudocode
        </h3>
        <span class="fw-semibold text-secondary">
            <i class="bi bi-code-square me-1"></i> เขียนคำสั่ง Pseudocode ด้านล่างเพื่อแปลงและทดสอบกับ Test Cases
        </span>
    </div>

    <div class="card shadow-sm border-0 rounded-4 p-4 bg-white">
        <div class="flowchart-wrapper" style="position: relative;">
            <div class="fc-canvas w-100">
                
                <div class="editor-container d-flex shadow-sm" style="height: 450px; border: 1px solid #cbd5e1; border-radius: 8px; background: #ffffff; overflow: hidden;">
                    <!-- ส่วนตัวเลขบรรทัด -->
                    <div class="line-number text-end pe-3 py-3 select-none border-end" id="lineNumber" style="width: 55px; background-color: #f8fafc; border-color: #cbd5e1 !important; font-family: 'Consolas', monospace; font-size: 15px; line-height: 1.6; color: #64748b;">1</div>
                    <!-- พื้นที่พิมพ์โค้ด (แก้ oninput เป็น handleInput() เพื่อให้เซฟด้วย) -->
                    <textarea id="pseudocode" class="flex-grow-1 border-0 p-3" style="background-color: #ffffff; color: #1e293b; font-family: 'Consolas', monospace; font-size: 15px; line-height: 1.6; resize: none; outline: none; white-space: pre; overflow-x: auto;" oninput="handleInput()" onscroll="syncScroll()" spellcheck="false" placeholder="Begin&#10;    input A&#10;    input B&#10;    sum = A + B&#10;    print sum&#10;End"></textarea>
                </div>

                <form id="pseudocodeForm" action="Process_Flowchart.jsp" method="POST">
                    <input type="hidden" name="flowchartData" id="flowchartData">
                    <% if (questionId != null) { %>
                        <input type="hidden" name="questionId" value="<%= questionId %>">
                    <% } %>
                    <% if (mode != null) { %>
                        <input type="hidden" name="mode" value="<%= mode %>">
                    <% } %>

                    <div class="d-flex justify-content-between mt-4">
                        <small class="text-success fw-bold align-self-center" id="saveStatus" style="opacity: 0; transition: opacity 0.3s;">
                            <i class="bi bi-cloud-check-fill me-1"></i> บันทึกข้อมูลร่างอัตโนมัติแล้ว
                        </small>
                        <button type="button" class="btn btn-success px-4 py-2 fs-6 fw-bold shadow-sm" onclick="submitFlow()">
                            <i class="bi bi-send-fill me-2"></i> Submit & Test Cases
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    // สร้าง Key สำหรับบันทึกข้อมูล แยกตามรหัสข้อ
    const draftKey = "pseudocode_draft_<%= questionId != null ? questionId : "default" %>";
    let saveTimeout;

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

    // ฟังก์ชันทำงานเวลาพิมพ์ข้อความ (อัปเดตบรรทัด + เซฟลง LocalStorage)
    function handleInput() {
        updateLineNumber();
        
        const currentCode = document.getElementById("pseudocode").value;
        localStorage.setItem(draftKey, currentCode);

        // แสดงสถานะว่าเซฟแล้ว
        const status = document.getElementById("saveStatus");
        status.style.opacity = "1";
        clearTimeout(saveTimeout);
        saveTimeout = setTimeout(() => {
            status.style.opacity = "0";
        }, 2000);
    }

    // ดักจับการกดปุ่ม Tab
    document.getElementById('pseudocode').addEventListener('keydown', function(e) {
        if (e.key === 'Tab') {
            e.preventDefault(); 
            
            const start = this.selectionStart;
            const end = this.selectionEnd;

            // แทรกเว้นวรรค 4 ช่อง
            this.value = this.value.substring(0, start) + "    " + this.value.substring(end);

            this.selectionStart = this.selectionEnd = start + 4;
            
            handleInput(); // เซฟออโต้ทันทีหลังกด Tab
        }
    });

    // ตอนโหลดหน้าเว็บ ให้เช็คว่ามีโค้ดเก่าที่เซฟไว้ไหม ถ้ามีให้ดึงมาแสดง
    window.onload = function(){
        const savedCode = localStorage.getItem(draftKey);
        if (savedCode !== null && savedCode !== "") {
            document.getElementById("pseudocode").value = savedCode;
        }
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