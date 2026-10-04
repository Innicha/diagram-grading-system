<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="2" />

<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/pages/Pseudocode.css">

<!-- Check Login -->
<mytag:check_login />

<%
    String Link = request.getAttribute("Loadfile5").toString();
%>

<div class="card mt-4 mb-4">

    <div class="d-flex align-items-center justify-content-between mb-4 mt-2">
        <div class="d-flex align-items-center gap-3">
            <a href="DesignAnswerkeys.jsp" class="btn btn-outline-primary btn-back"><i class="bi bi-arrow-left me-1"></i>กลับ</a>
            <h3 class="mb-0 fw-bold" style="color: #1a3c7c;">สร้าง Pseudocode</h3>
        </div>
    </div>
    
    <div class="card shadow-sm border-0 mb-4 rounded-3">
        <div class="card-header bg-white border-0 py-3 d-flex justify-content-between align-items-center" style="cursor: pointer;" data-bs-toggle="collapse" data-bs-target="#questionCollapse">
            <h6 class="mb-0 text-dark fw-bold">
                <span class="text-primary me-2">📄</span> โจทย์ปัญหา / คำถาม (Question)
            </h6>
            <span class="text-muted">˅</span>
        </div>
        <div class="collapse show" id="questionCollapse">
            <div class="card-body pt-0 pb-3 px-4">
                <div class="p-3 rounded-2" style="background-color: #f2f7ff; border: 1px solid #d5e5fb;">
                    <div class="text-primary fw-bold mb-1" style="font-size: 14px;">
                        <span class="me-1">🏢</span> โจทย์: Pseudocode
                    </div>
                    <div class="text-secondary" style="font-size: 13.5px;">
                        ให้คุณเขียน Pseudocode ตามโจทย์ที่กำหนด โดยสามารถใช้ตัวแปรและโครงสร้างควบคุมต่าง ๆ ได้ตามความเหมาะสม
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="card-body p-0">
        <div class="flowchart-wrapper">
            <div class="fc-canvas">

                <!-- Editor -->
                <div class="editor-container">
                    <div class="line-number" id="lineNumber">1</div>
                     <textarea
                        id="pseudocode"
                        oninput="updateLineNumber()"
                        onscroll="syncScroll()"
                        spellcheck="false"
                        placeholder="พิมพ์ Pseudocode ที่นี่..."></textarea>
                </div>

                <!-- กล่องแสดงผลลัพธ์ Terminal -->
                <div id="terminalContainer" style="display: none; padding: 0 20px 20px 20px;">
                    <label class="fw-bold text-success mb-2"><i class="bi bi-terminal-fill me-1"></i> ผลลัพธ์การรัน (Console Output):</label>
                    <textarea id="runOutput" class="form-control" style="background-color: #1e1e1e; color: #4ec9b0; font-family: 'Consolas', 'Courier New', monospace; height: 150px; resize: vertical;" readonly></textarea>
                </div>

                <form id="pseudoForm" action="processFlowchart.jsp" method="POST">
                    <input type="hidden" name="flowchartData" id="flowchartData">

                    <div class="submit-box d-flex justify-content-end gap-2" style="padding: 0 20px 20px 20px;">
                        <button type="button" class="btn btn-warning fw-bold text-dark shadow-sm" onclick="runPseudocode()">
                            <i class="bi bi-play-fill me-1"></i> ลองรันโค้ด
                        </button>
                        <button type="button" class="btn btn-success fw-bold shadow-sm" onclick="submitFlow()">
                            Submit
                        </button>
                    </div>
                </form>

            </div>
        </div>
    </div>

</div>

