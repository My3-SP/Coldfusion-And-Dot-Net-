<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="adminSidebar.cfm">


<cfif NOT structKeyExists(session,"user") OR session.user.role_id NEQ 1>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset doctorService   = createObject("component","MedicalManagementSystem.components.DoctorService")>
<cfset securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
<cfset doctors         = doctorService.getAllDoctors()>
<cfset departments     = doctorService.getDepartments()>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    #doctorTable thead th {
         background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #doctorTable tbody tr:hover {
        background-color: #f0f0ff;
    }
    #doctorTable tbody td {
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
        <h3>Admin - Manage Doctors</h3>
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
            <i class="bi bi-person-plus-fill me-1"></i> Add Doctor
        </button>
    </div>

    <!--- Doctors Table --->
    <div class="card border-0 shadow-sm">
        <div class="card-body fw-semibold">
            <i class="bi bi-person-badge me-2 text-primary"></i>Doctors List
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table id="doctorTable" class="table table-bordered table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Sl No</th>
                            <th>Name</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Department</th>
                            <th>Experience</th>
                            <th>Fee</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfset sl = 1>
                        <cfoutput query="doctors">
                        <tr>
                            <td>#sl#</td>
                            <td>#encodeForHTML(full_name)#</td>
                            <td>#encodeForHTML(username)#</td>
                            <td>#encodeForHTML(email)#</td>
                            <td>#encodeForHTML(dept_name)#</td>
                            <td>#experience_years# yrs</td>
                            <td>#consultation_fee#</td>
                            <td>
                                <button class="btn btn-sm statusBtn
                                    <cfif is_active EQ 1>btn-success<cfelse>btn-danger</cfif>"
                                    data-doctor_id="#securityService.encryptID(doctor_id)#"
                                    data-user_id="#securityService.encryptID(user_id)#"
                                    data-status="<cfif is_active EQ 1>Active<cfelse>Inactive</cfif>">
                                    <cfif is_active EQ 1>Active<cfelse>Inactive</cfif>
                                </button>
                            </td>
                            <td>
                                <cfif is_active EQ 1>
                                    <button type="button" class="btn btn-primary btn-sm editBtn"
                                        data-docid="#doctor_id#"
                                        data-enc_doctor_id="#encodeForHTMLAttribute(securityService.encryptID(doctor_id))#"
                                        data-enc_user_id="#encodeForHTMLAttribute(securityService.encryptID(user_id))#"
                                        data-full_name="#encodeForHTMLAttribute(full_name)#"
                                        data-username="#encodeForHTMLAttribute(username)#"
                                        data-email="#encodeForHTMLAttribute(email)#"
                                        data-phone="#encodeForHTMLAttribute(phone)#"
                                        data-dept_id="#dept_id#"
                                        data-specialization="#encodeForHTMLAttribute(specialization)#"
                                        data-qualification="#encodeForHTMLAttribute(qualification)#"
                                        data-experience="#experience_years#"
                                        data-fee="#consultation_fee#">
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

