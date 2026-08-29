<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="4" />
<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/AnswerKeyPages/AnswerKey_Pseudocode.css">
<!-- Check Login File -->
<mytag:check_login />  

<!-- ============================================== -->
<!-- CSS สำหรับ Layout หน้า Test Case -->
<!-- ============================================== -->

<!-- เริ่มต้น Container สำหรับหน้าเว็บ -->
<div class="container-fluid px-4 py-3">

    <!-- ============================================== -->
    <!-- หัวข้อหน้าเว็บ -->
    <!-- ============================================== -->
    <!-- ============================================== -->
    <!-- หัวข้อหน้าเว็บ -->
    <!-- ============================================== -->
    <div class="d-flex align-items-center justify-content-between mb-4 mt-2">
        <div class="d-flex align-items-center gap-3">
            
            <!-- เอาโค้ดมาวางตรงนี้ (อย่าลืมเปลี่ยนชื่อไฟล์ .jsp) -->
            <a href="CreateAnswerkeys.jsp" class="btn btn-outline-primary btn-back"><i class="bi bi-arrow-left me-1"></i>กลับ</a>
            
            <h3 class="mb-0 fw-bold" style="color: #1a3c7c;">สร้างเฉลย (กำหนด Test Case)</h3>
        </div>
    </div>

    <!-- ============================================== -->
    <!-- กล่องโจทย์ปัญหา (Question Box) -->
    <!-- ============================================== -->
    <div class="card shadow-sm border-0 mb-4 rounded-3">
        <div class="card-header bg-white border-0 py-3 d-flex justify-content-between align-items-center" style="cursor: pointer;" data-bs-toggle="collapse" data-bs-target="#questionCollapse">
            <h6 class="mb-0 text-dark fw-bold">
                <span class="text-primary me-2">📄</span> โจทย์ปัญหา / คำถาม (Question)
            </h6>
            <span class="text-muted">˅</span>
        </div>
        <div class="collapse show" id="questionCollapse">
            <div class="card-body pt-0 pb-3 px-4">
                <div class="p-3 rounded-2" style="background-color: #f2f7ff; border: 1px solid #d5e5fb;">
                    <div class="text-primary fw-bold mb-1" style="font-size: 14px;">
                        <span class="me-1">📝</span> โจทย์: กำหนดเงื่อนไขการทดสอบ (Test Case)
                    </div>
                    <div class="text-secondary" style="font-size: 13.5px;">
                        ให้คุณระบุตัวอย่างการรับค่า (Input) และแสดงผล (Output) รวมถึงชุดทดสอบ (Test case) ให้ครบถ้วน จากนั้นกดปุ่ม "บันทึก"
                    </div>
                </div>
            </div>
        </div>
    </div>

    <form action="processTestCase.jsp" method="POST" id="testCaseForm">
        
        <!-- ============================================== -->
        <!-- ส่วน Input / Output และ Test case -->
        <!-- ============================================== -->
        <div class="row">
            
            <!-- กรอบซ้าย: ตัวอย่าง Input / Output -->
            <div class="col-lg-5 mb-4">
                <div class="card shadow-sm border-0 rounded-3 h-100">
                    <div class="card-body p-4">
                        <h4 class="fw-bold mb-4" style="color: #1a3c7c;">ตัวอย่าง Input / Output</h4>
                        
                        <h6 class="fw-bold text-secondary">Input</h6>
                        <ul class="mb-4">
                            <li class="mb-2"><input type="text" class="custom-input w-75" name="input_var_1" value="N"></li>
                        </ul>
                        
                        <h6 class="fw-bold text-secondary">Output</h6>
                        <ul class="mb-4">
                            <li class="mb-2"><input type="text" class="custom-input w-75" name="output_var_1" value="ผลรวม"></li>
                            <li class="mb-2"><input type="text" class="custom-input w-75" name="output_var_2" value="Large หรือ Small"></li>
                        </ul>

                        <table class="table table-bordered table-io text-center mt-3">
                            <thead>
                                <tr>
                                    <th>Input</th>
                                    <th>Output</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><input type="text" class="custom-input w-100 text-center border-0" name="ex_in_1" value="5"></td>
                                    <td><input type="text" class="custom-input w-100 text-center border-0" name="ex_out_1" value="6 Small"></td>
                                </tr>
                                <tr>
                                    <td><input type="text" class="custom-input w-100 text-center border-0" name="ex_in_2" value="10"></td>
                                    <td><input type="text" class="custom-input w-100 text-center border-0" name="ex_out_2" value="30 Large"></td>
                                </tr>
                                <tr>
                                    <td><input type="text" class="custom-input w-100 text-center border-0" name="ex_in_3" value="15"></td>
                                    <td><input type="text" class="custom-input w-100 text-center border-0" name="ex_out_3" value="56 Large"></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- กรอบขวา: Test case -->
            <div class="col-lg-7 mb-4">
                <div class="card shadow-sm border-0 rounded-3 h-100">
                    <div class="card-body p-4 d-flex flex-column">
                        <h4 class="fw-bold mb-4" style="color: #1a3c7c;">Test case</h4>
                        
                        <div class="table-responsive">
                            <table class="table table-bordered table-io text-center align-middle">
                                <thead>
                                    <tr>
                                        <th style="width: 10%;">No.</th>
                                        <th style="width: 30%;">Input</th>
                                        <th style="width: 40%;">Expected Output</th>
                                        <th style="width: 20%;">คะแนน</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>1</td>
                                        <td><input type="text" class="custom-input w-100 text-center" name="tc_in_1" value="5"></td>
                                        <td><input type="text" class="custom-input w-100 text-center" name="tc_out_1" value="6 Small"></td>
                                        <td><input type="text" class="custom-input w-100 text-center" name="tc_score_1" value="1"></td>
                                    </tr>
                                    <tr>
                                        <td>2</td>
                                        <td><input type="text" class="custom-input w-100 text-center" name="tc_in_2" value="10"></td>
                                        <td><input type="text" class="custom-input w-100 text-center" name="tc_out_2" value="30 Small"></td>
                                        <td><input type="text" class="custom-input w-100 text-center" name="tc_score_2" value="1"></td>
                                    </tr>
                                    <tr>
                                        <td>3</td>
                                        <td><input type="text" class="custom-input w-100 text-center" name="tc_in_3" value="15"></td>
                                        <td><input type="text" class="custom-input w-100 text-center" name="tc_out_3" value="56 Large"></td>
                                        <td><input type="text" class="custom-input w-100 text-center" name="tc_score_3" value="1"></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- ปุ่มบันทึก (มุมขวาล่างของกรอบ Test case) -->
                        <div class="mt-auto text-end pt-4">
                            <button type="button" class="btn btn-primary px-5 py-2 fs-6 shadow-sm fw-bold" style="background-color: #214db8; border-color: #214db8;" onclick="submitTestCase()">
                                บันทึก
                            </button>
                        </div>
                    </div>
                </div>
            </div>

        </div> <!-- End Row -->
    </form>
</div>

<!-- ============================================== -->
<!-- Script สำหรับหน้า Test Case -->
<!-- ============================================== -->
<script>
    // ฟังก์ชันจัดการตอนกดปุ่ม บันทึก
    function submitTestCase() {
        // ทดสอบแจ้งเตือน
        alert("ทำการบันทึกข้อมูล Test Case เรียบร้อยแล้ว!");
        
        // หากเชื่อมระบบหลังบ้านเสร็จแล้ว ให้เอาคอมเมนต์บรรทัดล่างออกเพื่อส่งฟอร์มไปยังเซิร์ฟเวอร์
        // document.getElementById('testCaseForm').submit();
    }
</script>