<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="db.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    // Minimal JSON parser: accepts JSON objects, arrays, strings, numbers, booleans and null.
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
            ws();
            if (i >= s.length()) throw new IllegalArgumentException("JSON ว่าง");
            char c = s.charAt(i);
            if (c == '{') return object();
            if (c == '[') return array();
            if (c == '"') return string();
            if (s.startsWith("true", i)) { i += 4; return Boolean.TRUE; }
            if (s.startsWith("false", i)) { i += 5; return Boolean.FALSE; }
            if (s.startsWith("null", i)) { i += 4; return null; }
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
        private Map<String,Object> object() {
            Map<String,Object> m = new LinkedHashMap<String,Object>();
            i++; ws();
            if (i < s.length() && s.charAt(i) == '}') { i++; return m; }
            while (true) {
                ws();
                if (i >= s.length() || s.charAt(i) != '"')
                    throw new IllegalArgumentException("JSON object ต้องมี key เป็นข้อความ");
                String k = string(); ws();
                if (i >= s.length() || s.charAt(i++) != ':')
                    throw new IllegalArgumentException("ขาด : ใน JSON");
                m.put(k, value()); ws();
                if (i < s.length() && s.charAt(i) == '}') { i++; return m; }
                if (i >= s.length() || s.charAt(i++) != ',')
                    throw new IllegalArgumentException("ขาด , ใน JSON object");
            }
        }
        private List<Object> array() {
            List<Object> a = new ArrayList<Object>();
            i++; ws();
            if (i < s.length() && s.charAt(i) == ']') { i++; return a; }
            while (true) {
                a.add(value()); ws();
                if (i < s.length() && s.charAt(i) == ']') { i++; return a; }
                if (i >= s.length() || s.charAt(i++) != ',')
                    throw new IllegalArgumentException("ขาด , ใน JSON array");
            }
        }
        private String string() {
            StringBuilder b = new StringBuilder(); i++;
            while (i < s.length()) {
                char c = s.charAt(i++);
                if (c == '"') return b.toString();
                if (c == '\\') {
                    if (i >= s.length()) break;
                    char e = s.charAt(i++);
                    switch (e) {
                        case '"': b.append('"'); break;
                        case '\\': b.append('\\'); break;
                        case '/': b.append('/'); break;
                        case 'n': b.append('\n'); break;
                        case 'r': b.append('\r'); break;
                        case 't': b.append('\t'); break;
                        case 'b': b.append('\b'); break;
                        case 'f': b.append('\f'); break;
                        case 'u':
                            if (i + 4 > s.length()) throw new IllegalArgumentException("Unicode JSON ไม่ครบ");
                            b.append((char)Integer.parseInt(s.substring(i, i + 4), 16)); i += 4; break;
                        default: b.append(e);
                    }
                } else b.append(c);
            }
            throw new IllegalArgumentException("ข้อความ JSON ไม่ปิดเครื่องหมาย");
        }
    }

    private static String str(Object o) { return o == null ? "" : String.valueOf(o).trim(); }
    @SuppressWarnings("unchecked")
    private static Map<String,Object> map(Object o) {
        return o instanceof Map ? (Map<String,Object>)o : new LinkedHashMap<String,Object>();
    }
    @SuppressWarnings("unchecked")
    private static List<Object> list(Object o) {
        return o instanceof List ? (List<Object>)o : new ArrayList<Object>();
    }
    private static String jsonString(String s) {
        if (s == null) return "null";
        StringBuilder b = new StringBuilder("\"");
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"': b.append("\\\""); break;
                case '\\': b.append("\\\\"); break;
                case '\b': b.append("\\b"); break;
                case '\f': b.append("\\f"); break;
                case '\n': b.append("\\n"); break;
                case '\r': b.append("\\r"); break;
                case '\t': b.append("\\t"); break;
                default:
                    if (c < 32) b.append(String.format("\\u%04x", (int)c));
                    else b.append(c);
            }
        }
        return b.append('"').toString();
    }
    private static String jsonValue(Object o) {
        if (o == null) return "null";
        if (o instanceof String) return jsonString((String)o);
        if (o instanceof Number || o instanceof Boolean) return String.valueOf(o);
        if (o instanceof Map) {
            StringBuilder b = new StringBuilder("{"); boolean first = true;
            for (Object entryObj : ((Map)o).entrySet()) {
                Map.Entry entry = (Map.Entry)entryObj;
                if (!first) b.append(",");
                first = false;
                b.append(jsonString(String.valueOf(entry.getKey()))).append(":").append(jsonValue(entry.getValue()));
            }
            return b.append("}").toString();
        }
        if (o instanceof List) {
            StringBuilder b = new StringBuilder("["); boolean first = true;
            for (Object item : (List)o) {
                if (!first) b.append(",");
                first = false; b.append(jsonValue(item));
            }
            return b.append("]").toString();
        }
        return jsonString(String.valueOf(o));
    }

    // Convert drawing JSON into schema and relationship records.
    // Supported drawing format: {version, nodes:[{id,type,text,x,y}], edges:[{from,to,label}]}
    private static Map<String,Object> normalizeER(String rawJson) {
        Object parsed = new JsonReader(rawJson).parse();
        Map<String,Object> root = map(parsed);
        List<Object> rawNodes = list(root.get("nodes"));
        List<Object> rawEdges = list(root.get("edges"));
        if (rawNodes.isEmpty()) throw new IllegalArgumentException("ไม่พบโหนดใน ER Diagram");

        Map<String,Map<String,Object>> byId = new LinkedHashMap<String,Map<String,Object>>();
        for (Object obj : rawNodes) {
            Map<String,Object> n = map(obj);
            String id = str(n.get("id"));
            if (id.isEmpty()) throw new IllegalArgumentException("โหนดไม่มี id");
            if (byId.containsKey(id)) throw new IllegalArgumentException("พบ id โหนดซ้ำ: " + id);
            byId.put(id, n);
        }

        List<Map<String,Object>> edges = new ArrayList<Map<String,Object>>();
        Map<String,List<Map<String,Object>>> adjacent = new HashMap<String,List<Map<String,Object>>>();
        for (Object obj : rawEdges) {
            Map<String,Object> e = map(obj);
            String from = str(e.get("from")), to = str(e.get("to"));
            if (!byId.containsKey(from) || !byId.containsKey(to))
                throw new IllegalArgumentException("เส้นเชื่อมอ้างอิงโหนดที่ไม่มีอยู่");
            edges.add(e);
            if (!adjacent.containsKey(from)) adjacent.put(from, new ArrayList<Map<String,Object>>());
            if (!adjacent.containsKey(to)) adjacent.put(to, new ArrayList<Map<String,Object>>());
            Map<String,Object> forward = new LinkedHashMap<String,Object>(e);
            forward.put("_other", to);
            adjacent.get(from).add(forward);
            Map<String,Object> backward = new LinkedHashMap<String,Object>(e);
            backward.put("_other", from);
            adjacent.get(to).add(backward);
        }

        List<Object> tables = new ArrayList<Object>();
        List<Object> relationships = new ArrayList<Object>();
        for (Map.Entry<String,Map<String,Object>> entry : byId.entrySet()) {
            String id = entry.getKey();
            Map<String,Object> node = entry.getValue();
            String type = str(node.get("type"));
            String text = str(node.get("text"));
            if ("entity".equalsIgnoreCase(type) || "weakEntity".equalsIgnoreCase(type)) {
                Map<String,Object> table = new LinkedHashMap<String,Object>();
                table.put("node_id", id);
                table.put("name", text);
                table.put("entity_type", type);
                List<Object> columns = new ArrayList<Object>();
                for (Map<String,Object> edge : adjacent.containsKey(id) ? adjacent.get(id) : new ArrayList<Map<String,Object>>()) {
                    String otherId = str(edge.get("_other"));
                    Map<String,Object> other = byId.get(otherId);
                    String otherType = str(other.get("type"));
                    if ("attribute".equalsIgnoreCase(otherType)
                            || "primaryKey".equalsIgnoreCase(otherType)
                            || "foreignKey".equalsIgnoreCase(otherType)
                            || "multiValuedAttribute".equalsIgnoreCase(otherType)
                            || "derivedAttribute".equalsIgnoreCase(otherType)) {
                        Map<String,Object> col = new LinkedHashMap<String,Object>();
                        col.put("node_id", otherId);
                        col.put("name", str(other.get("text")).replaceFirst("(?i)\\s*\\(fk\\)\\s*$", ""));
                        String key = "NORMAL";
                        if ("primaryKey".equalsIgnoreCase(otherType)) key = "PK";
                        if ("foreignKey".equalsIgnoreCase(otherType)
                                || str(other.get("text")).matches("(?i).*\\(fk\\)\\s*$")) key = "FK";
                        col.put("key", key);
                        col.put("attribute_type", otherType);
                        columns.add(col);
                    }
                }
                table.put("columns", columns);
                tables.add(table);
            }
        }

        for (Map.Entry<String,Map<String,Object>> entry : byId.entrySet()) {
            String rid = entry.getKey();
            Map<String,Object> rnode = entry.getValue();
            String rt = str(rnode.get("type"));
            if (!"relationship".equalsIgnoreCase(rt) && !"identifyingRelationship".equalsIgnoreCase(rt)) continue;
            List<Object> endpoints = new ArrayList<Object>();
            for (Map<String,Object> edge : adjacent.containsKey(rid) ? adjacent.get(rid) : new ArrayList<Map<String,Object>>()) {
                String otherId = str(edge.get("_other"));
                Map<String,Object> other = byId.get(otherId);
                String ot = str(other.get("type"));
                if ("entity".equalsIgnoreCase(ot) || "weakEntity".equalsIgnoreCase(ot)) {
                    Map<String,Object> ep = new LinkedHashMap<String,Object>();
                    ep.put("entity_node_id", otherId);
                    ep.put("entity", str(other.get("text")));
                    ep.put("cardinality", str(edge.get("label")));
                    endpoints.add(ep);
                }
            }
            Map<String,Object> rel = new LinkedHashMap<String,Object>();
            rel.put("node_id", rid);
            rel.put("name", str(rnode.get("text")));
            rel.put("relationship_type", rt);
            rel.put("endpoints", endpoints);
            relationships.add(rel);
        }

        Map<String,Object> result = new LinkedHashMap<String,Object>();
        result.put("version", 1);
        result.put("tables", tables);
        result.put("relationships", relationships);
        result.put("node_count", byId.size());
        result.put("edge_count", edges.size());
        return result;
    }

    private static String html(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    String questionIdParam = request.getParameter("questionId");
    String drawingData = request.getParameter("erDiagramData");

    Object userIdObj = session.getAttribute("UserId");
    Object roleObj = session.getAttribute("Role");
    if (userIdObj == null || roleObj == null || !"student".equalsIgnoreCase(String.valueOf(roleObj))) {
        response.sendRedirect("index.jsp?error=1");
        return;
    }

    int studentId, questionId;
    try {
        studentId = Integer.parseInt(String.valueOf(userIdObj));
        if (questionIdParam == null || !questionIdParam.matches("\\d+"))
            throw new IllegalArgumentException("ไม่พบ questionId");
        questionId = Integer.parseInt(questionIdParam);
        if (studentId <= 0 || questionId <= 0) throw new IllegalArgumentException("รหัสไม่ถูกต้อง");
    } catch (Exception ex) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ไม่พบรหัสโจทย์หรือรหัสผู้ใช้ไม่ถูกต้อง");
        return;
    }

    if (drawingData == null || drawingData.trim().isEmpty()) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ไม่พบข้อมูล ER Diagram ที่ส่งมา");
        return;
    }

    Map<String,Object> normalized;
    String normalizedJson;
    try {
        normalized = normalizeER(drawingData);
        normalizedJson = jsonValue(normalized);
    } catch (Exception ex) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "แปลง ER Diagram ไม่สำเร็จ: " + ex.getMessage());
        return;
    }

    Connection con = null;
    String message = "บันทึกคำตอบเรียบร้อยแล้ว";
    BigDecimal totalScore = null, tableScore = null, relationshipScore = null, maxScore = null;
    String feedback = "บันทึกข้อมูลที่แปลงแล้วเรียบร้อย ยังไม่มีเฉลยสำหรับตรวจคะแนน";
    String gradingDetails = null;
    Integer answerVersion = null;
    String status = "SUBMITTED";

    try {
        con = DBConnection.getConnection();
        if (con == null) throw new SQLException("เชื่อมต่อฐานข้อมูลไม่สำเร็จ");

        // Keep the same student/question authorization rule as Process_Flowchart.jsp.
        String authSql = "SELECT q.id FROM questions q JOIN users u ON u.id = ? "
                + "WHERE q.id = ? AND q.status = 'ON' AND u.role = 'student' "
                + "AND u.status = 'ON' AND u.sec IS NOT NULL "
                + "AND FIND_IN_SET(CAST(u.sec AS CHAR), REPLACE(CAST(q.sec AS CHAR), ' ', '')) > 0";
        try (PreparedStatement ps = con.prepareStatement(authSql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "ไม่มีสิทธิ์ทำโจทย์นี้");
                    return;
                }
            }
        }

        // Load the expected answer if the teacher has created one.
        String answerSql = "SELECT expected_schema, expected_relationships, rubric_data, answer_version, max_score "
                + "FROM er_diagram_answers WHERE question_id = ?";
        try (PreparedStatement ps = con.prepareStatement(answerSql)) {
            ps.setInt(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    answerVersion = rs.getInt("answer_version");
                    maxScore = rs.getBigDecimal("max_score");
                    String expectedSchema = rs.getString("expected_schema");
                    String expectedRelationships = rs.getString("expected_relationships");
                    // Do not claim a grade until the grader is configured with valid expected data.
                    if (expectedSchema != null && !expectedSchema.trim().isEmpty()
                            && expectedRelationships != null && !expectedRelationships.trim().isEmpty()) {
                        // Grading comparison is intentionally not guessed here: the expected JSON schema
                        // must be finalized by the answer-key form before automated scores are assigned.
                        feedback = "พบเฉลยเวอร์ชัน " + answerVersion
                                + " แต่ยังต้องกำหนดตัวตรวจเปรียบเทียบ schema และ relationships ก่อนคิดคะแนน";
                    }
                }
            }
        }

        con.setAutoCommit(false);

        int attemptNo = 1;
        try (PreparedStatement attemptPs = con.prepareStatement(
                "SELECT COALESCE(MAX(attempt_no), 0) + 1 "
                + "FROM er_diagram_submissions WHERE question_id = ? AND student_id = ?")) {
            attemptPs.setInt(1, questionId);
            attemptPs.setInt(2, studentId);
            try (ResultSet attemptRs = attemptPs.executeQuery()) {
                if (attemptRs.next()) attemptNo = attemptRs.getInt(1);
            }
        }

        String saveSql = "INSERT INTO er_diagram_submissions "
                + "(question_id, student_id, answer_data, parsed_data, answer_version, score, "
                + "table_score, relationship_score, max_score, grading_details, feedback, attempt_no, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(saveSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, questionId);
            ps.setInt(2, studentId);
            ps.setString(3, drawingData);
            ps.setString(4, normalizedJson);
            if (answerVersion == null) ps.setNull(5, Types.INTEGER); else ps.setInt(5, answerVersion.intValue());
            ps.setNull(6, Types.DECIMAL);
            ps.setNull(7, Types.DECIMAL);
            ps.setNull(8, Types.DECIMAL);
            if (maxScore == null) ps.setNull(9, Types.DECIMAL); else ps.setBigDecimal(9, maxScore);
            ps.setString(10, gradingDetails);
            ps.setString(11, feedback);
            ps.setInt(12, attemptNo);
            ps.setString(13, status);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int submissionId = keys.getInt(1);
                    con.commit();
                }
            }
        } catch (Exception saveEx) {
            con.rollback();
            throw saveEx;
        } finally {
            con.setAutoCommit(true);
        }
    } catch (Exception ex) {
        if (con != null) try { con.rollback(); } catch (SQLException ignored) {}
        application.log("Process ER Diagram failed", ex);
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "บันทึก ER Diagram ไม่สำเร็จ: " + ex.getMessage());
        return;
    } finally {
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
    }
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ผลการบันทึก ER Diagram</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="card shadow-sm">
        <div class="card-body p-4">
            <h3 class="text-primary mb-3">บันทึก ER Diagram สำเร็จ</h3>
            <p><%= html(message) %></p>
            <p><strong>รหัสโจทย์:</strong> <%= questionId %></p>
            <p><strong>จำนวนโหนด:</strong> <%= normalized.get("node_count") %></p>
            <p><strong>จำนวนเส้นเชื่อม:</strong> <%= normalized.get("edge_count") %></p>
            <p><strong>สถานะ:</strong> <%= html(status) %></p>
            <div class="alert alert-info"><%= html(feedback) %></div>
            <h5>ข้อมูลที่แปลงแล้วสำหรับตรวจ</h5>
            <pre class="bg-body-secondary p-3 rounded" style="white-space:pre-wrap;overflow-wrap:anywhere"><%= html(normalizedJson) %></pre>
            <a class="btn btn-primary" href="javascript:history.back()">กลับไปหน้า ER Diagram</a>
        </div>
    </div>
</div>
</body>
</html>
