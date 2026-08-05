<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="5" />
<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/pages/flowchart.css">
<!-- Check Login File -->
<mytag:check_login />  

<%
    String Link = request.getAttribute("Loadfile5").toString();  
%>


<!-- ============================================== -->
<!-- ระบบสร้าง Pseudocode -->
<!-- ============================================== -->
<div class="card mt-4 mb-4">
    <div class="card-header bg-dark text-white">ระบบสร้าง Pseudocode
    </div>
    <div class="card-body p-0">
        <div class="flowchart-wrapper">
            <!-- แถบด้านซ้าย -->

            <!-- พื้นที่ Canvas ด้านขวา -->
            <div class="fc-canvas" id="fc-canvas" ondrop="fcDrop(event)" ondragover="fcAllowDrop(event)">
                <svg id="fc-svg">
                    <defs>
                        <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                            <polygon points="0 0, 10 3.5, 0 7" fill="#333" />
                        </marker>
                    </defs>
                </svg>

                <form action="processFlowchart.jsp" method="POST" id="flowchartForm">
                    <input type="hidden" name="flowchartData" id="flowchartData">
                    <button type="button" class="btn btn-success" id="fc-submitBtn" onclick="submitFlow()">Submit</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- ============================================== -->
<!-- Script สำหรับ Flowchart -->
<!-- ============================================== -->
<script>

    function submitFlow() {
        alert("ทดสอบปุ่ม Submit Flowchart");
    }
</script>