<script>
    // ==========================================
    // 1. ฟังก์ชันจัดหน้าตา Editor (เลขบรรทัด)
    // ==========================================
    function updateLineNumber(){
        const textarea = document.getElementById("pseudocode");
        const line = document.getElementById("lineNumber");
        let total = textarea.value.split("\n").length;
        let html = "";
        for(let i=1; i<=total; i++){ html += i + "<br>"; }
        line.innerHTML = html;
    }

    function syncScroll(){
        document.getElementById("lineNumber").scrollTop = document.getElementById("pseudocode").scrollTop;
    }

    window.onload = function(){ updateLineNumber(); }

    function submitFlow(){
        document.getElementById("flowchartData").value = document.getElementById("pseudocode").value;
        document.getElementById("pseudoForm").submit();
    }

    // ==========================================
    // 2. ฟังก์ชันแปลง Pseudocode เป็น JavaScript (นำมารวมไว้ในนี้เลย)
    // ==========================================
    function convertPseudocodeToJS(pseudoText) {
        if (!pseudoText || pseudoText.includes("❌") || pseudoText.trim() === "") {
            return "// ❌ ไม่สามารถแปลงได้ กรุณาตรวจสอบข้อมูลอีกครั้ง";
        }
        let lines = pseudoText.split('\n');
        let jsLines = [];
        let declaredVars = new Set(); 

        lines.forEach(line => {
            let trimmed = line.trim();
            let indentMatch = line.match(/^\s*/);
            let indent = indentMatch ? indentMatch[0] : ""; 
            if (indent.length >= 4) indent = indent.substring(4); 

            if (trimmed === "Begin" || trimmed === "End") { return; } 
            else if (/^input/i.test(trimmed)) {
                let varName = trimmed.replace(/^input\s+/i, '').trim();
                if (!declaredVars.has(varName)) {
                    jsLines.push(indent + "let " + varName + " = Number(prompt('Enter " + varName + ":'));");
                    declaredVars.add(varName);
                } else {
                    jsLines.push(indent + varName + " = Number(prompt('Enter " + varName + ":'));");
                }
            } 
            else if (/^(print|output)/i.test(trimmed)) {
                let textToPrint = trimmed.replace(/^(print|output)\s+/i, '').trim();
                jsLines.push(indent + "console.log(" + textToPrint + ");");
            } 
            else if (/^if\s*\(/i.test(trimmed)) { jsLines.push(indent + trimmed + " {"); } 
            else if (/^else\s+if\s*\(/i.test(trimmed)) { jsLines.push(indent + "} " + trimmed + " {"); } 
            else if (trimmed.toLowerCase() === "else") { jsLines.push(indent + "} else {"); } 
            else if (trimmed.toLowerCase() === "endif") { jsLines.push(indent + "}"); } 
            else if (/^while\s*\(/i.test(trimmed)) { jsLines.push(indent + trimmed + " {"); } 
            else if (trimmed.toLowerCase() === "endwhile") { jsLines.push(indent + "}"); } 
            else if (trimmed !== "") {
                let assignMatch = trimmed.match(/^([a-zA-Z_]\w*)\s*=/);
                if (assignMatch && !trimmed.includes("==") && !trimmed.includes("+=") && !trimmed.includes("-=")) {
                    let vName = assignMatch[1];
                    if (!declaredVars.has(vName)) {
                        jsLines.push(indent + "let " + trimmed + ";"); 
                        declaredVars.add(vName);
                    } else { jsLines.push(indent + trimmed + ";"); }
                } else { jsLines.push(indent + trimmed + ";"); }
            }
        });
        return jsLines.join('\n').trim();
    }

    function executeJavaScriptCode(jsCode) {
        if (!jsCode || jsCode.includes("❌") || jsCode.startsWith("//")) return "⚠️ กรุณากดรันใหม่";
        let logs = [];
        let fakeConsole = { log: function(...args) { logs.push(args.join(' ')); } };
        try {
            let runFn = new Function('console', jsCode);
            runFn(fakeConsole);
            return logs.length > 0 ? logs.join('\n') : "⚠️ โค้ดรันสำเร็จ แต่ไม่มีการแสดงผล (ไม่มีคำสั่ง console.log)";
        } catch (error) {
            return "❌ เกิดข้อผิดพลาดในการคอมไพล์:\n" + error.message;
        }
    }

    // ==========================================
    // 3. ฟังก์ชันกดปุ่ม "ลองรันโค้ด"
    // ==========================================
    function runPseudocode() {
        let pseudoText = document.getElementById("pseudocode").value;
        let terminalContainer = document.getElementById("terminalContainer");
        let runOutput = document.getElementById("runOutput");

        if (pseudoText.trim() === "") {
            alert("กรุณาพิมพ์ Pseudocode ก่อนกดรันครับ");
            return;
        }

        terminalContainer.style.display = "block";
        runOutput.style.color = "#f39c12"; 
        runOutput.value = "กำลังประมวลผล...\n(⏳ หากโค้ดมีคำสั่ง input โปรดมองหาหน้าต่าง Popup ที่ด้านบนของจอเพื่อกรอกตัวเลข!)";

        setTimeout(() => {
            try {
                let jsCode = convertPseudocodeToJS(pseudoText);
                if (jsCode.includes("❌")) {
                    runOutput.value = jsCode; 
                    runOutput.style.color = "#ff6b6b"; 
                    return;
                }

                let executionResult = executeJavaScriptCode(jsCode);
                runOutput.value = executionResult;
                
                if (executionResult.includes("❌")) {
                    runOutput.style.color = "#ff6b6b"; 
                } else {
                    runOutput.style.color = "#4ec9b0"; 
                }
            } catch (err) {
                runOutput.value = "❌ ระบบขัดข้อง: " + err.message;
                runOutput.style.color = "#ff6b6b";
            }
        }, 150); 
    }
</script>