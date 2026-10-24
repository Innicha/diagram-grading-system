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
    
    <style>
        /* บังคับตารางให้เลื่อนซ้ายขวาได้หากคอลัมน์เยอะเกินไป */
        .answer-table-wrap {
            overflow-x: auto;
            max-width: 100%;
        }
        .answer-grid th, .answer-grid td {
            min-width: 80px;
        }
        .answer-grid .table-name-heading, .answer-grid .table-name-cell {
            min-width: 150px;
        }
    </style>
</head>
<body>
<div class="container-fluid answer-key-page">
    <div class="page-header d-flex align-items-center justify-content-between flex-wrap">
        <div>
            <h3><i class="bi bi-file-earmark-code-fill text-primary me-2"></i>สร้างเฉลย ER Diagram</h3>
            <p class="page-subtitle mb-0">กรอกชื่อตารางและแอตทริบิวต์ลงในตาราง (รองรับการระบุ PK/FK ผ่านการพิมพ์โดยตรง)</p>
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
                <h4>ตารางเฉลย (ขนาด 20x20)</h4>
                <p>พิมพ์ชื่อตารางในคอลัมน์แรก และใส่ชื่อแอตทริบิวต์ในคอลัมน์ C1-C20 (สามารถพิมพ์ PK/FK ต่อท้ายได้เลย เช่น "id PK")</p>
            </div>
        </div>

        <div class="answer-toolbar">
            <div class="toolbar-left">
                <button type="button" class="btn btn-outline-danger" id="clearGridBtn"><i class="bi bi-eraser me-1"></i>ล้างตารางทั้งหมด</button>
            </div>
        </div>

        <div class="answer-table-wrap">
            <table class="answer-grid" id="answerGrid">
                <thead>
                    <tr>
                        <th class="table-name-heading">ชื่อตาราง</th>
                        <% for (int i = 1; i <= 20; i++) { %>
                            <th>C<%= i %></th>
                        <% } %>
                    </tr>
                </thead>
                <tbody id="answerGridBody"></tbody>
            </table>
        </div>

        <div class="answer-footer mt-4">
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

        <div class="save-status" id="saveStatus" role="status" aria-live="polite" style="display: none;"></div>
        
        <div class="bottom-actions mt-3">
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
    const questionId = '<%= questionId.replaceAll("[^0-9]", "") %>';
    const STORAGE_KEY = 'er-answer-draft-' + (questionId || 'new');
    
    // ตั้งค่าขนาดกระดานคงที่ (แถว=20, คอลัมน์=20)
    const MAX_ROWS = 20;
    const MAX_COLS = 20;

    function makeCell(value, label, extraClass) {
        const td = document.createElement('td');
        if (extraClass) td.className = extraClass;

        const input = document.createElement('input');
        input.type = 'text';
        input.value = value || '';
        input.autocomplete = 'off';
        input.setAttribute('aria-label', label);
        
        // เช็คการเน้นสีข้อความ PK/FK เบื้องต้น
        input.addEventListener('input', () => {
            input.classList.toggle('is-pk', /\bPK\b/i.test(input.value));
            input.classList.toggle('is-fk', /\bFK\b/i.test(input.value));
        });
        
        input.classList.toggle('is-pk', /\bPK\b/i.test(input.value));
        input.classList.toggle('is-fk', /\bFK\b/i.test(input.value));

        td.appendChild(input);
        return td;
    }

    function addRow(values = []) {
        const tr = document.createElement('tr');
        tr.appendChild(makeCell(values[0] || '', 'ชื่อตาราง', 'table-name-cell'));
        
        for (let i = 1; i <= MAX_COLS; i++) {
            tr.appendChild(makeCell(values[i] || '', 'C' + i, ''));
        }
        
        body.appendChild(tr);
    }

    function addRows(count) {
        for (let i = 0; i < count; i++) addRow();
    }

    function collectData() {
        const rows = [];

        [...body.querySelectorAll('tr')].forEach((tr, index) => {
            const values = [...tr.querySelectorAll('input')].map(input => input.value.trim());

            if (values.some(value => value !== '')) {
                rows.push({
                    row: index + 1,
                    tableName: values[0],
                    columns: values.slice(1).map((value, i) => ({
                        column: 'C' + (i + 1),
                        value: value,
                        keyType:
                            /\bPK\b/i.test(value) && /\bFK\b/i.test(value) ? 'PK_FK'
                            : /\bPK\b/i.test(value) ? 'PK'
                            : /\bFK\b/i.test(value) ? 'FK'
                            : 'NORMAL'
                    })).filter(col => col.value !== '')
                });
            }
        });

        return {
            version: 1,
            format: 'ER_ANSWER_TABLE',
            questionId: questionId,
            columnCount: MAX_COLS,
            rows: rows,
            relationships: [], // ส่ง Array ว่างไปเพื่อไม่ให้โค้ดฝั่ง Backend แตก
            answerText: document.getElementById('answerNotes').value.trim(),
            maxScore: document.getElementById('maxScore').value
        };
    }

    function showStatus(message, success) {
        const status = document.getElementById('saveStatus');
        status.textContent = message;
        status.className = 'save-status ' + (success ? 'success' : 'error') + ' mt-3 p-2 rounded';
        status.style.display = 'block';
        
        setTimeout(() => {
            status.style.display = 'none';
        }, 3000);
    }

    function saveDraft() {
        const data = collectData();
        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
            showStatus('บันทึกฉบับร่างไว้ในเบราว์เซอร์เรียบร้อยแล้ว', true);
            
            // TODO: หากมี API ยิงไปบันทึกลง Database สามารถเพิ่ม AJAX ตรงนี้ได้เลย
            // console.log(JSON.stringify(data));
            
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
                const values = Array(MAX_COLS + 1).fill('');
                values[0] = row.tableName || '';

                (row.columns || []).forEach(col => {
                    const idx = parseInt(String(col.column || '').replace('C', ''), 10);
                    if (idx >= 1 && idx <= MAX_COLS) {
                        values[idx] = col.value || '';
                    }
                });
                addRow(values);
            });

            // บังคับให้ตารางมี 20 แถวเสมอ (สร้างเพิ่มถ้าดึงมาแล้วไม่ครบ)
            const currentRows = body.querySelectorAll('tr').length;
            if (currentRows < MAX_ROWS) {
                addRows(MAX_ROWS - currentRows);
            } else if (currentRows > MAX_ROWS) {
                const rows = body.querySelectorAll('tr');
                for (let i = MAX_ROWS; i < rows.length; i++) rows[i].remove();
            }

            document.getElementById('answerNotes').value = data.answerText || '';
            document.getElementById('maxScore').value = data.maxScore || '10';

            showStatus('กู้คืนฉบับร่างที่บันทึกไว้ในเบราว์เซอร์แล้ว', true);
            return true;
        } catch (e) {
            console.error('โหลดฉบับร่างไม่สำเร็จ:', e);
            return false;
        }
    }

    document.getElementById('clearGridBtn').addEventListener('click', () => {
        if (confirm('ต้องการล้างข้อมูลในตารางทั้งหมดหรือไม่?')) {
            body.innerHTML = '';
            addRows(MAX_ROWS);
            localStorage.removeItem(STORAGE_KEY);
        }
    });

    document.getElementById('saveAnswerBtn').addEventListener('click', saveDraft);
    document.getElementById('saveAnswerBtnBottom').addEventListener('click', saveDraft);

    // Initial Load
    if (!loadDraft()) {
        addRows(MAX_ROWS);
    }
})();
</script>
</body>
</html>