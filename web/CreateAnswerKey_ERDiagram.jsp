<%@page import="java.sql.*"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="3"/>
<mytag:check_login />

<%
    request.setCharacterEncoding("UTF-8");
    String questionId = request.getParameter("questionId");
    if (questionId == null) questionId = "";
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create Answer Key ER Diagram</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/global.css">
    <link rel="stylesheet" href="css/AnswerKeyPages/AnswerKey_ERDiagram.css">
</head>
<body>
<div class="container-fluid answer-key-page">
    <div class="page-header d-flex align-items-center justify-content-between flex-wrap">
        <div>
            <h3><i class="bi bi-file-earmark-code-fill text-primary me-2"></i>สร้างเฉลย ER Diagram</h3>
            <p class="page-subtitle mb-0">กรอกชื่อตารางและแอตทริบิวต์ในรูปแบบตารางเฉลย พร้อมกำหนดความสัมพันธ์ได้อย่างแม่นยำ</p>
        </div>
        <div class="d-flex align-items-center gap-2 mt-2 mt-md-0">
            <span class="question-chip"><i class="bi bi-journal-text me-1"></i> Question ID: <strong id="questionIdLabel"><%= questionId.isEmpty() ? "-" : questionId.replaceAll("[^0-9]", "") %></strong></span>
            <button type="button" class="btn btn-primary btn-save-page" id="saveAnswerBtn">
                <i class="bi bi-floppy me-1"></i> บันทึกเฉลย
            </button>
        </div>
    </div>

    <div class="answer-card">
        <div class="answer-card-heading">
            <div class="heading-icon"><i class="bi bi-table"></i></div>
            <div>
                <h4>ตารางเฉลย</h4>
                <p>คลิกช่องที่ต้องการแล้วพิมพ์ได้ทันที รองรับการระบุ PK และ FK ในช่องแอตทริบิวต์</p>
            </div>
        </div>

        <div class="answer-toolbar">
            <div class="toolbar-left">
                <button type="button" class="btn btn-light border" id="addRowBtn"><i class="bi bi-plus-lg me-1"></i>เพิ่มแถว</button>
                <button type="button" class="btn btn-light border" id="addFiveRowsBtn"><i class="bi bi-plus-square me-1"></i>เพิ่ม 5 แถว</button>
                <button type="button" class="btn btn-light border" id="markPkBtn"><i class="bi bi-key me-1"></i>ใส่ PK</button>
                <button type="button" class="btn btn-light border" id="markFkBtn"><i class="bi bi-link-45deg me-1"></i>ใส่ FK</button>
                <button type="button" class="btn btn-outline-danger" id="clearGridBtn"><i class="bi bi-eraser me-1"></i>ล้างตาราง</button>
            </div>
            <span class="toolbar-note"><i class="bi bi-info-circle me-1 text-primary"></i>เลือกช่องก่อนกดปุ่ม PK/FK</span>
        </div>

        <div class="answer-table-wrap">
            <table class="answer-grid" id="answerGrid">
                <thead>
                    <tr>
                        <th class="table-name-heading">ชื่อตาราง</th>
                        <% for (int i = 1; i <= 10; i++) { %>
                            <th>C<%= i %></th>
                        <% } %>
                        <th class="delete-heading"><i class="bi bi-trash"></i></th>
                    </tr>
                </thead>
                <tbody id="answerGridBody"></tbody>
            </table>
        </div>

        <div class="relationship-card">
            <div class="relationship-heading">
                <div>
                    <h4><i class="bi bi-diagram-3 me-1 text-primary"></i> กำหนดความสัมพันธ์ระหว่างตาราง</h4>
                    <p>เลือกตารางที่เชื่อมโยงกัน พร้อมระบุชนิดและ Cardinality</p>
                </div>
                <button type="button" class="btn btn-primary" id="addRelationshipBtn">
                    <i class="bi bi-plus-lg me-1"></i> เพิ่มความสัมพันธ์
                </button>
            </div>

            <div class="relationship-table-wrap">
                <table class="relationship-table">
                    <thead>
                        <tr>
                            <th>ชื่อตารางต้นทาง</th>
                            <th>ความสัมพันธ์</th>
                            <th>ชื่อตารางปลายทาง</th>
                            <th>Cardinality</th>
                            <th style="width: 70px; text-align: center;"><i class="bi bi-trash"></i></th>
                        </tr>
                    </thead>
                    <tbody id="relationshipBody"></tbody>
                </table>
            </div>
            <p class="relationship-hint">
                <i class="bi bi-lightbulb me-1 text-warning"></i> <strong>ตัวอย่าง:</strong> Student → Enrollment แบบ 1:N หมายถึงนักศึกษาหนึ่งคนมีรายการลงทะเบียนได้หลายรายการ
            </p>
        </div>

        <div class="answer-footer">
            <div class="answer-notes">
                <label for="answerNotes"><i class="bi bi-chat-square-text me-1"></i>หมายเหตุ / คำอธิบายเฉลย</label>
                <textarea id="answerNotes" rows="2" placeholder="พิมพ์คำอธิบายเพิ่มเติม (ถ้ามี)"></textarea>
            </div>
            <div class="max-score-box">
                <label for="maxScore"><i class="bi bi-award me-1"></i>คะแนนเต็ม</label>
                <div class="score-input-wrap">
                    <input type="number" id="maxScore" min="0" step="0.5" value="10">
                    <span>คะแนน</span>
                </div>
            </div>
        </div>

        <div class="save-status" id="saveStatus" role="status" aria-live="polite"></div>
        
        <div class="bottom-actions">
            <span class="bottom-hint"><i class="bi bi-shield-check me-1 text-success"></i>ข้อมูลที่กรอกจะถูกรวบรวมเป็น JSON เพื่อส่งไปบันทึกเฉลยอัตโนมัติ</span>
            <button type="button" class="btn btn-primary btn-save-bottom" id="saveAnswerBtnBottom">
                <i class="bi bi-check2-circle me-1"></i>บันทึกเฉลย
            </button>
        </div>
    </div>
