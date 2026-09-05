<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="3" />
<link rel="stylesheet" href="css/CreateAssignment/CenterLayout.css">
<link rel="stylesheet" href="css/global.css">
<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/pages/flowchart.css">
<!-- Check Login File -->
<mytag:check_login />  

<%
    String Link = request.getAttribute("Loadfile5").toString();  
%>

<!-- ============================================== -->
<!-- CSS สำหรับ Layout ทั้งหมด -->
<!-- ============================================== -->


<!-- เริ่มต้น Container สำหรับหน้าเว็บ -->
<div class="container-fluid px-4 py-3">

    <!-- ============================================== -->
    <!-- หัวข้อหน้าเว็บ (Header แบบเดียวกับ ER) -->
    <!-- ============================================== -->
    <div class="d-flex align-items-center justify-content-between mb-4 mt-2">
        <div class="d-flex align-items-center gap-3">
            <a href="DesignAnswerkeys.jsp" class="btn btn-outline-primary btn-back"><i class="bi bi-arrow-left me-1"></i>กลับ</a>
            <h3 class="mb-0 fw-bold" style="color: #1a3c7c;">สร้าง Flowchart</h3>
        </div>
    </div>

    <!-- ============================================== -->
    <!-- กล่องโจทย์ปัญหา (Question Box) -->
    <!-- ============================================== -->
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
                        <span class="me-1">🏢</span> โจทย์: การออกแบบผังงาน (Flowchart)
                    </div>
                    <div class="text-secondary" style="font-size: 13.5px;">
                        ให้นักเรียนลากรูปทรงจากแถบด้านซ้ายมาวางบนพื้นที่ทำงาน จากนั้นใช้ "เครื่องมือเชื่อมเส้น" ที่ด้านล่างของเมนู เพื่อเชื่อมต่อขั้นตอนการทำงานให้ถูกต้อง (ดับเบิ้ลคลิกที่กล่องเพื่อแก้ไขข้อความ)
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ============================================== -->
    <!-- ระบบสร้าง Flowchart (พื้นที่ทำงาน) -->
    <!-- ============================================== -->
    <div class="card shadow-sm border-0 rounded-3 overflow-hidden mb-5">
        <div class="card-body p-0">
            <div class="flowchart-wrapper">
                <!-- แถบด้านซ้าย -->
                <div class="fc-sidebar">
                    <div class="fc-sidebar-item"><div class="fc-shape fc-pill" draggable="true" ondragstart="fcDrag(event)" data-type="start"><div class="fc-text-wrapper"><span class="fc-text">Start/End</span></div></div></div>
                    <div class="fc-sidebar-item"><div class="fc-shape fc-rect-green" draggable="true" ondragstart="fcDrag(event)" data-type="process"><div class="fc-text-wrapper"><span class="fc-text">Process</span></div></div></div>
                    <div class="fc-sidebar-item"><div class="fc-shape fc-parallelogram" draggable="true" ondragstart="fcDrag(event)" data-type="input"><div class="fc-text-wrapper"><span class="fc-text">Input/Output</span></div></div></div>
                    <div class="fc-sidebar-item"><div class="fc-shape fc-display" draggable="true" ondragstart="fcDrag(event)" data-type="display"><div class="fc-text-wrapper"><span class="fc-text">Display</span></div></div></div>
                    <div class="fc-sidebar-item"><div class="fc-shape fc-diamond" draggable="true" ondragstart="fcDrag(event)" data-type="decision"><div class="fc-text-wrapper"><span class="fc-text">Decision</span></div></div></div>
                    <div class="fc-sidebar-item"><div class="fc-shape fc-circle" draggable="true" ondragstart="fcDrag(event)" data-type="connector"><div class="fc-text-wrapper"><span class="fc-text">A</span></div></div></div>
                    
                    <!-- ส่วนเลือกประเภทของเส้น -->
                    <div class="fc-sidebar-divider"></div>
                    <div style="font-size:14px; color:#555; text-align:center; font-weight:bold; margin-bottom:15px;">เครื่องมือเชื่อมเส้น</div>
                    <div class="fc-tool-line" onclick="selectLineTool('normal')" id="tool-normal">➔ เส้นธรรมดา</div>
                    <div class="fc-tool-line" onclick="selectLineTool('yes')" id="tool-yes">➔ เส้น Yes</div>
                    <div class="fc-tool-line" onclick="selectLineTool('no')" id="tool-no">➔ เส้น No</div>
                    <div class="fc-tool-line" onclick="selectLineTool('loop')" id="tool-loop">➔ เส้น Loop </div>
                </div>

                <!-- พื้นที่ Canvas ด้านขวา -->
                <div class="fc-canvas" id="fc-canvas" ondrop="fcDrop(event)" ondragover="fcAllowDrop(event)">
                    
                    <!-- คอนเทนเนอร์ปุ่ม Submit ขวาล่าง -->
                    <div class="fc-submit-area">
                        <form action="Design_Flowchart.jsp" method="POST" id="flowchartForm" class="d-flex gap-2">
                            <input type="hidden" name="flowchartData" id="flowchartData">
                            <button type="button" class="btn btn-success btn-lg px-4 shadow" id="fc-submitBtn" onclick="submitFlow()">
                                <span class="me-1">📤</span> Submit
                            </button>
                        </form>
                    </div>
                    
                    <!-- วาดเส้นเชื่อมที่นี่ -->
                    <svg id="fc-svg" style="width:100%; height:100%; position:absolute; top:0; left:0; pointer-events:none; z-index:1;">
                        <defs>
                            <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                                <polygon points="0 0, 10 3.5, 0 7" fill="#333" />
                            </marker>
                        </defs>
                    </svg>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ============================================== -->
