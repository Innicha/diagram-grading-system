<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="3" />

<!-- Google Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<!-- Stylesheets -->
<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/pages/ERdiagram.css">
<link rel="stylesheet" href="css/AnswerKeyPages/AnswerKey_ERDiagram.css">

<mytag:check_login />  

<%
    String Link = request.getAttribute("Loadfile5") != null ? request.getAttribute("Loadfile5").toString() : "";  
%>

<div class="container-fluid p-4" style="min-height: 100vh; overflow-y: auto;">
    
    <!-- ส่วน Header (ปุ่มกลับ และ ชื่อหน้า) -->
    <div class="page-header d-flex align-items-center mb-4">
        <!-- เปลี่ยนไฟล์ใน window.location.href ให้ตรงกับที่คุณต้องการกลับไป -->
        <button type="button" class="btn btn-outline-primary btn-sm px-3 shadow-sm bg-white me-3" onclick="window.location.href='DesignAnswerkeys.jsp'">
            <i class="bi bi-arrow-left me-1"></i>กลับ
        </button>
        <h3 class="mb-0 fw-bold" style="color: #1e3a8a;">สร้าง ER Diagram</h3>
    </div>

    <!-- กล่องโจทย์ปัญหา (ใช้คลาส er-task-header จาก CSS ของคุณ) -->
    <div class="er-task-header">
        <h5><i class="bi bi-file-earmark-text-fill"></i> โจทย์ปัญหา / คำถาม (Question)</h5>
        <p>
            <strong>โจทย์: การออกแบบ ER Diagram สำหรับระบบจัดการข้อมูล</strong><br>
            ให้นักเรียนลากรูปทรงจากแถบด้านซ้ายมาวางบนพื้นที่ทำงาน จากนั้นใช้ <b>"โหมดเชื่อมเส้น"</b> 
            เพื่อเชื่อมต่อความสัมพันธ์ระหว่าง Entity, Attribute และ Relationship ให้ถูกต้อง (ดับเบิ้ลคลิกที่กล่องเพื่อแก้ไขข้อความ)
        </p>
    </div>

    <!-- ระบบสร้าง ER Diagram Container (ดึงจากคลาส flowchart-wrapper ของคุณ) -->
    <div class="flowchart-wrapper">
        
        <!-- แถบด้านซ้าย (Sidebar Shapes) -->
        <div class="fc-sidebar">
            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-1">องค์ประกอบ</div>

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
                <div class="fc-text-wrapper"><span class="fc-text">Weak Entity</span></div>
            </div>

            <div class="fc-shape" data-type="identifyingRelationship" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">Identifying</span></div>
            </div>
        </div>

        <!-- พื้นที่ Canvas ด้านขวา -->
        <div class="fc-canvas" id="fc-canvas" ondrop="fcDrop(event)" ondragover="fcAllowDrop(event)">
            
            <div class="fc-toolbar">
                <span class="fw-semibold">
                    <i class="bi bi-hand-index-thumb me-1"></i> ลากกล่องมาวาง ➔
                </span>
                <button type="button" class="btn btn-outline-primary btn-sm ms-2" id="connectModeBtn" onclick="toggleConnectMode()">
                    <i class="bi bi-link-45deg me-1"></i> เปิดโหมดเชื่อมเส้น
                </button>
            </div>
            
            <svg id="fc-svg"></svg>

            <!-- แบบฟอร์มและปุ่ม Submit ของ ER Diagram (จะไปอยู่มุมขวาล่างตาม CSS ของคุณ) -->
            <form action="processERDiagram.jsp" method="POST" id="erDiagramForm">
                <input type="hidden" name="erDiagramData" id="erDiagramData">
                <button type="button" id="fc-submitBtn" onclick="submitERDiagram()">
                    <i class="bi bi-send-fill me-1"></i> Submit
                </button>
            </form>
        </div>
    </div>

</div>