<!---  ADD DOCTOR MODAL  --->
<div class="modal fade" id="addDoctorModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form id="addDoctorForm" novalidate autocomplete="off">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-plus-circle me-2"></i>Add Doctor
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Full Name <span class="text-danger">*</span></label>
                            <input type="text" name="full_name" id="add_full_name"
                                   class="form-control" placeholder="Enter full name">
                            <div class="invalid-feedback" id="add_full_name_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Username <span class="text-danger">*</span></label>
                            <input type="text" name="username" id="add_username"
                                   class="form-control" placeholder="Min 4 chars, letters/numbers/underscore">
                            <div class="invalid-feedback" id="add_username_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Email <span class="text-danger">*</span></label>
                            <input type="text" name="email" id="add_email"
                                   class="form-control" placeholder="Enter email">
                            <div class="invalid-feedback" id="add_email_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Phone <span class="text-danger">*</span></label>
                            <input type="text" name="phone" id="add_phone"
                                   class="form-control" placeholder="Exactly 10 digits">
                            <div class="invalid-feedback" id="add_phone_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Department <span class="text-danger">*</span></label>
                            <select name="dept_id" id="add_dept_id" class="form-select">
                                <option value="">Select Department</option>
                                <cfoutput query="departments">
                                <option value="#dept_id#">#encodeForHTML(dept_name)#</option>
                                </cfoutput>
                            </select>
                            <div class="invalid-feedback" id="add_dept_id_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Specialization <span class="text-danger">*</span></label>
                            <input type="text" name="specialization" id="add_specialization"
                                   class="form-control" placeholder="Min 3 characters">
                            <div class="invalid-feedback" id="add_specialization_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Qualification <span class="text-danger">*</span></label>
                            <input type="text" name="qualification" id="add_qualification"
                                   class="form-control" placeholder="e.g. MBBS, MD">
                            <div class="invalid-feedback" id="add_qualification_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Experience Years</label>
                            <input type="text" name="experience_years" id="add_experience"
                                   class="form-control" placeholder="e.g. 5">
                            <div class="invalid-feedback" id="add_experience_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Consultation Fee</label>
                            <input type="text" name="consultation_fee" id="add_fee"
                                   class="form-control" placeholder="e.g. 500">
                            <div class="invalid-feedback" id="add_fee_err"></div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary"
                            data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-success" id="addDoctorBtn">
                        <span id="addDoctorBtnText">Add Doctor</span>
                        <span id="addDoctorSpinner"
                              class="spinner-border spinner-border-sm ms-1 d-none"
                              role="status"></span>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!---  EDIT DOCTOR MODAL  --->
