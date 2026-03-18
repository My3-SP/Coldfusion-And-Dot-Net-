<cfinclude template="../../includes/header.cfm">
<cfinclude template="adminSidebar.cfm">

<cfinclude template="../../includes/sessionCheck.cfm">
<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 1>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>
<cfset securityService  = createObject("component","MedicalManagementSystem.components.SecurityService")>
<cfset dashboardService = createObject("component","MedicalManagementSystem.components.DashboardService")>
<cfset qStats = dashboardService.getStats()>
<cfset qUsers = dashboardService.getUsers()>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<!--- DataTables styling --->
<style>
    #usersTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #usersTable tbody tr:hover {
        background-color: #f0f0ff;
    }
    #usersTable tbody td {
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
        background: #8984f5 !important;
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
        <h3>Admin Dashboard</h3>
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

    <cfoutput>
    <div class="page-content">

        <!--- Stats Cards --->
        <div class="row g-3">
            <div class="col-md-3 col-6">
                <div class="card border-0 shadow-sm">
                    <div class="card-body text-center py-4">
                        <div class="mb-1 text-muted medium"><b>Total Users</b></div>
                        <h3 class="fw-bold text-primary mb-0">#qStats.totalUsers#</h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="card border-0 shadow-sm">
                    <div class="card-body text-center py-4">
                        <div class="mb-1 text-muted medium"><b>Total Doctors</b></div>
                        <h3 class="fw-bold text-success mb-0">#qStats.totalDoctors#</h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="card border-0 shadow-sm">
                    <div class="card-body text-center py-4">
                        <div class="mb-1 text-muted medium"><b>Total Patients</b></div>
                        <h3 class="fw-bold text-warning mb-0">#qStats.totalPatients#</h3>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="card border-0 shadow-sm">
                    <div class="card-body text-center py-4">
                        <div class="mb-1 text-muted medium"><b>Total Departments</b></div>
                        <h3 class="fw-bold text-info mb-0">#qStats.totalDepartments#</h3>
                    </div>
                </div>
            </div>
        </div>

        <!--- Users Table --->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card border-0 shadow-sm">
                    <div class="card-body fw-semibold">
                        <i class="bi bi-people me-2 text-primary"></i>Users List
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover align-middle"
                                   id="usersTable">
                                <thead>
                                    <tr>
                                        <th>SL NO</th>
                                        <th>Username</th>
                                        <th>Full Name</th>
                                        <th>Role</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfset sl = 1>
                                    <cfoutput query="qUsers">
                                    <tr>
                                        <td>#sl#</td>
                                        <td>#encodeForHTML(username)#</td>
                                        <td>#encodeForHTML(full_name)#</td>
                                        <td>#encodeForHTML(role_name)#</td>
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
            </div>
        </div>

    </div>
    </cfoutput>
</div>

<!--- Edit User Modal --->
<div class="modal fade" id="editUserModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="editUserForm" novalidate autocomplete="off">

                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-pencil-square me-2"></i>Edit User
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <cfoutput>
                    <input type="hidden" name="updatedBy"   value="#session.user.user_id#">
                    </cfoutput>
                    <input type="hidden" name="enc_user_id" id="edit_user_id">

                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            Full Name <span class="text-danger">*</span>
                        </label>
                        <input type="text" name="fullName" id="edit_full_name"
                               class="form-control" placeholder="Enter full name">
                        <div class="invalid-feedback" id="fullNameError"></div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            Email <span class="text-danger">*</span>
                        </label>
                        <input type="text" name="email" id="edit_email"
                               class="form-control" placeholder="Enter email address">
                        <div class="invalid-feedback" id="emailError"></div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Phone</label>
                        <input type="text" name="phone" id="edit_phone"
                               class="form-control" placeholder="Enter phone number">
                        <div class="invalid-feedback" id="phoneError"></div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Status</label>
                        <select name="isActive" id="edit_active" class="form-select">
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary"
                            data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary" id="updateBtn">
                        <span id="updateBtnText">Update</span>
                        <span id="updateBtnSpinner"
                              class="spinner-border spinner-border-sm ms-1 d-none"
                              role="status"></span>
                    </button>
                </div>

            </form>
        </div>
    </div>
</div>

<cfinclude template="../../includes/footer.cfm">

<script>
    if (flashMessage) {
        Swal.fire({
            toast:             true,
            icon:              "success",
            title:             flashMessage,
            position:          "top-end",
            showConfirmButton: false,
            timer:             4000,
            timerProgressBar:  true
        });
    }
