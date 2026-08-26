package db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

import java.io.FileInputStream;
import java.util.Properties;

public class DBConnection {

    public static Connection getConnection() {
        Connection con = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");

            Properties props = new Properties();

            try (FileInputStream fis = new FileInputStream("db.properties")) {
                props.load(fis);
            }

            String url = props.getProperty("db.url");
            String user = props.getProperty("db.user");
            String password = props.getProperty("db.password");

            con = DriverManager.getConnection(url, user, password);

            System.out.println("Connected Database Successfully");

            initTables(con);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return con;
    }

    private static void initTables(Connection con) {
        try (Statement stmt = con.createStatement()) {

            stmt.executeUpdate("DROP TABLE IF EXISTS users;");

            String createUsersTable = "CREATE TABLE users ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "username VARCHAR(50) NOT NULL UNIQUE, "
                    + "password VARCHAR(255) NOT NULL, "
                    + "role ENUM('student', 'admin') DEFAULT 'student', "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                    + ");";

            stmt.executeUpdate(createUsersTable);
            System.out.println("Created users table successfully.");

        } catch (Exception e) {
            System.err.println("Error initializing tables: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        getConnection();
    }
}