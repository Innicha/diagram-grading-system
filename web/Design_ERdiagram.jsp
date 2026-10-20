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
<link rel="stylesheet" href="css/pages/ERdiagram.css">

<mytag:check_login /> 

<%
    String Link = request.getAttribute("Loadfile5") != null ? request.getAttribute("Loadfile5").toString() : ""; 
%>

<div class="container-fluid p-4" style="min-height: 100vh; overflow-y: auto;">
    <!-- Header: ชื่อหน้าอยู่ซ้าย ปุ่ม Submit อยู่ขวา -->
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
        <h3 class="mb-0 fw-bold" style="color: #1e3a8a;">สร้าง ER Diagram</h3>
        <form action="Process_ERdiagram.jsp" method="POST" id="erDiagramForm" class="mb-0">
            <input type="hidden" name="questionId" id="questionId" value="<%= request.getParameter("questionId") == null ? "" : request.getParameter("questionId").replaceAll("[^0-9]", "") %>">
            <input type="hidden" name="erDiagramData" id="erDiagramData">
            <button type="button" id="fc-submitBtn" onclick="submitERDiagram()">
                <i class="bi bi-send-fill me-1"></i> Submit
            </button>
        </form>
    </div>

    <!-- ระบบสร้าง ER Diagram Container -->
    <div class="flowchart-wrapper" id="flowchart-wrapper">
        <!-- แถบด้านซ้าย (Sidebar Shapes) -->
        <div class="fc-sidebar">
            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-1">องค์ประกอบ</div>
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

            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-1">คีย์หลักและคีย์นอก</div>
            <div class="fc-shape" data-type="primaryKey" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text"><u>PK_Attribute</u></span></div>
            </div>
            <div class="fc-shape" data-type="foreignKey" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">FK_Attribute</span></div>
            </div>

            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-1">ความสัมพันธ์</div>
            <div class="fc-shape" data-type="relationship" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">Relation</span></div>
            </div>
            <div class="fc-shape" data-type="identifyingRelationship" draggable="true" ondragstart="fcDrag(event)">
                <div class="fc-text-wrapper"><span class="fc-text">Identifying</span></div>
            </div>

            <div class="text-muted fw-bold small text-uppercase w-100 text-center mb-1">เส้นเชื่อม</div>
            <button type="button" class="btn btn-outline-primary btn-sm ms-2" id="connectModeBtn" onclick="toggleConnectMode()">
                <i class="bi bi-link-45deg me-1"></i> เปิดโหมดเชื่อมเส้น
            </button>
        </div>

        <!-- พื้นที่ Canvas ด้านขวา -->
        <div class="fc-canvas" id="fc-canvas" ondrop="fcDrop(event)" ondragover="fcAllowDrop(event)">
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
            <svg id="fc-svg"></svg>
        </div>
    </div>
</div>

<!-- Script สำหรับ ER Diagram -->
<script>
    let connections = []; 
    let nodeSequence = 0;
    let selectedNode = null; 
    let isConnectMode = false; 

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

        newNode.style.left = (ev.clientX - rect.left + canvas.scrollLeft - offsetX) + "px";
        newNode.style.top = (ev.clientY - rect.top + canvas.scrollTop - offsetY) + "px";
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
                    const fromType = selectedNode.getAttribute("data-type");
                    const toType = elmnt.getAttribute("data-type");
                    const relationshipTypes = ["relationship", "identifyingRelationship"];

                    if (relationshipTypes.includes(fromType) || relationshipTypes.includes(toType)) {
                        const userInput = prompt("ระบุอัตราส่วนความสัมพันธ์ (เช่น 1, M, N):", "1");
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

    function drawLines() {
        const svg = document.getElementById("fc-svg");
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
        if (!elem) {
            console.error("ไม่พบ flowchart-wrapper");
            return;
        }
        try {
            if (!document.fullscreenElement) {
                if (elem.requestFullscreen) {
                    await elem.requestFullscreen();
                } else if (elem.webkitRequestFullscreen) {
                    elem.webkitRequestFullscreen();
                }
            } else {
                if (document.exitFullscreen) {
                    await document.exitFullscreen();
                } else if (document.webkitExitFullscreen) {
                    document.webkitExitFullscreen();
                }
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