<!-- Script สำหรับ ER Diagram -->
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
            btn.className = "btn btn-danger btn-sm ms-2";
            btn.innerHTML = '<i class="bi bi-x-circle me-1"></i> ปิดโหมดเชื่อมเส้น';
        } else {
            btn.className = "btn btn-outline-primary btn-sm ms-2";
            btn.innerHTML = '<i class="bi bi-link-45deg me-1"></i> เปิดโหมดเชื่อมเส้น';
        }
    }

    function deselectNode() {
        if (selectedNode) {
            // ลบ effect แสงไฟตอนกดออกเพื่อให้กลับไปใช้ hover ตาม css
            selectedNode.style.boxShadow = ""; 
            selectedNode.style.borderColor = ""; 
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
        
        // ทำให้กล่องขยับได้ 100%
        newNode.style.position = "absolute";
        newNode.style.zIndex = "5";
        
        newNode.innerHTML = `<div class="fc-text-wrapper"><span class="fc-text">${text}</span></div>`;

        const rect = canvas.getBoundingClientRect();
        
        // ปรับจุดกึ่งกลางตอนวางให้แม่นยำขึ้นกับขนาดใน CSS
        let offsetX = 55; // ครึ่งนึงของ 110px
        let offsetY = 24; // ครึ่งนึงของ 48px
        
        if (type === 'relationship' || type === 'identifyingRelationship') {
            offsetX = 30; 
            offsetY = 30;
        }

        newNode.style.left = (ev.clientX - rect.left - offsetX) + "px"; 
        newNode.style.top = (ev.clientY - rect.top - offsetY) + "px";

        makeFcInteractive(newNode);
        canvas.appendChild(newNode);
    }

    function makeFcInteractive(elmnt) {
        var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
        let isDragging = false;
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
            if (textSpan.contentEditable === "true") return; 
            e.stopPropagation();
            e.preventDefault(); 

            isDragging = false;
            pos3 = e.clientX;
            pos4 = e.clientY;

            // ⭐ ปิด transition ชั่วคราว ป้องกันเบราว์เซอร์หน่วงการลาก
            elmnt.style.transition = "none";

            document.onmousemove = elementDrag;
            document.onmouseup = closeDragElement;
        };

        function elementDrag(e) {
            e.preventDefault();
            
            if (Math.abs(pos3 - e.clientX) > 2 || Math.abs(pos4 - e.clientY) > 2) {
                isDragging = true;
            }

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

            // ⭐ คืนค่า transition เพื่อให้ effect ตอน hover ทำงานได้ปกติ
            elmnt.style.transition = "";

            if (!isDragging) {
                if (isConnectMode) {
                    if (!selectedNode) {
                        selectedNode = elmnt;
                        elmnt.style.borderColor = "#e11d48";
                        elmnt.style.boxShadow = "0 0 0 4px rgba(225, 29, 72, 0.15)";
                    } else if (selectedNode !== elmnt) {
                        let lineLabel = "";
                        if (selectedNode.getAttribute("data-type") === "relationship" || 
                            selectedNode.getAttribute("data-type") === "identifyingRelationship" || 
                            elmnt.getAttribute("data-type") === "relationship" || 
                            elmnt.getAttribute("data-type") === "identifyingRelationship") {
                            
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
                } else {
                    deselectNode();
                    selectedNode = elmnt;
                    elmnt.style.borderColor = "#3b82f6";
                    elmnt.style.boxShadow = "0 0 0 4px rgba(59, 130, 246, 0.2)";
                }
            }
        }
    }
    function drawLines() {
        const svg = document.getElementById("fc-svg");
        
        // ลบเส้นเก่าออกให้หมดด้วยวิธีที่ปลอดภัย
        Array.from(svg.children).forEach(child => {
            if (child.tagName.toLowerCase() !== 'defs') {
                svg.removeChild(child);
            }
        });

        const canvasRect = document.getElementById("fc-canvas").getBoundingClientRect();

        connections.forEach(conn => {
            const rect1 = conn.from.getBoundingClientRect();
            const rect2 = conn.to.getBoundingClientRect();

            const x1 = rect1.left - canvasRect.left + (rect1.width / 2);
            const y1 = rect1.top - canvasRect.top + (rect1.height / 2);
            const x2 = rect2.left - canvasRect.left + (rect2.width / 2);
            const y2 = rect2.top - canvasRect.top + (rect2.height / 2);

            const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
            line.setAttribute('x1', x1);
            line.setAttribute('y1', y1);
            line.setAttribute('x2', x2);
            line.setAttribute('y2', y2);
            line.setAttribute('stroke', '#1e3a8a');
            line.setAttribute('stroke-width', '2');
            svg.appendChild(line);

            if (conn.label) {
                const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                const midX = (x1 + x2) / 2;
                const midY = (y1 + y2) / 2;
                
                text.setAttribute('x', midX);
                text.setAttribute('y', midY - 8);
                text.setAttribute('text-anchor', 'middle');
                text.setAttribute('fill', '#0284c7');
                text.setAttribute('font-weight', 'bold');
                text.setAttribute('font-size', '14px');
                text.textContent = conn.label;
                text.style.textShadow = "2px 2px 0 #fff, -1px -1px 0 #fff, 1px -1px 0 #fff, -1px 1px 0 #fff";
                
                svg.appendChild(text);
            }
        });
    }

    function submitERDiagram() {
        alert("บันทึก ER Diagram เรียบร้อยแล้ว");
        // โค้ดสำหรับส่งฟอร์มจริงเมื่อพร้อม
        // document.getElementById('erDiagramForm').submit();
    }
</script>