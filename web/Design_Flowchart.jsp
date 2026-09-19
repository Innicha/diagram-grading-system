<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="3" />

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/pages/flowchart.css">

<mytag:check_login />  

<%
    String Link = request.getAttribute("Loadfile5") != null ? request.getAttribute("Loadfile5").toString() : "";  
%>

<div class="container-fluid p-4" style="min-height: 100vh; overflow-y: auto;">
    
    <div class="page-header d-flex align-items-center mb-4">
        <button type="button" class="btn btn-outline-primary btn-sm px-3 shadow-sm bg-white me-3" onclick="window.location.href='DesignAnswerkeys.jsp'">
            <i class="bi bi-arrow-left me-1"></i>กลับ
        </button>
        <h3 class="mb-0 fw-bold" style="color: #1e3a8a;">สร้าง Flowchart </h3>
    </div>

    <div class="flowchart-wrapper">
        
        <div class="fc-sidebar">
            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-3">องค์ประกอบ</div>

            <div class="fc-shape fc-pill" data-type="start" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">Start/End</span></div></div>
            <div class="fc-shape fc-rect-green" data-type="process" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">Process</span></div></div>
            <div class="fc-shape fc-parallelogram" data-type="input" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">Input/Output</span></div></div>
            <div class="fc-shape fc-display" data-type="display" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">Display</span></div></div>
            <div class="fc-shape fc-diamond" data-type="decision" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">Decision</span></div></div>
            <div class="fc-shape fc-circle" data-type="connector" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">A</span></div></div>
            
            <div class="fc-sidebar-divider"></div>
            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-3">เครื่องมือเชื่อมเส้น</div>
            
            <div class="fc-tool-line" onclick="selectLineTool('normal')" id="tool-normal">➔ เส้นธรรมดา</div>
            <div class="fc-tool-line" onclick="selectLineTool('yes')" id="tool-yes">➔ เส้น Yes</div>
            <div class="fc-tool-line" onclick="selectLineTool('no')" id="tool-no">➔ เส้น No</div>
            <div class="fc-tool-line" onclick="selectLineTool('loop')" id="tool-loop">➔ เส้น Loop (ตีคู่ขนาน)</div>
        </div>

        <div class="fc-canvas" id="fc-canvas" ondrop="fcDrop(event)" ondragover="fcAllowDrop(event)">
            
            <div class="fc-toolbar">
                <span class="fw-semibold text-secondary">
                    <i class="bi bi-hand-index-thumb me-1"></i> เลือกลากกล่องมาวาง หรือคลิกที่เส้นเพื่อลบ
                </span>
                <button type="button" class="btn btn-outline-danger btn-sm" onclick="clearCanvasData()">
                    <i class="bi bi-trash"></i> ล้างกระดานใหม่
                </button>
            </div>
            
            <svg id="fc-svg" style="width:100%; height:100%; position:absolute; top:0; left:0; pointer-events:none; z-index:1;">
                <defs>
                    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                        <polygon points="0 0, 10 3.5, 0 7" fill="#333" />
                    </marker>
                </defs>
            </svg>

            <div class="fc-submit-area">
                <button type="button" class="btn btn-success btn-lg px-4 shadow" onclick="submitFlowchart()">
                    <i class="bi bi-send-fill me-1"></i> Submit & Convert
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    let connections = []; 
    let selectedNode = null; 
    let selectedConnectionIndex = null; 
    let isConnectMode = false; 
    let currentLineType = null; 

    function fcAllowDrop(ev) { ev.preventDefault(); }

    function fcDrag(ev) {
        ev.dataTransfer.setData("type", ev.target.getAttribute('data-type') || ev.target.closest('.fc-shape').getAttribute('data-type'));
        let textElem = ev.target.querySelector('.fc-text') || ev.target.closest('.fc-shape').querySelector('.fc-text');
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
        newNode.setAttribute("data-type", type);
        newNode.style.position = "absolute";
        newNode.style.zIndex = "5"; 
        newNode.style.margin = "0";
        newNode.innerHTML = `<div class="fc-text-wrapper"><span class="fc-text">${text}</span></div>`;

        const rect = canvas.getBoundingClientRect();
        let offsetX = 70, offsetY = 22;
        if (type === 'connector') { offsetX = 25; offsetY = 25; }
        if (type === 'decision') { offsetX = 32; offsetY = 32; }

        newNode.style.left = (ev.clientX - rect.left - offsetX) + "px"; 
        newNode.style.top = (ev.clientY - rect.top - offsetY) + "px";

        makeFcInteractive(newNode);
        canvas.appendChild(newNode);
    }

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
                e.preventDefault();
                connections.splice(selectedConnectionIndex, 1);
                selectedConnectionIndex = null;
                drawLines();
            }
        }
    });

    document.getElementById("fc-canvas").addEventListener('click', function(e) {
        if (e.target.id === 'fc-canvas' || e.target.id === 'fc-svg') {
            deselectNode();
            deselectConnection();
        }
    });

    function deselectNode() {
        if (selectedNode) { selectedNode.style.boxShadow = "2px 2px 5px rgba(0,0,0,0.15)"; selectedNode = null; }
    }
    function deselectConnection() {
        if (selectedConnectionIndex !== null) { selectedConnectionIndex = null; drawLines(); }
    }
    function selectConnection(index) { deselectNode(); selectedConnectionIndex = index; drawLines(); }

    function makeFcInteractive(elmnt) {
        let isDragging = false;
        let textSpan = elmnt.querySelector('.fc-text');
        let offsetX = 0, offsetY = 0;

        elmnt.ondblclick = function(e) {
            e.stopPropagation();
            textSpan.contentEditable = "true";
            textSpan.focus();
            elmnt.style.cursor = "text";
            deselectNode(); deselectConnection();
        };

        textSpan.onblur = function() { this.contentEditable = "false"; elmnt.style.cursor = "grab"; };

        elmnt.onmousedown = function(e) {
            if(textSpan.contentEditable === "true") return; 
            e.stopPropagation();
            e.preventDefault(); 
            
            if (isConnectMode) {
                if (!selectedNode) {
                    selectedNode = elmnt;
                    elmnt.style.boxShadow = "0 0 15px red"; 
                } else if (selectedNode !== elmnt) {
                    let lineLabel = "";
                    let lineType = currentLineType;
                    if (lineType === 'yes') lineLabel = "Yes";
                    else if (lineType === 'no') lineLabel = "No";
                    else if (lineType === 'loop') lineLabel = "Loop";

                    connections.push({ from: selectedNode, to: elmnt, label: lineLabel, type: lineType }); 
                    deselectNode();
                    drawLines();
                } else {
                    deselectNode(); 
                }
                return; 
            }
            
            elmnt.style.transition = "none";
            isDragging = false;
            let rect = elmnt.getBoundingClientRect();
            let canvasRect = document.getElementById("fc-canvas").getBoundingClientRect();
            offsetX = e.clientX - rect.left;
            offsetY = e.clientY - rect.top;

            document.onmousemove = function(e) {
                e.preventDefault();
                isDragging = true;
                elmnt.style.left = (e.clientX - canvasRect.left - offsetX) + "px";
                elmnt.style.top = (e.clientY - canvasRect.top - offsetY) + "px";
                drawLines();
            };

            document.onmouseup = function() {
                document.onmousemove = null;
                document.onmouseup = null;
                elmnt.style.transition = "";
                
                if (!isDragging) {
                    deselectNode(); deselectConnection();
                    selectedNode = elmnt;
                    elmnt.style.boxShadow = "0 0 15px blue"; 
                }
            };
        };
    }

    function drawLines() {
        const svg = document.getElementById("fc-svg");
        Array.from(svg.children).forEach(child => {
            if (child.tagName.toLowerCase() !== 'defs') svg.removeChild(child);
        });

        const canvasRect = document.getElementById("fc-canvas").getBoundingClientRect();

        connections.forEach((conn, index) => {
            const rect1 = conn.from.getBoundingClientRect();
            const rect2 = conn.to.getBoundingClientRect();
            const x1 = rect1.left - canvasRect.left + (rect1.width / 2);
            const y1 = rect1.top - canvasRect.top + (rect1.height / 2);
            const x2 = rect2.left - canvasRect.left + (rect2.width / 2);
            const y2 = rect2.top - canvasRect.top + (rect2.height / 2);

            let textX, textY;
            const isSelected = (index === selectedConnectionIndex);
            const strokeColor = isSelected ? '#ff0000' : (conn.type === 'loop' ? '#f39c12' : '#333');
            const strokeWidth = isSelected ? '3' : '2';

            if (conn.type === 'loop') {
                let dx = x2 - x1, dy = y2 - y1;
                let len = Math.sqrt(dx * dx + dy * dy) || 1;
                let nx = -dy / len, ny = dx / len, offset = 40;
                let loopX1 = x1 + (nx * offset), loopY1 = y1 + (ny * offset);
                let loopX2 = x2 + (nx * offset), loopY2 = y2 + (ny * offset);

                const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
                line.setAttribute('x1', loopX1); line.setAttribute('y1', loopY1);
                line.setAttribute('x2', loopX2); line.setAttribute('y2', loopY2);
                line.setAttribute('stroke', strokeColor); line.setAttribute('stroke-width', strokeWidth);
                line.setAttribute('stroke-dasharray', '5,5'); 
                if (!isSelected) line.setAttribute('marker-end', 'url(#arrowhead)');
                line.style.pointerEvents = "stroke"; line.style.cursor = "pointer";
                line.onclick = (e) => { e.stopPropagation(); selectConnection(index); };
                svg.appendChild(line);
                textX = (loopX1 + loopX2) / 2; textY = (loopY1 + loopY2) / 2;
            } else {
                const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
                line.setAttribute('x1', x1); line.setAttribute('y1', y1);
                line.setAttribute('x2', x2); line.setAttribute('y2', y2);
                line.setAttribute('stroke', strokeColor); line.setAttribute('stroke-width', strokeWidth);
                if (!isSelected) line.setAttribute('marker-end', 'url(#arrowhead)');
                line.style.pointerEvents = "stroke"; line.style.cursor = "pointer";
                line.onclick = (e) => { e.stopPropagation(); selectConnection(index); };
                svg.appendChild(line);
                textX = (x1 + x2) / 2; textY = (y1 + y2) / 2;
            }

            if (conn.label) {
                const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                text.setAttribute('x', textX); text.setAttribute('y', textY - 10); 
                text.setAttribute('text-anchor', 'middle');
                if (conn.type === 'yes') text.setAttribute('fill', '#2ecc71'); 
                else if (conn.type === 'no') text.setAttribute('fill', '#e74c3c'); 
                else if (conn.type === 'loop') text.setAttribute('fill', '#f39c12'); 
                else text.setAttribute('fill', '#333'); 
                text.setAttribute('font-weight', 'bold');
                text.setAttribute('font-size', '14px');
                text.textContent = conn.label;
                text.style.textShadow = "2px 2px 0 #fff, -1px -1px 0 #fff, 1px -1px 0 #fff, -1px 1px 0 #fff";
                text.style.pointerEvents = "auto"; text.style.cursor = "pointer";
                text.onclick = (e) => { e.stopPropagation(); selectConnection(index); };
                svg.appendChild(text);
            }
        });
    }

    function clearCanvasData() {
        if (confirm("ต้องการล้างกระดานและเริ่มวาดใหม่ทั้งหมดใช่หรือไม่?")) {
            location.reload();
        }
    }

    function submitFlowchart() {
        const canvas = document.getElementById("fc-canvas");
        const nodeElements = canvas.querySelectorAll(".fc-node");
        
        if (nodeElements.length === 0) {
            alert("กรุณาวาด Flowchart ก่อนกดส่งครับ");
            return;
        }

        let nodes = [];
        let nodeMap = new Map(); 

        nodeElements.forEach((elmnt, index) => {
            let nodeId = "node_" + index; 
            nodeMap.set(elmnt, nodeId);   
            nodes.push({
                id: nodeId,
                type: elmnt.getAttribute("data-type"),
                text: elmnt.querySelector(".fc-text").innerText.trim()
            });
        });

        let edges = [];
        connections.forEach(conn => {
            if (nodeMap.has(conn.from) && nodeMap.has(conn.to)) {
                edges.push({
                    from: nodeMap.get(conn.from),
                    to: nodeMap.get(conn.to),    
                    label: conn.label || "",
                    type: conn.type || "normal"
                });
            }
        });

        let flowchartPayload = JSON.stringify({ nodes: nodes, edges: edges });

        // ⭐ สร้าง Form ซ่อนเพื่อส่งข้อมูล วิธีนี้พอกดปุ่มกลับจากหน้า Process 
        // เบราว์เซอร์จะดึงหน้าวาดล่าสุดจากความจำ History มาแสดงให้เองแบบสมบูรณ์ 100%
        let form = document.createElement("form");
        form.method = "POST";
        form.action = "Process_Flowchart.jsp"; 
        
        let input = document.createElement("input");
        input.type = "hidden";
        input.name = "flowchartData";
        input.value = flowchartPayload;
        
        form.appendChild(input);
        document.body.appendChild(form);
        
        form.submit(); 
    }
</script>