<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="db.DBConnection" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private static class JsonReader {
        private final String s;
        private int i = 0;
        JsonReader(String s) { this.s = s == null ? "" : s; }
        Object parse() {
            Object v = value();
            ws();
            if (i != s.length()) throw new IllegalArgumentException("JSON มีข้อมูลส่วนเกิน");
            return v;
        }
        private void ws() { while (i < s.length() && Character.isWhitespace(s.charAt(i))) i++; }
        private Object value() {
            ws();
            if (i >= s.length()) throw new IllegalArgumentException("JSON ว่าง");
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
            if (i < s.length() && s.charAt(i) == '.') {
                i++;
                while (i < s.length() && Character.isDigit(s.charAt(i))) i++;
            }
            if (st == i) throw new IllegalArgumentException("JSON ไม่ถูกต้อง ตำแหน่ง " + i);
            String n = s.substring(st, i);
            return n.contains(".") ? Double.valueOf(n) : Long.valueOf(n);
        }
        private Map<String, Object> object() {
            Map<String, Object> m = new LinkedHashMap<String, Object>();
            i++;
            ws();
            if (i < s.length() && s.charAt(i) == '}') { i++; return m; }
            while (true) {
                ws();
                if (i >= s.length() || s.charAt(i) != '"') throw new IllegalArgumentException("ต้องใช้ key แบบข้อความใน JSON");
                String k = string();
                ws();
                if (i >= s.length() || s.charAt(i++) != ':') throw new IllegalArgumentException("ขาด : ใน JSON");
                m.put(k, value());
                ws();
                if (i < s.length() && s.charAt(i) == '}') { i++; return m; }
                if (i >= s.length() || s.charAt(i++) != ',') throw new IllegalArgumentException("ขาด , ใน JSON");
            }
        }
        private List<Object> array() {
            List<Object> a = new ArrayList<Object>();
            i++;
            ws();
            if (i < s.length() && s.charAt(i) == ']') { i++; return a; }
            while (true) {
                a.add(value());
                ws();
                if (i < s.length() && s.charAt(i) == ']') { i++; return a; }
                if (i >= s.length() || s.charAt(i++) != ',') throw new IllegalArgumentException("ขาด , ใน array");
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
                        case 'n': b.append('\n'); break;
                        case 'r': b.append('\r'); break;
                        case 't': b.append('\t'); break;
                        case 'b': b.append('\b'); break;
                        case 'f': b.append('\f'); break;
                        case 'u':
                            if (i + 4 > s.length()) throw new IllegalArgumentException("Unicode JSON ไม่ครบ");
                            b.append((char) Integer.parseInt(s.substring(i, i + 4), 16));
                            i += 4;
                            break;
                        default: b.append(e);
                    }
                } else {
                    b.append(c);
                }
            }
            throw new IllegalArgumentException("ข้อความ JSON ไม่ปิดเครื่องหมาย");
        }
    }

    private static String escHtml(Object value) {
        String s = value == null ? "" : String.valueOf(value);
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private static String textOf(Object o) { return o == null ? "null" : String.valueOf(o); }
    private static Object evalExpr(String expression, Map<String, Object> vars) { return new ExprReader(expression, vars).parse(); }
    private static boolean truth(Object o) {
        if (o == null) return false;
        if (o instanceof Boolean) return ((Boolean) o).booleanValue();
        if (o instanceof Number) return ((Number) o).doubleValue() != 0;
        return !String.valueOf(o).isEmpty();
    }
    private static double number(Object o) {
        if (o instanceof Number) return ((Number) o).doubleValue();
        try {
            return Double.parseDouble(String.valueOf(o));
        } catch (Exception e) {
            throw new IllegalArgumentException("ไม่ใช่ตัวเลข: " + o);
        }
    }
    private static String displayValue(Object o) {
        if (o == null) return "null";
        if (o instanceof Double) {
            double d = ((Double) o).doubleValue();
            if (d == Math.rint(d)) return String.valueOf((long) d);
        }
        if (o instanceof Long) return String.valueOf(o);
        return String.valueOf(o);
    }

    private static class ExprReader {
        private final List<String> t = new ArrayList<String>();
        private final Map<String, Object> vars;
        private int p = 0;
        ExprReader(String s, Map<String, Object> v) {
            vars = v;
            java.util.regex.Matcher m = java.util.regex.Pattern.compile("\\s*(>=|<=|==|!=|&&|\\|\\||[()+*/%<>!-]|-(?!>)|\\b(?:and|or|not)\\b|[A-Za-z_][A-Za-z0-9_]*|(?:\\d+\\.?\\d*|\\.\\d+)|'(?:[^'\\\\]|\\\\.)*'|\"(?:[^\"\\\\]|\\\\.)*\")", java.util.regex.Pattern.CASE_INSENSITIVE).matcher(s == null ? "" : s);
            int end = 0;
            while (m.find()) {
                if (m.start() != end && !s.substring(end, m.start()).trim().isEmpty())
                    throw new IllegalArgumentException("นิพจน์ไม่รองรับ: " + s.substring(end, m.start()));
                t.add(m.group().trim());
                end = m.end();
            }
            if (s != null && !s.substring(end).trim().isEmpty())
                throw new IllegalArgumentException("นิพจน์ไม่รองรับ: " + s.substring(end));
        }
        Object parse() {
            Object v = or();
            if (p < t.size()) throw new IllegalArgumentException("นิพจน์มีส่วนเกิน: " + t.get(p));
            return v;
        }
        boolean eat(String... ss) {
            if (p < t.size())
                for (String s : ss)
                    if (t.get(p).equalsIgnoreCase(s)) { p++; return true; }
            return false;
        }
        Object or() {
            Object a = and();
            while (eat("||", "or")) {
                Object b = and();
                a = Boolean.valueOf(truth(a) || truth(b));
            }
            return a;
        }
        Object and() {
            Object a = compare();
            while (eat("&&", "and")) {
                Object b = compare();
                a = Boolean.valueOf(truth(a) && truth(b));
            }
            return a;
        }
        Object compare() {
            Object a = add();
            while (p < t.size()) {
                String op = t.get(p);
                if (!Arrays.asList("==", "!=", ">", "<", ">=", "<=").contains(op)) break;
                p++;
                Object b = add();
                int c;
                if (a instanceof Number && b instanceof Number) c = Double.compare(number(a), number(b));
                else c = textOf(a).compareTo(textOf(b));
                boolean r = op.equals("==") ? (a instanceof Number && b instanceof Number ? c == 0 : Objects.equals(a, b) || textOf(a).equals(textOf(b))) :
                            op.equals("!=") ? (a instanceof Number && b instanceof Number ? c != 0 : !(Objects.equals(a, b) || textOf(a).equals(textOf(b)))) :
                            op.equals(">") ? c > 0 :
                            op.equals("<") ? c < 0 :
                            op.equals(">=") ? c >= 0 : c <= 0;
                a = Boolean.valueOf(r);
            }
            return a;
        }
        Object add() {
            Object a = mul();
            while (p < t.size() && (t.get(p).equals("+") || t.get(p).equals("-"))) {
                String op = t.get(p++);
                Object b = mul();
                if (op.equals("+") && (a instanceof String || b instanceof String)) a = textOf(a) + textOf(b);
                else a = Double.valueOf(op.equals("+") ? number(a) + number(b) : number(a) - number(b));
            }
            return a;
        }
        Object mul() {
            Object a = unary();
            while (p < t.size() && Arrays.asList("*", "/", "%").contains(t.get(p))) {
                String op = t.get(p++);
                Object b = unary();
                double n = op.equals("*") ? number(a) * number(b) : op.equals("/") ? number(a) / number(b) : number(a) % number(b);
                if (Double.isInfinite(n) || Double.isNaN(n)) throw new IllegalArgumentException("ผลคำนวณไม่ถูกต้อง");
                a = Double.valueOf(n);
            }
            return a;
        }
        Object unary() {
            if (eat("!", "not")) return Boolean.valueOf(!truth(unary()));
            if (eat("-")) return Double.valueOf(-number(unary()));
            if (eat("+")) return Double.valueOf(number(unary()));
            return atom();
        }
        Object atom() {
            if (eat("(")) {
                Object v = or();
                if (!eat(")")) throw new IllegalArgumentException("ขาด )");
                return v;
            }
            if (p >= t.size()) throw new IllegalArgumentException("นิพจน์ว่าง");
            String x = t.get(p++);
            if (x.startsWith("'") || x.startsWith("\"")) return x.substring(1, x.length() - 1);
            if (x.equalsIgnoreCase("true")) return Boolean.TRUE;
            if (x.equalsIgnoreCase("false")) return Boolean.FALSE;
            if (x.matches("(?:\\d+\\.?\\d*|\\.\\d+)")) return Double.valueOf(x);
            if (!vars.containsKey(x)) throw new IllegalArgumentException("ไม่พบตัวแปร " + x);
            return vars.get(x);
        }
    }

    private static String stripPrefix(String s, String regex) {
        return s == null ? "" : s.trim().replaceFirst("(?i)^\\s*(?:" + regex + ")\\s*", "").trim();
    }

    private static void parseInputs(String inputJson, List<String> detectedVars, Map<String, Object> vars) {
        try {
            Object in = new JsonReader(inputJson).parse();
            if (in instanceof Map) {
                Map im = (Map) in;
                for (Object k : im.keySet()) vars.put(String.valueOf(k), im.get(k));
                return;
            }
        } catch (Exception ignored) {}

        if (inputJson != null && !inputJson.trim().isEmpty()) {
            String[] tokens = inputJson.split(",");
            for (int k = 0; k < tokens.length; k++) {
                String valStr = tokens[k].trim();
                Object parsedVal;
                try {
                    parsedVal = Double.parseDouble(valStr);
                } catch (Exception ex) {
                    parsedVal = valStr;
                }
                if (k < detectedVars.size()) {
                    vars.put(detectedVars.get(k), parsedVal);
                }
                vars.put("input_" + (k + 1), parsedVal);
            }
        }
    }

    private static Map<String, Object> runFlowchart(String json, String inputJson) {
        Object rootObj = new JsonReader(json).parse();
        if (!(rootObj instanceof Map)) throw new IllegalArgumentException("Flowchart JSON ไม่ถูกต้อง");
        Map root = (Map) rootObj;
        Object no = root.get("nodes"), eo = root.get("edges");
        if (!(no instanceof List) || ((List) no).isEmpty()) throw new IllegalArgumentException("ไม่พบ Node");

        List<Map<String, Object>> nodes = (List<Map<String, Object>>) no;
        List<Map<String, Object>> edges = eo instanceof List ? (List<Map<String, Object>>) eo : new ArrayList<Map<String, Object>>();
        Map<String, Map<String, Object>> byId = new HashMap<String, Map<String, Object>>();
        for (Map<String, Object> n : nodes) byId.put(textOf(n.get("id")), n);

        List<String> detectedVars = new ArrayList<String>();
        for (Map<String, Object> n : nodes) {
            if ("input".equalsIgnoreCase(textOf(n.get("type")))) {
                String rawIn = stripPrefix(textOf(n.get("text")), "input|read|enter|รับค่า|รับข้อมูล");
                for (String v : rawIn.split("[,/]")) {
                    String cleanV = v.replaceAll("[^A-Za-z0-9_]", "").trim();
                    if (!cleanV.isEmpty()) detectedVars.add(cleanV);
                }
            }
        }

        Map<String, Object> vars = new LinkedHashMap<String, Object>();
        parseInputs(inputJson, detectedVars, vars);

        Map<String, Object> start = null;
        for (Map<String, Object> n : nodes) {
            if ("start".equalsIgnoreCase(textOf(n.get("type"))) && textOf(n.get("text")).toLowerCase().contains("start")) {
                start = n;
                break;
            }
        }
        if (start == null) for (Map<String, Object> n : nodes) if ("start".equalsIgnoreCase(textOf(n.get("type")))) { start = n; break; }
        if (start == null) throw new IllegalArgumentException("ไม่พบ Start node");

        String current = textOf(start.get("id"));
        String startId = current;
        List<String> outs = new ArrayList<String>();
        Set<String> visited = new HashSet<String>();
        int steps = 0;

        while (current != null && steps++ < 500) {
            Map<String, Object> n = byId.get(current);
            if (n == null) throw new IllegalArgumentException("เส้นเชื่อมไปยัง Node ที่ไม่มีอยู่");
            String type = textOf(n.get("type")).toLowerCase();
            String raw = textOf(n.get("text")).trim();

            if (!current.equals(startId) && type.equals("start") && raw.toLowerCase().contains("end")) break;

            if (type.equals("input")) {
                String varStr = stripPrefix(raw, "input|read|enter|รับค่า|รับข้อมูล");
                String[] varNames = varStr.split("[,/]");
                for (String rawVar : varNames) {
                    String var = rawVar.replaceAll("[^A-Za-z0-9_]", "").trim();
                    if (!var.isEmpty()) {
                        if (!vars.containsKey(var)) throw new IllegalArgumentException("Test Case ไม่มีค่า Input ของตัวแปร " + var);
                    }
                }
            } else if (type.equals("process")) {
                String stmt = raw.replaceFirst("(?i)^process\\s*:?\\s*", "").trim();
                java.util.regex.Matcher am = java.util.regex.Pattern.compile("^([A-Za-z_][A-Za-z0-9_]*)\\s*(?:=|←|<-|:=)\\s*(.+)$").matcher(stmt);
                if (!am.matches()) throw new IllegalArgumentException("Process ต้องเป็นการกำหนดค่า เช่น B = A * 2");
                vars.put(am.group(1), evalExpr(am.group(2), vars));
            } else if (type.equals("display")) {
                String expr = stripPrefix(raw, "display|output|print|show|แสดงผล|แสดง");
                if (expr.isEmpty()) throw new IllegalArgumentException("Display ต้องระบุค่าที่จะแสดง เช่น Display B");
                outs.add(displayValue(evalExpr(expr, vars)));
            }

            List<Map<String, Object>> outgoing = new ArrayList<Map<String, Object>>();
            for (Map<String, Object> e : edges) if (current.equals(textOf(e.get("from")))) outgoing.add(e);

            if (type.equals("decision")) {
                Object cond = evalExpr(raw.replaceFirst("(?i)^decision\\s*:?\\s*", "").trim(), vars);
                boolean yes = truth(cond);
                Map<String, Object> chosen = null;
                for (Map<String, Object> e : outgoing) {
                    String label = (textOf(e.get("label")) + " " + textOf(e.get("type"))).toLowerCase();
                    if (yes && (label.contains("yes") || label.contains("true") || label.contains("ใช่"))) { chosen = e; break; }
                    if (!yes && (label.contains("no") || label.contains("false") || label.contains("ไม่"))) { chosen = e; break; }
                }
                if (chosen == null) throw new IllegalArgumentException("Decision ต้องมีเส้น Yes และ No (หรือ True และ False)");
                current = textOf(chosen.get("to"));
                continue;
            }

            Map<String, Object> next = null;
            for (Map<String, Object> e : outgoing) {
                String label = (textOf(e.get("label")) + " " + textOf(e.get("type"))).toLowerCase();
                if (label.contains("yes") || label.contains("no") || label.contains("true") || label.contains("false")) continue;
                if (next == null) next = e;
            }
            if (next == null && outgoing.size() == 1) next = outgoing.get(0);
            if (next == null) break;

            String to = textOf(next.get("to"));
            if (visited.contains(current) && to.equals(current)) throw new IllegalArgumentException("ตรวจพบ Loop ที่วนอยู่ Node เดิม");
            visited.add(current);
            current = to;
        }

        if (steps >= 500) throw new IllegalArgumentException("Flowchart ทำงานเกิน 500 ขั้น อาจมี Loop ไม่สิ้นสุด");
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("output", String.join("\n", outs));
        result.put("variables", vars);
        return result;
    }

    private static int executePseudocodeBlock(List<String> lines, int idx, Map<String, Object> vars, List<String> outs) {
        while (idx < lines.size()) {
            String line = lines.get(idx).trim();
            if (line.isEmpty() || line.equalsIgnoreCase("begin") || line.equalsIgnoreCase("end")) {
                idx++;
                continue;
            }
            if (line.equalsIgnoreCase("endif") || line.equalsIgnoreCase("endwhile") || line.equalsIgnoreCase("else")) {
                return idx;
            }
            if (line.toLowerCase().startsWith("input ") || line.toLowerCase().startsWith("read ") || line.toLowerCase().startsWith("enter ")) {
                String varStr = stripPrefix(line, "input|read|enter");
                for (String v : varStr.split("[,/]")) {
                    String cleanV = v.replaceAll("[^A-Za-z0-9_]", "").trim();
                    if (!cleanV.isEmpty() && !vars.containsKey(cleanV)) {
                        throw new IllegalArgumentException("Test Case ไม่มีค่า Input ของตัวแปร " + cleanV);
                    }
                }
                idx++;
            } else if (line.toLowerCase().startsWith("print ") || line.toLowerCase().startsWith("output ")) {
                String expr = stripPrefix(line, "print|output");
                outs.add(displayValue(evalExpr(expr, vars)));
                idx++;
            } else if (line.toLowerCase().startsWith("if ") || line.toLowerCase().startsWith("if(")) {
                String condStr = line.replaceFirst("(?i)^if\\s*\\(?", "").replaceAll("\\)?\\s*\\{\\s*$", "").trim();
                if (condStr.endsWith("{")) condStr = condStr.substring(0, condStr.length() - 1).trim();
                boolean cond = truth(evalExpr(condStr, vars));

                idx++;
                List<String> thenBlock = new ArrayList<String>();
                List<String> elseBlock = new ArrayList<String>();
                boolean inElse = false;
                int depth = 1;
                while (idx < lines.size() && depth > 0) {
                    String l = lines.get(idx).trim();
                    if (l.toLowerCase().startsWith("if ") || l.toLowerCase().startsWith("if(")) {
                        depth++;
                    } else if (l.equalsIgnoreCase("endif")) {
                        depth--;
                        if (depth == 0) { idx++; break; }
                    } else if (l.equalsIgnoreCase("else") && depth == 1) {
                        inElse = true;
                        idx++;
                        continue;
                    }
                    if (depth > 0) {
                        if (inElse) elseBlock.add(lines.get(idx));
                        else thenBlock.add(lines.get(idx));
                    }
                    idx++;
                }
                if (cond) executePseudocodeBlock(thenBlock, 0, vars, outs);
                else executePseudocodeBlock(elseBlock, 0, vars, outs);
            } else if (line.toLowerCase().startsWith("while ") || line.toLowerCase().startsWith("while(")) {
                String condStr = line.replaceFirst("(?i)^while\\s*\\(?", "").replaceAll("\\)?\\s*\\{\\s*$", "").trim();
                if (condStr.endsWith("{")) condStr = condStr.substring(0, condStr.length() - 1).trim();

                idx++;
                List<String> bodyBlock = new ArrayList<String>();
                int depth = 1;
                while (idx < lines.size() && depth > 0) {
                    String l = lines.get(idx).trim();
                    if (l.toLowerCase().startsWith("while ") || l.toLowerCase().startsWith("while(")) {
                        depth++;
                    } else if (l.equalsIgnoreCase("endwhile")) {
                        depth--;
                        if (depth == 0) { idx++; break; }
                    }
                    if (depth > 0) bodyBlock.add(lines.get(idx));
                    idx++;
                }

                int loopCount = 0;
                while (truth(evalExpr(condStr, vars))) {
                    if (loopCount++ > 500) throw new IllegalArgumentException("ตรวจพบ Loop ไม่สิ้นสุด");
                    executePseudocodeBlock(bodyBlock, 0, vars, outs);
                }
            } else {
                String stmt = line.replaceAll(";$", "").trim();
                java.util.regex.Matcher am = java.util.regex.Pattern.compile("^([A-Za-z_][A-Za-z0-9_]*)\\s*(?:=|←|<-|:=)\\s*(.+)$").matcher(stmt);
                if (am.matches()) {
                    vars.put(am.group(1), evalExpr(am.group(2), vars));
                }
                idx++;
            }
        }
        return idx;
    }

    private static Map<String, Object> runPseudocode(String pseudocodeText, String inputJson) {
        String[] rawLines = pseudocodeText.split("\n");
        List<String> lines = new ArrayList<String>();
        List<String> detectedVars = new ArrayList<String>();

        for (String l : rawLines) {
            lines.add(l);
            String trimmed = l.trim();
            if (trimmed.toLowerCase().startsWith("input") || trimmed.toLowerCase().startsWith("read") || trimmed.toLowerCase().startsWith("enter")) {
                String varStr = stripPrefix(trimmed, "input|read|enter");
                for (String v : varStr.split("[,/]")) {
                    String cleanV = v.replaceAll("[^A-Za-z0-9_]", "").trim();
                    if (!cleanV.isEmpty()) detectedVars.add(cleanV);
                }
            }
        }

        Map<String, Object> vars = new LinkedHashMap<String, Object>();
        parseInputs(inputJson, detectedVars, vars);

        List<String> outs = new ArrayList<String>();
        executePseudocodeBlock(lines, 0, vars, outs);

        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("output", String.join("\n", outs));
        result.put("variables", vars);
        return result;
    }

    private static boolean sameOutput(String actual, String expected) {
        String a = actual == null ? "" : actual.trim().replace("\r\n", "\n");
        String e = expected == null ? "" : expected.trim().replace("\r\n", "\n");
        if (a.equals(e)) return true;
        try { return Double.compare(Double.parseDouble(a), Double.parseDouble(e)) == 0; } catch (Exception ignored) { return false; }
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    String questionIdParam = request.getParameter("questionId");
    String flowchartData = request.getParameter("flowchartData");
    if (flowchartData == null || flowchartData.trim().isEmpty()) {
        flowchartData = "{\"nodes\":[],\"edges\":[]}";
    }

    boolean isJsonInput = flowchartData.trim().startsWith("{");

    String safeJsonForJs = flowchartData
            .replace("\\", "\\\\")
            .replace("'", "\\'")
            .replace("\r", "\\r")
            .replace("\n", "\\n")
            .replace("</", "<\\/");

    Object userIdObj = session.getAttribute("UserId");
    Object roleObj = session.getAttribute("Role");

    if (userIdObj == null || roleObj == null || !"student".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect("index.jsp?error=1");
        return;
    }

    int studentId;
    int questionId;

    try {
        studentId = Integer.parseInt(userIdObj.toString());
        if (questionIdParam == null || !questionIdParam.matches("\\d+")) {
            throw new IllegalArgumentException("ไม่พบรหัสโจทย์");
        }
        questionId = Integer.parseInt(questionIdParam);
        if (studentId <= 0 || questionId <= 0) {
            throw new IllegalArgumentException("รหัสไม่ถูกต้อง");
        }
    } catch (Exception e) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "รหัสโจทย์หรือข้อมูลผู้ใช้ไม่ถูกต้อง");
        return;
    }

    List<Map<String, Object>> testCases = new ArrayList<Map<String, Object>>();
    boolean authorized = false;

    try (Connection con = DBConnection.getConnection()) {
        if (con == null) throw new SQLException("เชื่อมต่อฐานข้อมูลไม่สำเร็จ");

        String authSql = "SELECT q.id FROM questions q JOIN users u ON u.id = ? WHERE q.id = ? AND q.status = 'ON' AND u.role = 'student' AND u.status = 'ON' AND u.sec IS NOT NULL AND FIND_IN_SET(CAST(u.sec AS CHAR), REPLACE(CAST(q.sec AS CHAR), ' ', '')) > 0";
        try (PreparedStatement ps = con.prepareStatement(authSql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, questionId);
            try (ResultSet rs = ps.executeQuery()) { authorized = rs.next(); }
        }

        if (!authorized) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "ไม่มีสิทธิ์ทำโจทย์นี้");
            return;
        }

        String testSql = "SELECT id, case_no, input_data, expected_output, point FROM algorithm_test_cases WHERE question_id = ? ORDER BY case_no ASC";
        try (PreparedStatement ps = con.prepareStatement(testSql)) {
            ps.setInt(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> tc = new HashMap<String, Object>();
                    tc.put("id", rs.getInt("id"));
                    tc.put("case_no", rs.getInt("case_no"));
                    tc.put("input_data", rs.getString("input_data"));
                    tc.put("expected_output", rs.getString("expected_output"));
                    tc.put("point", rs.getInt("point"));
                    testCases.add(tc);
                }
            }
        }
    } catch (SQLException e) {
        application.log("Load Test Cases failed", e);
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "ไม่สามารถโหลด Test Case ได้");
        return;
    }

    if (testCases.isEmpty()) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "โจทย์นี้ยังไม่มี Test Case");
        return;
    }

    List<Map<String, Object>> caseResults = new ArrayList<Map<String, Object>>();
    int totalScore = 0;
    int passedCount = 0;

    for (Map<String, Object> tc : testCases) {
        Map<String, Object> cr = new LinkedHashMap<String, Object>();
        cr.put("case_no", tc.get("case_no"));
        cr.put("input_data", tc.get("input_data"));
        cr.put("expected_output", tc.get("expected_output"));
        cr.put("point", tc.get("point"));
        String actualOutput = "";
        String errorMessage = "";
        boolean passed = false;

        try {
            Map<String, Object> runResult;
            if (isJsonInput) {
                runResult = runFlowchart(flowchartData, String.valueOf(tc.get("input_data")));
            } else {
                runResult = runPseudocode(flowchartData, String.valueOf(tc.get("input_data")));
            }
            actualOutput = String.valueOf(runResult.get("output"));
            passed = sameOutput(actualOutput, String.valueOf(tc.get("expected_output")));
        } catch (Exception runError) {
            errorMessage = runError.getMessage() == null ? "ประมวลผลไม่สำเร็จ" : runError.getMessage();
            application.log("Test case " + tc.get("case_no") + " failed to execute", runError);
        }

        int casePoint = ((Number) tc.get("point")).intValue();
        if (passed) { totalScore += casePoint; passedCount++; }
        cr.put("actual_output", actualOutput);
        cr.put("passed", Boolean.valueOf(passed));
        cr.put("error", errorMessage);
        caseResults.add(cr);
    }

    try (Connection con = DBConnection.getConnection()) {
        if (con == null) throw new SQLException("เชื่อมต่อฐานข้อมูลไม่สำเร็จ");

        String saveSql = "INSERT INTO algorithm_submissions (question_id, student_id, answer_text, score, status) VALUES (?, ?, ?, ?, 'GRADED') ON DUPLICATE KEY UPDATE answer_text = VALUES(answer_text), score = VALUES(score), status = 'GRADED', submitted_at = CURRENT_TIMESTAMP";
        try (PreparedStatement ps = con.prepareStatement(saveSql)) {
            ps.setInt(1, questionId);
            ps.setInt(2, studentId);
            ps.setString(3, flowchartData);
            ps.setInt(4, totalScore);
            ps.executeUpdate();
        }
    } catch (SQLException e) {
        application.log("Save submission failed", e);
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "ไม่สามารถบันทึกคำตอบได้");
        return;
    }
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
        <h2 class="fw-bold mb-4" style="color: #1e3a8a;">ตรวจคำตอบสำเร็จ!</h2>
        
        <div class="alert alert-primary text-start mb-4">
            <h5 class="fw-bold mb-2">ผลการตรวจ Test Case</h5>
            <div>ผ่าน <strong><%= passedCount %> / <%= testCases.size() %></strong> เคส</div>
            <div>คะแนนที่ได้ <strong><%= totalScore %></strong> คะแนน</div>
            <small class="text-muted">ระบบนำ input_data ของแต่ละเคสเข้าประมวลผลแล้วเปรียบเทียบผลลัพธ์กับ expected_output</small>
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
                                <div class="small text-danger"><%= escHtml(cr.get("error")) %></div>
                            <% } %>
                        </td>
                        <td><%= ok ? escHtml(cr.get("point")) : "0" %> / <%= escHtml(cr.get("point")) %></td>
                        <td><span class="badge <%= ok ? "bg-success" : "bg-danger" %>"><%= ok ? "ผ่าน" : "ไม่ผ่าน" %></span></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <div class="row text-start mb-4">
            <div class="col-md-6 mb-3 mb-md-0">
                <label class="fw-bold text-dark mb-2"><i class="bi bi-code-square text-primary me-1"></i> 1. Generated Pseudocode:</label>
                <textarea class="code-display" id="pseudocodeOutput" readonly>กำลังโหลด...</textarea>
            </div>
            <div class="col-md-6">
                <label class="fw-bold text-dark mb-2"><i class="bi bi-filetype-js text-warning me-1"></i> 2. JavaScript Code:</label>
                <textarea class="code-display js-display" id="jsOutput" readonly>กำลังโหลด...</textarea>
            </div>
        </div>
    </div>
</body>
</html>