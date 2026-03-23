<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="receptionistSidebar.cfm">


<cfif NOT structKeyExists(session,"user") OR session.user.role_id NEQ 3>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset patientService  = createObject("component","MedicalManagementSystem.components.RegisterPatientService")>
<cfset securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
<cfset qPatients       = patientService.getAllPatients()>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    #patientsTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #patientsTable tbody tr:hover {
        background-color: #c7d4ff4f;
    }
    #patientsTable tbody td {
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
    .dataTables_wrapper .dataTables_paginate .paginate_button {
        padding: 3px 10px !important;
        margin: 0 !important;
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

    <div class="page-heading d-flex justify-content-between align-items-center mb-3">
        <h3>Register Patients</h3>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item">
                    <a href="/MedicalManagementSystem/pages/receptionist/receptionist_Account.cfm">
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

    <div class="mb-3">
        <button class="btn btn-success" id="openAddModal">
            <i class="bi bi-person-plus-fill me-1"></i> Register Patient
        </button>
    </div>

    <!--- Patients Table --->
    <div class="card border-0 shadow-sm">
        <div class="card-body fw-semibold">
            <i class="bi bi-people me-2 text-primary"></i>Patients List
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table id="patientsTable" class="table table-bordered table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Sl No</th>
                            <th>Full Name</th>
                            <th>Username</th>
                            <th>Phone</th>
                            <th>Gender</th>
                            <th>DOB</th>
                            <th>Blood Group</th>
                            <th>City</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfset sl = 1>
                        <cfoutput query="qPatients">
                            <cfset encPID = securityService.encryptID(patient_id)>
                            <cfset encUID = securityService.encryptID(user_id)>
                            <tr>
                                <td>#sl#</td>
                                <td>#encodeForHTML(full_name)#</td>
                                <td>#encodeForHTML(username)#</td>
                                <td>#encodeForHTML(phone)#</td>
                                <td>#encodeForHTML(gender)#</td>
                                <td>#dateFormat(date_of_birth,"dd-mmm-yyyy")#</td>
                                <td>#encodeForHTML(blood_group)#</td>
                                <td>#encodeForHTML(city)#</td>
                                <td>
                                    <button class="btn btn-sm statusBtn
                                        <cfif is_active EQ 1>btn-success<cfelse>btn-danger</cfif>"
                                        data-patient_id="#encPID#"
                                        data-user_id="#encUID#"
                                        data-status="<cfif is_active EQ 1>Active<cfelse>Inactive</cfif>">
                                        <cfif is_active EQ 1>Active<cfelse>Inactive</cfif>
                                    </button>
                                </td>
                                <td>
                                    <cfif is_active EQ 1>
                                        <button type="button" class="btn btn-primary btn-sm editBtn"
                                            data-patient_id="#patient_id#"
                                            data-enc_patient_id="#encodeForHTMLAttribute(encPID)#"
                                            data-enc_user_id="#encodeForHTMLAttribute(encUID)#"
                                            data-full_name="#encodeForHTMLAttribute(full_name)#"
                                            data-email="#encodeForHTMLAttribute(email)#"
                                            data-phone="#encodeForHTMLAttribute(phone)#"
                                            data-gender="#encodeForHTMLAttribute(gender)#"
                                            data-dob="#dateFormat(date_of_birth,'yyyy-mm-dd')#"
                                            data-blood_group="#encodeForHTMLAttribute(blood_group)#"
                                            data-address1="#encodeForHTMLAttribute(address_line1)#"
                                            data-address2="#encodeForHTMLAttribute(address_line2)#"
                                            data-city="#encodeForHTMLAttribute(city)#"
                                            data-state="#encodeForHTMLAttribute(state)#"
                                            data-postal_code="#encodeForHTMLAttribute(postal_code)#"
                                            data-country="#encodeForHTMLAttribute(country)#"
                                            data-emergency_name="#encodeForHTMLAttribute(emergency_contact_name)#"
                                            data-emergency_phone="#encodeForHTMLAttribute(emergency_contact_phone)#">
                                            <i class="bi bi-pencil-square"></i> Edit
                                        </button>
                                    </cfif>
                                    <button type="button" class="btn btn-light btn-sm viewBtn"
                                        data-full_name="#encodeForHTMLAttribute(full_name)#"
                                        data-username="#encodeForHTMLAttribute(username)#"
                                        data-email="#encodeForHTMLAttribute(email)#"
                                        data-phone="#encodeForHTMLAttribute(phone)#"
                                        data-gender="#encodeForHTMLAttribute(gender)#"
                                        data-dob="#dateFormat(date_of_birth,'dd-mmm-yyyy')#"
                                        data-blood_group="#encodeForHTMLAttribute(blood_group)#"
                                        data-address1="#encodeForHTMLAttribute(address_line1)#"
                                        data-address2="#encodeForHTMLAttribute(address_line2)#"
                                        data-city="#encodeForHTMLAttribute(city)#"
                                        data-state="#encodeForHTMLAttribute(state)#"
                                        data-postal_code="#encodeForHTMLAttribute(postal_code)#"
                                        data-country="#encodeForHTMLAttribute(country)#"
                                        data-emergency_name="#encodeForHTMLAttribute(emergency_contact_name)#"
                                        data-emergency_phone="#encodeForHTMLAttribute(emergency_contact_phone)#">
                                        <i class="bi bi-eye"></i> View
                                    </button>
                                </td>
                            </tr>
                            <cfset sl = sl + 1>
                        </cfoutput>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!---  ADD PATIENT MODAL  --->
    <div class="modal fade" id="addPatientModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form id="addPatientForm" novalidate autocomplete="off">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-plus-circle me-2"></i>Register Patient
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Full Name <span class="text-danger">*</span></label>
                                <input type="text" name="full_name" id="add_full_name" class="form-control" placeholder="Enter full name">
                                <div class="invalid-feedback" id="add_full_name_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Username <span class="text-danger">*</span></label>
                                <input type="text" name="username" id="add_username" class="form-control" placeholder="Enter username">
                                <div class="invalid-feedback" id="add_username_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Email <span class="text-danger">*</span></label>
                                <input type="text" name="email" id="add_email" class="form-control" placeholder="Enter email">
                                <div class="invalid-feedback" id="add_email_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Phone <span class="text-danger">*</span></label>
                                <input type="text" name="phone" id="add_phone" class="form-control" placeholder="Enter phone">
                                <div class="invalid-feedback" id="add_phone_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Date of Birth <span class="text-danger">*</span></label>
                                <input type="date" name="dob" id="add_dob" class="form-control">
                                <div class="invalid-feedback" id="add_dob_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Gender</label>
                                <select name="gender" id="add_gender" class="form-select">
                                    <option value="">Select</option>
                                    <option value="Male">Male</option>
                                    <option value="Female">Female</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Blood Group</label>
                                <input type="text" name="blood_group" id="add_blood_group" class="form-control" placeholder="e.g. A+">
                                <div class="invalid-feedback" id="add_blood_group_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Address Line 1</label>
                                <input type="text" name="address1" id="add_address1" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Address Line 2</label>
                                <input type="text" name="address2" id="add_address2" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">City</label>
                                <input type="text" name="city" id="add_city" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">State</label>
                                <input type="text" name="state" id="add_state" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Postal Code</label>
                                <input type="text" name="postal_code" id="add_postal_code" class="form-control">
                                <div class="invalid-feedback" id="add_postal_code_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Country</label>
                                <input type="text" name="country" id="add_country" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Emergency Contact Name <span class="text-danger">*</span></label>
                                <input type="text" name="emergency_name" id="add_emergency_name" class="form-control">
                                <div class="invalid-feedback" id="add_emergency_name_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Emergency Contact Phone <span class="text-danger">*</span></label>
                                <input type="text" name="emergency_phone" id="add_emergency_phone" class="form-control">
                                <div class="invalid-feedback" id="add_emergency_phone_err"></div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-success" id="addPatientBtn">
                            <span id="addPatientBtnText">Add Patient</span>
                            <span id="addPatientSpinner" class="spinner-border spinner-border-sm ms-1 d-none" role="status"></span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!---  EDIT PATIENT MODAL  --->
    <div class="modal fade" id="editPatientModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form id="editPatientForm" novalidate autocomplete="off">
                    <input type="hidden" name="enc_patient_id" id="editEncPatientID">
                    <input type="hidden" name="enc_user_id"    id="editEncUserID">
                    <input type="hidden" name="patient_id_ref" id="editPatientIDRef">
                    <cfoutput>
                    <input type="hidden" name="updated_by"     value="#session.user.user_id#">
                    </cfoutput>
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-pencil-square me-2"></i>Edit Patient
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Full Name <span class="text-danger">*</span></label>
                                <input type="text" name="full_name" id="editFullName" class="form-control">
                                <div class="invalid-feedback" id="edit_full_name_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Email <span class="text-danger">*</span></label>
                                <input type="text" name="email" id="editEmail" class="form-control">
                                <div class="invalid-feedback" id="edit_email_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Phone <span class="text-danger">*</span></label>
                                <input type="text" name="phone" id="editPhone" class="form-control">
                                <div class="invalid-feedback" id="edit_phone_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Gender</label>
                                <select name="gender" id="editGender" class="form-select">
                                    <option value="">Select</option>
                                    <option value="Male">Male</option>
                                    <option value="Female">Female</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Date of Birth</label>
                                <input type="date" name="dob" id="editDOB" class="form-control">
                                <div class="invalid-feedback" id="edit_dob_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Blood Group</label>
                                <input type="text" name="blood_group" id="editBloodGroup" class="form-control">
                                <div class="invalid-feedback" id="edit_blood_group_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Address Line 1</label>
                                <input type="text" name="address1" id="editAddress1" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Address Line 2</label>
                                <input type="text" name="address2" id="editAddress2" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">City</label>
                                <input type="text" name="city" id="editCity" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">State</label>
                                <input type="text" name="state" id="editState" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Postal Code</label>
                                <input type="text" name="postal_code" id="editPostalCode" class="form-control">
                                <div class="invalid-feedback" id="edit_postal_code_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Country</label>
                                <input type="text" name="country" id="editCountry" class="form-control">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Emergency Contact Name</label>
                                <input type="text" name="emergency_name" id="editEmergencyName" class="form-control">
                                <div class="invalid-feedback" id="edit_emergency_name_err"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-semibold">Emergency Contact Phone</label>
                                <input type="text" name="emergency_phone" id="editEmergencyPhone" class="form-control">
                                <div class="invalid-feedback" id="edit_emergency_phone_err"></div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary" id="editPatientBtn">
                            <span id="editPatientBtnText">Update Patient</span>
                            <span id="editPatientSpinner" class="spinner-border spinner-border-sm ms-1 d-none" role="status"></span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!---  VIEW PATIENT MODAL  --->
    <div class="modal fade" id="viewPatientModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-person-lines-fill me-2"></i>Patient Details
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-2">
                            <span class="text-muted small">Full Name</span>
                            <p class="fw-bold mb-0" id="viewFullName"></p>
                        </div>
                        <div class="col-md-6 mb-2">
                            <span class="text-muted small">Username</span>
                            <p class="fw-bold mb-0" id="viewUsername"></p>
                        </div>
                        <div class="col-md-6 mb-2">
                            <span class="text-muted small">Email</span>
                            <p class="fw-bold mb-0" id="viewEmail"></p>
                        </div>
                        <div class="col-md-6 mb-2">
                            <span class="text-muted small">Phone</span>
                            <p class="fw-bold mb-0" id="viewPhone"></p>
                        </div>
                        <div class="col-md-6 mb-2">
                            <span class="text-muted small">Gender</span>
                            <p class="fw-bold mb-0" id="viewGender"></p>
                        </div>
                        <div class="col-md-6 mb-2">
                            <span class="text-muted small">Date of Birth</span>
                            <p class="fw-bold mb-0" id="viewDOB"></p>
                        </div>
                        <div class="col-md-6 mb-2">
                            <span class="text-muted small">Blood Group</span>
                            <p class="fw-bold mb-0" id="viewBloodGroup"></p>
                        </div>
                        <div class="col-12 mb-2">
                            <span class="text-muted small">Address</span>
                            <p class="fw-bold mb-0" id="viewAddress"></p>
                        </div>
                        <div class="col-md-6 mb-2">
                            <span class="text-muted small">Emergency Contact Name</span>
                            <p class="fw-bold mb-0" id="viewEmergencyName"></p>
                        </div>
                        <div class="col-md-6 mb-2">
                            <span class="text-muted small">Emergency Contact Phone</span>
                            <p class="fw-bold mb-0" id="viewEmergencyPhone"></p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

</div><!--- end #main --->

<cfinclude template="../../includes/footer.cfm">

<script>
$(document).ready(function () {

    //  Patient data map 
    var patientMap = {};
    $('#patientsTable tbody tr').each(function () {
        var $btn = $(this).find('.editBtn');
        if (!$btn.length) return;
        var pid = $btn.data('patient_id').toString();
        patientMap[pid] = {
            enc_patient_id  : $btn.data('enc_patient_id'),
            enc_user_id     : $btn.data('enc_user_id'),
            full_name       : $btn.data('full_name'),
            email           : $btn.data('email'),
            phone           : $btn.data('phone'),
            gender          : $btn.data('gender'),
            dob             : $btn.data('dob'),
            blood_group     : $btn.data('blood_group'),
            address1        : $btn.data('address1'),
            address2        : $btn.data('address2'),
            city            : $btn.data('city'),
            state           : $btn.data('state'),
            postal_code     : $btn.data('postal_code'),
            country         : $btn.data('country'),
            emergency_name  : $btn.data('emergency_name'),
            emergency_phone : $btn.data('emergency_phone')
        };
    });

    //  DataTable 
    var dt = $('#patientsTable').DataTable({
        pageLength: 5,
        columnDefs: [{ orderable: false, targets: [8, 9] }],
        language: {
            search:       '<i class="bi bi-search me-1"></i>Search:',
            lengthMenu:   'Show _MENU_ entries',
            info:         'Showing _START_ to _END_ of _TOTAL_ patients',
            paginate: {
                previous: '&lsaquo;',
                next:     '&rsaquo;'
            }
        }
    });

    //  SweetAlert2 helpers 
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
    var addModalEl  = document.getElementById('addPatientModal');
    var editModalEl = document.getElementById('editPatientModal');
    var viewModalEl = document.getElementById('viewPatientModal');
    var addModal    = new bootstrap.Modal(addModalEl);
    var editModal   = new bootstrap.Modal(editModalEl);
    var viewModal   = new bootstrap.Modal(viewModalEl);

    //  Validation rules 
    var rules = {
        required  : function (v) { return $.trim(v).length > 0; },
        minLen    : function (v, n) { return $.trim(v).length >= n; },
        alpha     : function (v) { return /^[A-Za-z\s]+$/.test($.trim(v)); },
        alphaNum  : function (v) { return /^[A-Za-z0-9_]+$/.test($.trim(v)); },
        email    : function (v) { return /^(?!.*\.\.)([A-Za-z0-9]+)@[A-Za-z0-9-]+\.[A-Za-z]{2,}$/.test($.trim(v)); },
        phone     : function (v) { return /^(?!0+$)[6-9]\d{9}$/.test($.trim(v));},
        postalCode: function (v) {
            return $.trim(v).length === 0 || /^[A-Za-z0-9\s\-]{3,10}$/.test($.trim(v));
        },
        dob: function (v) {
            if (!v) return false;
            return new Date(v) <= new Date();
        }
    };

    function setError(inputId, errId, msg) {
        $('#' + inputId).addClass('is-invalid').removeClass('is-valid');
        $('#' + errId).text(msg);
    }

    function setValid(inputId) {
        $('#' + inputId).removeClass('is-invalid').addClass('is-valid');
    }

    function clearFormState(formId) {
        $('#' + formId + ' .form-control, #' + formId + ' .form-select')
            .removeClass('is-invalid is-valid');
        $('#' + formId + ' .invalid-feedback').text('');
    }

    function resetBtn(btnId, spinnerId, textId, label) {
        $('#' + textId).text(label);
        $('#' + spinnerId).addClass('d-none');
        $('#' + btnId).prop('disabled', false);
    }

    //  Add form validation 
    function validateAddForm() {
        var ok = true;

        var fullName = $('#add_full_name').val();
        if (!rules.required(fullName))       { setError('add_full_name','add_full_name_err','Full Name is required.'); ok=false; }
        else if (!rules.minLen(fullName,3))  { setError('add_full_name','add_full_name_err','Full Name must be at least 3 characters.'); ok=false; }
        else if (!rules.alpha(fullName))     { setError('add_full_name','add_full_name_err','Full Name must contain letters only.'); ok=false; }
        else setValid('add_full_name');

        var username = $('#add_username').val();
        if (!rules.required(username))       { setError('add_username','add_username_err','Username is required.'); ok=false; }
        else if (!rules.minLen(username,3))  { setError('add_username','add_username_err','Username must be at least 3 characters.'); ok=false; }
        else if (!rules.alphaNum(username))  { setError('add_username','add_username_err','Letters, numbers and underscores only.'); ok=false; }
        else setValid('add_username');

        var email = $('#add_email').val();
        if (!rules.required(email))          { setError('add_email','add_email_err','Email is required.'); ok=false; }
        else if (!rules.email(email))        { setError('add_email','add_email_err','Please enter a valid email address.'); ok=false; }
        else setValid('add_email');

        var phone = $('#add_phone').val();
        if (!rules.required(phone))          { setError('add_phone','add_phone_err','Phone is required.'); ok=false; }
        else if (!rules.phone(phone))        { setError('add_phone','add_phone_err','Phone must be 10 digits.'); ok=false; }
        else setValid('add_phone');

        var dob = $('#add_dob').val();
        if (!rules.required(dob))            { setError('add_dob','add_dob_err','Date of Birth is required.'); ok=false; }
        else if (!rules.dob(dob))            { setError('add_dob','add_dob_err','Date of Birth cannot be in the future.'); ok=false; }
        else setValid('add_dob');


        var postal = $('#add_postal_code').val();
        if (rules.required(postal) && !rules.postalCode(postal)) {
            setError('add_postal_code','add_postal_code_err','Enter a valid postal code (3-10 chars).'); ok=false;
        } else if (rules.required(postal)) setValid('add_postal_code');

        var eName = $('#add_emergency_name').val();
        if (!rules.required(eName))          { setError('add_emergency_name','add_emergency_name_err','Emergency Contact Name is required.'); ok=false; }
        else if (!rules.minLen(eName,3))     { setError('add_emergency_name','add_emergency_name_err','Must be at least 3 characters.'); ok=false; }
        else setValid('add_emergency_name');

        var ePhone = $('#add_emergency_phone').val();
        if (!rules.required(ePhone))         { setError('add_emergency_phone','add_emergency_phone_err','Emergency Contact Phone is required.'); ok=false; }
        else if (!rules.phone(ePhone))       { setError('add_emergency_phone','add_emergency_phone_err','Must be 10 digits.'); ok=false; }
        else setValid('add_emergency_phone');

        return ok;
    }

    //  Edit form validation 
    function validateEditForm() {
        var ok = true;

        var fullName = $('#editFullName').val();
        if (!rules.required(fullName))       { setError('editFullName','edit_full_name_err','Full Name is required.'); ok=false; }
        else if (!rules.minLen(fullName,3))  { setError('editFullName','edit_full_name_err','Must be at least 3 characters.'); ok=false; }
        else if (!rules.alpha(fullName))     { setError('editFullName','edit_full_name_err','Letters only.'); ok=false; }
        else setValid('editFullName');

        var email = $('#editEmail').val();
        if (!rules.required(email))          { setError('editEmail','edit_email_err','Email is required.'); ok=false; }
        else if (!rules.email(email))        { setError('editEmail','edit_email_err','Enter a valid email address.'); ok=false; }
        else setValid('editEmail');

        var phone = $('#editPhone').val();
        if (!rules.required(phone))          { setError('editPhone','edit_phone_err','Phone is required.'); ok=false; }
        else if (!rules.phone(phone))        { setError('editPhone','edit_phone_err','Must be 10 digits.'); ok=false; }
        else setValid('editPhone');

        var dob = $('#editDOB').val();
        if (!rules.required(dob))            { setError('editDOB','edit_dob_err','Date of Birth is required.'); ok=false; }
        else if (!rules.dob(dob))            { setError('editDOB','edit_dob_err','Date of Birth cannot be in the future.'); ok=false; }
        else setValid('editDOB');

        var postal = $('#editPostalCode').val();
        if (rules.required(postal) && !rules.postalCode(postal)) {
            setError('editPostalCode','edit_postal_code_err','Enter a valid postal code (3-10 chars).'); ok=false;
        } else if (rules.required(postal)) setValid('editPostalCode');

        var eName = $('#editEmergencyName').val();
        if (!rules.required(eName))          { setError('editEmergencyName','edit_emergency_name_err','Emergency Contact Name is required.'); ok=false; }
        else if (!rules.minLen(eName,3))     { setError('editEmergencyName','edit_emergency_name_err','Must be at least 3 characters.'); ok=false; }
        else setValid('editEmergencyName');

        var ePhone = $('#editEmergencyPhone').val();
        if (!rules.required(ePhone))         { setError('editEmergencyPhone','edit_emergency_phone_err','Emergency Contact Phone is required.'); ok=false; }
        else if (!rules.phone(ePhone))       { setError('editEmergencyPhone','edit_emergency_phone_err','Must be 10 digits.'); ok=false; }
        else setValid('editEmergencyPhone');

        return ok;
    }

    //  Open Add Modal 
    $('#openAddModal').on('click', function () {
        $('#addPatientForm')[0].reset();
        clearFormState('addPatientForm');
        addModal.show();
    });

    $(addModalEl).on('hidden.bs.modal', function () {
        $('#addPatientForm')[0].reset();
        clearFormState('addPatientForm');
        resetBtn('addPatientBtn','addPatientSpinner','addPatientBtnText','Add Patient');
    });

    //  Open Edit Modal 
    $('#patientsTable tbody').on('click', '.editBtn', function () {
        var pid = $(this).data('patient_id').toString();
        var p   = patientMap[pid];
        if (!p) {
            swAlert('error','Not Found','Could not load patient data — please refresh.');
            return;
        }
        clearFormState('editPatientForm');
        $('#editEncPatientID').val(p.enc_patient_id);
        $('#editEncUserID').val(p.enc_user_id);
        $('#editPatientIDRef').val(pid);
        $('#editFullName').val(p.full_name);
        $('#editEmail').val(p.email);
        $('#editPhone').val(p.phone);
        $('#editGender').val(p.gender);
        $('#editDOB').val(p.dob);
        $('#editBloodGroup').val(p.blood_group);
        $('#editAddress1').val(p.address1);
        $('#editAddress2').val(p.address2);
        $('#editCity').val(p.city);
        $('#editState').val(p.state);
        $('#editPostalCode').val(p.postal_code);
        $('#editCountry').val(p.country);
        $('#editEmergencyName').val(p.emergency_name);
        $('#editEmergencyPhone').val(p.emergency_phone);
        editModal.show();
    });

    $(editModalEl).on('hidden.bs.modal', function () {
        clearFormState('editPatientForm');
        resetBtn('editPatientBtn','editPatientSpinner','editPatientBtnText','Update Patient');
    });

    //  Open View Modal 
    $('#patientsTable tbody').on('click', '.viewBtn', function () {
        var btn  = $(this);
        var addr = [btn.data('address1'), btn.data('address2'), btn.data('city'),
                    btn.data('state'), btn.data('postal_code'), btn.data('country')]
                   .filter(Boolean).join(', ');
        $('#viewFullName').text(btn.data('full_name'));
        $('#viewUsername').text(btn.data('username'));
        $('#viewEmail').text(btn.data('email'));
        $('#viewPhone').text(btn.data('phone'));
        $('#viewGender').text(btn.data('gender'));
        $('#viewDOB').text(btn.data('dob'));
        $('#viewBloodGroup').text(btn.data('blood_group') || '—');
        $('#viewAddress').text(addr || '—');
        $('#viewEmergencyName').text(btn.data('emergency_name') || '—');
        $('#viewEmergencyPhone').text(btn.data('emergency_phone') || '—');
        viewModal.show();
    });

    //  Add Patient Submit 
    $('#addPatientForm').on('submit', function (e) {
        e.preventDefault();
        clearFormState('addPatientForm');
        if (!validateAddForm()) return;

        $('#addPatientBtnText').text('Adding...');
        $('#addPatientSpinner').removeClass('d-none');
        $('#addPatientBtn').prop('disabled', true);

        $.ajax({
            url:      '/MedicalManagementSystem/components/RegisterPatientService.cfc?method=addPatientAjax&returnformat=json',
            type:     'POST',
            data:     $(this).serialize()
                    + '&created_by=<cfoutput>#session.user.user_id#</cfoutput>',
            dataType: 'json',
            success: function (res) {
                resetBtn('addPatientBtn','addPatientSpinner','addPatientBtnText','Add Patient');

                var ok  = res.SUCCESS === true || res.SUCCESS === 'true' || res.success === true;
                var msg = res.MESSAGE || res.message || '';

                if (!ok) {
                    swAlert('error', 'Failed', msg);
                    return;
                }

                var newPid    = (res.PATIENT_ID || 0).toString();
                var newEncU   = res.ENC_USER_ID;
                var newEncP   = res.ENC_PATIENT_ID;
                var newName   = res.FULL_NAME;
                var newUser   = res.USERNAME;
                var newPhone  = res.PHONE;
                var newGend   = res.GENDER;
                var newDob    = res.DOB;
                var newBG     = res.BLOOD_GROUP;
                var newCity   = res.CITY;
                var newStatus = res.STATUS || 'Active';
                var statusClass = (newStatus === 'Active') ? 'btn-success' : 'btn-danger';

                var statusBtn =
                    '<button class="btn btn-sm statusBtn ' + statusClass + '" '
                    + 'data-patient_id="' + newEncP + '" '
                    + 'data-user_id="'    + newEncU + '" '
                    + 'data-status="'     + newStatus + '">'
                    + newStatus + '</button>';

                var actionHtml = '';
                if (newStatus === 'Active') {
                    actionHtml +=
                        '<button type="button" class="btn btn-primary btn-sm editBtn me-1" '
                        + 'data-patient_id="'     + newPid  + '" '
                        + 'data-enc_patient_id="' + newEncP + '" '
                        + 'data-enc_user_id="'    + newEncU + '">'
                        + '<i class="bi bi-pencil-square"></i> Edit</button>';
                }
                actionHtml +=
                    '<button type="button" class="btn btn-light btn-sm viewBtn">'
                    + '<i class="bi bi-eye"></i> View</button>';

                patientMap[newPid] = {
                    enc_patient_id  : newEncP,
                    enc_user_id     : newEncU,
                    full_name       : newName,
                    email           : $('#add_email').val().trim(),
                    phone           : newPhone,
                    gender          : newGend,
                    dob             : $('#add_dob').val(),
                    blood_group     : newBG,
                    address1        : $('#add_address1').val().trim(),
                    address2        : $('#add_address2').val().trim(),
                    city            : newCity,
                    state           : $('#add_state').val().trim(),
                    postal_code     : $('#add_postal_code').val().trim(),
                    country         : $('#add_country').val().trim(),
                    emergency_name  : $('#add_emergency_name').val().trim(),
                    emergency_phone : $('#add_emergency_phone').val().trim()
                };

                var existingRow = null;
                dt.rows().every(function () {
                    if (this.data()[2] === newUser) { existingRow = this; }
                });

                if (existingRow) {
                    var rowData = existingRow.data();
                    rowData[1] = newName; rowData[3] = newPhone;
                    rowData[4] = newGend; rowData[5] = newDob;
                    rowData[6] = newBG;   rowData[7] = newCity;
                    rowData[8] = statusBtn; rowData[9] = actionHtml;
                    existingRow.data(rowData).draw(false);
                } else {
                    dt.row.add([
                        dt.rows().count() + 1,
                        newName, newUser, newPhone, newGend,
                        newDob, newBG, newCity,
                        statusBtn, actionHtml
                    ]).draw(false);
                }

                addModal.hide();
                swAlert('success', 'Registered!', msg);
            },
            error: function (xhr) {
                resetBtn('addPatientBtn','addPatientSpinner','addPatientBtnText','Add Patient');
                console.error('Add AJAX error:', xhr.responseText);
                swAlert('error','Server Error','Something went wrong — please try again.');
            }
        });
    });

    //  Edit Patient Submit 
    $('#editPatientForm').on('submit', function (e) {
        e.preventDefault();
        clearFormState('editPatientForm');
        if (!validateEditForm()) return;

        var full_name = $('#editFullName').val();
        var email     = $('#editEmail').val();
        var phone     = $('#editPhone').val();

        $('#editPatientBtnText').text('Updating...');
        $('#editPatientSpinner').removeClass('d-none');
        $('#editPatientBtn').prop('disabled', true);

        $.ajax({
            url:      '/MedicalManagementSystem/components/RegisterPatientService.cfc?method=editPatientAjax&returnformat=json',
            type:     'POST',
            data:     $(this).serialize(),
            dataType: 'json',
            success: function (res) {
                resetBtn('editPatientBtn','editPatientSpinner','editPatientBtnText','Update Patient');

                var ok  = res.SUCCESS === true || res.SUCCESS === 'true' || res.success === true;
                var msg = res.MESSAGE || res.message || '';

                if (!ok) {
                    swAlert('error', 'Failed', msg);
                    return;
                }

                var pid    = $('#editPatientIDRef').val();
                var gender = $('#editGender').val();
                var dob    = $('#editDOB').val();
                var bg     = $('#editBloodGroup').val();
                var city   = $('#editCity').val();

                if (patientMap[pid]) {
                    patientMap[pid].full_name       = full_name.trim();
                    patientMap[pid].email           = email.trim();
                    patientMap[pid].phone           = phone.trim();
                    patientMap[pid].gender          = gender;
                    patientMap[pid].dob             = dob;
                    patientMap[pid].blood_group     = bg;
                    patientMap[pid].address1        = $('#editAddress1').val();
                    patientMap[pid].address2        = $('#editAddress2').val();
                    patientMap[pid].city            = city;
                    patientMap[pid].state           = $('#editState').val();
                    patientMap[pid].postal_code     = $('#editPostalCode').val();
                    patientMap[pid].country         = $('#editCountry').val();
                    patientMap[pid].emergency_name  = $('#editEmergencyName').val();
                    patientMap[pid].emergency_phone = $('#editEmergencyPhone').val();
                }

                var dobDisplay = '';
                if (dob) {
                    var d = new Date(dob);
                    if (!isNaN(d)) {
                        var months = ['Jan','Feb','Mar','Apr','May','Jun',
                                      'Jul','Aug','Sep','Oct','Nov','Dec'];
                        dobDisplay = ('0'+d.getDate()).slice(-2) + '-'
                                   + months[d.getMonth()] + '-' + d.getFullYear();
                    }
                }

                var $editBtn = $('#patientsTable').find('.editBtn[data-patient_id="' + pid + '"]');
                var dtRow    = dt.row($editBtn.closest('tr'));
                var rowData  = dtRow.data();
                rowData[1] = full_name.trim();
                rowData[3] = phone.trim();
                rowData[4] = gender;
                rowData[5] = dobDisplay;
                rowData[6] = bg;
                rowData[7] = city;
                dtRow.data(rowData).invalidate().draw(false);

                $editBtn
                    .data('full_name',   full_name.trim())
                    .data('email',       email.trim())
                    .data('phone',       phone.trim())
                    .data('gender',      gender)
                    .data('dob',         dob)
                    .data('blood_group', bg)
                    .data('city',        city);

                editModal.hide();
                swAlert('success', 'Updated!', msg);
            },
            error: function (xhr) {
                resetBtn('editPatientBtn','editPatientSpinner','editPatientBtnText','Update Patient');
                console.error('Edit AJAX error:', xhr.responseText);
                swAlert('error','Server Error','Something went wrong — please try again.');
            }
        });
    });

    //  Toggle Status 
    $('#patientsTable').on('click', '.statusBtn', function () {
        var $btn          = $(this);
        var encUserID     = $btn.data('user_id');
        var currentStatus = $btn.data('status');
        var newStatus     = currentStatus === 'Active' ? 'Inactive' : 'Active';

        Swal.fire({
            title:              'Change Status?',
            text:               'Set this patient to ' + newStatus + '?',
            icon:               'question',
            showCancelButton:   true,
            confirmButtonColor: newStatus === 'Active' ? '#198754' : '#dc3545',
            cancelButtonColor:  '#6c757d',
            confirmButtonText:  'Yes, set ' + newStatus,
            cancelButtonText:   'Cancel'
        }).then(function (result) {
            if (!result.isConfirmed) return;

            $.ajax({
                url:      '/MedicalManagementSystem/components/RegisterPatientService.cfc?method=toggleStatus&returnformat=json',
                type:     'POST',
                data:     { enc_user_id: encUserID, new_status: newStatus },
                dataType: 'json',
                success: function (res) {
                    var ok  = res.SUCCESS === true || res.SUCCESS === 'true';
                    var msg = res.MESSAGE || res.message || '';

                    if (!ok) {
                        swAlert('error', 'Failed', msg || 'Failed to update status.');
                        return;
                    }

                    $btn.data('status', newStatus).text(newStatus)
                        .removeClass('btn-success btn-danger')
                        .addClass(newStatus === 'Active' ? 'btn-success' : 'btn-danger');

                    var $row        = $btn.closest('tr');
                    var $actionCell = $row.find('td').last();
                    var $editBtn    = $row.find('.editBtn');

                    if (newStatus === 'Inactive') {
                        $editBtn.remove();
                    } else if ($editBtn.length === 0) {
                        // enc_patient_id is stored as data-patient_id on the status button
                        var encPID = $btn.data('patient_id');

                        // Find matching entry in patientMap by enc_user_id
                        var pid = '';
                        $.each(patientMap, function(key, val) {
                            if (val.enc_user_id === encUserID) { pid = key; return false; }
                        });

                        var p = patientMap[pid];
                        if (!p) {
                            // fallback — page reload will fix everything
                            location.reload();
                            return;
                        }

                        var editHtml =
                            '<button type="button" class="btn btn-primary btn-sm editBtn me-1" '
                            + 'data-patient_id="'     + pid              + '" '
                            + 'data-enc_patient_id="' + p.enc_patient_id + '" '
                            + 'data-enc_user_id="'    + p.enc_user_id    + '" '
                            + 'data-full_name="'      + p.full_name      + '" '
                            + 'data-email="'          + p.email          + '" '
                            + 'data-phone="'          + p.phone          + '" '
                            + 'data-gender="'         + p.gender         + '" '
                            + 'data-dob="'            + p.dob            + '" '
                            + 'data-blood_group="'    + p.blood_group    + '" '
                            + 'data-address1="'       + p.address1       + '" '
                            + 'data-address2="'       + p.address2       + '" '
                            + 'data-city="'           + p.city           + '" '
                            + 'data-state="'          + p.state          + '" '
                            + 'data-postal_code="'    + p.postal_code    + '" '
                            + 'data-country="'        + p.country        + '" '
                            + 'data-emergency_name="' + p.emergency_name  + '" '
                            + 'data-emergency_phone="'+ p.emergency_phone + '">'
                            + '<i class="bi bi-pencil-square"></i> Edit</button>';

                        $actionCell.prepend(editHtml);
                    }

                    swAlert('success', 'Done!', 'Status changed to ' + newStatus + '.');
                },
                error: function () {
                    swAlert('error','Server Error','Something went wrong. Please try again.');
                }
            });
        });
    });

});

</script>