</script>

<script>
$(document).ready(function () {

    // Build userDataMap from table rows
    var userDataMap = {};
    $('#usersTable tbody tr').each(function () {
        var $btn = $(this).find('.editBtn');
        if (!$btn.length) return;
        var userId = $btn.data('enc_user_id').toString();
        userDataMap[userId] = {
            name:   $btn.data('full_name'),
            email:  $btn.data('email'),
            phone:  $btn.data('phone'),
            active: '1'
        };
    });

    // ── DataTable ─
    var dt = $('#usersTable').DataTable({
        pageLength: 5,
        columnDefs: [{ orderable: false, targets: [6, 7] }],
        language: {
            search:         '<i class="bi bi-search me-1"></i>Search:',
            lengthMenu:     'Show _MENU_ entries',
            info:           'Showing _START_ to _END_ of _TOTAL_ users',
            paginate: {
                previous: '&lsaquo;',
                next:     '&rsaquo;'
            }
        }
    });

    // ── SweetAlert2 helpers ───────────────────────────────
    function swAlert(icon, title, text) {
        Swal.fire({
            icon:              icon,
            title:             title,
            text:              text,
            confirmButtonColor: '#4f46e5',
            timer:             icon === 'success' ? 2500 : undefined,
            timerProgressBar:  icon === 'success'
        });
    }

    // ── Modal helpers ─────────────────────────────────────
    var modalEl       = document.getElementById('editUserModal');
    var modalInstance = new bootstrap.Modal(modalEl);

    function clearErrors() {
        $('#editUserForm .form-control, #editUserForm .form-select')
            .removeClass('is-invalid');
        $('#fullNameError, #emailError, #phoneError').text('');
    }

    function fieldError(inputId, errorId, msg) {
        $('#' + inputId).addClass('is-invalid');
        $('#' + errorId).text(msg);
    }

    function resetBtn() {
        $('#updateBtnText').text('Update');
        $('#updateBtnSpinner').addClass('d-none');
        $('#updateBtn').prop('disabled', false);
    }

    function validName(v)  { return /^[A-Za-z\s]{3,}$/.test(v.trim()); }
    function validEmail(v) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v.trim()); }
    function validPhone(v) { return v.trim() === '' || /^[0-9]{10,15}$/.test(v.trim()); }

    // ── Open Edit Modal ───────────────────────────────────
    $('#usersTable tbody').on('click', '.editBtn', function () {
        var userId = $(this).data('enc_user_id').toString();
        var u = userDataMap[userId];
        if (!u) {
            swAlert('error', 'Not Found', 'User data not found — please refresh the page.');
            return;
        }
        clearErrors();
        $('#edit_user_id').val(userId);
        $('#edit_full_name').val(u.name);
        $('#edit_email').val(u.email);
        $('#edit_phone').val(u.phone);
        $('#edit_active').val(u.active);
        modalInstance.show();
    });

    $(modalEl).on('hidden.bs.modal', function () {
        clearErrors();
        resetBtn();
    });

    // ── Submit Edit Form ──────────────────────────────────
    $('#editUserForm').on('submit', function (e) {
        e.preventDefault();
        clearErrors();

        var fullName = $('#edit_full_name').val();
        var email    = $('#edit_email').val();
        var phone    = $('#edit_phone').val();
        var hasError = false;

        if (!validName(fullName)) {
            fieldError('edit_full_name','fullNameError',
                'Full Name must be at least 3 letters (alphabets and spaces only).');
            hasError = true;
        }
        if (!validEmail(email)) {
            fieldError('edit_email','emailError',
                'Please enter a valid email address.');
            hasError = true;
        }
        if (!validPhone(phone)) {
            fieldError('edit_phone','phoneError',
                'Phone must be 10–15 digits (numbers only).');
            hasError = true;
        }
        if (hasError) return;

        $('#updateBtnText').text('Updating...');
        $('#updateBtnSpinner').removeClass('d-none');
        $('#updateBtn').prop('disabled', true);

        $.ajax({
            url:      '/MedicalManagementSystem/components/DashboardService.cfc'
                    + '?method=updateUser&returnformat=json',
            type:     'POST',
            data:     $(this).serialize(),
            dataType: 'json',
            success: function (res) {
                resetBtn();

                var isSuccess = res.SUCCESS === true || res.success === true
                             || res.SUCCESS === 'true' || res.success === 'true';
                var msg       = res.MESSAGE || res.message || 'Operation completed.';

                if (isSuccess) {
                    var userId   = $('#edit_user_id').val();
                    var isActive = $('#edit_active').val();
                    var badge    = isActive === '1'
                        ? '<span class="badge bg-success">Active</span>'
                        : '<span class="badge bg-secondary">Inactive</span>';

                    if (userDataMap[userId]) {
                        userDataMap[userId].name   = fullName.trim();
                        userDataMap[userId].email  = email.trim();
                        userDataMap[userId].phone  = phone.trim();
                        userDataMap[userId].active = isActive;
                    }

                    var $editBtn = $('#usersTable')
                        .find('button.editBtn[data-enc_user_id="' + userId + '"]');
                    if ($editBtn.length) {
                        var dtRow   = dt.row($editBtn.closest('tr'));
                        var rowData = dtRow.data();
                        rowData[2]  = fullName.trim();
                        rowData[4]  = email.trim();
                        rowData[5]  = phone.trim();
                        rowData[6]  = badge;
                        dtRow.data(rowData).invalidate().draw(false);
                    }

                    modalInstance.hide();
                    swAlert('success', 'Updated!', msg);

                } else {
                    swAlert('error', 'Failed', msg);
                }
            },
            error: function (xhr) {
                resetBtn();
                console.error('AJAX raw response:', xhr.responseText);
                swAlert('error', 'Server Error',
                    'Something went wrong — check the console for details.');
            }
        });
    });

    // ── Toggle Status ─────────────────────────────────────
    $('#usersTable').on('click', '.statusBtn', function () {
        var $btn          = $(this);
        var encID         = $btn.data('userid');
        var currentStatus = $btn.data('status');
        var newStatus     = currentStatus === 'Active' ? 'Inactive' : 'Active';

        Swal.fire({
            title:              'Change Status?',
            text:               'Set this user to ' + newStatus + '?',
            icon:               'question',
            showCancelButton:   true,
            confirmButtonColor: newStatus === 'Active' ? '#198754' : '#dc3545',
            cancelButtonColor:  '#6c757d',
            confirmButtonText:  'Yes, set ' + newStatus,
            cancelButtonText:   'Cancel'
        }).then(function (result) {
            if (!result.isConfirmed) return;

            $.ajax({
                url:      '/MedicalManagementSystem/components/DashboardService.cfc'
                        + '?method=toggleStatus&returnformat=json',
                type:     'POST',
                data:     { enc_user_id: encID, new_status: newStatus },
                dataType: 'json',
                success: function (res) {
                    var ok  = res.SUCCESS === true || res.SUCCESS === 'true';
                    var msg = res.MESSAGE || res.message || '';

                    if (!ok) {
                        swAlert('error', 'Failed', msg || 'Failed to update status.');
                        return;
                    }

                    $btn.data('status', newStatus).text(newStatus);
                    if (newStatus === 'Active') {
                        $btn.removeClass('btn-danger').addClass('btn-success');
                    } else {
                        $btn.removeClass('btn-success').addClass('btn-danger');
                    }

                    var $row        = $btn.closest('tr');
                    var $actionCell = $row.find('td').last();
                    var $editBtn    = $row.find('.editBtn');

                    if (newStatus === 'Inactive') {
                        $editBtn.remove();
                    } else if ($editBtn.length === 0) {
                        var fullName = $row.find('td').eq(2).text().trim();
                        var username = $row.find('td').eq(1).text().trim();
                        var email    = $row.find('td').eq(4).text().trim();
                        var phone    = $row.find('td').eq(5).text().trim();

                        $actionCell.html(
                            '<button class="btn btn-primary btn-sm editBtn" '
                            + 'data-enc_user_id="' + encID + '" '
                            + 'data-full_name="'   + fullName + '" '
                            + 'data-username="'    + username + '" '
                            + 'data-email="'       + email    + '" '
                            + 'data-phone="'       + phone    + '">'
                            + '<i class="bi bi-pencil-square"></i> Edit</button>'
                        );
                    }

                    swAlert('success', 'Done!', 'Status changed to ' + newStatus + '.');
                },
                error: function () {
                    swAlert('error', 'Server Error', 'Something went wrong. Please try again.');
                }
            });
        });
    });

});
</script>

<script>
    const toggleBtn = document.getElementById('sidebarToggle');
    const sidebar   = document.querySelector('.sidebar-wrapper');
    toggleBtn.addEventListener('click', () => {
        sidebar.classList.toggle('hide-sidebar');
    });
</script>