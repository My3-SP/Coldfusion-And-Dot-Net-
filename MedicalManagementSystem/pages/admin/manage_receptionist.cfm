<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="adminSidebar.cfm">

<cfif NOT structKeyExists(session,"user") OR session.user.role_id NEQ 1>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset receptionService = createObject("component","MedicalManagementSystem.components.ReceptionService")>
<cfset securityService  = createObject("component","MedicalManagementSystem.components.SecurityService")>
<cfset receptionists    = receptionService.getAllReceptionists()>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    #receptionTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #receptionTable tbody tr:hover {
        background-color: #c7d4ff4f;
    }
    #receptionTable tbody td {
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
        font-size: 15px;
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
        <h3>Admin - Manage Receptionists</h3>
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
            <i class="bi bi-person-plus-fill me-1"></i> Add Receptionist
        </button>
    </div>

    <!--- Receptionists Table --->
    <div class="card border-0 shadow-sm">
        <div class="card-body fw-semibold">
            <i class="bi bi-person-badge me-2 text-primary"></i>Receptionists List
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table id="receptionTable" class="table table-bordered table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Sl No</th>
                            <th>Name</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfset sl = 1>
                        <cfoutput query="receptionists">
                        <tr>
                            <td>#sl#</td>
                            <td>#encodeForHTML(full_name)#</td>
                            <td>#encodeForHTML(username)#</td>
                            <td>#encodeForHTML(email)#</td>
                            <td>#encodeForHTML(phone)#</td>
                            <td>
                                <button class="btn btn-sm statusBtn
                                    <cfif is_active EQ 1>btn-success<cfelse>btn-danger</cfif>"
                                    data-userid="#securityService.encryptID(user_id)#"
                                    data-status="<cfif is_active EQ 1>Active<cfelse>Inactive</cfif>">
                                    <cfif is_active EQ 1>Active<cfelse>Inactive</cfif>
                                </button>
                            </td>
                            <td>
                                <cfif is_active EQ 1>
                                    <button class="btn btn-primary btn-sm editBtn"
                                        data-enc_user_id="#securityService.encryptID(user_id)#"
                                        data-full_name="#encodeForHTMLAttribute(full_name)#"
                                        data-username="#encodeForHTMLAttribute(username)#"
                                        data-email="#encodeForHTMLAttribute(email)#"
                                        data-phone="#encodeForHTMLAttribute(phone)#">
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

    <!---  ADD MODAL  --->
    <div class="modal fade" id="addReceptionModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form id="addReceptionForm" novalidate autocomplete="off">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-plus-circle me-2"></i>Add Receptionist
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Full Name <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="add_full_name" name="full_name"
                                   placeholder="Enter full name">
                            <div class="invalid-feedback" id="add_full_name_err"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Username <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="add_username" name="username"
                                   placeholder="Min 4 chars, letters/numbers/underscore">
                            <div class="invalid-feedback" id="add_username_err"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Email <span class="text-danger">*</span>
                            </label>
                            <input type="email" class="form-control" id="add_email" name="email"
                                   placeholder="Enter email">
                            <div class="invalid-feedback" id="add_email_err"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Phone <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="add_phone" name="phone"
                                   placeholder="Exactly 10 digits">
                            <div class="invalid-feedback" id="add_phone_err"></div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary"
                                data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-success" id="addReceptionBtn">
                            <span id="addReceptionBtnText">Add Receptionist</span>
                            <span id="addReceptionSpinner"
                                  class="spinner-border spinner-border-sm ms-1 d-none"
                                  role="status"></span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!---  EDIT MODAL  --->
    <div class="modal fade" id="editReceptionModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form id="editReceptionForm" novalidate autocomplete="off">
                    <input type="hidden" id="edit_user_id" name="enc_user_id">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-pencil-square me-2"></i>Edit Receptionist
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Full Name <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="edit_full_name" name="full_name">
                            <div class="invalid-feedback" id="edit_full_name_err"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Username <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="edit_username" name="username">
                            <div class="invalid-feedback" id="edit_username_err"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Email <span class="text-danger">*</span>
                            </label>
                            <input type="email" class="form-control" id="edit_email" name="email">
                            <div class="invalid-feedback" id="edit_email_err"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Phone <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="edit_phone" name="phone">
                            <div class="invalid-feedback" id="edit_phone_err"></div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary"
                                data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary" id="editReceptionBtn">
                            <span id="editReceptionBtnText">Update Receptionist</span>
                            <span id="editReceptionSpinner"
                                  class="spinner-border spinner-border-sm ms-1 d-none"
                                  role="status"></span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

