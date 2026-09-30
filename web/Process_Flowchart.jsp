<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String flowchartJson = request.getParameter("flowchartData");
    if (flowchartJson == null || flowchartJson.trim().isEmpty()) {
        flowchartJson = "{\"nodes\":[], \"edges\":[]}";
    }
    String safeJsonForJs = flowchartJson.replace("\\", "\\\\").replace("'", "\\'");
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ผลลัพธ์ Pseudocode และ JavaScript</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <style>
        body { font-family: 'Anuphan', sans-serif; background-color: #f4f6f9; padding: 40px 20px; }
        .result-card { background: #ffffff; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); border: 1px solid #dbe4f3; padding: 40px; max-width: 1000px; margin: 0 auto; }
        .code-display { width: 100%; height: 350px; font-family: 'Consolas', 'Courier New', monospace; font-size: 14px; padding: 15px; border-radius: 8px; border: 1px solid #ced4da; background-color: #1e1e1e; color: #dcdcaa; resize: vertical; white-space: pre; overflow-x: auto; }
        .js-display { color: #569cd6; } 
    </style>
</head>
<body>

    <div class="result-card text-center">
        <div class="mb-4"><i class="bi bi-check-circle-fill text-success" style="font-size: 4rem;"></i></div>
        <h2 class="fw-bold mb-4" style="color: #1e3a8a;">แปลง Flowchart สำเร็จ!</h2>
        
        <div class="row text-start mb-4">
            <div class="col-md-6 mb-3 mb-md-0">
                <label class="fw-bold text-dark mb-2"><i class="bi bi-code-square text-primary me-1"></i> 1. Generated Pseudocode:</label>
                <textarea class="code-display" id="pseudocodeOutput" readonly>กำลังแปลงโค้ด...</textarea>
            </div>
            <div class="col-md-6">
                <label class="fw-bold text-dark mb-2"><i class="bi bi-filetype-js text-warning me-1"></i> 2. JavaScript Code:</label>
                <textarea class="code-display js-display" id="jsOutput" readonly>// กดปุ่ม "แปลงเป็น JavaScript" ด้านล่างเพื่อดูผลลัพธ์</textarea>
            </div>
        </div>
        
        <div class="d-flex justify-content-center gap-3">
            <button class="btn btn-outline-secondary px-4 py-2 fw-bold" onclick="window.history.back();">
                <i class="bi bi-arrow-left me-1"></i> กลับไปวาดต่อ
            </button>
            <button class="btn btn-warning px-4 py-2 fw-bold shadow-sm text-dark" onclick="convertToJS()">
                <i class="bi bi-lightning-charge-fill me-1"></i> แปลงเป็น JavaScript
            </button>
        </div>
    </div>

    <script>
        try {
            const rawData = '<%= safeJsonForJs %>';
            const flowchartData = JSON.parse(rawData);
            const nodes = flowchartData.nodes || [];
            const edges = flowchartData.edges || [];

            let startNode = nodes.find(n => n.type === 'start' && n.text.toLowerCase().includes('start'));
            if (!startNode) startNode = nodes.find(n => n.type === 'start');

            if (!startNode || nodes.length === 0) {
                document.getElementById("pseudocodeOutput").value = "// ❌ ไม่พบจุดเริ่มต้น";
            } else {
                function generatePseudocode(nodeId, visited, indentLevel) {
                    if (visited.has(nodeId)) return "";
                    let node = nodes.find(n => n.id === nodeId);
                    if (!node) return "";
                    
                    let allOutEdges = edges.filter(e => e.from === nodeId);
                    let outEdges = allOutEdges.filter(e => e.type !== 'loop' && (!e.label || e.label.toLowerCase() !== 'loop'));
                    
                    let rawText = node.text.trim();
                    let indent = "    ".repeat(indentLevel);
                    let code = "";
                    visited.add(nodeId);

                    if (node.type === "start") {
                        code = "";
                    } else if (node.type === "input") {
                        code = indent + (rawText.toLowerCase().startsWith("input") ? rawText : "input " + rawText) + "\n";
                    } else if (node.type === "display") {
                        code = indent + (rawText.toLowerCase().startsWith("print") || rawText.toLowerCase().startsWith("output") ? rawText : "print " + rawText) + "\n";
                    } else if (node.type === "process") {
                        code = indent + rawText + "\n";
                    } else if (node.type === "decision") {
                        let cleanCond = rawText.replace(/^(else\s*if|elseif|if|while|for)\s*/i, "").replace(/^\(/, "").replace(/\)$/, "").trim();
                        let isLoop = edges.some(e => (e.to === nodeId || e.from === nodeId) && (e.type === 'loop' || (e.label && e.label.toLowerCase() === 'loop')));

                        if (isLoop) {
                            code = indent + "while (" + cleanCond + ")\n";
                            let yesEdge = outEdges.find(e => e.type === 'yes' || (e.label && e.label.toLowerCase() === 'yes'));
                            let noEdge = outEdges.find(e => e.type === 'no' || (e.label && e.label.toLowerCase() === 'no'));
                            if (yesEdge) code += generatePseudocode(yesEdge.to, new Set(visited), indentLevel + 1);
                            code += indent + "endwhile\n";
                            if (noEdge) code += generatePseudocode(noEdge.to, visited, indentLevel);
                            return code;
                        } else {
                            code = indent + "if (" + cleanCond + ")\n";
                            let yesEdge = outEdges.find(e => e.type === 'yes' || (e.label && e.label.toLowerCase() === 'yes'));
                            let noEdge = outEdges.find(e => e.type === 'no' || (e.label && e.label.toLowerCase() === 'no'));
                            if (yesEdge) code += generatePseudocode(yesEdge.to, new Set(visited), indentLevel + 1);

                            let currentNoEdge = noEdge;
                            while (currentNoEdge) {
                                let nextNode = nodes.find(n => n.id === currentNoEdge.to);
                                if (nextNode && nextNode.type === 'decision' && !visited.has(nextNode.id)) {
                                    let nextIsLoop = edges.some(e => (e.to === nextNode.id || e.from === nextNode.id) && (e.type === 'loop' || (e.label && e.label.toLowerCase() === 'loop')));
                                    if (!nextIsLoop) {
                                        visited.add(nextNode.id);
                                        let nextCleanCond = nextNode.text.trim().replace(/^(else\s*if|elseif|if)\s*/i, "").replace(/^\(/, "").replace(/\)$/, "").trim();
                                        code += indent + "else if (" + nextCleanCond + ")\n";
                                        let nextOutEdges = edges.filter(e => e.from === nextNode.id);
                                        let nextYesEdge = nextOutEdges.find(e => e.type === 'yes' || (e.label && e.label.toLowerCase() === 'yes'));
                                        if (nextYesEdge) code += generatePseudocode(nextYesEdge.to, new Set(visited), indentLevel + 1);
                                        currentNoEdge = nextOutEdges.find(e => e.type === 'no' || (e.label && e.label.toLowerCase() === 'no'));
                                        continue; 
                                    }
                                }
                                code += indent + "else\n";
                                code += generatePseudocode(currentNoEdge.to, new Set(visited), indentLevel + 1);
                                currentNoEdge = null; 
                            }
                            code += indent + "endif\n";
                            return code;
                        }
                    } else {
                        code = indent + rawText + "\n";
                    }

                    if (outEdges.length === 1 && outEdges[0].type !== 'loop') {
                        code += generatePseudocode(outEdges[0].to, visited, indentLevel);
                    }
                    return code;
                }

                let bodyCode = generatePseudocode(startNode.id, new Set(), 1);
                document.getElementById("pseudocodeOutput").value = ("Begin\n" + bodyCode + "End").trim();
            }
        } catch (error) {
            document.getElementById("pseudocodeOutput").value = "// ❌ Error: " + error.message;
        }

        // ==========================================
        // ฟังก์ชันแปลงเป็น JavaScript โค้ดมาตรฐาน
        // ==========================================
        function convertToJS() {
            let pseudo = document.getElementById("pseudocodeOutput").value;
            let jsOutputBox = document.getElementById("jsOutput");

            if (pseudo.includes("❌") || pseudo.trim() === "") {
                jsOutputBox.value = "// ❌ ไม่สามารถแปลงได้"; return;
            }

            let lines = pseudo.split('\n');
            let jsLines = [];
            
            let declaredVars = new Set(); // เอาไว้จำว่าตัวแปรไหนประกาศ let ไปแล้วบ้าง

            lines.forEach(line => {
                let trimmed = line.trim();
                let indentMatch = line.match(/^\s*/);
                // ดึงการย่อหน้า (Indent) มา แต่ตัดออกไป 4 เคาะแรกเพื่อให้โค้ด JS ชิดขอบซ้ายสวยงาม
                let indent = indentMatch ? indentMatch[0] : ""; 
                if (indent.length >= 4) indent = indent.substring(4);

                if (trimmed === "Begin" || trimmed === "End") {
                    return; // ข้าม Begin / End ไปเลย
                } 
                else if (/^input/i.test(trimmed)) {
                    let varName = trimmed.replace(/^input\s+/i, '').trim();
                    
                    if (!declaredVars.has(varName)) {
                        // ใส่ let และใช้ 'Enter A:' (ไม่มีเว้นวรรคหลัง :)
                        jsLines.push(indent + "let " + varName + " = Number(prompt('Enter " + varName + ":'));");
                        declaredVars.add(varName);
                    } else {
                        jsLines.push(indent + varName + " = Number(prompt('Enter " + varName + ":'));");
                    }
                } 
                else if (/^(print|output)/i.test(trimmed)) {
                    let textToPrint = trimmed.replace(/^(print|output)\s+/i, '').trim();
                    // เปลี่ยนเป็น console.log ตรงๆ
                    jsLines.push(indent + "console.log(" + textToPrint + ");");
                } 
                else if (/^if\s*\(/i.test(trimmed)) {
                    jsLines.push(indent + trimmed + " {");
                } 
                else if (/^else\s+if\s*\(/i.test(trimmed)) {
                    jsLines.push(indent + "} " + trimmed + " {");
                } 
                else if (trimmed.toLowerCase() === "else") {
                    jsLines.push(indent + "} else {");
                } 
                else if (trimmed.toLowerCase() === "endif") {
                    jsLines.push(indent + "}");
                } 
                else if (/^while\s*\(/i.test(trimmed)) {
                    jsLines.push(indent + trimmed + " {");
                } 
                else if (trimmed.toLowerCase() === "endwhile") {
                    jsLines.push(indent + "}");
                } 
                else if (trimmed !== "") {
                    // จัดการสมการคณิตศาสตร์ เช่น A = 2
                    let assignMatch = trimmed.match(/^([a-zA-Z_]\w*)\s*=/);
                    if (assignMatch && !trimmed.includes("==") && !trimmed.includes("+=") && !trimmed.includes("-=")) {
                        let vName = assignMatch[1];
                        if (!declaredVars.has(vName)) {
                            jsLines.push(indent + "let " + trimmed + ";"); 
                            declaredVars.add(vName);
                        } else {
                            jsLines.push(indent + trimmed + ";");
                        }
                    } else {
                        jsLines.push(indent + trimmed + ";"); 
                    }
                }
            });

            jsOutputBox.value = jsLines.join('\n').trim();
        }
    </script>
</body>
</html>