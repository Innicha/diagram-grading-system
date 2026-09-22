package db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.io.InputStream;
import java.util.Properties;

public class DBConnection {

    public static Connection getConnection() {

        Connection con = null;

        try {

            // MySQL JDBC Driver
            Class.forName("com.mysql.jdbc.Driver");

            // อ่านไฟล์ db.properties
            Properties props = new Properties();

            try (InputStream input =
                    DBConnection.class.getResourceAsStream("db.properties")) {

                if (input == null) {
                    throw new Exception("ไม่พบไฟล์ db.properties");
                }

                props.load(input);
            }

            // อ่านค่าจาก db.properties
            String url = props.getProperty("db.url");
            String user = props.getProperty("db.user");
            String password = props.getProperty("db.password");

            // ตรวจสอบค่าที่อ่านได้
            System.out.println("Database URL: " + url);
            System.out.println("Database User: " + user);

            // เชื่อมต่อ Database
            con = DriverManager.getConnection(
                    url,
                    user,
                    password
            );

            System.out.println("Connected Database Successfully");

            // ตรวจสอบ/สร้างตาราง users
            initTables(con);

        } catch (Exception e) {

            System.err.println("========== DATABASE ERROR ==========");
            e.printStackTrace();
            System.err.println("====================================");
        }

        return con;
    }


    private static void initTables(Connection con) {

        try (Statement stmt = con.createStatement()) {

            // Users Table
            String createUsersTable =
                    "CREATE TABLE IF NOT EXISTS users ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "username VARCHAR(50) NOT NULL UNIQUE, "
                    + "password VARCHAR(255) NOT NULL, "
                    + "full_name VARCHAR(255) NOT NULL, "
                    + "role ENUM('student', 'teacher') NOT NULL, "
                    + "sec INT NULL, "
                    + "status ENUM('ON', 'OFF') NOT NULL DEFAULT 'ON', "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                    + ");";

            stmt.executeUpdate(createUsersTable);
            System.out.println("Users table checked successfully.");

            // Courses Table
            String createCoursesTable =
                    "CREATE TABLE IF NOT EXISTS courses ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "course_name VARCHAR(255) NOT NULL, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                    + ");";

            stmt.executeUpdate(createCoursesTable);
            System.out.println("Courses table checked successfully.");

            // Subjects Table
            String createSubjectsTable =
                    "CREATE TABLE IF NOT EXISTS subjects ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "name VARCHAR(100) NOT NULL, "
                    + "point INT NOT NULL DEFAULT 0, "
                    + "status ENUM('ON', 'OFF') NOT NULL DEFAULT 'ON', "
                    + "sec VARCHAR(100) NOT NULL, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                    + "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP "
                    + "ON UPDATE CURRENT_TIMESTAMP"
                    + ");";

            stmt.executeUpdate(createSubjectsTable);

            System.out.println("Subjects table checked successfully.");
                    
        } catch (Exception e) {

            System.err.println(
                    "Error initializing users table: "
                    + e.getMessage()
            );
        }
    }


    public static void main(String[] args) {

        getConnection();
    }
}