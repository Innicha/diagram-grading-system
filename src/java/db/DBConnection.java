package db;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    public static Connection getConnection() {
        Connection con = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");

            con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/diagram_grading_system?useUnicode=true&characterEncoding=UTF-8",
                "root",
                ""
            );

            System.out.println("Connected Database Successfully");

        } catch (Exception e) {
            e.printStackTrace();       
        }

        return con;
    }
}