<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="6"/>
<mytag:check_login />

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>แบบฝึกหัด / โจทย์</title>
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <!-- Google Font -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Bootstrap -->
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <!-- Global CSS -->
    <link rel="stylesheet" href="css/global.css">
    <!-- Page CSS -->
    <link rel="stylesheet" href="css/pages/StudentsPart.css">
</head>
<body>

<div class="student-page">

    <!-- PAGE HEADER -->
    <div class="page-header">
        <div class="page-title-area">
            <div class="page-icon">
                <i class="fa-regular fa-rectangle-list"></i>
            </div>
            <div>
                <h1>แบบฝึกหัด / โจทย์</h1>
                <p>เลือกโจทย์เพื่อทำแบบฝึกหัด และตรวจสอบคะแนนของคุณ</p>
            </div>
        </div>

        <!-- SUMMARY CARDS -->
        <div class="summary-area">
            <!-- คะแนนรวม -->
            <div class="summary-card total-score">
                <div class="summary-icon"><i class="fa-solid fa-trophy"></i></div>
                <div class="summary-content">
                    <span>คะแนนรวมของคุณ</span>
                    <strong>78 / 100</strong>
                </div>
            </div>

            <!-- ทำแล้ว -->
            <div class="summary-card completed-card">
                <div class="summary-icon"><i class="fa-regular fa-file-lines"></i></div>
                <div class="summary-content">
                    <span>ทำแล้ว</span>
                    <strong>6 / 10</strong>
                </div>
            </div>

            <!-- รอทำ -->
            <div class="summary-card pending-card">
                <div class="summary-icon"><i class="fa-regular fa-clock"></i></div>
                <div class="summary-content">
                    <span>รอทำ</span>
                    <strong>4 รายการ</strong>
                </div>
            </div>
        </div>
    </div>

    <!-- EXERCISE CONTAINER -->
    <div class="exercise-container">

        <!-- FILTER BAR -->
        <div class="filter-bar">
            <div class="filter-left">
                <div class="filter-label">
                    <i class="fa-solid fa-filter"></i>
                    <span>เลือกเซตชัน</span>
                </div>

                <!-- Select -->
                <div class="select-wrapper">
                    <select>
                        <option>ทั้งหมด</option>
                        <option>ER Diagram</option>
                        <option>Relationship</option>
                        <option>Normalization</option>
                    </select>
                    <i class="fa-solid fa-chevron-down"></i>
                </div>

                <!-- Search -->
                <div class="search-box">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" placeholder="ค้นหาชื่อโจทย์...">
                </div>
            </div>

            <!-- จำนวนโจทย์ -->
            <div class="question-count">
                <i class="fa-solid fa-list"></i>
                <span>ทั้งหมด 10 รายการ</span>
            </div>
        </div>

        <!-- TABLE -->
        <div class="table-wrapper">
            <table class="exercise-table">
                <thead>
                    <tr>
                        <th class="col-number">#</th>
                        <th class="col-name">ชื่อโจทย์</th>
                        <th class="col-score">คะแนนเต็ม</th>
                        <th class="col-score">คะแนนที่ได้</th>
                        <th class="col-status">สถานะ</th>
                        <th class="col-date">กำหนดส่ง</th>
                        <th class="col-action">จัดการ</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- ROW 1 -->
                    <tr>
                        <td>1</td>
                        <td><div class="question-name">ER_01 พื้นฐานการออกแบบ ER Diagram</div></td>
                        <td>10</td>
                        <td class="score-earned">10</td>
                        <td>
                            <span class="status submitted">
                                <i class="fa-solid fa-check"></i> ส่งแล้ว
                            </span>
                        </td>
                        <td>12 ก.ย. 2569 23:59</td>
                        <td>
                            <button class="btn-action btn-view">
                                <i class="fa-solid fa-eye"></i> ดูคำตอบ
                            </button>
                        </td>
                    </tr>

                    <!-- ROW 2 -->
                    <tr>
                        <td>2</td>
                        <td><div class="question-name">ER_02 ความสัมพันธ์ระหว่าง Entity</div></td>
                        <td>10</td>
                        <td class="score-earned">8</td>
                        <td>
                            <span class="status submitted">
                                <i class="fa-solid fa-check"></i> ส่งแล้ว
                            </span>
                        </td>
                        <td>15 ก.ย. 2569 23:59</td>
                        <td>
                            <button class="btn-action btn-view">
                                <i class="fa-solid fa-eye"></i> ดูคำตอบ
                            </button>
                        </td>
                    </tr>

                    <!-- ROW 3 -->
                    <tr>
                        <td>3</td>
                        <td><div class="question-name">ER_03 Cardinality และ Participation</div></td>
                        <td>15</td>
                        <td class="score-empty">-</td>
                        <td>
                            <span class="status not-started">
                                <i class="fa-regular fa-clock"></i> ยังไม่ได้ทำ
                            </span>
                        </td>
                        <td>18 ก.ย. 2569 23:59</td>
                        <td>
                            <button class="btn-action btn-start">
                                <i class="fa-solid fa-pen"></i> เริ่มทำ
                            </button>
                        </td>
                    </tr>

                    <!-- ROW 4 -->
                    <tr>
                        <td>4</td>
                        <td><div class="question-name">ER_04 Weak Entity และ Identifying Relationship</div></td>
                        <td>15</td>
                        <td class="score-empty">-</td>
                        <td>
                            <span class="status not-started">
                                <i class="fa-regular fa-clock"></i> ยังไม่ได้ทำ
                            </span>
                        </td>
                        <td>20 ก.ย. 2569 23:59</td>
                        <td>
                            <button class="btn-action btn-start">
                                <i class="fa-solid fa-pen"></i> เริ่มทำ
                            </button>
                        </td>
                    </tr>

                    <!-- ROW 5 -->
                    <tr>
                        <td>5</td>
                        <td><div class="question-name">ER_05 การแปลง ER เป็น Relational Schema</div></td>
                        <td>20</td>
                        <td class="score-earned">18</td>
                        <td>
                            <span class="status submitted">
                                <i class="fa-solid fa-check"></i> ส่งแล้ว
                            </span>
                        </td>
                        <td>22 ก.ย. 2569 23:59</td>
                        <td>
                            <button class="btn-action btn-view">
                                <i class="fa-solid fa-eye"></i> ดูคำตอบ
                            </button>
                        </td>
                    </tr>

                    <!-- ROW 6 -->
                    <tr>
                        <td>6</td>
                        <td><div class="question-name">ER_06 การออกแบบฐานข้อมูลจากโจทย์จริง</div></td>
                        <td>20</td>
                        <td class="score-empty">-</td>
                        <td>
                            <span class="status not-started">
                                <i class="fa-regular fa-clock"></i> ยังไม่ได้ทำ
                            </span>
                        </td>
                        <td>25 ก.ย. 2569 23:59</td>
                        <td>
                            <button class="btn-action btn-start">
                                <i class="fa-solid fa-pen"></i> เริ่มทำ
                            </button>
                        </td>
                    </tr>

                    <!-- ROW 7 -->
                    <tr>
                        <td>7</td>
                        <td><div class="question-name">ER_07 การปรับปรุงและ Normalization</div></td>
                        <td>20</td>
                        <td class="score-earned">15</td>
                        <td>
                            <span class="status submitted">
                                <i class="fa-solid fa-check"></i> ส่งแล้ว
                            </span>
                        </td>
                        <td>28 ก.ย. 2569 23:59</td>
                        <td>
                            <button class="btn-action btn-view">
                                <i class="fa-solid fa-eye"></i> ดูคำตอบ
                            </button>
                        </td>
                    </tr>

                    <!-- ROW 8 -->
                    <tr>
                        <td>8</td>
                        <td><div class="question-name">ER_08 ข้อสอบย้อนหลัง</div></td>
                        <td>25</td>
                        <td class="score-empty">-</td>
                        <td>
                            <span class="status not-started">
                                <i class="fa-regular fa-clock"></i> ยังไม่ได้ทำ
                            </span>
                        </td>
                        <td>30 ก.ย. 2569 23:59</td>
                        <td>
                            <button class="btn-action btn-start">
                                <i class="fa-solid fa-pen"></i> เริ่มทำ
                            </button>
                        </td>
                    </tr>

                    <!-- ROW 9 -->
                    <tr>
                        <td>9</td>
                        <td><div class="question-name">ER_09 แบบฝึกหัดเสริม</div></td>
                        <td>25</td>
                        <td class="score-empty">-</td>
                        <td>
                            <span class="status not-started">
                                <i class="fa-regular fa-clock"></i> ยังไม่ได้ทำ
                            </span>
                        </td>
                        <td>5 ต.ค. 2569 23:59</td>
                        <td>
                            <button class="btn-action btn-start">
                                <i class="fa-solid fa-pen"></i> เริ่มทำ
                            </button>
                        </td>
                    </tr>

                    <!-- ROW 10 -->
                    <tr>
                        <td>10</td>
                        <td><div class="question-name">ER_10 สรุปและทบทวน</div></td>
                        <td>30</td>
                        <td class="score-empty">-</td>
                        <td>
                            <span class="status not-started">
                                <i class="fa-regular fa-clock"></i> ยังไม่ได้ทำ
                            </span>
                        </td>
                        <td>10 ต.ค. 2569 23:59</td>
                        <td>
                            <button class="btn-action btn-start">
                                <i class="fa-solid fa-pen"></i> เริ่มทำ
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- PAGINATION -->
        <div class="table-footer">
            <div class="showing-text">แสดง 1 - 10 จาก 10 รายการ</div>
            <div class="pagination">
                <button class="page-btn disabled"><i class="fa-solid fa-chevron-left"></i></button>
                <button class="page-btn active">1</button>
                <button class="page-btn disabled"><i class="fa-solid fa-chevron-right"></i></button>
            </div>
        </div>
    </div>

</div>

</body>
</html>