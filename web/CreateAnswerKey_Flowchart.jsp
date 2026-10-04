<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag"%>

<%!
    private String html(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;");
    }
%>

<%
    String subjectId = request.getParameter("subjectId");
    String mode = request.getParameter("mode");

    boolean isEdit = "edit".equals(mode)
            && subjectId != null
            && subjectId.matches("\\d+");

    String questionType = request.getParameter("questionType");
    String subjectName = "";
    String pdfFile = "";

    List<Map<String, Object>> testCases =
            new ArrayList<Map<String, Object>>();

    String loadError = null;

    if (!isEdit && !"FLOWCHART".equals(questionType)
            && !"PSEUDOCODE".equals(questionType)) {
        questionType = "FLOWCHART";
    }

    if (isEdit) {
        Connection editCon = null;
        try {
            editCon = db.DBConnection.getConnection();

            if (editCon == null) {
                throw new Exception("ไม่สามารถเชื่อมต่อฐานข้อมูลได้");
            }

            try (PreparedStatement ps = editCon.prepareStatement(
                    "SELECT name, pdf_file, question_type FROM questions WHERE id = ?")) {

                ps.setInt(1, Integer.parseInt(subjectId));

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new Exception("ไม่พบโจทย์ที่ต้องการแก้ไข");
                    }

                    subjectName = rs.getString("name");
                    pdfFile = rs.getString("pdf_file");
                    questionType = rs.getString("question_type");
                }
            }

            try (PreparedStatement ps = editCon.prepareStatement(
                    "SELECT input_data, expected_output, point "
                    + "FROM algorithm_test_cases "
                    + "WHERE question_id = ? ORDER BY case_no, id")) {

                ps.setInt(1, Integer.parseInt(subjectId));

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> tc =
                                new HashMap<String, Object>();

                        tc.put("input", rs.getString("input_data"));
                        tc.put("expected", rs.getString("expected_output"));
                        tc.put("point", rs.getInt("point"));

                        testCases.add(tc);
                    }
                }
            }

        } catch (Exception e) {
            loadError = e.getMessage();
        } finally {
            if (editCon != null) {
                try {
                    editCon.close();
                } catch (Exception ignored) {}
            }
        }
    }
%>

<mytag:ReadFile />
<mytag:header menu="3"/>
<mytag:check_login />

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>
        <%= isEdit ? "แก้ไขเฉลย Flowchart & Pseudocode"
                   : "สร้างเฉลย Flowchart & Pseudocode" %>
    </title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Sarabun:wght@300;400;500;600;700&display=swap">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/global.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/pages/SubjectsView.css?v=2">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/AnswerKeyPages/AnswerKey_Flowchart.css">

    <style>
        .teacher-page {
            font-family: 'Sarabun', sans-serif;
        }

        .page-header {
            margin-bottom: 24px;
        }

        .page-header-left {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .testcase-card {
            margin-top: 24px;
        }

        .testcase-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 18px;
        }

        .testcase-title {
            display: flex;
            align-items: center;
            gap: 9px;
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }

        .testcase-title i {
            font-size: 19px;
        }

        .testcase-table-wrapper {
            width: 100%;
            overflow-x: auto;
        }

        .testcase-table {
            width: 100%;
            min-width: 650px;
            border-collapse: collapse;
        }

        .testcase-table th,
        .testcase-table td {
            vertical-align: middle;
            text-align: center;
            padding: 12px 10px;
        }

        .testcase-table th {
            white-space: nowrap;
        }

        .testcase-table .table-input {
            display: block;
            width: 100%;
            min-width: 70px;
            padding: 8px 10px;
            border: 1px solid #e2e6ea;
            border-radius: 7px;
            outline: none;
            background: #fff;
            text-align: center;
            font-family: inherit;
            font-size: 14px;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .testcase-table .table-input:focus {
            border-color: #86b7fe;
            box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.12);
        }

        .testcase-table .case-no {
            font-weight: 500;
        }

        .testcase-table .btn-delete {
            display: inline-flex;
            justify-content: center;
            align-items: center;
        }

        .testcase-table .btn-delete i {
            pointer-events: none;
        }

        .testcase-summary {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 16px;
            font-size: 14px;
        }

        .testcase-summary strong {
            font-weight: 600;
            color: #0d6efd;
        }

        .testcase-actions {
            display: flex;
            justify-content: flex-end;
            margin-top: 22px;
        }

        .save-button {
            min-width: 130px;
        }

        @media (max-width: 576px) {
            .testcase-header {
                align-items: flex-start;
            }

            .testcase-summary {
                justify-content: flex-start;
            }

            .page-header-left {
                align-items: flex-start;
            }
        }
    </style>
</head>

<body>

