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

            // อ่านค่าการเชื่อมต่อ Database
            String url = props.getProperty("db.url");
            String user = props.getProperty("db.user");
            String password = props.getProperty("db.password");

            System.out.println("Database URL: " + url);
            System.out.println("Database User: " + user);

            // เชื่อมต่อ Database
            con = DriverManager.getConnection(url, user, password);

            System.out.println("Connected Database Successfully");

            // สร้างตารางทั้งหมด
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

            // 1. Users Table
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
                    + ") ENGINE=InnoDB;";

            stmt.executeUpdate(createUsersTable);
            System.out.println("Users table checked successfully.");

            // 2. Questions Table
            String createQuestionsTable =
                    "CREATE TABLE IF NOT EXISTS questions ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "question_type ENUM('FLOWCHART', 'PSEUDOCODE', 'ER_DIAGRAM') NOT NULL, "
                    + "name VARCHAR(255) NOT NULL, "
                    + "point INT NOT NULL DEFAULT 0, "
                    + "sec VARCHAR(100) NULL, "
                    + "pdf_file VARCHAR(255) NULL, "
                    + "status ENUM('ON', 'OFF') NOT NULL DEFAULT 'ON', "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                    + "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP "
                    + "ON UPDATE CURRENT_TIMESTAMP"
                    + ") ENGINE=InnoDB;";

            stmt.executeUpdate(createQuestionsTable);
            System.out.println("Questions table checked successfully.");

            // 3. Algorithm Test Cases Table
            String createAlgorithmTestCasesTable =
                    "CREATE TABLE IF NOT EXISTS algorithm_test_cases ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "question_id INT NOT NULL, "
                    + "case_no INT NOT NULL, "
                    + "input_data TEXT NOT NULL, "
                    + "expected_output TEXT NOT NULL, "
                    + "point INT NOT NULL DEFAULT 0, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                    + "CONSTRAINT fk_algorithm_test_cases_question "
                    + "FOREIGN KEY (question_id) "
                    + "REFERENCES questions(id) "
                    + "ON DELETE CASCADE ON UPDATE CASCADE, "
                    + "UNIQUE KEY unique_algorithm_case (question_id, case_no)"
                    + ") ENGINE=InnoDB;";

            stmt.executeUpdate(createAlgorithmTestCasesTable);
            System.out.println("Algorithm test cases table checked successfully.");

            // 4. Algorithm Submissions Table
            String createAlgorithmSubmissionsTable =
                    "CREATE TABLE IF NOT EXISTS algorithm_submissions ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "question_id INT NOT NULL, "
                    + "student_id INT NOT NULL, "
                    + "answer_text LONGTEXT NULL, "
                    + "score INT NULL, "
                    + "status ENUM('SUBMITTED', 'GRADED') "
                    + "NOT NULL DEFAULT 'SUBMITTED', "
                    + "submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                    + "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP "
                    + "ON UPDATE CURRENT_TIMESTAMP, "
                    + "CONSTRAINT fk_algorithm_submissions_question "
                    + "FOREIGN KEY (question_id) "
                    + "REFERENCES questions(id) "
                    + "ON DELETE CASCADE ON UPDATE CASCADE, "
                    + "CONSTRAINT fk_algorithm_submissions_student "
                    + "FOREIGN KEY (student_id) "
                    + "REFERENCES users(id) "
                    + "ON DELETE CASCADE ON UPDATE CASCADE, "
                    + "UNIQUE KEY unique_algorithm_submission "
                    + "(question_id, student_id)"
                    + ") ENGINE=InnoDB;";

            stmt.executeUpdate(createAlgorithmSubmissionsTable);
            System.out.println("Algorithm submissions table checked successfully.");

            // 5. ER Diagram Answers Table
            String createERDiagramAnswersTable =
                    "CREATE TABLE IF NOT EXISTS er_diagram_answers ("
                    + "question_id INT PRIMARY KEY, "
                    + "answer_data LONGTEXT NOT NULL, "
                    + "answer_text TEXT NULL, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                    + "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP "
                    + "ON UPDATE CURRENT_TIMESTAMP, "
                    + "CONSTRAINT fk_er_answers_question "
                    + "FOREIGN KEY (question_id) "
                    + "REFERENCES questions(id) "
                    + "ON DELETE CASCADE ON UPDATE CASCADE"
                    + ") ENGINE=InnoDB;";

            stmt.executeUpdate(createERDiagramAnswersTable);
            System.out.println("ER diagram answers table checked successfully.");

            // 6. ER Diagram Submissions Table
            String createERDiagramSubmissionsTable =
                    "CREATE TABLE IF NOT EXISTS er_diagram_submissions ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "question_id INT NOT NULL, "
                    + "student_id INT NOT NULL, "
                    + "answer_data LONGTEXT NOT NULL, "
                    + "score INT NULL, "
                    + "status ENUM('SUBMITTED', 'GRADED') "
                    + "NOT NULL DEFAULT 'SUBMITTED', "
                    + "submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                    + "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP "
                    + "ON UPDATE CURRENT_TIMESTAMP, "
                    + "CONSTRAINT fk_er_submissions_question "
                    + "FOREIGN KEY (question_id) "
                    + "REFERENCES questions(id) "
                    + "ON DELETE CASCADE ON UPDATE CASCADE, "
                    + "CONSTRAINT fk_er_submissions_student "
                    + "FOREIGN KEY (student_id) "
                    + "REFERENCES users(id) "
                    + "ON DELETE CASCADE ON UPDATE CASCADE, "
                    + "UNIQUE KEY unique_er_submission "
                    + "(question_id, student_id)"
                    + ") ENGINE=InnoDB;";

            stmt.executeUpdate(createERDiagramSubmissionsTable);
            System.out.println("ER diagram submissions table checked successfully.");

            
            // 7. Student Questions Table
            String createStudentQuestionsTable =
                    "CREATE TABLE IF NOT EXISTS student_questions ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "student_id INT NOT NULL, "
                    + "question_id INT NOT NULL, "
                    + "assigned_by INT NULL, "
                    + "assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "

                    // Foreign Key: นักศึกษา
                    + "CONSTRAINT fk_student_questions_student "
                    + "FOREIGN KEY (student_id) "
                    + "REFERENCES users(id) "
                    + "ON DELETE CASCADE ON UPDATE CASCADE, "

                    // Foreign Key: โจทย์
                    + "CONSTRAINT fk_student_questions_question "
                    + "FOREIGN KEY (question_id) "
                    + "REFERENCES questions(id) "
                    + "ON DELETE CASCADE ON UPDATE CASCADE, "

                    // Foreign Key: อาจารย์ผู้มอบหมาย
                    + "CONSTRAINT fk_student_questions_teacher "
                    + "FOREIGN KEY (assigned_by) "
                    + "REFERENCES users(id) "
                    + "ON DELETE SET NULL ON UPDATE CASCADE, "

                    // ป้องกันการมอบหมายโจทย์เดิมซ้ำ
                    + "UNIQUE KEY unique_student_question "
                    + "(student_id, question_id)"
                    + ") ENGINE=InnoDB;";

            stmt.executeUpdate(createStudentQuestionsTable);
            System.out.println("Student questions table checked successfully.");


            System.out.println("All database tables checked successfully.");

        } catch (Exception e) {
            System.err.println(
                    "Error initializing database tables: "
                    + e.getMessage()
            );
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {

        Connection con = getConnection();

        if (con != null) {
            System.out.println("Database initialization completed.");

            try {
                con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}