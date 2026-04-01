<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="adminSidebar.cfm">


<cfif NOT structKeyExists(session,"user") OR session.user.role_id NEQ 1>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset departmentService = createObject("component","MedicalManagementSystem.components.DepartmentService")>
<cfset securityService   = createObject("component","MedicalManagementSystem.components.SecurityService")>
<cfset qDepartments      = departmentService.getAllDepartments()>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    #deptTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #deptTable tbody tr:hover {
        background-color: #c7d4ff4f;
    }
    #deptTable tbody td {
        font-size: 15px;
        vertical-align: middle;
    }
    .dataTables_wrapper .dataTables_filter input {
        border: 1px solid #c7d2fe;
        border-radius: 6px;
        padding: 4px 10px;
        font-size: 15px;
    }
    .dataTables_wrapper .dataTables_length select {
        border: 1px solid #c7d2fe;
        border-radius: 6px;
        padding: 2px 8px;
        font-size: 15px;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button.current {
        background: #4f46e5 !important;
        color: #fff !important;
        border-radius: 5px;
        border: none !important;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
        background: #e0e7ff !important;
        color: #4f46e5 !important;
        border: none !important;
        border-radius: 5px;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button {
        padding: 3px 10px !important;
        margin: 0 !important;
    }
    .dataTables_wrapper .dataTables_info {
        font-size: 13px;
        color: #6b7280;
    }
</style>

<div id="main">
    <header class="mb-3">
        <a href="#" class="burger-btn d-block d-xl-none">
            <i class="bi bi-justify fs-3"></i>
        </a>
    </header>

    <div class="page-heading d-flex justify-content-between align-items-center">
        <h3>Admin - Manage Departments</h3>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item">
                    <a href="/MedicalManagementSystem/pages/admin/admin_Account.cfm">
                        <i class="bi bi-person me-2"></i>My Account
                    </a>
                </li>
                <li class="breadcrumb-item">
                    <a href="/MedicalManagementSystem/pages/logout.cfm" class="text-danger">
                        <i class="bi bi-box-arrow-right me-2"></i>Logout
                    </a>
                </li>
            </ol>
        </nav>
    </div>

    <div class="page-heading mt-3">
        <button class="btn btn-success mb-3" id="openAddModal">
            <i class="bi bi-plus-circle me-1"></i> Add Department
        </button>
    </div>

    <!--- Departments Table --->
    <div class="card border-0 shadow-sm">
        <div class="card-body fw-semibold">
            <i class="bi bi-building me-2 text-primary"></i>Departments List
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table id="deptTable" class="table table-bordered table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Sl No</th>
                            <th>Name</th>
                            <th>Description</th>
                            <th>Created At</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfset sl = 1>
                        <cfoutput query="qDepartments">
                            <cfset encDeptID = securityService.encryptID(dept_id)>
                            <tr id="deptRow-#dept_id#">
                                <td>#sl#</td>
                                <td>#encodeForHTML(dept_name)#</td>
                                <td>#encodeForHTML(description)#</td>
                                <td>#dateFormat(created_at,"dd-mmm-yyyy")#</td>
                                <td>
                                    <button class="btn btn-sm statusBtn
                                        <cfif is_active EQ 1>btn-success<cfelse>btn-danger</cfif>"
                                        data-id="#encDeptID#"
                                        data-status="<cfif is_active EQ 1>Active<cfelse>Inactive</cfif>">
                                        <cfif is_active EQ 1>Active<cfelse>Inactive</cfif>
                                    </button>
                                </td>
                                <td>
                                    <cfif is_active EQ 1>
                                        <button type="button" class="btn btn-primary btn-sm editBtn"
                                            data-id="#encDeptID#"
                                            data-encid="#encodeForHTMLAttribute(encDeptID)#"
                                            data-name="#encodeForHTMLAttribute(dept_name)#"
                                            data-description="#encodeForHTMLAttribute(description)#">
                                            <i class="bi bi-pencil-square"></i> Edit
                                        </button>
                                    </cfif>
                                </td>
                            </tr>
                            <cfset sl = sl + 1>
                        </cfoutput>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!--- ADD MODAL --->
    <div class="modal fade" id="addDepartmentModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form id="addDeptForm" novalidate autocomplete="off">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-plus-circle me-2"></i>Add Department
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Name <span class="text-danger">*</span>
                            </label>
                            <input type="text" name="dept_name" id="add_dept_name"
                                   class="form-control" placeholder="Enter department name">
                            <div class="invalid-feedback" id="addNameError"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea name="description" id="add_description"
                                      class="form-control" rows="3"
                                      placeholder="Enter description (optional)"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary"
                                data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-success" id="addBtn">
                            <span id="addBtnText">Add</span>
                            <span id="addBtnSpinner"
                                  class="spinner-border spinner-border-sm ms-1 d-none"
                                  role="status"></span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!---  EDIT MODAL  --->
    <div class="modal fade" id="editDepartmentModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form id="editDeptForm" novalidate autocomplete="off">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-pencil-square me-2"></i>Edit Department
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="dept_id" id="edit_dept_id">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Name <span class="text-danger">*</span>
                            </label>
                            <input type="text" name="dept_name" id="edit_dept_name"
                                   class="form-control" placeholder="Enter department name">
                            <div class="invalid-feedback" id="editNameError"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea name="description" id="edit_description"
                                      class="form-control" rows="3"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary"
                                data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary" id="editBtn">
                            <span id="editBtnText">Update</span>
                            <span id="editBtnSpinner"
                                  class="spinner-border spinner-border-sm ms-1 d-none"
                                  role="status"></span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

</div>

<cfinclude template="../../includes/footer.cfm">

<script>
$(document).ready(function () {

    //  Dept data map 
    var deptDataMap = {};
    $('#deptTable tbody tr').each(function () {
        var $btn = $(this).find('.editBtn');
        if (!$btn.length) return;
        var id = $btn.data('id').toString();
        deptDataMap[id] = {
            encId       : $btn.data('encid'),
            name        : $btn.data('name'),
            description : $btn.data('description')
        };
    });

    //  DataTable
    var dt = $('#deptTable').DataTable({
        pageLength: 5,
        columnDefs: [{ orderable: false, targets: [4, 5] }],
        language: {
            search:       '<i class="bi bi-search me-1"></i>Search:',
            lengthMenu:   'Show _MENU_ entries',
            info:         'Showing _START_ to _END_ of _TOTAL_ departments',
            paginate: {
                previous: '&lsaquo;',
                next:     '&rsaquo;'
            }
        }
    });

    //  SweetAlert2 helper 
    function swAlert(icon, title, text) {
        Swal.fire({
            icon:               icon,
            title:              title,
            text:               text,
            confirmButtonColor: '#4f46e5',
            timer:              icon === 'success' ? 2500 : undefined,
            timerProgressBar:   icon === 'success'
        });
    }

    //  Modal instances 
    var addModalEl  = document.getElementById('addDepartmentModal');
    var editModalEl = document.getElementById('editDepartmentModal');
    var addModal    = new bootstrap.Modal(addModalEl);
    var editModal   = new bootstrap.Modal(editModalEl);

    function validName(v) {
        v = v.trim();
        return v.length >= 3 && /^[A-Za-z ]+$/.test(v);
    }

    function resetBtn(btnId, spinnerId, textId, label) {
        $('#' + textId).text(label);
        $('#' + spinnerId).addClass('d-none');
        $('#' + btnId).prop('disabled', false);
    }

    //  Open Add Modal 
    $('#openAddModal').on('click', function () {
        $('#addDeptForm')[0].reset();
        $('#add_dept_name').removeClass('is-invalid');
        $('#addNameError').text('');
        addModal.show();
    });

    $(addModalEl).on('hidden.bs.modal', function () {
        $('#addDeptForm')[0].reset();
        $('#add_dept_name').removeClass('is-invalid');
        $('#addNameError').text('');
        resetBtn('addBtn','addBtnSpinner','addBtnText','Add');
    });

    //  Open Edit Modal 
    $('#deptTable tbody').on('click', '.editBtn', function () {
        var id = $(this).data('id').toString();
        var d  = deptDataMap[id];
        if (!d) {
            swAlert('error', 'Not Found', 'Could not load department data — please refresh.');
            return;
        }
        $('#edit_dept_id').val(id);
        $('#edit_dept_name').val(d.name);
        $('#edit_description').val(d.description);
        $('#edit_dept_name').removeClass('is-invalid');
        $('#editNameError').text('');
        editModal.show();
    });

    $(editModalEl).on('hidden.bs.modal', function () {
        $('#edit_dept_name').removeClass('is-invalid');
        $('#editNameError').text('');
        resetBtn('editBtn','editBtnSpinner','editBtnText','Update');
    });

    //  Add Department 
    $('#addDeptForm').on('submit', function (e) {
        e.preventDefault();

        var name = $('#add_dept_name').val();
        $('#add_dept_name').removeClass('is-invalid');
        $('#addNameError').text('');

        if (!validName(name)) {
            $('#add_dept_name').addClass('is-invalid');
            $('#addNameError').text('Name must be at least 3 letters (alphabets only).');
            return;
        }

        $('#addBtnText').text('Adding...');
        $('#addBtnSpinner').removeClass('d-none');
        $('#addBtn').prop('disabled', true);

        $.ajax({
            url:      '/MedicalManagementSystem/components/DepartmentService.cfc'
                    + '?method=addDepartmentAjax&returnformat=json',
            type:     'POST',
            data:     { dept_name: name, description: $('#add_description').val() },
            dataType: 'json',
            success: function (res) {
                resetBtn('addBtn','addBtnSpinner','addBtnText','Add');

                if (res.SUCCESS) {
                    var rowId = '#deptRow-' + res.DEPT_ID;

                    var statusBtn =
                        '<button class="btn btn-sm statusBtn btn-success" '
                        + 'data-id="' + res.ENC_DEPT_ID + '" data-status="Active">Active</button>';

                    var editBtnHtml =
                        '<button type="button" class="btn btn-primary btn-sm editBtn" '
                        + 'data-id="'          + res.ENC_DEPT_ID  + '" '
                        + 'data-encid="'       + res.ENC_DEPT_ID  + '" '
                        + 'data-name="'        + res.DEPT_NAME    + '" '
                        + 'data-description="' + res.DESCRIPTION  + '">'
                        + '<i class="bi bi-pencil-square"></i> Edit</button>';

                    // Register in deptDataMap so Edit works immediately 
                        deptDataMap[res.ENC_DEPT_ID] = {
                            encId       : res.ENC_DEPT_ID,
                            name        : res.DEPT_NAME,
                            description : res.DESCRIPTION
                        };

                        if ($(rowId).length) {
                            // Reactivation — update existing row
                            var row     = dt.row($(rowId));
                            var rowData = row.data();
                            rowData[1]  = res.DEPT_NAME;
                            rowData[2]  = res.DESCRIPTION;
                            rowData[3]  = res.CREATED_AT;
                            rowData[4]  = statusBtn;
                            rowData[5]  = editBtnHtml;
                            row.data(rowData).draw(false);
                        } else {
                            // New department
                            dt.row.add([
                                dt.rows().count() + 1,
                                res.DEPT_NAME,
                                res.DESCRIPTION,
                                res.CREATED_AT,
                                statusBtn,
                                editBtnHtml
                            ]).draw(false);
                        }

                    addModal.hide();
                    swAlert('success', 'Added!', res.MESSAGE);

                } else {
                    swAlert('error', 'Failed', res.MESSAGE);
                }
            },
            error: function (xhr) {
                resetBtn('addBtn','addBtnSpinner','addBtnText','Add');
                console.error('Add AJAX error:', xhr.responseText);
                swAlert('error', 'Server Error', 'Something went wrong — please try again.');
            }
        });
    });

    // Edit Department
    $('#editDeptForm').on('submit', function (e) {
        e.preventDefault();

        var id   = $('#edit_dept_id').val();
        var name = $('#edit_dept_name').val();
        var desc = $('#edit_description').val();

        $('#edit_dept_name').removeClass('is-invalid');
        $('#editNameError').text('');

        if (!validName(name)) {
            $('#edit_dept_name').addClass('is-invalid');
            $('#editNameError').text('Name must be at least 3 letters (alphabets only).');
            return;
        }

        $('#editBtnText').text('Updating...');
        $('#editBtnSpinner').removeClass('d-none');
        $('#editBtn').prop('disabled', true);

        $.ajax({
            url:      '/MedicalManagementSystem/components/DepartmentService.cfc'
                    + '?method=editDepartmentAjax&returnformat=json',
            type:     'POST',
            data:     { enc_dept_id: id, dept_name: name, description: desc },
            dataType: 'json',
            success: function (res) {
                resetBtn('editBtn','editBtnSpinner','editBtnText','Update');

                var ok  = res.SUCCESS === true  || res.success === true
                       || res.SUCCESS === 'true' || res.success === 'true';
                var msg = res.MESSAGE || res.message || '';

                if (ok) {
                    if (deptDataMap[id]) {
                        deptDataMap[id].name        = name.trim();
                        deptDataMap[id].description = desc.trim();
                    }

                    var $btn    = $('#deptTable').find('.editBtn[data-id="' + id + '"]');
                    var dtRow   = dt.row($btn.closest('tr'));
                    var rowData = dtRow.data();
                    rowData[1]  = name.trim();
                    rowData[2]  = desc.trim();
                    dtRow.data(rowData).invalidate().draw(false);

                    $('#deptTable').find('.editBtn[data-id="' + id + '"]')
                        .data('name', name.trim())
                        .data('description', desc.trim());

                    editModal.hide();
                    swAlert('success', 'Updated!', msg);

                } else {
                    // Keep modal open, show inline error
                    $('#edit_dept_name').addClass('is-invalid');
                    $('#editNameError').text(msg);
                }
            },
            error: function (xhr) {
                resetBtn('editBtn','editBtnSpinner','editBtnText','Update');
                console.error('Edit AJAX error:', xhr.responseText);
                swAlert('error', 'Server Error', 'Something went wrong — please try again.');
            }
        });
    });

    //  Toggle Status 
    $('#deptTable').on('click', '.statusBtn', function () {
        var $btn          = $(this);
        var encId         = $btn.data('id');
        var currentStatus = $btn.data('status');
        var newStatus     = currentStatus === 'Active' ? 'Inactive' : 'Active';

        Swal.fire({
            title:              'Change Status?',
            text:               'Set this department to ' + newStatus + '?',
            icon:               'question',
            showCancelButton:   true,
            confirmButtonColor: newStatus === 'Active' ? '#198754' : '#dc3545',
            cancelButtonColor:  '#6c757d',
            confirmButtonText:  'Yes, set ' + newStatus,
            cancelButtonText:   'Cancel'
        }).then(function (result) {
            if (!result.isConfirmed) return;

            $.ajax({
                url:      '/MedicalManagementSystem/components/DepartmentService.cfc'
                        + '?method=toggleStatus&returnformat=json',
                type:     'POST',
                data:     { enc_id: encId, new_status: newStatus },
                dataType: 'json',
                success: function (res) {
                    var ok  = res.SUCCESS === true || res.SUCCESS === 'true' || res.success === true;
                    var msg = res.MESSAGE || res.message || '';

                    if (!ok) {
                        swAlert('error', 'Failed', msg || 'Failed to update status.');
                        return;
                    }

                    var row     = dt.row($btn.closest('tr'));
                    var rowData = row.data();

                    if (newStatus === 'Active') {
                        rowData[4] =
                            '<button class="btn btn-sm statusBtn btn-success" '
                            + 'data-id="' + encId + '" data-status="Active">Active</button>';
                        rowData[5] =
                            '<button type="button" class="btn btn-primary btn-sm editBtn" '
                            + 'data-id="' + encId + '">'
                            + '<i class="bi bi-pencil-square"></i> Edit</button>';
                    } else {
                        rowData[4] =
                            '<button class="btn btn-sm statusBtn btn-danger" '
                            + 'data-id="' + encId + '" data-status="Inactive">Inactive</button>';
                        rowData[5] = '';
                    }

                    row.data(rowData).draw(false);
                    swAlert('success', 'Done!', 'Status changed to ' + newStatus + '.');
                },
                error: function (xhr) {
                    console.error('Status toggle error:', xhr.responseText);
                    swAlert('error', 'Server Error', 'Something went wrong. Please try again.');
                }
            });
        });
    });

});
</script>
