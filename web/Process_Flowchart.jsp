<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="javax.script.*"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<%!
    private static class JsonReader {
        private final String s;
        private int i = 0;
        JsonReader(String s) { this.s = s == null ? "" : s; }
        Object parse() {
            Object v = value(); ws();
            if (i != s.length()) throw new IllegalArgumentException("JSON มีข้อมูลส่วนเกิน");
            return v;
        }
        private void ws() { while (i < s.length() && Character.isWhitespace(s.charAt(i))) i++; }
        private Object value() {
            ws(); if (i >= s.length()) throw new IllegalArgumentException("JSON ว่าง");
            char c = s.charAt(i);
            if (c == '{') return object();
            if (c == '[') return array();
            if (c == '"') return string();
            if (c == 't' && s.startsWith("true", i)) { i += 4; return Boolean.TRUE; }
            if (c == 'f' && s.startsWith("false", i)) { i += 5; return Boolean.FALSE; }
            if (c == 'n' && s.startsWith("null", i)) { i += 4; return null; }
            int st = i;
            if (c == '-') i++;
            while (i < s.length() && Character.isDigit(s.charAt(i))) i++;
            if (i < s.length() && s.charAt(i) == '.') { i++; while (i < s.length() && Character.isDigit(s.charAt(i))) i++; }
            if (st == i) throw new IllegalArgumentException("JSON ไม่ถูกต้อง ตำแหน่ง " + i);
            String n = s.substring(st, i);
            return n.contains(".") ? Double.valueOf(n) : Long.valueOf(n);
        }
        private Map<String, Object> object() {
            Map<String, Object> m = new LinkedHashMap<String, Object>();
            i++; ws(); if (i < s.length() && s.charAt(i) == '}') { i++; return m; }
            while (true) {
                ws(); if (i >= s.length() || s.charAt(i) != '"') throw new IllegalArgumentException("ต้องใช้ key แบบข้อความ");
                String k = string(); ws(); if (i >= s.length() || s.charAt(i++) != ':') throw new IllegalArgumentException("ขาด :");
                m.put(k, value()); ws(); if (i < s.length() && s.charAt(i) == '}') { i++; return m; }
                if (i >= s.length() || s.charAt(i++) != ',') throw new IllegalArgumentException("ขาด ,");
            }
        }
        private List<Object> array() {
            List<Object> a = new ArrayList<Object>();
            i++; ws(); if (i < s.length() && s.charAt(i) == ']') { i++; return a; }
            while (true) {
                a.add(value()); ws(); if (i < s.length() && s.charAt(i) == ']') { i++; return a; }
                if (i >= s.length() || s.charAt(i++) != ',') throw new IllegalArgumentException("ขาด ,");
            }
        }
        private String string() {
            StringBuilder b = new StringBuilder();
            i++;
            while (i < s.length()) {
                char c = s.charAt(i++);
                if (c == '"') return b.toString();
                if (c == '\\') {
                    if (i >= s.length()) break;
                    char e = s.charAt(i++);
                    switch (e) {
                        case 'n': b.append('\n'); break; case 'r': b.append('\r'); break;
                        case 't': b.append('\t'); break; case 'b': b.append('\b'); break;
                        case 'f': b.append('\f'); break;
                        case 'u': b.append((char) Integer.parseInt(s.substring(i, i + 4), 16)); i += 4; break;
                        default: b.append(e);
                    }
                } else b.append(c);
            }
            throw new IllegalArgumentException("ข้อความ JSON ไม่ปิดเครื่องหมาย");
        }
    }

    private static String textOf(Object o) { return o == null ? "" : String.valueOf(o); }
    private static String escHtml(Object value) {
        return textOf(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

    // 1. แปลงโชว์หน้าเว็บ (ฉลาดขึ้น ตรวจจับ If และ While ได้)
    private static String convertFlowchartToPseudocode(String json) {
        Object rootObj = new JsonReader(json).parse();
        if (!(rootObj instanceof Map)) throw new IllegalArgumentException("Flowchart JSON ไม่ถูกต้อง");
        Map root = (Map) rootObj;
        List<Map<String, Object>> nodes = (List<Map<String, Object>>) root.get("nodes");
        List<Map<String, Object>> edges = (List<Map<String, Object>>) root.get("edges");
        
        if (nodes == null || nodes.isEmpty()) return "Begin\nEnd";

        Map<String, Map<String, Object>> byId = new HashMap<>();
        for (Map<String, Object> n : nodes) byId.put(textOf(n.get("id")), n);

        String startId = null;
        for (Map<String, Object> n : nodes) {
            if ("start".equalsIgnoreCase(textOf(n.get("type"))) && textOf(n.get("text")).toLowerCase().contains("start")) { startId = textOf(n.get("id")); break; }
        }
        if (startId == null) for (Map<String, Object> n : nodes) if ("start".equalsIgnoreCase(textOf(n.get("type")))) { startId = textOf(n.get("id")); break; }
        if (startId == null) return "Begin\nEnd";

        StringBuilder pseudo = new StringBuilder();
        pseudo.append("Begin\n");

        String currentId = startId;
        Set<String> visited = new HashSet<>();
        
        while (currentId != null) {
            if (visited.contains(currentId)) break;
            visited.add(currentId);
            
            Map<String, Object> n = byId.get(currentId);
            if (n == null) break;
            
            String type = textOf(n.get("type")).toLowerCase();
            String raw = textOf(n.get("text")).trim();

            if (!currentId.equals(startId) && type.equals("start") && raw.toLowerCase().contains("end")) break;

            if (type.equals("input")) pseudo.append("    ").append(raw.startsWith("input") ? raw : "input " + raw).append("\n");
            else if (type.equals("process")) pseudo.append("    ").append(raw).append("\n");
            else if (type.equals("display")) pseudo.append("    ").append(raw.startsWith("print") ? raw : "print " + raw.replace("display", "").trim()).append("\n");
            else if (type.equals("decision")) {
                
                // นับจำนวนเส้นลูกศรขาเข้าเพื่อแยก If กับ While
                int incomingCount = 0;
                for (Map<String, Object> e : edges) if (currentId.equals(textOf(e.get("to")))) incomingCount++;
                
                if (incomingCount > 1) { 
                    // แปลงเป็น While Loop
                    pseudo.append("    while (").append(raw).append(")\n");
                    
                    String bodyNodeId = null, exitNodeId = null;
                    for (Map<String, Object> e : edges) {
                        if (currentId.equals(textOf(e.get("from")))) {
                            String lbl = (textOf(e.get("label")) + " " + textOf(e.get("type"))).toLowerCase();
                            if (lbl.contains("yes") || lbl.contains("true") || lbl.contains("ใช่")) bodyNodeId = textOf(e.get("to"));
                            else exitNodeId = textOf(e.get("to"));
                        }
                    }
                    
                    // ดึงคำสั่งใน Loop ออกมาโชว์
                    String currBody = bodyNodeId;
                    Set<String> bodyVisited = new HashSet<>();
                    while (currBody != null && !currBody.equals(currentId) && !bodyVisited.contains(currBody)) {
                        bodyVisited.add(currBody);
                        Map<String, Object> bn = byId.get(currBody);
                        if (bn == null) break;
                        String btype = textOf(bn.get("type")).toLowerCase();
                        String braw = textOf(bn.get("text")).trim();
                        
                        if (btype.equals("input")) pseudo.append("        ").append(braw.startsWith("input") ? braw : "input " + braw).append("\n");
                        else if (btype.equals("process")) pseudo.append("        ").append(braw).append("\n");
                        else if (btype.equals("display")) pseudo.append("        ").append(braw.startsWith("print") ? braw : "print " + braw.replace("display", "").trim()).append("\n");
                        
                        String nextB = null;
                        for (Map<String, Object> e : edges) {
                            if (currBody.equals(textOf(e.get("from")))) { nextB = textOf(e.get("to")); break; }
                        }
                        currBody = nextB;
                    }
                    pseudo.append("    endwhile\n");
                    currentId = exitNodeId; // โดดข้ามไปจบ Loop
                    continue;
                } else {
                    // แปลงเป็น If ปกติ
                    pseudo.append("    if (").append(raw).append(") then\n");
                    
                    String bodyNodeId = null, exitNodeId = null;
                    for (Map<String, Object> e : edges) {
                        if (currentId.equals(textOf(e.get("from")))) {
                            String lbl = (textOf(e.get("label")) + " " + textOf(e.get("type"))).toLowerCase();
                            if (lbl.contains("yes") || lbl.contains("true") || lbl.contains("ใช่")) bodyNodeId = textOf(e.get("to"));
                            else exitNodeId = textOf(e.get("to"));
                        }
                    }
                    
                    if (bodyNodeId != null) {
                        String currBody = bodyNodeId;
                        Set<String> bodyVisited = new HashSet<>();
                        while (currBody != null && !currBody.equals(exitNodeId) && !bodyVisited.contains(currBody)) {
                            bodyVisited.add(currBody);
                            Map<String, Object> bn = byId.get(currBody);
                            if (bn == null) break;
                            String btype = textOf(bn.get("type")).toLowerCase();
                            String braw = textOf(bn.get("text")).trim();
                            
                            if (btype.equals("input")) pseudo.append("        ").append(braw.startsWith("input") ? braw : "input " + braw).append("\n");
                            else if (btype.equals("process")) pseudo.append("        ").append(braw).append("\n");
                            else if (btype.equals("display")) pseudo.append("        ").append(braw.startsWith("print") ? braw : "print " + braw.replace("display", "").trim()).append("\n");
                            
                            String nextB = null;
                            for (Map<String, Object> e : edges) {
                                if (currBody.equals(textOf(e.get("from")))) { nextB = textOf(e.get("to")); break; }
                            }
                            currBody = nextB;
                        }
                    }
                    pseudo.append("    endif\n");
                    currentId = exitNodeId;
                    continue;
                }
            }

            String nextId = null;
            for (Map<String, Object> e : edges) {
                if (currentId.equals(textOf(e.get("from")))) { nextId = textOf(e.get("to")); break; }
            }
            currentId = nextId;
        }

        pseudo.append("End");
        return pseudo.toString();
    }

    // 2. แปลงโค้ดสำหรับรันจริง (Flowchart -> JS State Machine ป้องกัน Loop ล่ม)
    private static String transpileFlowchartToJS(String json) {
        Object rootObj = new JsonReader(json).parse();
        if (!(rootObj instanceof Map)) throw new IllegalArgumentException("Flowchart JSON ไม่ถูกต้อง");
        Map root = (Map) rootObj;
        List<Map<String, Object>> nodes = (List<Map<String, Object>>) root.get("nodes");
        List<Map<String, Object>> edges = (List<Map<String, Object>>) root.get("edges");
        
        if (nodes == null || nodes.isEmpty()) throw new IllegalArgumentException("ไม่พบ Node");

        String startId = null;
        for (Map<String, Object> n : nodes) {
            if ("start".equalsIgnoreCase(textOf(n.get("type"))) && textOf(n.get("text")).toLowerCase().contains("start")) { startId = textOf(n.get("id")); break; }
        }
        if (startId == null) {
            for (Map<String, Object> n : nodes) if ("start".equalsIgnoreCase(textOf(n.get("type")))) { startId = textOf(n.get("id")); break; }
        }
        if (startId == null) throw new IllegalArgumentException("ไม่พบ Start node");

        StringBuilder js = new StringBuilder();
        js.append("var outputs = [];\nvar loopCount = 0;\nvar state = '").append(startId).append("';\n");
        js.append("while(state !== 'END') {\n");
        js.append("  if(loopCount++ > 1000) throw 'Infinite Loop Detected';\n");
        js.append("  switch(state) {\n");

        for (Map<String, Object> n : nodes) {
            String id = textOf(n.get("id"));
            String type = textOf(n.get("type")).toLowerCase();
            String raw = textOf(n.get("text")).trim();
            js.append("    case '").append(id).append("':\n");

            if (type.equals("start") && raw.toLowerCase().contains("end")) {
                js.append("      state = 'END';\n      break;\n");
                continue;
            }

            if (type.equals("input")) {
                String varStr = raw.replaceFirst("(?i)^(input|read|enter|รับค่า|รับข้อมูล)\\s*", "");
                for (String v : varStr.split("[,/]")) {
                    String cleanV = v.replaceAll("[^A-Za-z0-9_]", "").trim();
                    if(!cleanV.isEmpty()) js.append("      ").append(cleanV).append(" = inputs.shift();\n");
                }
            } else if (type.equals("process")) {
                String stmt = raw.replaceFirst("(?i)^process\\s*:?\\s*", "");
                js.append("      ").append(stmt).append(";\n");
            } else if (type.equals("display")) {
                String expr = raw.replaceFirst("(?i)^(display|output|print|show|แสดงผล|แสดง)\\s*", "");
                js.append("      outputs.push(").append(expr).append(");\n");
            }

            if (type.equals("decision")) {
                String cond = raw.replaceFirst("(?i)^decision\\s*:?\\s*", "");
                String yesNode = "END", noNode = "END";
                for (Map<String, Object> e : edges) {
                    if (id.equals(textOf(e.get("from")))) {
                        String lbl = (textOf(e.get("label")) + " " + textOf(e.get("type"))).toLowerCase();
                        if (lbl.contains("yes") || lbl.contains("true") || lbl.contains("ใช่")) yesNode = textOf(e.get("to"));
                        else if (lbl.contains("no") || lbl.contains("false") || lbl.contains("ไม่")) noNode = textOf(e.get("to"));
                    }
                }
                js.append("      if (").append(cond).append(") { state = '").append(yesNode).append("'; }\n");
                js.append("      else { state = '").append(noNode).append("'; }\n");
            } else {
                String nextNode = "END";
                for (Map<String, Object> e : edges) {
                    if (id.equals(textOf(e.get("from")))) { nextNode = textOf(e.get("to")); break; }
                }
                js.append("      state = '").append(nextNode).append("';\n");
            }
            js.append("      break;\n");
        }
        js.append("    default:\n      state = 'END';\n      break;\n");
        js.append("  }\n}\noutputs.join('\\n');");
        return js.toString();
    }

    // 3. แปลง Pseudocode เป็น JavaScript (ใช้โชว์หน้าเว็บให้อ่านง่าย)
    private static String transpilePseudocodeToJS(String pseudo) {
        StringBuilder js = new StringBuilder();
        js.append("var outputs = [];\nvar loopCount = 0;\n");
        String[] lines = pseudo.split("\n");
        for (String line : lines) {
            String l = line.trim();
            if (l.isEmpty() || l.equalsIgnoreCase("begin") || l.equalsIgnoreCase("end")) continue;
            
            if (l.toLowerCase().startsWith("input") || l.toLowerCase().startsWith("read")) {
                String varStr = l.replaceFirst("(?i)^(input|read)\\s+", "");
                for (String v : varStr.split("[,/]")) {
                    String cleanV = v.replaceAll("[^A-Za-z0-9_]", "").trim();
                    js.append("var ").append(cleanV).append(" = inputs.shift();\n");
                }
            } else if (l.toLowerCase().startsWith("print") || l.toLowerCase().startsWith("output")) {
                String exp = l.replaceFirst("(?i)^(print|output)\\s+", "");
                js.append("outputs.push(").append(exp).append(");\n");
            } else if (l.toLowerCase().startsWith("if") || l.toLowerCase().startsWith("if(")) {
                String cond = l.replaceFirst("(?i)^if\\s*\\(?", "").replaceAll("(?i)\\)?\\s*then\\s*$", "").trim();
                if (cond.endsWith("{")) cond = cond.substring(0, cond.length()-1).trim();
                js.append("if (").append(cond).append(") {\n");
            } else if (l.equalsIgnoreCase("else")) {
                js.append("} else {\n");
            } else if (l.equalsIgnoreCase("endif")) {
                js.append("}\n");
            } else if (l.toLowerCase().startsWith("while") || l.toLowerCase().startsWith("while(")) {
                String cond = l.replaceFirst("(?i)^while\\s*\\(?", "").replaceAll("\\)?\\s*\\{\\s*$", "").trim();
                js.append("while (").append(cond).append(") {\n  if(loopCount++ > 1000) throw 'Infinite Loop Detected';\n");
            } else if (l.equalsIgnoreCase("endwhile")) {
                js.append("}\n");
            } else {
                js.append(l).append(";\n");
            }
        }
        js.append("outputs.join('\\n');");
        return js.toString();
    }

    private static Map<String, Object> executeJavaScript(String jsCode, String inputJson) throws Exception {
        ScriptEngineManager manager = new ScriptEngineManager();
        ScriptEngine engine = manager.getEngineByName("JavaScript");
        if (engine == null) throw new Exception("เซิร์ฟเวอร์ Java ไม่รองรับ JavaScript Engine");

        List<String> inputList = new ArrayList<>();
        if (inputJson != null && !inputJson.trim().isEmpty()) {
            if (inputJson.startsWith("{")) {
                Map im = (Map) new JsonReader(inputJson).parse();
                for (Object v : im.values()) inputList.add(String.valueOf(v));
            } else {
                String[] tokens = inputJson.split(",");
                for (String t : tokens) inputList.add(t.trim());
            }
        }
        
        StringBuilder jsInputs = new StringBuilder("[");
        for (int i = 0; i < inputList.size(); i++) {
            String val = inputList.get(i);
            try { Double.parseDouble(val); jsInputs.append(val); } 
            catch (Exception e) { jsInputs.append("'").append(val.replace("'", "\\'")).append("'"); }
            if (i < inputList.size() - 1) jsInputs.append(", ");
        }
        jsInputs.append("]");

        engine.eval("var inputs = " + jsInputs.toString() + ";");
        Object rawResult = engine.eval(jsCode);
        
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("output", textOf(rawResult));
        return result;
    }

    // ตัวแก้ช่องว่าง
    private static boolean sameOutput(String actual, String expected) {
        String a = actual == null ? "" : actual.replaceAll("\\s+", " ").trim();
        String e = expected == null ? "" : expected.replaceAll("\\s+", " ").trim();
        if (a.equals(e)) return true;
        try { return Double.compare(Double.parseDouble(a), Double.parseDouble(e)) == 0; } catch (Exception ignored) { return false; }
    }
%>

<%
    request.setCharacterEncoding("UTF-8");
    String questionIdParam = request.getParameter("questionId");
    String flowchartData = request.getParameter("flowchartData");
    if (flowchartData == null || flowchartData.trim().isEmpty()) flowchartData = "{\"nodes\":[],\"edges\":[]}";

    boolean isJsonInput = flowchartData.trim().startsWith("{");
    Object userIdObj = session.getAttribute("UserId");
    Object roleObj = session.getAttribute("Role");

    if (userIdObj == null || roleObj == null || !"student".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect("index.jsp?error=1");
        return;
    }

    int studentId, questionId;
    try {
        studentId = Integer.parseInt(userIdObj.toString());
        questionId = Integer.parseInt(questionIdParam);
    } catch (Exception e) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "รหัสโจทย์ไม่ถูกต้อง");
        return;
    }

    List<Map<String, Object>> testCases = new ArrayList<>();
    try (Connection con = DBConnection.getConnection()) {
        String testSql = "SELECT id, case_no, input_data, expected_output, point FROM algorithm_test_cases WHERE question_id = ? ORDER BY case_no ASC";
        try (PreparedStatement ps = con.prepareStatement(testSql)) {
            ps.setInt(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> tc = new HashMap<>();
                    tc.put("case_no", rs.getInt("case_no"));
                    tc.put("input_data", rs.getString("input_data"));
                    tc.put("expected_output", rs.getString("expected_output"));
                    tc.put("point", rs.getInt("point"));
                    testCases.add(tc);
                }
            }
        }
    } catch (SQLException e) {
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "ไม่สามารถโหลด Test Case ได้");
        return;
    }

    String generatedPseudocode = "";
    String executeJS = "";
    String displayJS = "";
    
    try {
        if (isJsonInput) {
            generatedPseudocode = convertFlowchartToPseudocode(flowchartData);
            executeJS = transpileFlowchartToJS(flowchartData);
            displayJS = transpilePseudocodeToJS(generatedPseudocode);
        } else {
            generatedPseudocode = flowchartData;
            executeJS = transpilePseudocodeToJS(flowchartData);
            displayJS = executeJS;
        }
    } catch (Exception parseEx) {
        executeJS = "throw 'แปลงรหัสผิดพลาด: " + parseEx.getMessage().replace("'", "\\'") + "';";
        displayJS = executeJS;
    }

    List<Map<String, Object>> caseResults = new ArrayList<>();
    int totalScore = 0;
    int passedCount = 0;

    for (Map<String, Object> tc : testCases) {
        Map<String, Object> cr = new LinkedHashMap<>();
        cr.put("case_no", tc.get("case_no"));
        cr.put("input_data", tc.get("input_data"));
        cr.put("expected_output", tc.get("expected_output"));
        cr.put("point", tc.get("point"));
        
        String actualOutput = "";
        String errorMessage = "";
        boolean passed = false;

        try {
            Map<String, Object> runResult = executeJavaScript(executeJS, String.valueOf(tc.get("input_data")));
            actualOutput = String.valueOf(runResult.get("output"));
            passed = sameOutput(actualOutput, String.valueOf(tc.get("expected_output")));
        } catch (Exception runError) {
            errorMessage = runError.getMessage();
        }

        int casePoint = ((Number) tc.get("point")).intValue();
        if (passed) { totalScore += casePoint; passedCount++; }
        cr.put("actual_output", actualOutput);
        cr.put("passed", passed);
        cr.put("error", errorMessage);
        caseResults.add(cr);
    }

    try (Connection con = DBConnection.getConnection()) {
        String saveSql = "INSERT INTO algorithm_submissions (question_id, student_id, answer_text, score, status) VALUES (?, ?, ?, ?, 'GRADED') ON DUPLICATE KEY UPDATE answer_text = VALUES(answer_text), score = VALUES(score), status = 'GRADED', submitted_at = CURRENT_TIMESTAMP";
        try (PreparedStatement ps = con.prepareStatement(saveSql)) {
            ps.setInt(1, questionId);
            ps.setInt(2, studentId);
            ps.setString(3, flowchartData);
            ps.setInt(4, totalScore);
            ps.executeUpdate();
        }
    }