<div class="modal fade" id="editDoctorModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form id="editDoctorForm" novalidate autocomplete="off">
                <input type="hidden" name="enc_doctor_id" id="edit_enc_doctor_id">
                <input type="hidden" name="enc_user_id"   id="edit_enc_user_id">
                <input type="hidden" name="doc_id_ref"    id="edit_doc_id_ref">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-pencil-square me-2"></i>Edit Doctor
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Full Name <span class="text-danger">*</span></label>
                            <input type="text" name="full_name" id="edit_full_name" class="form-control">
                            <div class="invalid-feedback" id="edit_full_name_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Username <span class="text-danger">*</span></label>
                            <input type="text" name="username" id="edit_username" class="form-control">
                            <div class="invalid-feedback" id="edit_username_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Email <span class="text-danger">*</span></label>
                            <input type="text" name="email" id="edit_email" class="form-control">
                            <div class="invalid-feedback" id="edit_email_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Phone <span class="text-danger">*</span></label>
                            <input type="text" name="phone" id="edit_phone" class="form-control">
                            <div class="invalid-feedback" id="edit_phone_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Department <span class="text-danger">*</span></label>
                            <select name="dept_id" id="edit_dept_id" class="form-select">
                                <option value="">Select Department</option>
                                <cfoutput query="departments">
                                <option value="#dept_id#">#encodeForHTML(dept_name)#</option>
                                </cfoutput>
                            </select>
                            <div class="invalid-feedback" id="edit_dept_id_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Specialization <span class="text-danger">*</span></label>
                            <input type="text" name="specialization" id="edit_specialization" class="form-control">
                            <div class="invalid-feedback" id="edit_specialization_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Qualification <span class="text-danger">*</span></label>
                            <input type="text" name="qualification" id="edit_qualification" class="form-control">
                            <div class="invalid-feedback" id="edit_qualification_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Experience Years</label>
                            <input type="text" name="experience_years" id="edit_experience" class="form-control">
                            <div class="invalid-feedback" id="edit_experience_err"></div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold">Consultation Fee</label>
                            <input type="text" name="consultation_fee" id="edit_fee" class="form-control">
                            <div class="invalid-feedback" id="edit_fee_err"></div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary"
                            data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary" id="editDoctorBtn">
                        <span id="editDoctorBtnText">Update Doctor</span>
                        <span id="editDoctorSpinner"
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
$(document).ready(function () {

    //  Doctor data map 
    var doctorMap = {};
    $('#doctorTable tbody tr').each(function () {
        var $btn = $(this).find('.editBtn');
        if (!$btn.length) return;
        var did = $btn.data('docid').toString();
        doctorMap[did] = {
            enc_doctor_id  : $btn.data('enc_doctor_id'),
            enc_user_id    : $btn.data('enc_user_id'),
            full_name      : $btn.data('full_name'),
            username       : $btn.data('username'),
            email          : $btn.data('email'),
            phone          : $btn.data('phone'),
            dept_id        : $btn.data('dept_id').toString(),
            specialization : $btn.data('specialization'),
            qualification  : $btn.data('qualification'),
            experience     : $btn.data('experience'),
            fee            : $btn.data('fee')
        };
    });

    //  DataTable 
    var dt = $('#doctorTable').DataTable({
        pageLength: 5,
        columnDefs: [{ orderable: false, targets: [7, 8] }],
        language: {
            search:       '<i class="bi bi-search me-1"></i>Search:',
            lengthMenu:   'Show _MENU_ entries',
            info:         'Showing _START_ to _END_ of _TOTAL_ doctors',
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
    var addModalEl  = document.getElementById('addDoctorModal');
    var editModalEl = document.getElementById('editDoctorModal');
    var addModal    = new bootstrap.Modal(addModalEl);
    var editModal   = new bootstrap.Modal(editModalEl);

    //  Validation rules 
    var R = {
        req      : function (v) { return $.trim(v).length > 0; },
        minLen   : function (v, n) { return $.trim(v).length >= n; },
        alpha    : function (v) { return /^[A-Za-z\s]+$/.test($.trim(v)); },
        alphaNum : function (v) { return /^[A-Za-z0-9_]+$/.test($.trim(v)); },
        email    : function (v) { return /^(?!.*\.\.)([A-Za-z0-9]+)@[A-Za-z0-9-]+\.[A-Za-z]{2,}$/.test($.trim(v)); },
        phone     : function (v) { return /^(?!0+$)[6-9]\d{9}$/.test($.trim(v));},
        posNum   : function (v) { return $.trim(v) === '' || ($.isNumeric($.trim(v)) && parseFloat($.trim(v)) >= 0); }
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

    //  Add validation 
    function validateAdd() {
        var ok = true;

        var name = $('#add_full_name').val();
        if (!R.req(name))           { setErr('add_full_name','add_full_name_err','Full Name is required.'); ok=false; }
        else if (!R.minLen(name,3)) { setErr('add_full_name','add_full_name_err','Full Name must be at least 3 characters.'); ok=false; }
        else if (!R.alpha(name))    { setErr('add_full_name','add_full_name_err','Full Name must contain letters only.'); ok=false; }
        else setOk('add_full_name');

        var uname = $('#add_username').val();
        if (!R.req(uname))           { setErr('add_username','add_username_err','Username is required.'); ok=false; }
        else if (!R.minLen(uname,4)) { setErr('add_username','add_username_err','Username must be at least 4 characters.'); ok=false; }
        else if (!R.alphaNum(uname)) { setErr('add_username','add_username_err','Username: letters, numbers, underscore only.'); ok=false; }
        else setOk('add_username');

        var email = $('#add_email').val();
        if (!R.req(email))      { setErr('add_email','add_email_err','Email is required.'); ok=false; }
        else if (!R.email(email)) { setErr('add_email','add_email_err','Enter a valid email address.'); ok=false; }
        else setOk('add_email');

        var phone = $('#add_phone').val();
        if (!R.req(phone))        { setErr('add_phone','add_phone_err','Phone is required.'); ok=false; }
        else if (!R.phone(phone)) { setErr('add_phone','add_phone_err','Phone must be exactly 10 digits.'); ok=false; }
        else setOk('add_phone');

        var dept = $('#add_dept_id').val();
        if (!dept) { setErr('add_dept_id','add_dept_id_err','Please select a department.'); ok=false; }
        else setOk('add_dept_id');

        var spec = $('#add_specialization').val();
        if (!R.req(spec))           { setErr('add_specialization','add_specialization_err','Specialization is required.'); ok=false; }
        else if (!R.minLen(spec,3)) { setErr('add_specialization','add_specialization_err','Specialization must be at least 3 characters.'); ok=false; }
        else setOk('add_specialization');

        var qual = $('#add_qualification').val();
        if (!R.req(qual)) { setErr('add_qualification','add_qualification_err','Qualification is required.'); ok=false; }
        else setOk('add_qualification');

        var exp = $('#add_experience').val();
        if (R.req(exp) && !R.posNum(exp)) { setErr('add_experience','add_experience_err','Experience must be a positive number.'); ok=false; }
        else if (R.req(exp)) setOk('add_experience');

        var fee = $('#add_fee').val();
        if (R.req(fee) && !R.posNum(fee)) { setErr('add_fee','add_fee_err','Consultation fee must be a positive number.'); ok=false; }
        else if (R.req(fee)) setOk('add_fee');

        return ok;
    }

    //  Edit validation 
    function validateEdit() {
        var ok = true;

        var name = $('#edit_full_name').val();
        if (!R.req(name))           { setErr('edit_full_name','edit_full_name_err','Full Name is required.'); ok=false; }
        else if (!R.minLen(name,3)) { setErr('edit_full_name','edit_full_name_err','Full Name must be at least 3 characters.'); ok=false; }
        else if (!R.alpha(name))    { setErr('edit_full_name','edit_full_name_err','Full Name must contain letters only.'); ok=false; }
        else setOk('edit_full_name');

        var uname = $('#edit_username').val();
        if (!R.req(uname))           { setErr('edit_username','edit_username_err','Username is required.'); ok=false; }
        else if (!R.minLen(uname,4)) { setErr('edit_username','edit_username_err','Username must be at least 4 characters.'); ok=false; }
        else if (!R.alphaNum(uname)) { setErr('edit_username','edit_username_err','Username: letters, numbers, underscore only.'); ok=false; }
        else setOk('edit_username');

        var email = $('#edit_email').val();
        if (!R.req(email))        { setErr('edit_email','edit_email_err','Email is required.'); ok=false; }
        else if (!R.email(email)) { setErr('edit_email','edit_email_err','Enter a valid email address.'); ok=false; }
        else setOk('edit_email');

        var phone = $('#edit_phone').val();
        if (!R.req(phone))          { setErr('edit_phone','edit_phone_err','Phone is required.'); ok=false; }
        else if (!R.phone(phone)) { setErr('edit_phone','edit_phone_err','Phone must be exactly 10 digits.'); ok=false; }
        else setOk('edit_phone');

        var dept = $('#edit_dept_id').val();
        if (!dept) { setErr('edit_dept_id','edit_dept_id_err','Please select a department.'); ok=false; }
        else setOk('edit_dept_id');

        var spec = $('#edit_specialization').val();
        if (!R.req(spec))           { setErr('edit_specialization','edit_specialization_err','Specialization is required.'); ok=false; }
        else if (!R.minLen(spec,3)) { setErr('edit_specialization','edit_specialization_err','Specialization must be at least 3 characters.'); ok=false; }
        else setOk('edit_specialization');

        var qual = $('#edit_qualification').val();
        if (!R.req(qual)) { setErr('edit_qualification','edit_qualification_err','Qualification is required.'); ok=false; }
        else setOk('edit_qualification');

        var exp = $('#edit_experience').val();
        if (R.req(exp) && !R.posNum(exp)) { setErr('edit_experience','edit_experience_err','Experience must be a positive number.'); ok=false; }
        else if (R.req(exp)) setOk('edit_experience');

        var fee = $('#edit_fee').val();
        if (R.req(fee) && !R.posNum(fee)) { setErr('edit_fee','edit_fee_err','Consultation fee must be a positive number.'); ok=false; }
        else if (R.req(fee)) setOk('edit_fee');

        return ok;
    }

    //  Open Add Modal 
    $('#openAddModal').on('click', function () {
        $('#addDoctorForm')[0].reset();
        clearForm('addDoctorForm');
        addModal.show();
    });

    $(addModalEl).on('hidden.bs.modal', function () {
        $('#addDoctorForm')[0].reset();
        clearForm('addDoctorForm');
        resetBtn('addDoctorBtn','addDoctorSpinner','addDoctorBtnText','Add Doctor');
    });

    //  Open Edit Modal 
    $('#doctorTable tbody').on('click', '.editBtn', function () {
        var did = $(this).data('docid').toString();
        var d   = doctorMap[did];
        if (!d) {
            swAlert('error','Not Found','Could not load doctor data — please refresh.');
            return;
        }
        clearForm('editDoctorForm');
        $('#edit_enc_doctor_id').val(d.enc_doctor_id);
        $('#edit_enc_user_id').val(d.enc_user_id);
        $('#edit_doc_id_ref').val(did);
        $('#edit_full_name').val(d.full_name);
        $('#edit_username').val(d.username);
        $('#edit_email').val(d.email);
        $('#edit_phone').val(d.phone);
        $('#edit_dept_id').val(d.dept_id);
        $('#edit_specialization').val(d.specialization);
        $('#edit_qualification').val(d.qualification);
        $('#edit_experience').val(d.experience);
        $('#edit_fee').val(d.fee);
        editModal.show();
    });

    $(editModalEl).on('hidden.bs.modal', function () {
        clearForm('editDoctorForm');
        resetBtn('editDoctorBtn','editDoctorSpinner','editDoctorBtnText','Update Doctor');
    });

    //  Add Doctor Submit 
    $('#addDoctorForm').on('submit', function (e) {
        e.preventDefault();
        clearForm('addDoctorForm');
        if (!validateAdd()) return;

        $('#addDoctorBtnText').text('Adding...');
        $('#addDoctorSpinner').removeClass('d-none');
        $('#addDoctorBtn').prop('disabled', true);

        $.ajax({
            url:      '/MedicalManagementSystem/components/DoctorService.cfc'
                    + '?method=addDoctorAjax&returnformat=json',
            type:     'POST',
            data:     $(this).serialize()
                    + '&created_by=<cfoutput>#session.user.user_id#</cfoutput>',
            dataType: 'json',
            success: function (res) {
                resetBtn('addDoctorBtn','addDoctorSpinner','addDoctorBtnText','Add Doctor');

                var ok  = res.SUCCESS === true || res.SUCCESS === 'true' || res.success === true;
                var msg = res.MESSAGE || res.message || '';

                if (!ok) {
                    swAlert('error', 'Failed', msg);
                    return;
                }

                var newDid    = (res.DOCTOR_ID || 0).toString();
                var newName   = res.FULL_NAME;
                var newUser   = res.USERNAME;
                var newEmail  = res.EMAIL;
                var newDept   = res.DEPT_NAME;
                var newDeptId = res.DEPT_ID;
                var newExp    = res.EXPERIENCE;
                var newFee    = res.FEE;
                var encD      = res.ENC_DOCTOR_ID;
                var encU      = res.ENC_USER_ID;
                var newStatus = res.STATUS || 'Active';
                var statusClass = (newStatus === 'Active') ? 'btn-success' : 'btn-danger';

                var statusBtn =
                    '<button class="btn btn-sm statusBtn ' + statusClass + '" '
                    + 'data-doctor_id="' + encD + '" '
                    + 'data-user_id="'   + encU + '" '
                    + 'data-status="'    + newStatus + '">'
                    + newStatus + '</button>';

                var actionHtml = '';
                if (newStatus === 'Active') {
                    actionHtml =
                        '<button type="button" class="btn btn-primary btn-sm editBtn" '
                        + 'data-docid="'         + newDid  + '" '
                        + 'data-enc_doctor_id="' + encD    + '" '
                        + 'data-enc_user_id="'   + encU    + '" '
                        + 'data-full_name="'     + newName + '" '
                        + 'data-username="'      + newUser + '" '
                        + 'data-email="'         + newEmail + '" '
                        + 'data-phone="'         + $('#add_phone').val().trim()          + '" '
                        + 'data-dept_id="'       + newDeptId                             + '" '
                        + 'data-specialization="'+ $('#add_specialization').val().trim() + '" '
                        + 'data-qualification="' + $('#add_qualification').val().trim()  + '" '
                        + 'data-experience="'    + newExp + '" '
                        + 'data-fee="'           + newFee + '">'
                        + '<i class="bi bi-pencil-square"></i> Edit</button>';
                }

                
                doctorMap[newDid] = {
                    enc_doctor_id  : encD,
                    enc_user_id    : encU,
                    full_name      : newName,
                    username       : newUser,
                    email          : newEmail,
                    phone          : $('#add_phone').val().trim(),
                    dept_id        : newDeptId.toString(),
                    specialization : $('#add_specialization').val().trim(),
                    qualification  : $('#add_qualification').val().trim(),
                    experience     : newExp,
                    fee            : newFee
                };

                var existingRow = null;
                dt.rows().every(function () {
                    if (this.data()[2] === newUser) { existingRow = this; }
                });

                if (existingRow) {
                    existingRow.data([
                        existingRow.index() + 1,
                        newName, newUser, newEmail, newDept,
                        newExp + ' yrs', newFee,
                        statusBtn, actionHtml
                    ]).draw(false);
                } else {
                    dt.row.add([
                        dt.rows().count() + 1,
                        newName, newUser, newEmail, newDept,
                        newExp + ' yrs', newFee,
                        statusBtn, actionHtml
                    ]).draw(false);
                }

                addModal.hide();
                swAlert('success', 'Added!', msg);
            },
            error: function (xhr) {
                resetBtn('addDoctorBtn','addDoctorSpinner','addDoctorBtnText','Add Doctor');
                console.error('Add error:', xhr.responseText);
                swAlert('error','Server Error','Something went wrong — please try again.');
            }
        });
    });

    //  Edit Doctor Submit 
    $('#editDoctorForm').on('submit', function (e) {
        e.preventDefault();
        clearForm('editDoctorForm');
        if (!validateEdit()) return;

        $('#editDoctorBtnText').text('Updating...');
        $('#editDoctorSpinner').removeClass('d-none');
        $('#editDoctorBtn').prop('disabled', true);

        $.ajax({
            url:      '/MedicalManagementSystem/components/DoctorService.cfc'
                    + '?method=editDoctorAjax&returnformat=json',
            type:     'POST',
            data:     $(this).serialize(),
            dataType: 'json',
            success: function (res) {
                resetBtn('editDoctorBtn','editDoctorSpinner','editDoctorBtnText','Update Doctor');

                var ok  = res.SUCCESS === true || res.SUCCESS === 'true' || res.success === true;
                var msg = res.MESSAGE || res.message || '';

                if (!ok) {
                    swAlert('error', 'Failed', msg);
                    return;
                }

                var did      = $('#edit_doc_id_ref').val();
                var fullName = $('#edit_full_name').val().trim();
                var username = $('#edit_username').val().trim();
                var email    = $('#edit_email').val().trim();
                var deptName = res.DEPT_NAME || res.dept_name || '';
                var exp      = res.EXPERIENCE !== undefined ? res.EXPERIENCE : (res.experience || '');
                var fee      = res.FEE        !== undefined ? res.FEE        : (res.fee        || '');

                if (doctorMap[did]) {
                    doctorMap[did].full_name      = fullName;
                    doctorMap[did].username       = username;
                    doctorMap[did].email          = email;
                    doctorMap[did].phone          = $('#edit_phone').val().trim();
                    doctorMap[did].dept_id        = $('#edit_dept_id').val();
                    doctorMap[did].specialization = $('#edit_specialization').val().trim();
                    doctorMap[did].qualification  = $('#edit_qualification').val().trim();
                    doctorMap[did].experience     = exp;
                    doctorMap[did].fee            = fee;
                }

                var $editBtn = $('#doctorTable').find('.editBtn[data-docid="' + did + '"]');
                var dtRow    = dt.row($editBtn.closest('tr'));
                var rowData  = dtRow.data();
                rowData[1] = fullName;
                rowData[2] = username;
                rowData[3] = email;
                rowData[4] = deptName;
                rowData[5] = exp + ' yrs';
                rowData[6] = fee;
                dtRow.data(rowData).invalidate().draw(false);

                $('#doctorTable').find('.editBtn[data-docid="' + did + '"]')
                    .data('full_name',      fullName)
                    .data('username',       username)
                    .data('email',          email)
                    .data('phone',          $('#edit_phone').val().trim())
                    .data('dept_id',        $('#edit_dept_id').val())
                    .data('specialization', $('#edit_specialization').val().trim())
                    .data('qualification',  $('#edit_qualification').val().trim())
                    .data('experience',     exp)
                    .data('fee',            fee);

                editModal.hide();
                swAlert('success', 'Updated!', msg);
            },
            error: function (xhr) {
                resetBtn('editDoctorBtn','editDoctorSpinner','editDoctorBtnText','Update Doctor');
                console.error('Edit error:', xhr.responseText);
                swAlert('error','Server Error','Something went wrong — please try again.');
            }
        });
    });

    //  Toggle Status 
    $('#doctorTable').on('click', '.statusBtn', function () {
        var $btn          = $(this);
        var encDoctorId   = $btn.data('doctor_id');
        var encUserId     = $btn.data('user_id');
        var currentStatus = $btn.data('status');
        var newStatus     = currentStatus === 'Active' ? 'Inactive' : 'Active';

        Swal.fire({
            title:              'Change Status?',
            text:               'Set this doctor to ' + newStatus + '?',
            icon:               'question',
            showCancelButton:   true,
            confirmButtonColor: newStatus === 'Active' ? '#198754' : '#dc3545',
            cancelButtonColor:  '#6c757d',
            confirmButtonText:  'Yes, set ' + newStatus,
            cancelButtonText:   'Cancel'
        }).then(function (result) {
            if (!result.isConfirmed) return;

            $.ajax({
                url:      '/MedicalManagementSystem/components/DoctorService.cfc'
                        + '?method=toggleStatus&returnformat=json',
                type:     'POST',
                data:     {
                    enc_doctor_id: encDoctorId,
                    enc_user_id:   encUserId,
                    new_status:    newStatus
                },
                dataType: 'json',
                success: function (res) {
                    var ok  = res.SUCCESS === true || res.success === true || res.SUCCESS === 'true';
                    var msg = res.MESSAGE || res.message || '';

                    if (!ok) {
                        swAlert('error', 'Failed', msg || 'Failed to update doctor status.');
                        return;
                    }

                    var row     = dt.row($btn.closest('tr'));
                    var rowData = row.data();

                    if (newStatus === 'Active') {
                        rowData[7] =
                            '<button class="btn btn-sm statusBtn btn-success" '
                            + 'data-doctor_id="' + encDoctorId + '" '
                            + 'data-user_id="'   + encUserId   + '" '
                            + 'data-status="Active">Active</button>';

                        // Get the real docId from the encrypted ID stored in doctorMap
                        var docId = '';
                        $.each(doctorMap, function(id, d) {
                            if (d.enc_doctor_id === encDoctorId) { docId = id; }
                        });

                        var d = doctorMap[docId] || {};
                        rowData[8] =
                            '<button type="button" class="btn btn-primary btn-sm editBtn" '
                            + 'data-docid="'         + docId                        + '" '
                            + 'data-enc_doctor_id="' + (d.enc_doctor_id || '')      + '" '
                            + 'data-enc_user_id="'   + (d.enc_user_id   || '')      + '" '
                            + 'data-full_name="'     + (d.full_name      || '')      + '" '
                            + 'data-username="'      + (d.username       || '')      + '" '
                            + 'data-email="'         + (d.email          || '')      + '" '
                            + 'data-phone="'         + (d.phone          || '')      + '" '
                            + 'data-dept_id="'       + (d.dept_id        || '')      + '" '
                            + 'data-specialization="'+ (d.specialization || '')      + '" '
                            + 'data-qualification="' + (d.qualification  || '')      + '" '
                            + 'data-experience="'    + (d.experience     || '')      + '" '
                            + 'data-fee="'           + (d.fee            || '')      + '">'
                            + '<i class="bi bi-pencil-square"></i> Edit</button>';

                    } else {
                        rowData[7] =
                            '<button class="btn btn-sm statusBtn btn-danger" '
                            + 'data-doctor_id="' + encDoctorId + '" '
                            + 'data-user_id="'   + encUserId   + '" '
                            + 'data-status="Inactive">Inactive</button>';
                        rowData[8] = '';
                    }

                    row.data(rowData).draw(false);
                    swAlert('success', 'Done!', 'Doctor status changed to ' + newStatus + '.');
                },
                error: function (xhr) {
                    console.error(xhr.responseText);
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

<script>
    const toggleBtn = document.getElementById('sidebarToggle');
    const sidebar   = document.querySelector('.sidebar-wrapper');
    toggleBtn.addEventListener('click', () => {
        sidebar.classList.toggle('hide-sidebar');
    });
</script>