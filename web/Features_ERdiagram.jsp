<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="3" />
<link rel="stylesheet" href="css/CreateAssignment/CenterLayout.css">
<link rel="stylesheet" href="css/global.css">
<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/pages/ERdiagram.css">
<!-- Check Login File -->
<mytag:check_login />  

<%
    String Link = request.getAttribute("Loadfile5").toString();  
%>


<!-- ============================================== -->
<!-- พื้นที่ด้านบนสำหรับใส่โจทย์ (Task Header) -->
<!-- ============================================== -->
<!-- <div class="card mt-3">
    <div class="er-task-header">
        <h5> โจทย์: การออกแบบ ER Diagram สำหรับระบบจัดการข้อมูล</h5>
        <p class="mb-0 text-muted">
            ให้นักเรียนลากรูปทรงจากแถบด้านซ้ายมาวางบนพื้นที่ทำงาน จากนั้นใช้ <strong>"โหมดเชื่อมเส้น"</strong> เพื่อเชื่อมต่อความสัมพันธ์ระหว่าง Entity, Attribute และ Relationship ให้ถูกต้อง (ดับเบิ้ลคลิกที่กล่องเพื่อแก้ไขข้อความ)
        </p>
    </div>
</div> -->

<!-- ============================================== -->
<!-- ระบบสร้าง ER Diagram -->
<!-- ============================================== -->
<div class="card mt-3 mb-4">
    <div class="card-header bg-dark text-white">ระบบสร้าง ER Diagram</div>
    <div class="card-body p-0">
        <div class="flowchart-wrapper">
            <!-- แถบด้านซ้าย (Shapes) -->
            <div class="fc-sidebar">
                <div class="fc-shape" data-type="entity" draggable="true" ondragstart="fcDrag(event)">
                    <div class="fc-text-wrapper"><span class="fc-text">Entity</span></div>
                </div>

                <div class="fc-shape" data-type="attribute" draggable="true" ondragstart="fcDrag(event)">
                    <div class="fc-text-wrapper"><span class="fc-text">Attribute</span></div>
                </div>

                <div class="fc-shape" data-type="relationship" draggable="true" ondragstart="fcDrag(event)">
                    <div class="fc-text-wrapper"><span class="fc-text">Relation</span></div>
                </div>

                <div class="fc-shape" data-type="weakEntity" draggable="true" ondragstart="fcDrag(event)">
                    <div class="fc-text-wrapper"><span class="fc-text">Weak Entity</span>
                    </div>
                </div>

                <div class="fc-shape" data-type="identifyingRelationship" draggable="true" ondragstart="fcDrag(event)">
                    <div class="fc-text-wrapper"><span class="fc-text">Identifying</span>
                    </div>
                </div>
            </div>

            <!-- พื้นที่ Canvas ด้านขวา (ไม่มีลายตาราง) -->
            <div class="fc-canvas" id="fc-canvas" ondrop="fcDrop(event)" ondragover="fcAllowDrop(event)">
                
                <div class="fc-toolbar">
                    <span class="fw-bold">ลากกล่องมาวาง ➔</span>
                    <button type="button" class="btn btn-primary btn-sm ms-3" id="connectModeBtn" onclick="toggleConnectMode()">🔗 เปิดโหมดเชื่อมเส้น</button>
                </div>
                
                <svg id="fc-svg">
                    <defs>
                        <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                            <polygon points="0 0, 10 3.5, 0 7" fill="#333" />
                        </marker>
                    </defs>
                </svg>

                <form action="processFlowchart.jsp" method="POST" id="flowchartForm">
                    <input type="hidden" name="flowchartData" id="flowchartData">
                    <button type="button" class="btn btn-success" id="fc-submitBtn" onclick="submitFlow()">Submit Diagram</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- ============================================== -->