%>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { font-family: 'Anuphan', sans-serif; background-color: #f4f6f9; padding: 40px 20px; }
        .result-card { background: #ffffff; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); padding: 40px; max-width: 1000px; margin: 0 auto; }
        .code-display { width: 100%; height: 250px; font-family: 'Consolas', monospace; font-size: 14px; padding: 15px; border-radius: 8px; border: 1px solid #ced4da; background-color: #1e1e1e; color: #dcdcaa; white-space: pre; overflow-x: auto; }
        .js-display { color: #569cd6; } 
    </style>
</head>
<body>
    <div class="result-card text-center">
        <div class="mb-4"><i class="bi bi-check-circle-fill text-success" style="font-size: 4rem;"></i></div>
        <h2 class="fw-bold mb-4" style="color: #1e3a8a;">ตรวจคำตอบสำเร็จ!</h2>
        
        <div class="alert alert-primary text-start mb-4">
            <h5 class="fw-bold mb-2">ผลการตรวจ Test Case</h5>
            <div>ผ่าน <strong><%= passedCount %> / <%= testCases.size() %></strong> เคส</div>
            <div>คะแนนที่ได้ <strong><%= totalScore %></strong> คะแนน</div>
        </div>

        <div class="table-responsive mb-4 text-start">
            <table class="table table-bordered table-striped align-middle">
                <thead class="table-dark">
                    <tr><th>Case</th><th>Input</th><th>Expected Output</th><th>Actual Output</th><th>คะแนน</th><th>ผลตรวจ</th></tr>
                </thead>
                <tbody>
                <% for (Map<String, Object> cr : caseResults) { boolean ok = Boolean.TRUE.equals(cr.get("passed")); %>
                    <tr>
                        <td><%= escHtml(cr.get("case_no")) %></td>
                        <td><code><%= escHtml(cr.get("input_data")) %></code></td>
                        <td><code><%= escHtml(cr.get("expected_output")) %></code></td>
                        <td>
                            <code><%= escHtml(cr.get("actual_output")) %></code>
                            <% if (!String.valueOf(cr.get("error")).isEmpty()) { %>
                                <div class="small text-danger mt-1"><%= escHtml(cr.get("error")) %></div>
                            <% } %>
                        </td>
                        <td><%= ok ? escHtml(cr.get("point")) : "0" %> / <%= escHtml(cr.get("point")) %></td>
                        <td><span class="badge <%= ok ? "bg-success" : "bg-danger" %>"><%= ok ? "ผ่าน" : "ไม่ผ่าน" %></span></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <!-- กล่องแสดงโค้ดที่อัปเกรดความฉลาดแล้ว -->
        <div class="row text-start mb-4">
            <div class="col-md-6 mb-3 mb-md-0">
                <label class="fw-bold text-dark mb-2"><i class="bi bi-code-square text-primary me-1"></i> 1. Pseudocode:</label>
                <textarea class="code-display" readonly><%= escHtml(generatedPseudocode) %></textarea>
            </div>
            <div class="col-md-6">
                <label class="fw-bold text-dark mb-2"><i class="bi bi-filetype-js text-warning me-1"></i> 2. Compiled JavaScript:</label>
                <textarea class="code-display js-display" readonly><%= escHtml(displayJS) %></textarea>
            </div>
        </div>

        <div class="d-flex justify-content-center gap-3 mt-4">
            <% String modeParam = request.getParameter("mode") != null ? request.getParameter("mode") : "student"; %>
            <% if (isJsonInput) { %>
                <a href="Design_Flowchart.jsp?questionId=<%= questionId %>&mode=<%= modeParam %>" class="btn btn-outline-primary px-4 py-2 shadow-sm">
                    <i class="bi bi-diagram-3 me-2"></i>Return to Flowchart
                </a>
            <% } else { %>
                <a href="Design_Pseudocode.jsp?questionId=<%= questionId %>&mode=<%= modeParam %>" class="btn btn-outline-primary px-4 py-2 shadow-sm">
                    <i class="bi bi-code-square me-2"></i>Return to Pseudocode
                </a>
            <% } %>
            <a href="StudentsPart.jsp?id=<%= questionId %>" class="btn btn-primary px-4 py-2 shadow-sm">
                <i class="bi bi-list-task me-2"></i>View Question
            </a>
        </div>
    </div>
</body>
</html>