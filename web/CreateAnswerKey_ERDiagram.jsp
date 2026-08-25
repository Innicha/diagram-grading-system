<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<mytag:ReadFile />
<mytag:header menu="6"/>
<mytag:check_login />  
<html>
    <head>
        <meta charset="UTF-8">
        <title>Create Answer Key ER Diagram</title>

        <!-- Google Fonts & FontAwesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Anuphan:wght@300;400;500;600;700&display=swap" rel="stylesheet">

        <!-- Bootstrap & Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="css/bootstrap.min.css">
        <!-- Global CSS -->
        <link rel="stylesheet" href="css/global.css">
        <!-- Custom CSS -->
        <link rel="stylesheet" href="css/AnswerKeyPages/AnswerKey_ERDiagram.css">
    </head>

    <body>

        <div class="container-fluid p-4">

            <!-- Header -->
            <div class="page-header d-flex align-items-center mb-4">
                <a href="CreateAnswerkeys.jsp" class="btn btn-outline-primary btn-back"><i class="bi bi-arrow-left me-1"></i>กลับ</a>
                <h3>สร้างเฉลย ER Diagram</h3>
                <button type="button" class="btn btn-primary btn-save-page">
                    <i class="bi bi-floppy me-1"></i>
                    บันทึกเฉลย
                </button>
            </div>

            <!-- Question Box -->
            <div class="card question-box-card shadow-sm border-0 mb-4">
                <!-- Header -->
                <div class="card-header bg-transparent d-flex align-items-center justify-content-between py-3 px-4 border-bottom-0">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-file-earmark-text-fill text-primary fs-4"></i>
                        <h5 class="m-0 fw-bold text-dark">โจทย์ปัญหา / คำถาม (Question)</h5>
                    </div>
                    <!-- ปุ่มพับ/กาง สำหรับกล่องโจทย์ -->
                    <button type="button" class="btn btn-icon text-muted toggle-question-btn" title="พับ/กาง โจทย์">
                        <i class="bi bi-chevron-down question-toggle-icon"></i>
                    </button>
                </div>

                <!-- Body (กำหนดพื้นที่พิมพ์ข้อความพร้อม Scrollbar) -->
                <div class="card-body px-4 pb-4 pt-0 question-collapse-body">
                    <div class="question-input-wrapper">
                        <textarea 
                            class="form-control question-textarea" 
                            rows="5" 
                            placeholder="ระบุโจทย์หรือรายละเอียดคำถามที่นี่..."></textarea>
                    </div>
                </div>
            </div>

            <!-- Main Grid Layout (Left 8 Cols / Right 4 Cols) -->
            <div class="row g-4">
                <!-- Left Column (Entity & Attribute Section) -->
                <div class="col-lg-8">
                    <div class="card card-er shadow-sm border-0 er-main-card">
                        <div class="card-body p-4 d-flex flex-column">
                            
                            <!-- Section Title -->
                            <div class="d-flex align-items-center mb-4 flex-shrink-0">
                                <i class="bi bi-database-fill text-primary fs-3 me-2"></i>
                                <h4 class="m-0 fw-bold text-dark">กำหนด Entity และ Attribute</h4>
                            </div>

                            <!-- Entities Grid Container ( Scrollbar เมื่อข้อมูลเกิน ) -->
                            <div class="row g-4 er-scroll-container" id="entityContainer">
                                <!-- JS จะ render entity cards 4 กล่องตรงนี้ -->
                            </div>

                            <!-- Add Entity Button -->
                            <div class="mt-auto pt-3 flex-shrink-0">
                                <button type="button" class="btn btn-add-entity w-100 py-3 fw-bold" id="addEntityBtn">
                                    <i class="bi bi-plus-circle-fill me-1"></i> เพิ่ม Entity
                                </button>
                            </div>

                        </div>
                    </div>
                </div>

                <!-- Right Column (Relationship Section) -->
                <div class="col-lg-4">
                    <div class="card card-er shadow-sm border-0 er-main-card">
                        <div class="card-body p-4 relationship-box d-flex flex-column">
                            
                            <!-- Header -->
                            <div class="d-flex align-items-center mb-4 flex-shrink-0">
                                <i class="bi bi-diagram-3-fill text-primary fs-3 me-2"></i>
                                <h4 class="m-0 fw-bold text-dark">กำหนด Relationship</h4>
                            </div>

                            <!-- Container สำหรับรายการ Relationship Cards -->
                            <div class="er-scroll-container" id="relationshipContainer">
                                <!-- JS จะ render รายการความสัมพันธ์ตรงนี้ -->
                            </div>

                            <!-- ปุ่มเพิ่ม Relationship -->
                            <div class="mt-auto pt-3 flex-shrink-0">
                                <button type="button" class="btn btn-add-rel w-100 py-2.5 fw-bold" id="addRelBtn">
                                    <i class="bi bi-plus-circle-fill me-1"></i> เพิ่ม Relationship
                                </button>
                            </div>

                        </div>
                    </div>
                </div>
            </div>

                <!-- Template สำหรับ Relationship Item -->
                <template id="relTemplate">
                    <div class="card rel-card mb-3">
                        <div class="card-body p-3">
                            <!-- Rel Header -->
                            <div class="d-flex align-items-center justify-content-between mb-2">
                                <!-- ฝั่งซ้าย: Badge ความสัมพันธ์ -->
                                <span class="badge bg-primary-subtle text-primary fw-semibold px-2 py-1.5 fs-7">
                                    <i class="bi bi-link-45deg me-1"></i> ความสัมพันธ์
                                </span>

                                <!-- ฝั่งขวา: เครื่องมือ -->
                                <div class="d-flex align-items-center">
                                    
                                    <!-- 1. ก้อนคะแนน -->
                                    <div class="d-flex align-items-center bg-light border rounded px-2 py-0.5">
                                        <span class="text-muted small me-1 fw-semibold" style="font-size: 0.75rem;">คะแนน:</span>
                                        <input type="text" 
                                            inputmode="numeric" 
                                            pattern="[0-9]*" 
                                            class="form-control form-control-sm border-0 p-0 text-center fw-bold text-success entity-score-input" 
                                            name="relScore[]" 
                                            placeholder="0" 
                                            value="10" 
                                            style="width: 28px; font-size: 0.8rem; background: transparent;">
                                    </div>

                                    <!-- 2. ไอคอนลบ -->
                                    <button type="button" class="btn btn-icon-sm text-danger p-0 delete-rel-btn" title="ลบ" style="margin-left: 15px;">
                                        <i class="bi bi-trash fs-6"></i>
                                    </button>

                                    <!-- 3. ไอคอนพับ/กาง -->
                                    <button type="button" class="btn btn-icon-sm text-muted p-0 toggle-collapse-btn" data-bs-toggle="collapse" style="margin-left: 15px;">
                                        <i class="bi bi-chevron-down toggle-icon fs-6"></i>
                                    </button>

                                </div>
                            </div>

                            <!-- Source Entity & Column -->
                            <div class="row g-2 mb-2">
                                <div class="col-6">
                                    <label class="form-label fs-7 text-muted mb-1">ตารางต้นทาง</label>
                                    <select class="form-select form-select-sm rel-source-entity" name="relSourceEntity[]">
                                        <option value="">-- เลือกตาราง --</option>
                                    </select>
                                </div>
                                <div class="col-6">
                                    <label class="form-label fs-7 text-muted mb-1">คอลัมน์ (FK/PK)</label>
                                    <select class="form-select form-select-sm rel-source-attr" name="relSourceAttr[]">
                                        <option value="">-- เลือกคอลัมน์ --</option>
                                    </select>
                                </div>
                            </div>

                            <!-- Cardinality / Relationship Type -->
                            <div class="my-2 py-1">
                                <label class="form-label fs-7 text-muted mb-1 d-block">ประเภทความสัมพันธ์</label>
                                <select class="form-select form-select-sm rel-type-select w-100" name="relType[]">
                                    <option value="1:1">One-to-One (1 : 1)</option>
                                    <option value="1:N" selected>One-to-Many (1 : N)</option>
                                    <option value="N:M">Many-to-Many (N : M)</option>
                                </select>
                            </div>

                            <!-- Target Entity & Column -->
                            <div class="row g-2">
                                <div class="col-6">
                                    <label class="form-label fs-7 text-muted mb-1">ตารางปลายทาง</label>
                                    <select class="form-select form-select-sm rel-target-entity" name="relTargetEntity[]">
                                        <option value="">-- เลือกตาราง --</option>
                                    </select>
                                </div>
                                <div class="col-6">
                                    <label class="form-label fs-7 text-muted mb-1">คอลัมน์อ้างอิง</label>
                                    <select class="form-select form-select-sm rel-target-attr" name="relTargetAttr[]">
                                        <option value="">-- เลือกคอลัมน์ --</option>
                                    </select>
                                </div>
                            </div>

                        </div>
                    </div>
                </template>

            </div>
        </div>

        <!-- HTML Templates for Dynamic JS rendering -->
        <template id="entityTemplate">
            <div class="col-md-6 mb-4 entity-card-wrapper">
                <div class="card entity-card h-100">
                    <!-- header -->
                    <div class="card-header entity-header d-flex align-items-center justify-content-between bg-transparent">
                        <!-- ฝั่งซ้าย: ไอคอน + ชื่อ Entity -->
                        <div class="d-flex align-items-center gap-2 flex-grow-1 me-2">
                            <i class="bi bi-table text-primary fs-5"></i>
                            <input type="text" class="form-control form-control-plaintext fw-bold text-primary fs-5 entity-title-input" 
                                name="entityName[]" placeholder="ระบุชื่อ Entity..." value="EntityName">
                        </div>

                        <!-- ฝั่งขวา: ช่องกำหนดคะแนน + ปุ่มเครื่องมือต่าง ๆ -->
                        <div class="d-flex align-items-center gap-2">
                            <!-- ช่องกำหนดคะแนน (Score Input) -->
                            <div class="d-flex align-items-center bg-light border rounded px-2 py-1">
                                <span class="text-muted small me-1 fw-semibold">คะแนน:</span>
                                <input type="text" inputmode="numeric" pattern="[0-9]*" 
                                    class="form-control form-control-sm border-0 p-0 text-center fw-bold text-success entity-score-input" 
                                    name="entityScore[]" placeholder="0" value="10" style="width: 30px; background: transparent;">
                            </div>
                            <button type="button" class="btn btn-icon text-muted edit-entity-btn" title="แก้ไขชื่อ">
                                <i class="bi bi-pencil"></i>
                            </button>
                            <button type="button" class="btn btn-icon text-danger delete-entity-btn" title="ลบ Entity">
                                <i class="bi bi-trash"></i>
                            </button>
                            <!-- ปุ่มพับ/กาง (ใส่ data-bs-toggle="collapse" ไว้) -->
                            <button type="button" class="btn btn-icon text-muted toggle-collapse-btn" data-bs-toggle="collapse">
                                <i class="bi bi-chevron-down toggle-icon"></i>
                            </button>
                        </div>
                    </div>
                    <!-- fig Attribute (เพิ่ม collapse show และ class entity-collapse-body) -->
                    <div class="card-body p-3 collapse show entity-collapse-body">
                        <div class="d-flex justify-content-between align-items-center mb-2 px-1 text-muted small fw-semibold">
                            <span style="width: 45%;">Attribute</span>
                            <span style="width: 40%;">ประเภท</span>
                            <span class="text-end">
                            <button type="button" class="btn btn-add-attr-sq add-attribute-btn" title="เพิ่ม Attribute">
                                <i class="bi bi-plus-lg"></i>
                            </button>
                            </span>
                        </div>

                        <div class="attribute-list">
                            <!-- JS จะใส่ attribute rows ตรงนี้ -->
                        </div>
                    </div>
                </div>
            </div>
        </template>

        <template id="attributeTemplate">
            <div class="attribute-row d-flex align-items-center mb-2 gap-2">
                <i class="bi bi-three-dots-vertical text-muted drag-handle"></i>
                <div class="flex-grow-1">
                    <input type="text" class="form-control form-control-sm attr-name-input" name="attributeName[]" placeholder="ชื่อ Attribute">
                </div>
                <div class="d-flex align-items-center flex-shrink-0" style="width: 50%; gap: 5px;">
                    <select class="form-select form-select-sm attr-type-select" name="attributeType[]">
                        <option value="NORMAL">Normal</option>
                        <option value="PK">Primary Key</option>
                        <option value="FK">Foreign Key</option>
                        <option value="PK_FK">Primary + Foreign Key</option>
                    </select>
                    <span class="badge badge-type-tag"></span>
                </div>
                <button type="button" class="btn btn-icon-sm text-danger remove-attribute-btn" title="ลบ">
                    <i class="bi bi-trash"></i>
                </button>
            </div>
        </template>

        <!-- Script -->
        <script>
        let entityCounter = 0;

        document.addEventListener('DOMContentLoaded', function () {
            const entityContainer = document.getElementById('entityContainer');
            const addEntityBtn = document.getElementById('addEntityBtn');
            const attributeTemplate = document.getElementById('attributeTemplate');

            function createAttributeRow(name = '', type = 'NORMAL') {
                const clone = attributeTemplate.content.cloneNode(true);
                const row = clone.querySelector('.attribute-row');
                const nameInput = clone.querySelector('.attr-name-input');
                const typeSelect = clone.querySelector('.attr-type-select');
                const badge = clone.querySelector('.badge-type-tag');
                const removeBtn = clone.querySelector('.remove-attribute-btn');

                nameInput.value = name;
                typeSelect.value = type;

                function updateBadge() {
                    const val = typeSelect.value;
                    badge.className = 'badge badge-type-tag'; 
                    badge.style.display = ''; 

                    if (val === 'PK') {
                        badge.textContent = 'PK';
                        badge.classList.add('badge-pk');
                        badge.style.display = 'inline-block';
                    } else if (val === 'FK') {
                        badge.textContent = 'FK';
                        badge.classList.add('badge-fk');
                        badge.style.display = 'inline-block';
                    } else if (val === 'PK_FK') {
                        badge.textContent = 'PK/FK';
                        badge.classList.add('badge-pk');
                        badge.style.display = 'inline-block';
                    } else {
                        badge.style.display = 'none';
                    }
                }

                typeSelect.addEventListener('change', updateBadge);
                removeBtn.addEventListener('click', () => row.remove());

                updateBadge();
                return clone;
            }

            function createEntityCard(entityName = 'NewEntity', attributes = []) {
                const clone = document.getElementById('entityTemplate').content.cloneNode(true);
                const cardWrapper = clone.querySelector('.entity-card-wrapper');
                const nameInput = clone.querySelector('.entity-title-input');
                const attrList = clone.querySelector('.attribute-list');
                const addAttrBtn = clone.querySelector('.add-attribute-btn');
                const deleteEntityBtn = clone.querySelector('.delete-entity-btn');
                const editEntityBtn = clone.querySelector('.edit-entity-btn');
                
                const collapseBtn = clone.querySelector('.toggle-collapse-btn');
                const collapseBody = clone.querySelector('.entity-collapse-body');
                const toggleIcon = clone.querySelector('.toggle-icon');
                const entityCard = clone.querySelector('.entity-card');

                collapseBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    const isCollapsed = collapseBody.classList.contains('d-none');
                    
                    if (isCollapsed) {
                        collapseBody.classList.remove('d-none');
                        entityCard.classList.add('h-100');
                        toggleIcon.classList.remove('bi-chevron-up');
                        toggleIcon.classList.add('bi-chevron-down');
                    } else {
                        collapseBody.classList.add('d-none');
                        entityCard.classList.remove('h-100');
                        toggleIcon.classList.remove('bi-chevron-down');
                        toggleIcon.classList.add('bi-chevron-up');
                    }
                });

                nameInput.value = entityName;

                editEntityBtn.addEventListener('click', () => nameInput.focus());

                addAttrBtn.addEventListener('click', () => {
                    attrList.appendChild(createAttributeRow());
                });

                deleteEntityBtn.addEventListener('click', () => {
                    if (confirm(`คุณต้องการลบ Entity "${nameInput.value}" ใช่หรือไม่?`)) {
                        cardWrapper.remove();
                    }
                });

                if (attributes.length > 0) {
                    attributes.forEach(attr => {
                        attrList.appendChild(createAttributeRow(attr.name, attr.type));
                    });
                } else {
                    attrList.appendChild(createAttributeRow());
                }

                return clone;
            }

            addEntityBtn.addEventListener('click', () => {
                entityContainer.appendChild(createEntityCard('NewEntity'));
            });

            for (let i = 0; i < 4; i++) {
                entityContainer.appendChild(createEntityCard('NewEntity'));
            }

            const relCard = createRelationshipCard(true); // ส่ง true เพื่อสั่งพับตั้งแต่เริ่ม
            document.getElementById('relationshipContainer').appendChild(relCard);
        });

        // ฟังก์ชันสร้าง Relationship Card
        function createRelationshipCard(startCollapsed = false) {
            const relTemplate = document.getElementById('relTemplate');
            const clone = relTemplate.content.cloneNode(true);
            const card = clone.querySelector('.rel-card');
            const deleteBtn = clone.querySelector('.delete-rel-btn');

            const sourceEntitySelect = clone.querySelector('.rel-source-entity');
            const targetEntitySelect = clone.querySelector('.rel-target-entity');

            const collapseBtn = clone.querySelector('.toggle-collapse-btn');
            const toggleIcon = clone.querySelector('.toggle-icon');
            
            const cardBody = clone.querySelector('.card-body');
            const contentElements = Array.from(cardBody.children).slice(1);

            // ฟังก์ชันสั่งพับ / กาง
            function toggleCollapse(collapse) {
                if (collapse) {
                    contentElements.forEach(el => el.classList.add('d-none'));
                    toggleIcon.classList.remove('bi-chevron-down');
                    toggleIcon.classList.add('bi-chevron-up');
                } else {
                    contentElements.forEach(el => el.classList.remove('d-none'));
                    toggleIcon.classList.remove('bi-chevron-up');
                    toggleIcon.classList.add('bi-chevron-down');
                }
            }

            collapseBtn.addEventListener('click', function (e) {
                e.preventDefault();
                const isCollapsed = contentElements[0].classList.contains('d-none');
                toggleCollapse(!isCollapsed);
            });

            // ถ้าสั่งให้พับตั้งแต่แรก (startCollapsed === true)
            if (startCollapsed) {
                toggleCollapse(true);
            }

            function populateEntitySelects() {
                const entityInputs = document.querySelectorAll('.entity-title-input');
                const currentSource = sourceEntitySelect.value;
                const currentTarget = targetEntitySelect.value;

                sourceEntitySelect.innerHTML = '<option value="">-- เลือกตาราง --</option>';
                targetEntitySelect.innerHTML = '<option value="">-- เลือกตาราง --</option>';

                entityInputs.forEach(input => {
                    const name = input.value.trim() || 'Untitled';
                    const opt1 = new Option(name, name);
                    const opt2 = new Option(name, name);
                    
                    sourceEntitySelect.add(opt1);
                    targetEntitySelect.add(opt2);
                });

                sourceEntitySelect.value = currentSource;
                targetEntitySelect.value = currentTarget;
            }

            deleteBtn.addEventListener('click', () => card.remove());
            populateEntitySelects();

            return clone;
        }

        document.getElementById('addRelBtn').addEventListener('click', () => {
            document.getElementById('relationshipContainer').appendChild(createRelationshipCard(false));
        });
        </script>
    </body>
</html>