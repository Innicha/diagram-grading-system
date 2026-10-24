<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="2" />

<!-- Google Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<!-- Stylesheets -->
<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/pages/ERdiagram.css">

<mytag:check_login /> 

<%
    String Link = request.getAttribute("Loadfile5") != null ? request.getAttribute("Loadfile5").toString() : ""; 
%>

<style>
    /* ปรับ Layout ให้เต็มหน้าจออัตโนมัติ */
    html, body {
        height: 100%;
        margin: 0;
        overflow: hidden; 
    }
    .main-container {
        display: flex;
        flex-direction: column;
        height: 100vh;
        padding: 20px;
    }

    #flowchart-wrapper {
        display: flex !important;
        flex-grow: 1 !important; 
        border: 2px solid #cbd5e1 !important;
        border-radius: 12px !important;
        background: #fff !important;
        overflow: hidden !important;
        position: relative;
        transition: all 0.3s ease;
    }
    
    #flowchart-wrapper:fullscreen {
        height: 100vh !important;
        border: none !important;
        border-radius: 0 !important;
    }

    .fc-sidebar {
        width: 250px !important;
        min-width: 250px !important;
        border-right: 2px solid #cbd5e1 !important;
        background-color: #f8fafc !important;
        overflow-y: auto !important;
        z-index: 10 !important;
        padding: 15px;
    }

    .fc-canvas-container {
        flex-grow: 1 !important;
        display: flex !important;
        flex-direction: column !important;
        position: relative !important;
        overflow: hidden !important;
    }

    .fc-toolbar {
        display: flex !important;
        justify-content: space-between !important;
        align-items: center !important;
        padding: 12px 20px !important;
        background: #ffffff !important;
        border-bottom: 2px solid #cbd5e1 !important;
        z-index: 10 !important;
        box-shadow: 0 4px 10px rgba(0,0,0,0.03) !important;
    }

    .fc-scroll-area {
        flex-grow: 1 !important;
        overflow: auto !important;
        position: relative !important;
        background-color: #f1f5f9 !important;
        background-image: radial-gradient(#cbd5e1 1px, transparent 1px) !important;
        background-size: 20px 20px !important;
    }

    #fc-canvas {
        width: 4000px !important;
        height: 4000px !important;
        position: relative !important;
        background: transparent !important;
    }

    .fc-submit-area {
        position: absolute !important;
        bottom: 25px !important;
        right: 25px !important;
        z-index: 100 !important;
    }

    .fc-tool-line {
        padding: 8px 15px;
        margin-bottom: 5px;
        border-radius: 6px;
        cursor: pointer;
        transition: 0.2s;
        border: 1px solid #e2e8f0;
        background: #fff;
        color: #334155;
        font-size: 14px;
        text-align: left;
    }
    .fc-tool-line:hover { background: #f1f5f9; }
    .fc-tool-line.active {
        background: #eff6ff;
        border-color: #3b82f6;
        color: #1d4ed8;
        font-weight: 600;
    }
</style>

<div class="main-container">
    
    <div class="page-header d-flex align-items-center justify-content-between mb-3">
        <h3 class="mb-0 fw-bold" style="color: #1e3a8a;">สร้าง ER Diagram</h3>
    </div>

    <!-- ฟอร์มซ่อนไว้สำหรับส่งข้อมูล -->
    <form action="Process_ERdiagram.jsp" method="POST" id="erDiagramForm" style="display: none;">
        <input type="hidden" name="questionId" id="questionId" value="<%= request.getParameter("questionId") == null ? "" : request.getParameter("questionId").replaceAll("[^0-9]", "") %>">
        <input type="hidden" name="erDiagramData" id="erDiagramData">
    </form>

    <div class="flowchart-wrapper" id="flowchart-wrapper">
        
        <!-- แถบด้านซ้าย -->
        <div class="fc-sidebar">
            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-2">องค์ประกอบตาราง</div>
            <div class="fc-shape" data-type="entity" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">Entity</span></div>
            </div>
            <div class="fc-shape" data-type="weakEntity" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">Weak Entity</span></div>
            </div>
            <div class="fc-shape" data-type="attribute" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">Attribute</span></div>
            </div>
            <div class="fc-shape" data-type="multiValuedAttribute" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">Multi-valued</span></div>
            </div>
            <div class="fc-shape" data-type="derivedAttribute" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">Derived</span></div>
            </div>

            <hr class="text-muted my-3">

            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-2">คีย์หลักและคีย์นอก</div>
            <div class="fc-shape" data-type="primaryKey" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text"><u>PK_Attribute</u></span></div>
            </div>
            <div class="fc-shape" data-type="foreignKey" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">FK_Attribute</span></div>
            </div>

            <hr class="text-muted my-3">

            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-2">ความสัมพันธ์</div>
            <div class="fc-shape" data-type="relationship" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">Relation</span></div>
            </div>
            <div class="fc-shape" data-type="identifyingRelationship" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">Identifying</span></div>
            </div>

            <hr class="text-muted my-3">

            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-2">เครื่องมือเชื่อมเส้น</div>
            <div class="fc-tool-line" onclick="selectLineTool('normal')" id="tool-normal">➔ เส้นธรรมดา</div>
            <div class="fc-tool-line" onclick="selectLineTool('1')" id="tool-1">➔ เส้นความสัมพันธ์ "1"</div>
            <div class="fc-tool-line" onclick="selectLineTool('M')" id="tool-M">➔ เส้นความสัมพันธ์ "M"</div>
            <div class="fc-tool-line" onclick="selectLineTool('N')" id="tool-N">➔ เส้นความสัมพันธ์ "N"</div>
        </div>

        <!-- พื้นที่ Canvas ด้านขวา -->
        <div class="fc-canvas-container">
            <div class="fc-toolbar">
                <span class="fw-semibold text-secondary">
                    <i class="bi bi-hand-index-thumb me-1"></i> เลือกลากกล่องมาวาง หรือคลิกที่เส้นเพื่อลบ
                </span>
                <div>
                    <button type="button" class="btn btn-outline-primary btn-sm me-2 shadow-sm" onclick="toggleFullscreen()">
                        <i class="bi bi-arrows-fullscreen"></i> เต็มจอ
                    </button>
                    <button type="button" class="btn btn-outline-danger btn-sm shadow-sm" onclick="clearCanvasData()">
                        <i class="bi bi-trash"></i> ล้างกระดานใหม่
                    </button>
                </div>
            </div>

            <div class="fc-scroll-area" id="fc-scroll-area">
                <div class="fc-canvas" id="fc-canvas" ondrop="fcDrop(event)" ondragover="fcAllowDrop(event)">
                    <svg id="fc-svg" style="width:100%; height:100%; position:absolute; top:0; left:0; pointer-events:none; z-index:1;"></svg>
                </div>
            </div>

            <div class="fc-submit-area">
                <button type="button" class="btn btn-success btn-lg px-4 shadow" id="fc-submitBtn" onclick="submitERDiagram()">
                    <i class="bi bi-send-fill me-1"></i> Submit
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    let connections = []; 
    let nodeSequence = 0;
    let selectedNode = null; 
    let selectedConnectionIndex = null; // เพิ่มตัวแปรจำว่าเลือกเส้นไหนอยู่
    let isConnectMode = false; 
    let currentLineType = null; 

    // เพิ่มดักกดปุ่ม Delete ลบเส้น
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Delete' || e.key === 'Backspace') {
            if (document.activeElement.isContentEditable) return; 
            
            if (selectedNode) {
                e.preventDefault(); 
                connections = connections.filter(conn => conn.from !== selectedNode && conn.to !== selectedNode);
                selectedNode.remove();
                selectedNode = null;
                drawLines(); 
            } else if (selectedConnectionIndex !== null) {
                // ส่วนลบเส้นที่ถูกคลิก
                e.preventDefault();
                connections.splice(selectedConnectionIndex, 1);
                selectedConnectionIndex = null;
                drawLines();
            }
        }
    });

    document.getElementById("fc-scroll-area").addEventListener('click', function(e) {
        if (e.target.id === 'fc-canvas' || e.target.id === 'fc-svg' || e.target.id === 'fc-scroll-area') {
            deselectNode();
            deselectConnection(); // ยกเลิกการเลือกเส้นเมื่อกดพื้นที่ว่าง
        }
    });

    function selectLineTool(type) {
        deselectNode();
        deselectConnection();
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

    function deselectNode() {
        if (selectedNode) {
            selectedNode.style.boxShadow = ""; 
            selectedNode.style.borderColor = ""; 
            selectedNode = null;
        }
    }

    function deselectConnection() {
        if (selectedConnectionIndex !== null) {
            selectedConnectionIndex = null;
            drawLines();
        }
    }

    function selectConnection(index) {
        deselectNode();
        selectedConnectionIndex = index;
        drawLines();
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
        newNode.setAttribute("data-node-id", "er-node-" + (++nodeSequence));
        newNode.style.position = "absolute";
        newNode.style.zIndex = "5";
        newNode.innerHTML = `<div class="fc-text-wrapper"><span class="fc-text">${text}</span></div>`;

        const rect = canvas.getBoundingClientRect();
        let offsetX = 55;
        let offsetY = 24;
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
        let isDragging = false;
        let textSpan = elmnt.querySelector('.fc-text');
        let startMouseX = 0;
        let startMouseY = 0;
        let startLeft = 0;
        let startTop = 0;
        let mouseMoveHandler = null;
        let mouseUpHandler = null;

        elmnt.style.cursor = "grab";

        elmnt.ondblclick = function(e) {
            e.stopPropagation();
            textSpan.contentEditable = "true";
            textSpan.focus();
            elmnt.style.cursor = "text";
            deselectNode();
            deselectConnection();
        };

        textSpan.onblur = function() {
            this.contentEditable = "false";
            formatForeignKeyText(elmnt);
            elmnt.style.cursor = "grab";
        };

        elmnt.onmousedown = function(e) {
            if (textSpan.contentEditable === "true") return;
            if (e.button !== 0) return;
            e.preventDefault();
            e.stopPropagation();
            isDragging = false;
            startMouseX = e.clientX;
            startMouseY = e.clientY;
            startLeft = parseFloat(elmnt.style.left) || 0;
            startTop = parseFloat(elmnt.style.top) || 0;
            elmnt.style.transition = "none";
            elmnt.style.cursor = "grabbing";

            mouseMoveHandler = function(ev) { elementDrag(ev); };
            mouseUpHandler = function(ev) { closeDragElement(ev); };

            document.addEventListener("mousemove", mouseMoveHandler);
            document.addEventListener("mouseup", mouseUpHandler);
        };

        function elementDrag(e) {
            e.preventDefault();
            const dx = e.clientX - startMouseX;
            const dy = e.clientY - startMouseY;
            if (Math.abs(dx) > 3 || Math.abs(dy) > 3) {
                isDragging = true;
            }
            elmnt.style.left = (startLeft + dx) + "px";
            elmnt.style.top = (startTop + dy) + "px";
            if (isDragging) {
                drawLines();
            }
        }

        function closeDragElement(e) {
            document.removeEventListener("mousemove", mouseMoveHandler);
            document.removeEventListener("mouseup", mouseUpHandler);
            mouseMoveHandler = null;
            mouseUpHandler = null;
            elmnt.style.transition = "";
            elmnt.style.cursor = "grab";

            if (isDragging) {
                drawLines();
                return;
            }

            if (isConnectMode) {
                if (!selectedNode) {
                    selectedNode = elmnt;
                    elmnt.style.borderColor = "#e11d48";
                    elmnt.style.boxShadow = "0 0 0 4px rgba(225, 29, 72, 0.15)";
                } else if (selectedNode !== elmnt) {
                    let lineLabel = "";
                    if (currentLineType && currentLineType !== 'normal') {
                        lineLabel = currentLineType;
                    }

                    connections.push({ from: selectedNode, to: elmnt, label: lineLabel });
                    deselectNode();
                    drawLines();
                } else {
                    deselectNode();
                }
            } else {
                deselectNode();
                deselectConnection();
                selectedNode = elmnt;
                elmnt.style.borderColor = "#3b82f6";
                elmnt.style.boxShadow = "0 0 0 4px rgba(59, 130, 246, 0.2)";
            }
        }
    }

    function drawLines() {
        const svg = document.getElementById("fc-svg");
        Array.from(svg.children).forEach(child => {
            if (child.tagName.toLowerCase() !== 'defs') {
                svg.removeChild(child);
            }
        });

        const canvasRect = document.getElementById("fc-canvas").getBoundingClientRect();

        connections.forEach((conn, index) => {
            const rect1 = conn.from.getBoundingClientRect();
            const rect2 = conn.to.getBoundingClientRect();
            
            const x1 = rect1.left - canvasRect.left + (rect1.width / 2);
            const y1 = rect1.top - canvasRect.top + (rect1.height / 2);
            const x2 = rect2.left - canvasRect.left + (rect2.width / 2);
            const y2 = rect2.top - canvasRect.top + (rect2.height / 2);

            const isSelected = (index === selectedConnectionIndex);
            const strokeColor = isSelected ? '#ff0000' : '#1e3a8a';
            const strokeWidth = isSelected ? '3' : '2';

            const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
            line.setAttribute('x1', x1);
            line.setAttribute('y1', y1);
            line.setAttribute('x2', x2);
            line.setAttribute('y2', y2);
            line.setAttribute('stroke', strokeColor);
            line.setAttribute('stroke-width', strokeWidth);
            line.style.pointerEvents = "stroke"; 
            line.style.cursor = "pointer";
            line.onclick = (e) => { e.stopPropagation(); selectConnection(index); };
            svg.appendChild(line);

            if (conn.label) {
                const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                const midX = (x1 + x2) / 2;
                const midY = (y1 + y2) / 2;
                
                text.setAttribute('x', midX);
                text.setAttribute('y', midY - 8);
                text.setAttribute('text-anchor', 'middle');
                text.setAttribute('fill', isSelected ? '#ff0000' : '#0284c7');
                text.setAttribute('font-weight', 'bold');
                text.setAttribute('font-size', '16px'); 
                text.textContent = conn.label;
                text.style.textShadow = "2px 2px 0 #fff, -1px -1px 0 #fff, 1px -1px 0 #fff, -1px 1px 0 #fff";
                text.style.pointerEvents = "auto"; 
                text.style.cursor = "pointer";
                text.onclick = (e) => { e.stopPropagation(); selectConnection(index); };
                svg.appendChild(text);
            }
        });
    }

    function serializeERDiagram() {
        const canvas = document.getElementById("fc-canvas");

        const nodes = Array.from(canvas.querySelectorAll(".fc-node")).map(node => ({
            id: node.dataset.nodeId,
            type: node.dataset.type || "",
            text: (node.querySelector(".fc-text")?.textContent || "").trim(),
            x: parseFloat(node.style.left) || 0,
            y: parseFloat(node.style.top) || 0
        }));

        const edges = connections
            .filter(conn => conn.from && conn.to &&
                canvas.contains(conn.from) && canvas.contains(conn.to))
            .map((conn, index) => ({
                id: "er-edge-" + (index + 1),
                from: conn.from.dataset.nodeId,
                to: conn.to.dataset.nodeId,
                label: conn.label || ""
            }));

        return {
            version: 1,
            nodes: nodes,
            edges: edges
        };
    }

    function submitERDiagram() {
        const questionId = document.getElementById("questionId").value.trim();
        const data = serializeERDiagram();

        if (!questionId) {
            alert("ไม่พบรหัสโจทย์ (questionId) กรุณาเปิดหน้านี้จากโจทย์ ER Diagram");
            return;
        }

        if (data.nodes.length === 0) {
            alert("กรุณาวาด ER Diagram ก่อนบันทึก");
            return;
        }

        const nodeIds = new Set(data.nodes.map(node => node.id));
        const invalidEdge = data.edges.some(edge =>
            !nodeIds.has(edge.from) || !nodeIds.has(edge.to)
        );
        if (invalidEdge) {
            alert("พบเส้นเชื่อมที่อ้างอิงโหนดไม่ถูกต้อง กรุณาตรวจสอบแผนภาพ");
            return;
        }

        document.getElementById("erDiagramData").value = JSON.stringify(data);
        document.getElementById("fc-submitBtn").disabled = true;
        document.getElementById("erDiagramForm").submit();
    }

    async function toggleFullscreen() {
        const elem = document.getElementById("flowchart-wrapper");
        if (!elem) return;
        try {
            if (!document.fullscreenElement) {
                if (elem.requestFullscreen) await elem.requestFullscreen();
                else if (elem.webkitRequestFullscreen) elem.webkitRequestFullscreen();
            } else {
                if (document.exitFullscreen) await document.exitFullscreen();
                else if (document.webkitExitFullscreen) document.webkitExitFullscreen();
            }
        } catch (error) {
            console.error("ไม่สามารถเปลี่ยนโหมดเต็มจอได้:", error);
        }
    }

    function clearCanvasData() {
        if (confirm("ต้องการล้างกระดานและเริ่มวาดใหม่ทั้งหมดใช่หรือไม่?")) {
            location.reload();
        }
    }

    function formatForeignKeyText(elmnt) {
        const textSpan = elmnt.querySelector(".fc-text");
        if (!textSpan) return;
        if (elmnt.getAttribute("data-type") !== "foreignKey") return;
        let text = textSpan.textContent.trim();
        text = text.replace(/\s*\(fk\)\s*$/i, "");
        if (text !== "") {
            textSpan.textContent = text + " (fk)";
        }
    }
</script>