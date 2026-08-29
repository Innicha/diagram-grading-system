<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="3" />

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
        <!-- สามารถใช้ Bootstrap data-bs-toggle="collapse" เพื่อให้คลิกพับได้ -->
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

                    <div class="line-number" id="lineNumber">
        1
                    </div>

                     <textarea
                        id="pseudocode"
                        oninput="updateLineNumber()"
                        onscroll="syncScroll()"
                        spellcheck="false"></textarea>

                </div>

                <form action="processFlowchart.jsp" method="POST">

                    <input
                        type="hidden"
                        name="flowchartData"
                        id="flowchartData">

                    <div class="submit-box">

                        <button
                            type="button"
                            class="btn btn-success"
                            onclick="submitFlow()">
                            Submit
                        </button>

                    </div>

                </form>

            </div>

        </div>

    </div>

</div>

<script>

function updateLineNumber(){

    const textarea=document.getElementById("pseudocode");
    const line=document.getElementById("lineNumber");

    let total=textarea.value.split("\n").length;

    let html="";

    for(let i=1;i<=total;i++){

        html+=i+"<br>";

    }

    line.innerHTML=html;

}

function syncScroll(){

    document.getElementById("lineNumber").scrollTop=
    document.getElementById("pseudocode").scrollTop;

}

window.onload=function(){

    updateLineNumber();

}

function submitFlow(){

    document.getElementById("flowchartData").value=
    document.getElementById("pseudocode").value;

    document.forms[0].submit();

}

</script>