</div><!--- main end --->

<cfinclude template="../../includes/footer.cfm">

<script>
$(document).ready(function () {

    // Reception data map 
    var receptionMap = {};
    $('#receptionTable tbody tr').each(function () {
        var $btn = $(this).find('.editBtn');
        if (!$btn.length) return;
        var encID = $btn.data('enc_user_id').toString();
        receptionMap[encID] = {
            enc_user_id : encID,
            full_name   : $btn.data('full_name'),
            username    : $btn.data('username'),
            email       : $btn.data('email'),
            phone       : $btn.data('phone')
        };
    });

    //  DataTable 
    var dt = $('#receptionTable').DataTable({
        pageLength: 5,
        columnDefs: [{ orderable: false, targets: [5, 6] }],
        language: {
            search:       '<i class="bi bi-search me-1"></i>Search:',
            lengthMenu:   'Show _MENU_ entries',
            info:         'Showing _START_ to _END_ of _TOTAL_ receptionists',
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
    var addModalEl  = document.getElementById('addReceptionModal');
    var editModalEl = document.getElementById('editReceptionModal');
    var addModal    = new bootstrap.Modal(addModalEl);
    var editModal   = new bootstrap.Modal(editModalEl);

    //Validation rules
    var R = {
        req      : function (v) { return $.trim(v).length > 0; },
        minLen   : function (v, n) { return $.trim(v).length >= n; },
        alpha    : function (v) { return /^[A-Za-z\s]+$/.test($.trim(v)); },
        alphaNum : function (v) { return /^[A-Za-z0-9_]+$/.test($.trim(v)); },
        email    : function (v) { return /^(?!.*\.\.)([A-Za-z0-9]+)@[A-Za-z0-9-]+\.[A-Za-z]{2,}$/.test($.trim(v)); },
        phone     : function (v) { return /^(?!0+$)[6-9]\d{9}$/.test($.trim(v));},
    };

    function setErr(inputId, errId, msg) {
        $('#' + inputId).addClass('is-invalid').removeClass('is-valid');
        $('#' + errId).text(msg);
    }

    function setOk(inputId) {
        $('#' + inputId).removeClass('is-invalid').addClass('is-valid');
    }

    function clearForm(formId) {
        $('#' + formId + ' .form-control, #' + formId + ' .form-select')
            .removeClass('is-invalid is-valid');
        $('#' + formId + ' .invalid-feedback').text('');
    }

    function resetBtn(btnId, spinnerId, textId, label) {
        $('#' + textId).text(label);
        $('#' + spinnerId).addClass('d-none');
        $('#' + btnId).prop('disabled', false);
    }

    // Add validation
    function validateAdd() {
        var ok = true;

        var name = $('#add_full_name').val();
        if (!R.req(name))           { setErr('add_full_name','add_full_name_err','Full Name is required.'); ok=false; }
        else if (!R.minLen(name,3)) { setErr('add_full_name','add_full_name_err','Must be at least 3 characters.'); ok=false; }
        else if (!R.alpha(name))    { setErr('add_full_name','add_full_name_err','Letters only.'); ok=false; }
        else setOk('add_full_name');

        var uname = $('#add_username').val();
        if (!R.req(uname))           { setErr('add_username','add_username_err','Username is required.'); ok=false; }
        else if (!R.minLen(uname,4)) { setErr('add_username','add_username_err','Must be at least 4 characters.'); ok=false; }
        else if (!R.alphaNum(uname)) { setErr('add_username','add_username_err','Letters, numbers and underscores only.'); ok=false; }
        else setOk('add_username');

        var email = $('#add_email').val();
        if (!R.req(email))        { setErr('add_email','add_email_err','Email is required.'); ok=false; }
        else if (!R.email(email)) { setErr('add_email','add_email_err','Enter a valid email address.'); ok=false; }
        else setOk('add_email');

        var phone = $('#add_phone').val();
        if (!R.req(phone))          { setErr('add_phone','add_phone_err','Phone is required.'); ok=false; }
        else if (!R.phone10(phone)) { setErr('add_phone','add_phone_err','Must be exactly 10 digits.'); ok=false; }
        else setOk('add_phone');

        return ok;
    }

    //  Edit validation 
    function validateEdit() {
        var ok = true;

        var name = $('#edit_full_name').val();
        if (!R.req(name))           { setErr('edit_full_name','edit_full_name_err','Full Name is required.'); ok=false; }
        else if (!R.minLen(name,3)) { setErr('edit_full_name','edit_full_name_err','Must be at least 3 characters.'); ok=false; }
        else if (!R.alpha(name))    { setErr('edit_full_name','edit_full_name_err','Letters only.'); ok=false; }
        else setOk('edit_full_name');

        var uname = $('#edit_username').val();
        if (!R.req(uname))           { setErr('edit_username','edit_username_err','Username is required.'); ok=false; }
        else if (!R.minLen(uname,4)) { setErr('edit_username','edit_username_err','Must be at least 4 characters.'); ok=false; }
        else if (!R.alphaNum(uname)) { setErr('edit_username','edit_username_err','Letters, numbers and underscores only.'); ok=false; }
        else setOk('edit_username');

        var email = $('#edit_email').val();
        if (!R.req(email))        { setErr('edit_email','edit_email_err','Email is required.'); ok=false; }
        else if (!R.email(email)) { setErr('edit_email','edit_email_err','Enter a valid email address.'); ok=false; }
        else setOk('edit_email');

        var phone = $('#edit_phone').val();
        if (!R.req(phone))          { setErr('edit_phone','edit_phone_err','Phone is required.'); ok=false; }
        else if (!R.phone10(phone)) { setErr('edit_phone','edit_phone_err','Must be exactly 10 digits.'); ok=false; }
        else setOk('edit_phone');

        return ok;
    }

    //  Open Add Modal 
    $('#openAddModal').on('click', function () {
        $('#addReceptionForm')[0].reset();
        clearForm('addReceptionForm');
        addModal.show();
    });

    $(addModalEl).on('hidden.bs.modal', function () {
        $('#addReceptionForm')[0].reset();
        clearForm('addReceptionForm');
        resetBtn('addReceptionBtn','addReceptionSpinner','addReceptionBtnText','Add Receptionist');
    });

    // Open Edit Modal
    $('#receptionTable').on('click', '.editBtn', function () {
        var encID = $(this).data('enc_user_id').toString();
        var r     = receptionMap[encID];
        if (!r) {
            swAlert('error','Not Found','Unable to load receptionist details — please refresh.');
            return;
        }
        clearForm('editReceptionForm');
        $('#edit_user_id').val(r.enc_user_id);
        $('#edit_full_name').val(r.full_name);
        $('#edit_username').val(r.username);
        $('#edit_email').val(r.email);
        $('#edit_phone').val(r.phone);
        editModal.show();
    });

    $(editModalEl).on('hidden.bs.modal', function () {
        clearForm('editReceptionForm');
        resetBtn('editReceptionBtn','editReceptionSpinner','editReceptionBtnText','Update Receptionist');
    });

    //  Add Receptionist Submit
    $('#addReceptionForm').on('submit', function (e) {
        e.preventDefault();
        clearForm('addReceptionForm');
        if (!validateAdd()) return;

        $('#addReceptionBtnText').text('Adding...');
        $('#addReceptionSpinner').removeClass('d-none');
        $('#addReceptionBtn').prop('disabled', true);

        $.ajax({
            url:      '/MedicalManagementSystem/components/ReceptionService.cfc'
                    + '?method=addReceptionistAjax&returnformat=json',
            type:     'POST',
            data:     $(this).serialize()
                    + '&created_by=<cfoutput>#session.user.user_id#</cfoutput>',
            dataType: 'json',
            success: function (res) {
                resetBtn('addReceptionBtn','addReceptionSpinner','addReceptionBtnText','Add Receptionist');

                var ok  = res.SUCCESS === true || res.SUCCESS === 'true' || res.success === true;
                var msg = res.MESSAGE || res.message || '';

                if (!ok) {
                    swAlert('error', 'Failed', msg);
                    return;
                }

                var newEncID = (res.ENC_USER_ID || res.enc_user_id || '').toString();
                var newName  = $('#add_full_name').val().trim();
                var newUser  = $('#add_username').val().trim();
                var newEmail = $('#add_email').val().trim();
                var newPhone = $('#add_phone').val().trim();

                // Register in map so Edit works immediately
                receptionMap[newEncID] = {
                    enc_user_id : newEncID,
                    full_name   : newName,
                    username    : newUser,
                    email       : newEmail,
                    phone       : newPhone
                };

                var statusBtn =
                    '<button class="btn btn-sm btn-success statusBtn" '
                    + 'data-userid="' + newEncID + '" '
                    + 'data-status="Active">Active</button>';

                var actionHtml =
                    '<button type="button" class="btn btn-primary btn-sm editBtn" '
                    + 'data-enc_user_id="' + newEncID + '" '
                    + 'data-full_name="'   + newName  + '" '
                    + 'data-username="'    + newUser  + '" '
                    + 'data-email="'       + newEmail + '" '
                    + 'data-phone="'       + newPhone + '">'
                    + '<i class="bi bi-pencil-square"></i> Edit</button>';

                // Reactivation — row exists, update it
                var existingRow = null;
                dt.rows().every(function () {
                    if (this.data()[2] === newUser) { existingRow = this; }
                });

                if (existingRow) {
                    var rowData = existingRow.data();
                    rowData[1] = newName;
                    rowData[3] = newEmail;
                    rowData[4] = newPhone;
                    rowData[5] = statusBtn;
                    rowData[6] = actionHtml;
                    existingRow.data(rowData).draw(false);
                } else {
                    dt.row.add([
                        dt.rows().count() + 1,
                        newName, newUser, newEmail, newPhone,
                        statusBtn, actionHtml
                    ]).draw(false);
                }

                addModal.hide();
                swAlert('success', 'Added!', msg);
            },
            error: function (xhr) {
                resetBtn('addReceptionBtn','addReceptionSpinner','addReceptionBtnText','Add Receptionist');
                console.error('Add error:', xhr.responseText);
                swAlert('error','Server Error','Something went wrong — please try again.');
            }
        });
    });

    // Edit Receptionist Submit
    $('#editReceptionForm').on('submit', function (e) {
        e.preventDefault();
        clearForm('editReceptionForm');
        if (!validateEdit()) return;

        $('#editReceptionBtnText').text('Updating...');
        $('#editReceptionSpinner').removeClass('d-none');
        $('#editReceptionBtn').prop('disabled', true);

        $.ajax({
            url:      '/MedicalManagementSystem/components/ReceptionService.cfc'
                    + '?method=editReceptionistAjax&returnformat=json',
            type:     'POST',
            data:     $(this).serialize(),
            dataType: 'json',
            success: function (res) {
                resetBtn('editReceptionBtn','editReceptionSpinner','editReceptionBtnText','Update Receptionist');

                var ok  = res.SUCCESS === true || res.SUCCESS === 'true' || res.success === true;
                var msg = res.MESSAGE || res.message || '';

                if (!ok) {
                    swAlert('error', 'Failed', msg);
                    return;
                }

                var encID    = $('#edit_user_id').val();
                var fullName = $('#edit_full_name').val().trim();
                var username = $('#edit_username').val().trim();
                var email    = $('#edit_email').val().trim();
                var phone    = $('#edit_phone').val().trim();

                // Update map
                if (receptionMap[encID]) {
                    receptionMap[encID].full_name = fullName;
                    receptionMap[encID].username  = username;
                    receptionMap[encID].email     = email;
                    receptionMap[encID].phone     = phone;
                }

                // Update DataTable row
                var $editBtn = $('#receptionTable')
                    .find('.editBtn[data-enc_user_id="' + encID + '"]');
                var dtRow   = dt.row($editBtn.closest('tr'));
                var rowData = dtRow.data();
                rowData[1] = fullName;
                rowData[2] = username;
                rowData[3] = email;
                rowData[4] = phone;
                dtRow.data(rowData).invalidate().draw(false);

                // Re-sync data attrs
                $('#receptionTable')
                    .find('.editBtn[data-enc_user_id="' + encID + '"]')
                    .data('full_name', fullName)
                    .data('username',  username)
                    .data('email',     email)
                    .data('phone',     phone);

                editModal.hide();
                swAlert('success', 'Updated!', msg);
            },
            error: function (xhr) {
                resetBtn('editReceptionBtn','editReceptionSpinner','editReceptionBtnText','Update Receptionist');
                console.error('Edit error:', xhr.responseText);
                swAlert('error','Server Error','Something went wrong — please try again.');
            }
        });
    });

    // Toggle Status
    $('#receptionTable').on('click', '.statusBtn', function () {
        var $btn          = $(this);
        var encID         = $btn.data('userid');
        var currentStatus = $btn.data('status');
        var newStatus     = currentStatus === 'Active' ? 'Inactive' : 'Active';

        Swal.fire({
            title:              'Change Status?',
            text:               'Set this receptionist to ' + newStatus + '?',
            icon:               'question',
            showCancelButton:   true,
            confirmButtonColor: newStatus === 'Active' ? '#198754' : '#dc3545',
            cancelButtonColor:  '#6c757d',
            confirmButtonText:  'Yes, set ' + newStatus,
            cancelButtonText:   'Cancel'
        }).then(function (result) {
            if (!result.isConfirmed) return;

            $.ajax({
                url:      '/MedicalManagementSystem/components/ReceptionService.cfc'
                        + '?method=toggleStatus&returnformat=json',
                type:     'POST',
                data:     { enc_user_id: encID, new_status: newStatus },
                dataType: 'json',
                success: function (res) {
                    var ok  = res.SUCCESS === true || res.SUCCESS === 'true' || res.success === true;
                    var msg = res.MESSAGE || res.message || '';

                    if (!ok) {
                        swAlert('error', 'Failed', msg || 'Failed to update status.');
                        return;
                    }

                    $btn.data('status', newStatus)
                        .text(newStatus)
                        .removeClass('btn-success btn-danger')
                        .addClass(newStatus === 'Active' ? 'btn-success' : 'btn-danger');

                    var $row        = $btn.closest('tr');
                    var $actionCell = $row.find('td').last();
                    var $editBtn    = $row.find('.editBtn');

                    if (newStatus === 'Inactive') {
                        $editBtn.remove();
                    } else if ($editBtn.length === 0) {
                        $actionCell.html(
                            '<button type="button" class="btn btn-primary btn-sm editBtn" '
                            + 'data-enc_user_id="' + encID + '">'
                            + '<i class="bi bi-pencil-square"></i> Edit</button>'
                        );
                    }

                    swAlert('success', 'Done!', 'Status changed to ' + newStatus + '.');
                },
                error: function () {
                    swAlert('error','Server Error','Something went wrong. Please try again.');
                }
            });
        });
    });

    if ($('#flashAlert').length) {
        setTimeout(function () {
            bootstrap.Alert.getOrCreateInstance(document.getElementById('flashAlert')).close();
        }, 3000);
    }

});
</script>
