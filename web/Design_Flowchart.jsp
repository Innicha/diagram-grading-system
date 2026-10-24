<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="db.DBConnection" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<%
    // ⭐ ส่วนที่ 1: ดึงข้อมูล Flowchart เก่าจาก Database (ถ้ามี)
    Object userIdObj = session.getAttribute("UserId");
    String questionIdParam = request.getParameter("questionId");
    String savedFlowchartData = null;

    if (userIdObj != null && questionIdParam != null) {
        try (Connection con = DBConnection.getConnection()) {
            if (con != null) {
                String sql = "SELECT answer_text FROM algorithm_submissions WHERE question_id = ? AND student_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(questionIdParam));
                    ps.setInt(2, Integer.parseInt(userIdObj.toString()));
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            savedFlowchartData = rs.getString("answer_text");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // แปลง JSON ให้ปลอดภัยสำหรับใส่ในตัวแปร JavaScript
    String safeSavedData = "null";
    if (savedFlowchartData != null && !savedFlowchartData.trim().isEmpty()) {
        safeSavedData = savedFlowchartData
            .replace("\\", "\\\\")
            .replace("'", "\\'")
            .replace("\"", "\\\"")
            .replace("\r", "\\r")
            .replace("\n", "\\n")
            .replace("</", "<\\/");
        safeSavedData = "\"" + safeSavedData + "\"";
    }
%>

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

<!-- ⭐ เพิ่ม CSS จัดการหน้าจอเต็มจอและการเลื่อน Scroll -->
<style>
    #flowchart-wrapper {
        display: flex !important;
        height: 75vh !important; 
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
</style>

<div class="container-fluid p-4" style="min-height: 100vh; overflow-y: auto;">
    
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
        <h3 class="mb-0 fw-bold" style="color: #1e3a8a;">
            สร้าง Flowchart
        </h3>
    </div>

    <div class="flowchart-wrapper" id="flowchart-wrapper">
        <div class="fc-sidebar">
            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-3">องค์ประกอบ</div>
            <div class="fc-shape fc-pill" data-type="start" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">Start/End</span></div></div>
            <div class="fc-shape fc-rect-green" data-type="process" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">Process</span></div></div>
            <div class="fc-shape fc-parallelogram" data-type="input" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">Input</span></div></div>
            <div class="fc-shape fc-display" data-type="display" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">Output</span></div></div>
            <div class="fc-shape fc-diamond" data-type="decision" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">Decision</span></div></div>
            <div class="fc-shape fc-circle" data-type="connector" draggable="true" ondragstart="fcDrag(event)"><div class="fc-text-wrapper"><span class="fc-text">A</span></div></div>
            
            <div class="fc-sidebar-divider"></div>
            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-3">เครื่องมือเชื่อมเส้น</div>
            
            <div class="fc-tool-line" onclick="selectLineTool('normal')" id="tool-normal">➔ เส้นธรรมดา</div>
            <div class="fc-tool-line" onclick="selectLineTool('yes')" id="tool-yes">➔ เส้น Yes</div>
            <div class="fc-tool-line" onclick="selectLineTool('no')" id="tool-no">➔ เส้น No</div>
            <div class="fc-tool-line" onclick="selectLineTool('loop')" id="tool-loop">➔ เส้น Loop (เลี้ยวกลับ)</div>
        </div>

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
                    <svg id="fc-svg" style="width:100%; height:100%; position:absolute; top:0; left:0; pointer-events:none; z-index:1;">
                        <defs>
                            <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                                <polygon points="0 0, 10 3.5, 0 7" fill="#333" />
                            </marker>
                            <marker id="arrowhead-selected" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                                <polygon points="0 0, 10 3.5, 0 7" fill="#ff0000" />
                            </marker>
                            <marker id="arrowhead-loop" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                                <polygon points="0 0, 10 3.5, 0 7" fill="#f39c12" />
                            </marker>
                        </defs>
                    </svg>
                </div>
            </div>

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

    // ⭐ ส่วนที่ 2: ฟังก์ชันโหลดข้อมูลเก่ามาระบายบนกระดานเมื่อเปิดเว็บ
    window.onload = function() {
        const savedDataStr = <%= safeSavedData %>;
        if (savedDataStr) {
            try {
                const data = JSON.parse(savedDataStr);
                restoreFlowchart(data);
            } catch(e) {
                console.error("โหลดข้อมูล Flowchart เก่าไม่สำเร็จ:", e);
            }
        }
    };

    function restoreFlowchart(data) {
        if (!data || !data.nodes || !data.edges) return;
        
        const canvas = document.getElementById("fc-canvas");
        const nodeMap = {}; 
        
        // 2.1 วาดกล่องทั้งหมด
        data.nodes.forEach(savedNode => {
            const newNode = document.createElement("div");
            let shapeClass = "fc-shape fc-node ";
            
            if (savedNode.type === 'start') shapeClass += "fc-pill";
            else if (savedNode.type === 'process') shapeClass += "fc-rect-green";
            else if (savedNode.type === 'input') shapeClass += "fc-parallelogram";
            else if (savedNode.type === 'display') shapeClass += "fc-display";
            else if (savedNode.type === 'decision') shapeClass += "fc-diamond";
            else if (savedNode.type === 'connector') shapeClass += "fc-circle";

            newNode.className = shapeClass;
            newNode.setAttribute("data-type", savedNode.type);
            newNode.style.position = "absolute";
            newNode.style.zIndex = "5"; 
            newNode.style.margin = "0";
            
            // ใส่ข้อความเก่า
            newNode.innerHTML = '<div class="fc-text-wrapper"><span class="fc-text">' + (savedNode.text || '') + '</span></div>';

            // ใส่ตำแหน่ง X, Y เก่า
            newNode.style.left = savedNode.x || "100px"; 
            newNode.style.top = savedNode.y || "100px";

            makeFcInteractive(newNode);
            canvas.appendChild(newNode);
            
            nodeMap[savedNode.id] = newNode;
        });

        // 2.2 เชื่อมเส้นทั้งหมด
        data.edges.forEach(savedEdge => {
            const fromNode = nodeMap[savedEdge.from];
            const toNode = nodeMap[savedEdge.to];
            if (fromNode && toNode) {
                connections.push({
                    from: fromNode,
                    to: toNode,
                    label: savedEdge.label || "",
                    type: savedEdge.type || "normal"
                });
            }
        });

        // รอให้กล่องแสดงผลเสร็จค่อยวาดเส้น
        setTimeout(() => {
            drawLines();
        }, 150);
    }

    function toggleFullscreen() {
        let elem = document.getElementById("flowchart-wrapper");
        if (!document.fullscreenElement) {
            if (elem.requestFullscreen) elem.requestFullscreen();
            else if (elem.webkitRequestFullscreen) elem.webkitRequestFullscreen();
            else if (elem.msRequestFullscreen) elem.msRequestFullscreen();
        } else {
            if (document.exitFullscreen) document.exitFullscreen();
            else if (document.webkitExitFullscreen) document.webkitExitFullscreen();
            else if (document.msExitFullscreen) document.msExitFullscreen();
        }
    }

    function fcAllowDrop(ev) { ev.preventDefault(); }

    function fcDrag(ev) {
        ev.dataTransfer.setData("type", ev.target.getAttribute('data-type') || ev.target.closest('.fc-shape').getAttribute('data-type'));
        let textElem = ev.target.querySelector('.fc-text') || ev.target.closest('.fc-shape').querySelector('.fc-text');
        ev.dataTransfer.setData("text", textElem ? textElem.innerText : "Text");
    }

    function fcDrop(ev) {
        ev.preventDefault();
        const type = ev.dataTransfer.getData("type");
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
        newNode.innerHTML = '<div class="fc-text-wrapper"><span class="fc-text"></span></div>';

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

    document.getElementById("fc-scroll-area").addEventListener('click', function(e) {
        if (e.target.id === 'fc-canvas' || e.target.id === 'fc-svg' || e.target.id === 'fc-scroll-area') {
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
            
            const cx1 = rect1.left - canvasRect.left + (rect1.width / 2);
            const cy1 = rect1.top - canvasRect.top + (rect1.height / 2);
            const cx2 = rect2.left - canvasRect.left + (rect2.width / 2);
            const cy2 = rect2.top - canvasRect.top + (rect2.height / 2);

            const angle = Math.atan2(cy2 - cy1, cx2 - cx1);
            const r1 = Math.min(rect1.width, rect1.height) / 2; 
            const r2 = (Math.min(rect2.width, rect2.height) / 2) + 8; 

            const x1 = cx1 + (r1 * Math.cos(angle));
            const y1 = cy1 + (r1 * Math.sin(angle));
            const x2 = cx2 - (r2 * Math.cos(angle));
            const y2 = cy2 - (r2 * Math.sin(angle));

            let textX, textY;
            const isSelected = (index === selectedConnectionIndex);
            
            const strokeColor = isSelected ? '#ff0000' : (conn.type === 'loop' ? '#f39c12' : '#333');
            const strokeWidth = isSelected ? '3' : '2';
            const markerEnd = isSelected ? 'url(#arrowhead-selected)' : (conn.type === 'loop' ? 'url(#arrowhead-loop)' : 'url(#arrowhead)');

            if (conn.type === 'loop') {
                const rightEdge = Math.max(cx1, cx2) + 80; 
                const polyline = document.createElementNS('http://www.w3.org/2000/svg', 'polyline');
                
                const startX = cx1 + (rect1.width / 2);
                const startY = cy1;
                const endX = cx2 + (rect2.width / 2) + 8;
                const endY = cy2;
                
                const points = startX + "," + startY + " " + rightEdge + "," + startY + " " + rightEdge + "," + endY + " " + endX + "," + endY;
                
                polyline.setAttribute('points', points);
                polyline.setAttribute('stroke', strokeColor); 
                polyline.setAttribute('stroke-width', strokeWidth);
                polyline.setAttribute('fill', 'none'); 
                polyline.setAttribute('marker-end', markerEnd);
                
                polyline.style.pointerEvents = "stroke"; 
                polyline.style.cursor = "pointer";
                polyline.onclick = (e) => { e.stopPropagation(); selectConnection(index); };
                
                svg.appendChild(polyline);
                
                textX = rightEdge; 
                textY = (startY + endY) / 2;
            } else {
                const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
                line.setAttribute('x1', x1); line.setAttribute('y1', y1);
                line.setAttribute('x2', x2); line.setAttribute('y2', y2);
                line.setAttribute('stroke', strokeColor); 
                line.setAttribute('stroke-width', strokeWidth);
                line.setAttribute('marker-end', markerEnd);
                
                line.style.pointerEvents = "stroke"; 
                line.style.cursor = "pointer";
                line.onclick = (e) => { e.stopPropagation(); selectConnection(index); };
                svg.appendChild(line);
                textX = (x1 + x2) / 2; textY = (y1 + y2) / 2;
            }

            if (conn.label) {
                const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                
                if (conn.type === 'loop') {
                    text.setAttribute('x', textX + 20); 
                    text.setAttribute('y', textY + 5); 
                } else {
                    text.setAttribute('x', textX); 
                    text.setAttribute('y', textY - 10); 
                }
                
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
            // ล้างข้อมูลหน้าจอและลบ query string ออกให้เริ่มใหม่หมด
            const url = new URL(window.location.href);
            window.location.href = url.pathname + "?questionId=" + url.searchParams.get("questionId") + "&mode=student";
        }
    }

    function submitFlowchart() {
        const canvas = document.getElementById("fc-canvas");
        const nodeElements = canvas.querySelectorAll(".fc-node");

        if (nodeElements.length === 0) {
            alert("กรุณาวาด Flowchart ก่อนกดส่ง");
            return;
        }

        const params = new URLSearchParams(window.location.search);
        const questionId = params.get("questionId");
        const mode = params.get("mode");

        if (mode === "student" && (!questionId || !/^\d+$/.test(questionId))) {
            alert("ไม่พบรหัสโจทย์ กรุณากลับไปเลือกโจทย์ใหม่");
            return;
        }

        const nodes = [];
        const nodeMap = new Map();

        // ⭐ ส่วนที่ 3: แก้ไขตอนบันทึกให้จำตำแหน่ง X, Y แกนด้วย
        nodeElements.forEach((element, index) => {
            const nodeId = "node_" + index;
            nodeMap.set(element, nodeId);

            const textElement = element.querySelector(".fc-text");

            nodes.push({
                id: nodeId,
                type: element.getAttribute("data-type"),
                text: textElement ? textElement.innerText.trim() : "",
                x: element.style.left, // จำพิกัดแกน X 
                y: element.style.top   // จำพิกัดแกน Y
            });
        });

        const edges = [];

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

        const form = document.createElement("form");
        form.method = "POST";
        form.action = "Process_Flowchart.jsp";

        function addHiddenInput(name, value) {
            const input = document.createElement("input");
            input.type = "hidden";
            input.name = name;
            input.value = value;
            form.appendChild(input);
        }

        addHiddenInput("flowchartData", JSON.stringify({
            nodes: nodes,
            edges: edges
        }));

        if (questionId) {
            addHiddenInput("questionId", questionId);
        }

        if (mode) {
            addHiddenInput("mode", mode);
        }

        document.body.appendChild(form);
        form.submit();
    }

</script>