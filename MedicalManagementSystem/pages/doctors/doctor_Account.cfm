<cfinclude template="../../includes/header.cfm">
<cfinclude template="doctorSidebar.cfm">

<cfinclude template="../../includes/sessionCheck.cfm">
<!---  SESSION SECURITY  --->

<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 2>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset accountService  = createObject("component","MedicalManagementSystem.components.DoctorAccountService")>
<cfset securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>

<cfset doctor = accountService.getDoctorDetails(session.user.user_id)>


<div id="main">
    <header class="mb-3">
        <a href="#" class="burger-btn d-block d-xl-none">
            <i class="bi bi-justify fs-3"></i>
        </a>
    </header>
    <cfoutput>
        <div class="page-heading d-flex justify-content-between align-items-center mb-3">
            <h3>My Account</h3>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item">
                        <a href="/MedicalManagementSystem/pages/doctors/doctor_Account.cfm">
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

        <div class="container-fluid">

            <div id="formMessage" class="alert d-none mb-3"></div>

            <!--- Personal Details Card --->
            <div class="card mb-4 shadow-sm">
                <div class="card-body fw-semibold">
                    <i class="bi bi-person-circle me-2"></i>Personal Details
                </div>
                <div class="card-body">
                    <form id="updateDetailsForm">
                        <input type="hidden" name="enc_user_id" value="#securityService.encryptID(doctor.user_id)#">

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Full Name <span class="text-danger">*</span></label>
                                <input type="text" name="full_name" id="full_name"
                                    class="form-control" value="#encodeForHTML(doctor.full_name)#">
                                <small class="text-danger" id="err_full_name"></small>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Username <span class="text-danger">*</span></label>
                                <input type="text" name="username" id="username"
                                    class="form-control" value="#encodeForHTML(doctor.username)#">
                                <small class="text-danger" id="err_username"></small>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Email <span class="text-danger">*</span></label>
                                <input type="email" name="email" id="email"
                                    class="form-control" value="#encodeForHTML(doctor.email)#">
                                <small class="text-danger" id="err_email"></small>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Phone</label>
                                <input type="text" name="phone" id="phone"
                                    class="form-control" value="#encodeForHTML(doctor.phone)#">
                                <small class="text-danger" id="err_phone"></small>
                            </div>
                        </div>

                        <button type="submit" id="updateBtn" class="btn btn-primary">
                            <span id="updateBtnText">Update Profile</span>
                            <span id="updateSpinner" class="spinner-border spinner-border-sm d-none ms-1"></span>
                        </button>
                    </form>
                </div>
            </div>

            <!--- Professional Details (read-only) --->
            <div class="card mb-4 shadow-sm">
                <div class="card-body fw-semibold">
                    <i class="bi bi-hospital me-2"></i>Professional Details
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="text-muted small">Department</label>
                            <p class="fw-bold mb-0">#encodeForHTML(doctor.dept_name)#</p>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="text-muted small">Specialization</label>
                            <p class="fw-bold mb-0">
                                #len(trim(doctor.specialization)) ? encodeForHTML(doctor.specialization) : "—"#
                            </p>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="text-muted small">Qualification</label>
                            <p class="fw-bold mb-0">
                                #len(trim(doctor.qualification)) ? encodeForHTML(doctor.qualification) : "—"#
                            </p>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="text-muted small">Experience</label>
                            <p class="fw-bold mb-0">
                                #isNumeric(doctor.experience_years) ? doctor.experience_years & " years" : "—"#
                            </p>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="text-muted small">Consultation Fee</label>
                            <p class="fw-bold mb-0">
                                #isNumeric(doctor.consultation_fee) ? "Rs. " & numberFormat(doctor.consultation_fee,"__.00") : "—"#
                            </p>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="text-muted small">Status</label>
                            <p class="mb-0">
                                <cfif doctor.is_active>
                                    <span class="badge bg-success">Active</span>
                                <cfelse>
                                    <span class="badge bg-danger">Inactive</span>
                                </cfif>
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <!--- Change Password Card --->
            <div class="card mb-4">
                <div class="card-header fw-bold">
                    <i class="bi bi-lock me-2"></i>Password
                </div>
                <div class="card-body">
                    <a href="/MedicalManagementSystem/pages/forgotPassword.cfm"
                    class="btn btn-warning">
                        <i class="bi bi-key me-1"></i> Forgot / Change Password
                    </a>
                </div>
            </div>

        </div>
    </cfoutput>
</div>


<cfinclude template="../../includes/footer.cfm">

<script>
    $(document).ready(function () {

        var CFC_URL = '/MedicalManagementSystem/components/DoctorAccountService.cfc';

        function showMessage(type, msg) {
            $('#formMessage')
                .removeClass('d-none alert-success alert-danger')
                .addClass('alert alert-' + type)
                .html(msg);
            $('html,body').animate({ scrollTop: 0 }, 250);
            setTimeout(function () { $('#formMessage').addClass('d-none'); }, 5000);
        }

        function clearErrors() {
            $('small[id^="err_"]').text('');
        }

        function showError(id, msg) {
            $('#err_' + id).text(msg);
        }

        function getVal(res, key) {
            return res[key] !== undefined ? res[key] : res[key.toUpperCase()];
        }

        //  Update Details 
        $('#updateDetailsForm').on('submit', function (e) {
            e.preventDefault();
            clearErrors();

            var fullName = $('#full_name').val().trim();
            var username = $('#username').val().trim();
            var email    = $('#email').val().trim();
            var phone    = $('#phone').val().trim();
            var nameRx   = /^[A-Za-z.\- ]+$/;
            var emailRegex = /^(?!.*\.\.)([A-Za-z0-9]+)@[A-Za-z0-9-]+\.[A-Za-z]{2,}$/;
            var phoneRegex = /^(?!0+$)[6-9]\d{9}$/;
            var valid    = true;

            if (!fullName) {
                showError('full_name', 'Full name is required.'); valid = false;
            } else if (!nameRx.test(fullName)) {
                showError('full_name', 'Only letters, spaces, dots and hyphens allowed.'); valid = false;
            }
            if (username.length < 4) {
                showError('username', 'Username must be at least 4 characters.'); valid = false;
            }
            if (!emailRx.test(email)) {
                showError('email', 'Enter a valid email address.'); valid = false;
            }
            if (phone && !phoneRx.test(phone)) {
                showError('phone', 'Phone must be exactly 10 digits.'); valid = false;
            }
            if (!valid) return;

            $('#updateBtnText').text('Updating...');
            $('#updateSpinner').removeClass('d-none');
            $('#updateBtn').prop('disabled', true);

            $.ajax({
                url:      CFC_URL,
                type:     'POST',
                dataType: 'json',
                data: {
                    method:       'updateDoctorDetails',
                    returnformat: 'json',
                    enc_user_id:  $('input[name="enc_user_id"]', this).val(),
                    full_name:    fullName,
                    username:     username,
                    email:        email,
                    phone:        phone
                },
                success: function (res) {
                    $('#updateBtnText').text('Update Profile');
                    $('#updateSpinner').addClass('d-none');
                    $('#updateBtn').prop('disabled', false);
                    showMessage(getVal(res,'success') ? 'success' : 'danger', getVal(res,'message'));
                },
                error: function () {
                    $('#updateBtnText').text('Update Profile');
                    $('#updateSpinner').addClass('d-none');
                    $('#updateBtn').prop('disabled', false);
                    showMessage('danger', 'Server error. Please try again.');
                }
            });
        });
    });
</script>
