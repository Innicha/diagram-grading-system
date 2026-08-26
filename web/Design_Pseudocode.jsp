<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="5" />

<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/pages/Pseudocode.css">

<!-- Check Login -->
<mytag:check_login />

<%
    String Link = request.getAttribute("Loadfile5").toString();
%>

<div class="card mt-4 mb-4">

    <div class="card-header bg-dark text-white">
        ระบบสร้าง Pseudocode
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