<!-- Script สำหรับ Flowchart -->
<!-- ============================================== -->
<script>
    let connections = []; 
    let selectedNode = null; 
    let isConnectMode = false; 
    let currentLineType = null; 

    function selectLineTool(type) {
        deselectNode();
        if (currentLineType === type) {
            currentLineType = null;
            isConnectMode = false;
        } else {
            currentLineType = type;
            isConnectMode = true;
        }
        
        document.querySelectorAll('.fc-tool-line').forEach(el => el.classList.remove('active'));
        if (currentLineType) {
            document.getElementById('tool-' + currentLineType).classList.add('active');
            document.getElementById('fc-canvas').style.cursor = 'crosshair'; 
        } else {
            document.getElementById('fc-canvas').style.cursor = 'default';
        }
    }

    document.addEventListener('keydown', function(e) {
        if ((e.key === 'Delete' || e.key === 'Backspace') && selectedNode) {
            if (document.activeElement.isContentEditable) return; 
            e.preventDefault(); 
            connections = connections.filter(conn => conn.from !== selectedNode && conn.to !== selectedNode);
            selectedNode.remove();
            selectedNode = null;
            drawLines(); 
        }
    });

    document.getElementById("fc-canvas").addEventListener('click', function(e) {
        if (e.target.id === 'fc-canvas' || e.target.id === 'fc-svg') {
            deselectNode();
        }
    });

    function deselectNode() {
        if (selectedNode) {
            selectedNode.style.boxShadow = "2px 2px 5px rgba(0,0,0,0.15)"; 
            selectedNode = null;
        }
    }

    function fcAllowDrop(ev) { ev.preventDefault(); }

    function fcDrag(ev) {
        ev.dataTransfer.setData("type", ev.target.closest('.fc-shape').getAttribute('data-type'));
        let textElem = ev.target.closest('.fc-shape').querySelector('.fc-text');
        ev.dataTransfer.setData("text", textElem ? textElem.innerText : "Text");
    }

    function fcDrop(ev) {
        ev.preventDefault();
        const type = ev.dataTransfer.getData("type");
        const text = ev.dataTransfer.getData("text");
        const canvas = document.getElementById("fc-canvas");

        const newNode = document.createElement("div");
        let shapeClass = "fc-shape fc-node ";
        
        if (type === 'start') shapeClass += "fc-pill";
        else if (type === 'process') shapeClass += "fc-rect-green";
        else if (type === 'input') shapeClass += "fc-parallelogram";
        else if (type === 'display') shapeClass += "fc-display";
        else if (type === 'decision') shapeClass += "fc-diamond";
        else if (type === 'connector') shapeClass += "fc-circle";

        newNode.className = shapeClass;
        newNode.style.position = "absolute";
        newNode.style.zIndex = "2"; 
        newNode.innerHTML = `<div class="fc-text-wrapper"><span class="fc-text">${text}</span></div>`;

        const rect = canvas.getBoundingClientRect();
        
        let offsetX = 70;
        let offsetY = 22;
        if (type === 'connector') { offsetX = 25; offsetY = 25; }
        if (type === 'decision') { offsetX = 32; offsetY = 32; }

        newNode.style.left = (ev.clientX - rect.left - offsetX) + "px"; 
        newNode.style.top = (ev.clientY - rect.top - offsetY) + "px";

        makeFcInteractive(newNode);
        canvas.appendChild(newNode);
    }

    function makeFcInteractive(elmnt) {
        var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
        let textSpan = elmnt.querySelector('.fc-text');

        elmnt.ondblclick = function(e) {
            e.stopPropagation();
            textSpan.contentEditable = "true";
            textSpan.focus();
            elmnt.style.cursor = "text";
            deselectNode(); 
        };
        textSpan.onblur = function() {
            this.contentEditable = "false";
            elmnt.style.cursor = "grab";
        };

        elmnt.onmousedown = function(e) {
            if(textSpan.contentEditable === "true") return; 
            e.stopPropagation();
            
            if (isConnectMode) {
                if (!selectedNode) {
                    selectedNode = elmnt;
                    elmnt.style.boxShadow = "0 0 15px red"; 
                } else if (selectedNode !== elmnt) {
                    let lineLabel = "";
                    if (currentLineType === 'yes') lineLabel = "Yes";
                    else if (currentLineType === 'no') lineLabel = "No";
                    else if (currentLineType === 'loop') lineLabel = "Loop";

                    connections.push({ from: selectedNode, to: elmnt, label: lineLabel, type: currentLineType }); 
                    
                    deselectNode();
                    drawLines();
                } else {
                    deselectNode(); 
                }
            } else {
                deselectNode();
                selectedNode = elmnt;
                elmnt.style.boxShadow = "0 0 15px blue"; 
                elmnt.style.cursor = "grabbing";

                e.preventDefault();
                pos3 = e.clientX;
                pos4 = e.clientY;
                document.onmouseup = closeDragElement;
                document.onmousemove = elementDrag;
            }
        };

        function elementDrag(e) {
            e.preventDefault();
            pos1 = pos3 - e.clientX;
            pos2 = pos4 - e.clientY;
            pos3 = e.clientX;
            pos4 = e.clientY;
            elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
            elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
            drawLines();
        }

        function closeDragElement() {
            document.onmouseup = null;
            document.onmousemove = null;
            elmnt.style.cursor = "grab";
        }
    }

    function drawLines() {
        const svg = document.getElementById("fc-svg");
        
        // วิธีเคลียร์เส้นเก่าที่เสถียรกว่า (ไม่ทำให้ tag path บัค)
        Array.from(svg.children).forEach(child => {
            if (child.tagName.toLowerCase() !== 'defs') {
                svg.removeChild(child);
            }
        });

        const canvasRect = document.getElementById("fc-canvas").getBoundingClientRect();

        connections.forEach(conn => {
            const rect1 = conn.from.getBoundingClientRect();
            const rect2 = conn.to.getBoundingClientRect();

            // คำนวณจุดกึ่งกลางของกล่องต้นทางและปลายทาง
            const x1 = rect1.left - canvasRect.left + (rect1.width / 2);
            const y1 = rect1.top - canvasRect.top + (rect1.height / 2);
            const x2 = rect2.left - canvasRect.left + (rect2.width / 2);
            const y2 = rect2.top - canvasRect.top + (rect2.height / 2);

            let textX, textY;

            if (conn.type === 'loop') {
                const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
                
                // คำนวณให้เส้นหักมุมออกไปทางขวา 120px จากกล่องที่อยู่ขวาสุด
                let offsetX = Math.max(x1, x2) + 120; 
                
                // ลากเส้นแบบหักมุม: ออกขวา (L) -> ขึ้น/ลง (L) -> กลับเข้าซ้าย (L)
                path.setAttribute('d', `M ${x1},${y1} L ${offsetX},${y1} L ${offsetX},${y2} L ${x2},${y2}`);
                path.setAttribute('stroke', '#333');
                path.setAttribute('stroke-width', '2');
                path.setAttribute('fill', 'none');
                path.setAttribute('stroke-dasharray', '5,5'); // ทำให้เป็นเส้นประ
                path.setAttribute('marker-end', 'url(#arrowhead)');
                svg.appendChild(path);

                // ตำแหน่งตัวหนังสือให้อยู่ตรงกลางเส้นแนวตั้งขวาสุด
                textX = offsetX;
                textY = (y1 + y2) / 2;
            } else {
                // วาดเส้นตรงสำหรับเส้นธรรมดา, Yes, No
                const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
                line.setAttribute('x1', x1);
                line.setAttribute('y1', y1);
                line.setAttribute('x2', x2);
                line.setAttribute('y2', y2);
                line.setAttribute('stroke', '#333');
                line.setAttribute('stroke-width', '2');
                line.setAttribute('marker-end', 'url(#arrowhead)');
                svg.appendChild(line);

                textX = (x1 + x2) / 2;
                textY = (y1 + y2) / 2;
            }

            // จัดการตัวหนังสือบนเส้น
            if (conn.label) {
                const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                text.setAttribute('x', textX);
                text.setAttribute('y', textY - 10); 
                text.setAttribute('text-anchor', 'middle');
                
                if (conn.type === 'yes') text.setAttribute('fill', '#2ecc71'); 
                else if (conn.type === 'no') text.setAttribute('fill', '#e74c3c'); 
                else if (conn.type === 'loop') text.setAttribute('fill', '#f39c12'); 
                else text.setAttribute('fill', '#333'); 

                text.setAttribute('font-weight', 'bold');
                text.setAttribute('font-size', '14px');
                text.textContent = conn.label;
                
                // ขอบขาวให้ตัวหนังสืออ่านง่าย
                text.style.textShadow = "2px 2px 0 #fff, -1px -1px 0 #fff, 1px -1px 0 #fff, -1px 1px 0 #fff, 1px 1px 0 #fff";
                
                svg.appendChild(text);
            }
        });
    }

    function submitFlow() {
        alert("ทดสอบปุ่ม Submit Flowchart");
    }
</script>