</div>

<script>
(() => {
    const body = document.getElementById('answerGridBody');
    const relationshipBody = document.getElementById('relationshipBody');
    const questionId = '<%= questionId.replaceAll("[^0-9]", "") %>';
    const selected = { input: null };
    const STORAGE_KEY = 'er-answer-draft-' + (questionId || 'new');
    let rowCounter = 0;

    function makeCell(value, label, extraClass) {
        const td = document.createElement('td');
        if (extraClass) td.className = extraClass;

        const input = document.createElement('input');
        input.type = 'text';
        input.value = value || '';
        input.autocomplete = 'off';
        input.setAttribute('aria-label', label);
        input.addEventListener('focus', () => selected.input = input);
        input.addEventListener('input', () => {
            decorateInput(input);
            refreshRelationshipTables();
        });

        decorateInput(input);
        td.appendChild(input);
        return td;
    }

    function decorateInput(input) {
        input.classList.toggle('is-pk', /\bPK\b/i.test(input.value));
        input.classList.toggle('is-fk', /\bFK\b/i.test(input.value));
    }

    function addRow(values = []) {
        rowCounter++;
        const tr = document.createElement('tr');
        tr.dataset.rowId = String(rowCounter);

        tr.appendChild(makeCell(values[0] || '', 'ชื่อตาราง', 'table-name-cell'));

        for (let i = 1; i <= 10; i++) {
            tr.appendChild(makeCell(values[i] || '', 'C' + i, ''));
        }

        const action = document.createElement('td');
        action.className = 'delete-cell';

        const del = document.createElement('button');
        del.type = 'button';
        del.className = 'delete-row-btn';
        del.title = 'ลบแถว';
        del.setAttribute('aria-label', 'ลบแถว');
        del.innerHTML = '<i class="bi bi-x-lg"></i>';

        del.addEventListener('click', () => {
            tr.remove();
            refreshRelationshipTables();
        });

        action.appendChild(del);
        tr.appendChild(action);
        body.appendChild(tr);
    }

    function addRows(count) {
        for (let i = 0; i < count; i++) addRow();
    }

    function markSelected(type) {
        if (!selected.input) {
            showStatus('กรุณาคลิกช่องแอตทริบิวต์ที่ต้องการก่อน', false);
            return;
        }

        const input = selected.input;
        const value = input.value.trim();
        const regex = new RegExp('(^|\\s)' + type + '(\\s|$)', 'i');

        if (!regex.test(value)) {
            input.value = value ? value + ' ' + type : type;
        }

        decorateInput(input);
        input.focus();
    }

    // อ่านรายชื่อตารางจากคอลัมน์แรก
    function getTableNames() {
        return [...body.querySelectorAll('tr')]
            .map(tr => tr.querySelector('.table-name-cell input')?.value.trim())
            .filter(Boolean)
            .filter((name, index, all) => all.indexOf(name) === index);
    }

    // สร้าง dropdown
    function makeSelect(options, selectedValue = '') {
        const select = document.createElement('select');

        options.forEach(item => {
            const option = document.createElement('option');
            option.value = item.value;
            option.textContent = item.label;
            select.appendChild(option);
        });

        select.value = selectedValue;
        return select;
    }

    // อัปเดต dropdown โดยพยายามรักษาค่าที่เลือกไว้
    function refreshRelationshipTables() {
        if (!relationshipBody) return;

        const names = getTableNames();

        relationshipBody.querySelectorAll('.table-source, .table-target')
            .forEach(select => {
                const oldValue = select.value;
                select.innerHTML = '';

                const placeholder = document.createElement('option');
                placeholder.value = '';
                placeholder.textContent = '-- เลือกตาราง --';
                select.appendChild(placeholder);

                names.forEach(name => {
                    const option = document.createElement('option');
                    option.value = name;
                    option.textContent = name;
                    select.appendChild(option);
                });

                select.value = names.includes(oldValue) ? oldValue : '';
            });
    }

    function addRelationship(data = {}) {
        const tr = document.createElement('tr');

        const sourceCell = document.createElement('td');
        const source = makeSelect(
            [{ value: '', label: '-- เลือกตาราง --' }],
            data.source || ''
        );
        source.className = 'table-source';
        sourceCell.appendChild(source);

        const typeCell = document.createElement('td');
        const type = makeSelect([
            { value: 'HAS', label: 'มี / ประกอบด้วย' },
            { value: 'ENROLLS', label: 'ลงทะเบียน' },
            { value: 'BELONGS_TO', label: 'สังกัด' },
            { value: 'ASSOCIATED_WITH', label: 'เชื่อมโยงกับ' },
            { value: 'IDENTIFYING', label: 'ความสัมพันธ์ระบุเอกลักษณ์' }
        ], data.type || 'ASSOCIATED_WITH');
        typeCell.appendChild(type);

        const targetCell = document.createElement('td');
        const target = makeSelect(
            [{ value: '', label: '-- เลือกตาราง --' }],
            data.target || ''
        );
        target.className = 'table-target';
        targetCell.appendChild(target);

        const cardinalityCell = document.createElement('td');
        const cardinality = makeSelect([
            { value: '1:1', label: '1 : 1' },
            { value: '1:N', label: '1 : N' },
            { value: 'N:1', label: 'N : 1' },
            { value: 'M:N', label: 'M : N' }
        ], data.cardinality || '1:N');
        cardinalityCell.appendChild(cardinality);

        const deleteCell = document.createElement('td');
        deleteCell.style.textAlign = 'center';
        const deleteBtn = document.createElement('button');
        deleteBtn.type = 'button';
        deleteBtn.className = 'delete-row-btn';
        deleteBtn.title = 'ลบความสัมพันธ์';
        deleteBtn.innerHTML = '<i class="bi bi-x-lg"></i>';
        deleteBtn.addEventListener('click', () => tr.remove());
        deleteCell.appendChild(deleteBtn);

        tr.append(sourceCell, typeCell, targetCell, cardinalityCell, deleteCell);
        relationshipBody.appendChild(tr);

        refreshRelationshipTables();

        // กำหนดค่าหลังสร้าง options ของ dropdown แล้ว
        source.value = data.source || '';
        target.value = data.target || '';
    }

    // รวบรวมความสัมพันธ์ทั้งหมด
    function collectRelationships() {
        return [...relationshipBody.querySelectorAll('tr')]
            .map(tr => ({
                source: tr.querySelector('.table-source').value,
                type: tr.querySelectorAll('select')[1].value,
                target: tr.querySelector('.table-target').value,
                cardinality: tr.querySelectorAll('select')[2].value
            }))
            .filter(r => r.source && r.target);
    }

    function collectData() {
        const rows = [];

        [...body.querySelectorAll('tr')].forEach((tr, index) => {
            const values = [...tr.querySelectorAll('input')]
                .map(input => input.value.trim());

            if (values.some(value => value !== '')) {
                rows.push({
                    row: index + 1,
                    tableName: values[0],
                    columns: values.slice(1).map((value, i) => ({
                        column: 'C' + (i + 1),
                        value: value,
                        keyType:
                            /\bPK\b/i.test(value) && /\bFK\b/i.test(value)
                                ? 'PK_FK'
                                : /\bPK\b/i.test(value)
                                    ? 'PK'
                                    : /\bFK\b/i.test(value)
                                        ? 'FK'
                                        : 'NORMAL'
                    })).filter(col => col.value !== '')
                });
            }
        });

        return {
            version: 1,
            format: 'ER_ANSWER_TABLE',
            questionId: questionId,
            columnCount: 10,
            rows: rows,
            relationships: collectRelationships(),
            answerText: document.getElementById('answerNotes').value.trim(),
            maxScore: document.getElementById('maxScore').value
        };
    }

    function showStatus(message, success) {
        const status = document.getElementById('saveStatus');
        status.textContent = message;
        status.className = 'save-status ' + (success ? 'success' : 'error');
        status.style.display = 'block';
    }

    function saveDraft() {
        const data = collectData();

        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
            showStatus(
                'บันทึกฉบับร่างไว้ในเบราว์เซอร์เรียบร้อยแล้ว',
                true
            );
        } catch (e) {
            showStatus('ไม่สามารถบันทึกฉบับร่างในเบราว์เซอร์ได้', false);
        }
    }

    function loadDraft() {
        try {
            const raw = localStorage.getItem(STORAGE_KEY);
            if (!raw) return false;

            const data = JSON.parse(raw);
            if (!data || !Array.isArray(data.rows)) return false;

            body.innerHTML = '';

            data.rows.forEach(row => {
                const values = Array(11).fill('');
                values[0] = row.tableName || '';

                (row.columns || []).forEach(col => {
                    const idx = parseInt(
                        String(col.column || '').replace('C', ''),
                        10
                    );

                    if (idx >= 1 && idx <= 10) {
                        values[idx] = col.value || '';
                    }
                });

                addRow(values);
            });

            if (!body.children.length) addRows(4);

            document.getElementById('answerNotes').value = data.answerText || '';
            document.getElementById('maxScore').value = data.maxScore || '10';

            // กู้คืนข้อมูลความสัมพันธ์หลังโหลดรายชื่อตารางแล้ว
            relationshipBody.innerHTML = '';

            if (Array.isArray(data.relationships)) {
                data.relationships.forEach(rel => addRelationship(rel));
            }

            refreshRelationshipTables();

            showStatus('กู้คืนฉบับร่างที่บันทึกไว้ในเบราว์เซอร์แล้ว', true);
            return true;
        } catch (e) {
            console.error('โหลดฉบับร่างไม่สำเร็จ:', e);
            return false;
        }
    }

    document.getElementById('addRowBtn')
        .addEventListener('click', () => addRow());

    document.getElementById('addFiveRowsBtn')
        .addEventListener('click', () => addRows(5));

    document.getElementById('markPkBtn')
        .addEventListener('click', () => markSelected('PK'));

    document.getElementById('markFkBtn')
        .addEventListener('click', () => markSelected('FK'));

    document.getElementById('clearGridBtn').addEventListener('click', () => {
        if (confirm('ต้องการล้างข้อมูลในตารางทั้งหมดหรือไม่?')) {
            body.innerHTML = '';
            addRows(4);
            refreshRelationshipTables();
        }
    });

    document.getElementById('saveAnswerBtn')
        .addEventListener('click', saveDraft);

    document.getElementById('saveAnswerBtnBottom')
        .addEventListener('click', saveDraft);

    document.getElementById('addRelationshipBtn')
        .addEventListener('click', () => addRelationship());

    // เมื่อเพิ่มหรือลบชื่อ table ให้อัปเดต dropdown
    body.addEventListener('input', refreshRelationshipTables);

    if (!loadDraft()) {
        addRows(4);
        refreshRelationshipTables();
    }
})();
</script>

</body>
</html>