<% if (loadError != null) { %>

    <div class="container py-4">
        <div class="alert alert-danger">
            <%= html(loadError) %>
        </div>
        <a href="SubjectsView.jsp">กลับ</a>
    </div>

<% } else { %>

<div class="container teacher-page py-4">

    <div class="page-header">
        <div class="page-header-left">
            <div class="icon-box-header">
                <i class="bi bi-file-earmark-text"></i>
            </div>

            <div>
                <h3 class="header-title">
                    <%= isEdit ? "แก้ไขเฉลย Flowchart & Pseudocode"
                               : "สร้างเฉลย Flowchart & Pseudocode" %>
                </h3>

                <p class="header-subtitle">
                    กำหนดข้อมูลโจทย์และ Test Case สำหรับใช้ตรวจคำตอบ
                </p>
            </div>
        </div>

        <div class="testcase-actions">
            <button type="submit"
                    form="answerForm"
                    class="btn btn-primary px-4 py-2 shadow-sm save-button">
                <i class="bi bi-save me-2"></i>
                <%= isEdit ? "บันทึกการแก้ไข" : "บันทึก" %>
            </button>
        </div>
    </div>

    <form id="answerForm"
          action="SaveAlgorithmQuestion.jsp"
          method="post"
          enctype="multipart/form-data"
          onsubmit="return validateForm()">

        <input type="hidden"
               name="questionType"
               id="questionType"
               value="<%= html(questionType) %>">

        <input type="hidden"
               name="subjectId"
               value="<%= isEdit ? html(subjectId) : "" %>">

        <input type="hidden"
               name="mode"
               value="<%= isEdit ? "edit" : "add" %>">

        <div class="main-card add-subject-card">

            <div class="add-subject-header">
                <div class="add-icon">
                    <i class="bi bi-plus-lg"></i>
                </div>

                <div>
                    <h4>
                        <%= isEdit ? "แก้ไขโจทย์" : "เพิ่มโจทย์ใหม่" %>
                    </h4>

                    <p>
                        <%= isEdit
                            ? "แก้ไขข้อมูลโจทย์และ Test Case เดิม"
                            : "กรอกชื่อโจทย์และเลือกไฟล์ PDF" %>
                    </p>
                </div>
            </div>

            <div class="subject-form-row">

                <div class="subject-form-group subject-name-group">
                    <label for="subjectName">ชื่อโจทย์ (Name)</label>

                    <input type="text"
                           id="subjectName"
                           name="subjectName"
                           class="subject-input"
                           placeholder="กรอกชื่อโจทย์ เช่น FC_01"
                           value="<%= html(subjectName) %>"
                           maxlength="255"
                           required>
                </div>

                <div class="subject-form-group">
                    <label for="pdfFile">Upload PDF</label>

                    <input type="file"
                           id="pdfFile"
                           name="pdfFile"
                           class="subject-input"
                           accept=".pdf,application/pdf"
                           <%= isEdit ? "" : "required" %>>

                    <% if (isEdit && pdfFile != null && !pdfFile.isEmpty()) { %>
                        <small class="text-muted">
                            ไฟล์ PDF ปัจจุบัน:
                            <%= html(pdfFile) %>
                            — หากไม่เลือกไฟล์ใหม่ ระบบจะใช้ไฟล์เดิม
                        </small>
                    <% } %>
                </div>

            </div>
        </div>

        <div class="main-card subject-card testcase-card">

            <div class="testcase-header">
                <h4 class="testcase-title">
                    <i class="bi bi-list-check"></i>
                    Test Case
                </h4>

                <button type="button"
                        class="btn-add-subject"
                        onclick="addTestCase()">
                    <i class="bi bi-plus-lg"></i>
                    เพิ่ม Test Case
                </button>
            </div>

            <div class="testcase-table-wrapper">
                <table class="custom-table testcase-table"
                       id="testCaseTable">

                    <thead>
                        <tr>
                            <th style="width: 8%;">#</th>
                            <th style="width: 25%;">INPUT</th>
                            <th style="width: 35%;">EXPECTED OUTPUT</th>
                            <th style="width: 15%;">POINT</th>
                            <th style="width: 12%; text-align: center;">DEL</th>
                        </tr>
                    </thead>

                    <tbody id="testCaseBody">

                        <% for (int i = 0; i < testCases.size(); i++) {
                            Map<String, Object> tc = testCases.get(i); %>

                        <tr>
                            <td class="case-no"><%= i + 1 %></td>

                            <td>
                                <input type="text"
                                       name="tc_input[]"
                                       class="table-input"
                                       value="<%= html((String) tc.get("input")) %>"
                                       required>
                            </td>

                            <td>
                                <input type="text"
                                       name="tc_expected[]"
                                       class="table-input"
                                       value="<%= html((String) tc.get("expected")) %>"
                                       required>
                            </td>

                            <td>
                                <input type="number"
                                       name="tc_score[]"
                                       class="table-input score-input"
                                       min="0"
                                       step="1"
                                       value="<%= tc.get("point") %>"
                                       required>
                            </td>

                            <td class="text-center">
                                <button type="button"
                                        class="btn-delete"
                                        title="ลบ Test Case"
                                        aria-label="ลบ Test Case"
                                        onclick="removeTestCase(this)">
                                    <i class="bi bi-trash3"></i>
                                </button>
                            </td>
                        </tr>

                        <% } %>

                    </tbody>
                </table>
            </div>

            <div class="testcase-summary">
                <span>จำนวน Test Case:</span>
                <strong id="totalCases">0</strong>

                <span class="ms-2">คะแนนรวม:</span>
                <strong id="totalScore">0</strong>
                <span>คะแนน</span>
            </div>

            <input type="hidden"
                   name="totalScore"
                   id="totalScoreInput"
                   value="0">

        </div>

    </form>
</div>

<% } %>