<!-- Script สำหรับ ER Diagram -->
<!-- ============================================== -->
<script>
    let connections = []; 
    let selectedNode = null; 
    let isConnectMode = false; 

    // กดปุ่ม Delete / Backspace เพื่อลบกล่อง
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

    function toggleConnectMode() {
        isConnectMode = !isConnectMode;
        const btn = document.getElementById("connectModeBtn");
        deselectNode(); 

        if (isConnectMode) {
            btn.className = "btn btn-danger btn-sm ms-3";
            btn.innerHTML = "❌ ปิดโหมดเชื่อมเส้น";
        } else {
            btn.className = "btn btn-primary btn-sm ms-3";
            btn.innerHTML = "🔗 เปิดโหมดเชื่อมเส้น";
        }
    }

    function deselectNode() {
        if (selectedNode) {
            selectedNode.style.boxShadow = "2px 2px 5px rgba(0,0,0,0.1)"; 
            selectedNode = null;
        }
    }

    function fcAllowDrop(ev) { ev.preventDefault(); }

    function fcDrag(ev) {
        ev.dataTransfer.setData("type", ev.target.getAttribute('data-type'));
        let textElem = ev.target.querySelector('.fc-text');
        ev.dataTransfer.setData("text", textElem ? textElem.innerText : "Text");
    }

    function fcDrop(ev) {
        ev.preventDefault();
        const type = ev.dataTransfer.getData("type");
        const text = ev.dataTransfer.getData("text");
        const canvas = document.getElementById("fc-canvas");

        const newNode = document.createElement("div");
        newNode.className = "fc-shape fc-node";
        newNode.setAttribute("data-type", type);
        newNode.innerHTML = `<div class="fc-text-wrapper"><span class="fc-text">${text}</span></div>`;

        const rect = canvas.getBoundingClientRect();
        newNode.style.left = (ev.clientX - rect.left - 40) + "px"; 
        newNode.style.top = (ev.clientY - rect.top - 20) + "px";

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
            elmnt.style.cursor = "move";
        };

        elmnt.onmousedown = function(e) {
            if(textSpan.contentEditable === "true") return; 
            e.stopPropagation();
            
            if (isConnectMode) {
                if (!selectedNode) {
                    selectedNode = elmnt;
                    elmnt.style.boxShadow = "0 0 10px red"; 
                } else if (selectedNode !== elmnt) {
                    
                    let lineLabel = "";
                    // ถ้าโหนดต้นทางเป็น Relationship (ข้าวหลามตัด) ให้ถาม Cardinality (1, M, N)
                    if (selectedNode.getAttribute("data-type") === "relationship") {
                        let userInput = prompt("ระบุอัตราส่วนความสัมพันธ์ (เช่น 1, M, N):", "1");
                        if (userInput === null) {
                            deselectNode();
                            return;
                        }
                        lineLabel = userInput;
                    }

                    connections.push({ from: selectedNode, to: elmnt, label: lineLabel }); 
                    deselectNode();
                    drawLines();
                } else {
                    deselectNode(); 
                }
            } 
            else {
                deselectNode();
                selectedNode = elmnt;
                elmnt.style.boxShadow = "0 0 10px #0d6efd"; 

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
        }
    }

    function drawLines() {
        const svg = document.getElementById("fc-svg");
        const defs = svg.querySelector('defs').outerHTML;
        svg.innerHTML = defs; 

        const canvasRect = document.getElementById("fc-canvas").getBoundingClientRect();

        connections.forEach(conn => {
            const rect1 = conn.from.getBoundingClientRect();
            const rect2 = conn.to.getBoundingClientRect();

            const x1 = rect1.left - canvasRect.left + (rect1.width / 2);
            const y1 = rect1.top - canvasRect.top + (rect1.height / 2);
            const x2 = rect2.left - canvasRect.left + (rect2.width / 2);
            const y2 = rect2.top - canvasRect.top + (rect2.height / 2);

            // สร้างเส้นเชื่อม
            const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
            line.setAttribute('x1', x1);
            line.setAttribute('y1', y1);
            line.setAttribute('x2', x2);
            line.setAttribute('y2', y2);
            line.setAttribute('stroke', '#333');
            line.setAttribute('stroke-width', '2');
            svg.appendChild(line);

            // ใส่ข้อความ (1, M, N) บนเส้น
            if (conn.label) {
                const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                const midX = (x1 + x2) / 2;
                const midY = (y1 + y2) / 2;
                
                text.setAttribute('x', midX);
                text.setAttribute('y', midY - 8);
                text.setAttribute('text-anchor', 'middle');
                text.setAttribute('fill', '#d9534f');
                text.setAttribute('font-weight', 'bold');
                text.setAttribute('font-size', '14px');
                text.textContent = conn.label;
                text.style.textShadow = "2px 2px 0 #fff, -1px -1px 0 #fff, 1px -1px 0 #fff, -1px 1px 0 #fff";
                
                svg.appendChild(text);
            }
        });
    }

    function submitFlow() {
        alert("บันทึก ER Diagram เรียบร้อยแล้ว");
    }
</script>