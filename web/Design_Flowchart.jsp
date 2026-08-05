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
<!-- ระบบสร้าง Flowchart -->
<!-- ============================================== -->
<div class="card mt-4 mb-4">
    <div class="card-header bg-dark text-white">ระบบสร้าง Flowchart 
            <a href="CreateAnswerKey_Flowchart.jsp" class="btn btn-info text-white">📝 ไปหน้าสร้างเฉลย</a>
    </div>
    
    <div class="card-body p-0">
        <div class="flowchart-wrapper">
            <!-- แถบด้านซ้าย -->
            <div class="fc-sidebar">
                <div class="fc-shape fc-pill" draggable="true" ondragstart="fcDrag(event)" data-type="start"><div class="fc-text-wrapper"><span class="fc-text">Start/End</span></div></div>
                <div class="fc-shape fc-rect-grey" draggable="true" ondragstart="fcDrag(event)" data-type="grey"><div class="fc-text-wrapper"><span class="fc-text">Process 1</span></div></div>
                <div class="fc-shape fc-rect-blue" draggable="true" ondragstart="fcDrag(event)" data-type="blue"><div class="fc-text-wrapper"><span class="fc-text">Process 2</span></div></div>
                <div class="fc-shape fc-diamond" draggable="true" ondragstart="fcDrag(event)" data-type="decision"><div class="fc-text-wrapper"><span class="fc-text">Decision</span></div></div>
            </div>

            <!-- พื้นที่ Canvas ด้านขวา -->
            <div class="fc-canvas" id="fc-canvas" ondrop="fcDrop(event)" ondragover="fcAllowDrop(event)">
                
                <div class="fc-toolbar">
                    <h3>ลากกล่องมาวาง ➔</h3>
                    <button type="button" class="btn btn-primary btn-sm ms-3" id="connectModeBtn" onclick="toggleConnectMode()">🔗 เปิดโหมดเชื่อมเส้น</button>
                </div>
                
                <svg id="fc-svg">
                    <defs>
                        <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                            <polygon points="0 0, 10 3.5, 0 7" fill="#333" />
                        </marker>
                    </defs>
                </svg>

                <!-- เพิ่มปุ่มไปหน้าสร้างเฉลยไว้ข้างปุ่ม Submit -->
                <form action="processFlowchart.jsp" method="POST" id="flowchartForm" class="d-flex gap-2">
                    <input type="hidden" name="flowchartData" id="flowchartData">
                    <button type="button" class="btn btn-success" id="fc-submitBtn" onclick="submitFlow()">Submit</button>
                    <!-- เปลี่ยน "ชื่อไฟล์หน้าเฉลย.jsp" ให้ตรงกับไฟล์ที่คุณบันทึกไว้ -->
                    
                </form>
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
        let shapeClass = "fc-shape fc-node ";
        if (type === 'start') shapeClass += "fc-pill";
        else if (type === 'grey') shapeClass += "fc-rect-grey";
        else if (type === 'blue') shapeClass += "fc-rect-blue";
        else if (type === 'decision') shapeClass += "fc-diamond";

        newNode.className = shapeClass;
        newNode.innerHTML = `<div class="fc-text-wrapper"><span class="fc-text">${text}</span></div>`;

        const rect = canvas.getBoundingClientRect();
        newNode.style.left = (ev.clientX - rect.left - 50) + "px"; 
        newNode.style.top = (ev.clientY - rect.top - 25) + "px";

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
                    elmnt.style.boxShadow = "0 0 15px red"; 
                } else if (selectedNode !== elmnt) {
                    
                    let lineLabel = "";
                    // เช็คว่าต้นทางเป็น Decision (ข้าวหลามตัด) หรือไม่
                    if (selectedNode.classList.contains("fc-diamond")) {
                        // ถามผู้ใช้ว่าเส้นนี้ชื่ออะไร
                        let userInput = prompt("ระบุเงื่อนไขสำหรับเส้นนี้ (เช่น Yes, No):", "Yes");
                        if (userInput === null) {
                            deselectNode(); // ถ้ายกเลิก ไม่ต้องลากเส้น
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
                elmnt.style.boxShadow = "0 0 15px blue"; 

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
            line.setAttribute('marker-end', 'url(#arrowhead)');
            svg.appendChild(line);

            // ใส่ข้อความ (Yes/No) บนเส้นถ้ามี
            if (conn.label) {
                const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                const midX = (x1 + x2) / 2;
                const midY = (y1 + y2) / 2;
                
                text.setAttribute('x', midX);
                text.setAttribute('y', midY - 10); // ดันให้ตัวหนังสือลอยขึ้นเหนือเส้นนิดนึง
                text.setAttribute('text-anchor', 'middle');
                text.setAttribute('fill', '#e74c3c'); // สีตัวหนังสือ (แดง)
                text.setAttribute('font-weight', 'bold');
                text.setAttribute('font-size', '14px');
                text.textContent = conn.label;
                
                // เพิ่มพื้นหลังสีขาวเล็กๆ ให้ตัวหนังสืออ่านง่ายขึ้น (วาดทับเส้น)
                text.style.textShadow = "2px 2px 0 #fff, -1px -1px 0 #fff, 1px -1px 0 #fff, -1px 1px 0 #fff, 1px 1px 0 #fff";
                
                svg.appendChild(text);
            }
        });
    }

    function submitFlow() {
        alert("ทดสอบปุ่ม Submit Flowchart");
    }
</script>