<template id="testCaseTemplate">
    <tr>
        <td class="case-no"></td>

        <td>
            <input type="text"
                   name="tc_input[]"
                   class="table-input"
                   placeholder="Input"
                   required>
        </td>

        <td>
            <input type="text"
                   name="tc_expected[]"
                   class="table-input"
                   placeholder="Expected Output"
                   required>
        </td>

        <td>
            <input type="number"
                   name="tc_score[]"
                   class="table-input score-input"
                   placeholder="กรอกคะแนน"
                   min="0"
                   step="1"
                   required>
        </td>

        <td class="text-center">
            <button type="button"
                    class="btn-delete"
                    title="ลบ Test Case"
                    aria-label="ลบ Test Case"
                    onclick="removeTestCase(this)">
                <i class="bi bi-trash3"></i>
            </button>
        </td>
    </tr>
</template>

<script>
    function addTestCase() {
        const tbody = document.getElementById("testCaseBody");
        const template = document.getElementById("testCaseTemplate");

        const fragment = template.content.cloneNode(true);
        const newRow = fragment.querySelector("tr");

        tbody.appendChild(fragment);

        updateCaseNumbers();

        newRow.querySelector('input[name="tc_input[]"]').focus();
    }

    function removeTestCase(button) {
        const row = button.closest("tr");

        if (row) {
            row.remove();
        }

        updateCaseNumbers();
    }

    function updateCaseNumbers() {
        const rows = document.querySelectorAll("#testCaseBody tr");

        rows.forEach(function(row, index) {
            row.querySelector(".case-no").textContent = index + 1;
        });

        document.getElementById("totalCases").textContent = rows.length;

        updateTotalScore();
    }

    function updateTotalScore() {
        const scoreInputs = document.querySelectorAll(
            "#testCaseBody .score-input"
        );

        let total = 0;

        scoreInputs.forEach(function(input) {
            if (input.value !== "") {
                const score = Number(input.value);

                if (Number.isFinite(score) && score >= 0) {
                    total += score;
                }
            }
        });

        document.getElementById("totalScore").textContent = total;
        document.getElementById("totalScoreInput").value = total;
    }

    function validateForm() {
        const subjectName = document
            .getElementById("subjectName")
            .value.trim();

        const pdfInput = document.getElementById("pdfFile");
        const pdfFile = pdfInput.files[0];

        const rows = document.querySelectorAll("#testCaseBody tr");

        if (subjectName === "") {
            alert("กรุณากรอกชื่อโจทย์");
            document.getElementById("subjectName").focus();
            return false;
        }

        const isEdit =
            document.querySelector('input[name="mode"]').value === "edit";

        if (!isEdit && !pdfFile) {
            alert("กรุณาเลือกไฟล์ PDF");
            pdfInput.focus();
            return false;
        }

        if (pdfFile && pdfFile.type !== "application/pdf" &&
            !pdfFile.name.toLowerCase().endsWith(".pdf")) {
            alert("กรุณาเลือกไฟล์ PDF เท่านั้น");
            pdfInput.value = "";
            pdfInput.focus();
            return false;
        }

        if (rows.length === 0) {
            alert("กรุณาเพิ่ม Test Case อย่างน้อย 1 รายการ");
            return false;
        }

        for (let i = 0; i < rows.length; i++) {
            const input = rows[i].querySelector(
                'input[name="tc_input[]"]'
            );

            const expected = rows[i].querySelector(
                'input[name="tc_expected[]"]'
            );

            const score = rows[i].querySelector(
                'input[name="tc_score[]"]'
            );

            if (input.value.trim() === "") {
                alert("กรุณากรอก Input ใน Test Case ที่ " + (i + 1));
                input.focus();
                return false;
            }

            if (expected.value.trim() === "") {
                alert("กรุณากรอก Expected Output ใน Test Case ที่ " + (i + 1));
                expected.focus();
                return false;
            }

            if (score.value === "" ||
                !Number.isInteger(Number(score.value)) ||
                Number(score.value) < 0) {
                alert(
                    "กรุณากรอกคะแนนเป็นจำนวนเต็มตั้งแต่ 0 ขึ้นไป ใน Test Case ที่ "
                    + (i + 1)
                );
                score.focus();
                return false;
            }
        }

        updateTotalScore();

        return confirm(isEdit
            ? "ยืนยันการบันทึกการแก้ไขโจทย์และ Test Case หรือไม่?"
            : "ยืนยันการบันทึกโจทย์และ Test Case หรือไม่?");
    }

    document.addEventListener("DOMContentLoaded", function() {
        updateCaseNumbers();

        document.getElementById("testCaseBody").addEventListener(
            "input",
            function(event) {
                if (event.target.classList.contains("score-input")) {
                    updateTotalScore();
                }
            }
        );
    });
</script>

</body>
</html>