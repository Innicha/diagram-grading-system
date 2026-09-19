<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String flowchartJson = request.getParameter("flowchartData");
    if (flowchartJson == null || flowchartJson.trim().isEmpty()) {
        flowchartJson = "{\"nodes\":[], \"edges\":[]}";
    }
    
    // จัดการอักขระพิเศษกันพังเวลาพิมพ์เครื่องหมายแปลกๆ ลงไป
    String safeJsonForJs = flowchartJson.replace("\\", "\\\\").replace("'", "\\'");
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <style>
        body { font-family: 'Anuphan', sans-serif; background-color: #f4f6f9; padding: 40px 20px; }
        .result-card { background: #ffffff; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); border: 1px solid #dbe4f3; padding: 40px; max-width: 900px; margin: 0 auto; }
        .code-display { width: 100%; height: 320px; font-family: 'Consolas', 'Courier New', monospace; font-size: 14px; padding: 15px; border-radius: 8px; border: 1px solid #ced4da; background-color: #1e1e1e; color: #dcdcaa; resize: vertical; white-space: pre; }
    </style>
</head>
<body>

    <div class="result-card text-center">
        <div class="mb-4"><i class="bi bi-check-circle-fill text-success" style="font-size: 4rem;"></i></div>
        
        <h2 class="fw-bold mb-3" style="color: #1e3a8a;">แปลง Flowchart เป็น Pseudocode สำเร็จ!</h2>
        
        <div class="text-start mb-4">
            <label class="fw-bold text-dark mb-2"><i class="bi bi-code-square text-primary me-1"></i> Generated Pseudocode:</label>
            <textarea class="code-display" id="pseudocodeOutput" readonly>กำลังแปลงโค้ด...</textarea>
        </div>
        
        <div class="d-flex justify-content-center">
            <button class="btn btn-outline-secondary px-4 py-2 fw-bold" onclick="window.history.back();">
                <i class="bi bi-arrow-left me-1"></i> กลับไปหน้าวาด Flowchart
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
                document.getElementById("pseudocodeOutput").value = "// ❌ ไม่พบจุดเริ่มต้นหรือข้อมูล Flowchart ไม่ถูกต้อง";
            } else {
                
                function generatePseudocode(nodeId, visited, indentLevel) {
                    if (visited.has(nodeId)) return "";
                    
                    let node = nodes.find(n => n.id === nodeId);
                    if (!node) return "";
                    
                    let outEdges = edges.filter(e => e.from === nodeId);
                    let rawText = node.text.trim();
                    let indent = "    ".repeat(indentLevel);
                    let code = "";

                    visited.add(nodeId);

                    if (node.type === "start") {
                        code = "";
                    } else if (node.type === "input") {
                        let cmd = rawText.toLowerCase().startsWith("input") ? rawText : "input " + rawText;
                        code = indent + cmd + "\n";
                    } else if (node.type === "display") {
                        let cmd = rawText.toLowerCase().startsWith("print") || rawText.toLowerCase().startsWith("output") ? rawText : "print " + rawText;
                        code = indent + cmd + "\n";
                    } else if (node.type === "process") {
                        code = indent + rawText + "\n";
                    } else if (node.type === "decision") {
                        let lowerText = rawText.toLowerCase();

                        if (lowerText.includes("for")) {
                            let cleanText = rawText.replace(/for\s*/i, "").replace(/[()]/g, "").trim();
                            let forExpr = cleanText;

                            if (cleanText.includes("in")) {
                                let pyMatch = cleanText.match(/(\w+)\s+in\s+\(?([\d\w]+)\)?/i);
                                if (pyMatch) {
                                    let varName = pyMatch[1];
                                    let limitVal = pyMatch[2];
                                    forExpr = varName + "= 0 to " + limitVal;
                                }
                            }
                            else if (cleanText.includes(';')) {
                                let parts = cleanText.split(';');
                                let initPart = parts[0].trim(); 
                                let condPart = parts[1] ? parts[1].trim() : ""; 

                                let varMatch = initPart.match(/(?:int\s+)?(\w+)\s*=\s*([\d\w]+)/i);
                                let condMatch = condPart.match(/(\w+)\s*(?:<|<=)\s*(.+)/);

                                if (varMatch && condMatch) {
                                    let varName = varMatch[1];
                                    let startVal = varMatch[2];
                                    let endVal = condMatch[2].trim();
                                    forExpr = `${varName} = ${startVal} to ${endVal}`;
                                }
                            }

                            code = indent + "for " + forExpr + "\n";
                            
                            let inLoopEdges = outEdges.filter(e => e.type !== 'loop' && !e.label?.toLowerCase().includes('no'));
                            let outLoopEdges = outEdges.filter(e => e.type === 'loop' || e.label?.toLowerCase().includes('no'));

                            inLoopEdges.forEach(e => {
                                code += generatePseudocode(e.to, new Set(visited), indentLevel + 1);
                            });
                            
                            code += indent + "endfor\n";

                            outLoopEdges.forEach(e => {
                                if (e.type !== 'loop') {
                                    code += generatePseudocode(e.to, visited, indentLevel);
                                }
                            });

                            return code;
                        } 
                        else if (lowerText.startsWith("while")) {
                            let cleanCond = rawText.replace(/^while\s*/i, "").replace(/^\(/, "").replace(/\)$/, "");
                            code = indent + "while (" + cleanCond + ")\n";
                            
                            outEdges.forEach(e => {
                                if (e.type === 'loop') return; 
                                code += generatePseudocode(e.to, new Set(visited), indentLevel + 1);
                            });
                            
                            code += indent + "endwhile\n";
                            return code;
                        } 
                        else {
                            // ⭐ จุดที่แก้ไข: ทำการแยกเส้น Yes และ No ออกจากกันเพื่อใส่ else
                            let cleanCond = rawText.replace(/^if\s*/i, "").replace(/^\(/, "").replace(/\)$/, "");
                            code = indent + "if (" + cleanCond + ")\n";

                            let yesEdge = outEdges.find(e => e.type === 'yes' || (e.label && e.label.toLowerCase() === 'yes'));
                            let noEdge = outEdges.find(e => e.type === 'no' || (e.label && e.label.toLowerCase() === 'no'));

                            if (yesEdge) {
                                code += generatePseudocode(yesEdge.to, new Set(visited), indentLevel + 1);
                            }

                            if (noEdge) {
                                code += indent + "else\n";
                                code += generatePseudocode(noEdge.to, new Set(visited), indentLevel + 1);
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
                let finalPseudocode = "Begin\n" + bodyCode + "End";

                document.getElementById("pseudocodeOutput").value = finalPseudocode.trim();
            }
        } catch (error) {
            console.error(error);
            document.getElementById("pseudocodeOutput").value = "// ❌ เกิดข้อผิดพลาดในการแปลง Pseudocode: " + error.message;
        }
    </script>
</body>
</html>