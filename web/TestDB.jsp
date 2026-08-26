<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Database Connection Test</title>
</head>
<body>
    <%
        // 1. ระบุชื่อ Database ที่คุณเพิ่งสร้างในข้อ 1
        String dbName = "project_db"; 
        
        // 2. ตั้งค่าการเชื่อมต่อ
        String url = "jdbc:mysql://127.0.0.1:3306/" + dbName + "?useUnicode=true&characterEncoding=UTF-8";
        String username = "root"; 
        String password = "p@ssw0rd.123"; // ถ้าไม่มีรหัสให้ใส่เป็น ""
        
        Connection conn = null;

        try {
            // 3. โหลด Driver (ใช้ตัวนี้เพราะไฟล์ .jar คุณเป็นเวอร์ชัน 5.1)
            Class.forName("com.mysql.jdbc.Driver");
            
            // 4. สั่งเชื่อมต่อ
            conn = DriverManager.getConnection(url, username, password);
            out.println("<h3 style='color: green;'>เชื่อมต่อฐานข้อมูลสำเร็จแล้ว! 🎉</h3>");
            
        } catch (ClassNotFoundException e) {
            out.println("<h3 style='color: red;'>Error: หาไฟล์ .jar ไม่เจอ ตรวจสอบโฟลเดอร์ WEB-INF/lib</h3>");
        } catch (SQLException e) {
            out.println("<h3 style='color: red;'>Error การเชื่อมต่อ: " + e.getMessage() + "</h3>");
        } finally {
            // ปิดการเชื่อมต่อเสมอ
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignore) {}
            }
        }
    %>
</body>
</html>