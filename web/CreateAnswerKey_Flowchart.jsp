<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="3" />
<link rel="stylesheet" href="css/pages/CenterLayout.css">
<link rel="stylesheet" href="css/AnswerKeyPages/AnswerKey_Flowchart.css">
<!-- Check Login File -->
<mytag:check_login />  

<%
    String Link = request.getAttribute("Loadfile5").toString();  
%>
<head>
    <meta charset="UTF-8">
    <title>สร้างเฉลย Flowchart & Pseudocode</title>
</head>
<body>

<div class="container main-container">
    <h3 class="title-text">สร้างเฉลย Flowchart & Pseudocode</h3>
        
        <!-- ส่วนที่ 1: โจทย์/คำอธิบาย (วงกลมบนสุด) -->
        <div class="section-box">
            <textarea class="form-control" name="problem_description" rows="3" placeholder="เขียน Flowchart...">เขียน Flowchart&#13;&#10;รับค่าจำนวนเต็ม N จากผู้ใช้ จากนั้นหาผลรวมของเลขคู่ตั้งแต่ 1 ถึง N แล้วแสดงผลรวม หากผลรวมมากกว่า 50 ให้แสดงข้อความ "Large" มิฉะนั้นให้แสดงข้อความ "Small"</textarea>
        </div>

        <div class="row">
            <!-- ส่วนที่ 2: ตัวอย่าง Input / Output (กล่องซ้าย) -->
            <div class="col-md-5">
                <div class="section-box h-100">
                    <h6>ตัวอย่าง Input / Output</h6>
                    
                    <div class="mb-3 mt-3">
                        <label>Input</label>
                        <ul>
                            <!-- วงกลม N -->
                            <li><input type="text" name="input_var_name" class="form-control form-control-sm w-50" value="N"></li>
                        </ul>
                        <label>Output</label>
                        <ul>
                            <li>ผลรวม</li>
                            <!-- วงกลม Large หรือ Small -->
                            <li><input type="text" name="output_var_name" class="form-control form-control-sm w-75" value="Large หรือ Small"></li>
                        </ul>
                    </div>

                    <!-- วงกลมตารางซ้ายล่าง -->
                    <table class="table table-bordered table-sm bg-white">
                        <thead class="table-light">
                            <tr>
                                <th>Input</th>
                                <th>Output</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><input type="text" name="ex_input[]" class="table-input" value="5"></td>
                                <td><input type="text" name="ex_output[]" class="table-input" value="6 Small"></td>
                            </tr>
                            <tr>
                                <td><input type="text" name="ex_input[]" class="table-input" value="10"></td>
                                <td><input type="text" name="ex_output[]" class="table-input" value="30 Large"></td>
                            </tr>
                            <tr>
                                <td><input type="text" name="ex_input[]" class="table-input" value="15"></td>
                                <td><input type="text" name="ex_output[]" class="table-input" value="56 Large"></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ส่วนที่ 3: Test case (กล่องขวา) -->
            <div class="col-md-7">
                <div class="section-box h-100 position-relative">
                    <h6>Test case</h6>
                    
                    <!-- วงกลมตารางขวา -->
                    <table class="table table-bordered table-sm bg-white mt-3 text-center">
                        <thead class="table-light">
                            <tr>
                                <th>No.</th>
                                <th>Input</th>
                                <th>Expected Output</th>
                                <th>คะแนน</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>1</td>
                                <td><input type="text" name="tc_input[]" class="table-input text-center" value="5"></td>
                                <td><input type="text" name="tc_expected[]" class="table-input" value="6 Small"></td>
                                <td><input type="number" name="tc_score[]" class="table-input text-center" value="1" min="0"></td>
                            </tr>
                            <tr>
                                <td>2</td>
                                <td><input type="text" name="tc_input[]" class="table-input text-center" value="10"></td>
                                <td><input type="text" name="tc_expected[]" class="table-input" value="30 Small"></td>
                                <td><input type="number" name="tc_score[]" class="table-input text-center" value="1" min="0"></td>
                            </tr>
                            <tr>
                                <td>3</td>
                                <td><input type="text" name="tc_input[]" class="table-input text-center" value="15"></td>
                                <td><input type="text" name="tc_expected[]" class="table-input" value="56 Large"></td>
                                <td><input type="number" name="tc_score[]" class="table-input text-center" value="1" min="0"></td>
                            </tr>
                        </tbody>
                    </table>
                    
                    <!-- ปุ่มบันทึก มุมขวาล่าง -->
                    <div class="save-button-container">
                        <button type="submit" class="btn btn-secondary btn-sm px-4">บันทึก</button>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

</body>
</html>