<cfinclude template="../../includes/sessionCheck.cfm">

<!---  SESSION SECURITY  --->
<cfif NOT structKeyExists(session,"user") OR session.user.role_id NEQ 4>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfinclude template="../../includes/header.cfm">
<cfinclude template="patientSidebar.cfm">

<cfset userService     = createObject("component","MedicalManagementSystem.components.patientAccountService")>
<cfset securityService = createObject("component","MedicalManagementSystem.components.securityService")>
<cfset patient         = userService.getPatientByUserID(session.user.user_id)>

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
                    <a href="/MedicalManagementSystem/pages/patients/patient_Account.cfm">
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

        <!--- Personal Details --->
        <div class="card mb-4 shadow-sm">
            <div class="card-body fw-semibold">
                <i class="bi bi-person-circle me-2"></i>Personal Details
            </div>
            <div class="card-body">
                <form id="updateDetailsForm">
                    <input type="hidden" name="enc_user_id"    value="#securityService.encryptID(patient.user_id)#">
                    <input type="hidden" name="enc_patient_id" value="#securityService.encryptID(patient.patient_id)#">

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Full Name <span class="text-danger">*</span></label>
                            <input type="text" name="full_name" class="form-control"
                                   value="#encodeForHTML(patient.full_name)#">
                            <small class="text-danger" id="fullNameError"></small>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Username</label>
                            <input type="text" class="form-control"
                                   value="#encodeForHTML(patient.username)#" readonly>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Email <span class="text-danger">*</span></label>
                            <input type="email" name="email" class="form-control"
                                   value="#encodeForHTML(patient.email)#">
                            <small class="text-danger" id="emailError"></small>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Phone <span class="text-danger">*</span></label>
                            <input type="text" name="phone" class="form-control"
                                   value="#encodeForHTML(patient.phone)#">
                            <small class="text-danger" id="phoneError"></small>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Date of Birth</label>
                            <input type="date" name="date_of_birth" class="form-control"
                                   value="#len(trim(patient.date_of_birth)) ? dateFormat(patient.date_of_birth,'yyyy-mm-dd') : ''#">
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label">Gender</label>
                            <select name="gender" class="form-select">
                                <option value="Male"   #patient.gender EQ "Male"   ? "selected" : ""#>Male</option>
                                <option value="Female" #patient.gender EQ "Female" ? "selected" : ""#>Female</option>
                                <option value="Other"  #patient.gender EQ "Other"  ? "selected" : ""#>Other</option>
                            </select>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label">Blood Group</label>
                            <select name="blood_group" class="form-select">
                                <cfset bloodGroups = ["A+","A-","B+","B-","AB+","AB-","O+","O-"]>
                                <option value="">-- Select --</option>
                                <cfloop array="#bloodGroups#" index="bg">
                                    <option value="#bg#" #patient.blood_group EQ bg ? "selected" : ""#>#bg#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div>

                    <hr>
                    <h6 class="fw-bold mb-3"><i class="bi bi-geo-alt me-2"></i>Address</h6>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Address Line 1</label>
                            <input type="text" name="address_line1" class="form-control"
                                   value="#encodeForHTML(patient.address_line1)#">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Address Line 2</label>
                            <input type="text" name="address_line2" class="form-control"
                                   value="#encodeForHTML(patient.address_line2)#">
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label">City</label>
                            <input type="text" name="city" class="form-control"
                                   value="#encodeForHTML(patient.city)#">
                            <small class="text-danger" id="cityError"></small>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label">State</label>
                            <input type="text" name="state" class="form-control"
                                   value="#encodeForHTML(patient.state)#">
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label">Postal Code</label>
                            <input type="text" name="postal_code" class="form-control"
                                   value="#encodeForHTML(patient.postal_code)#">
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label">Country</label>
                            <input type="text" name="country" class="form-control"
                                   value="#encodeForHTML(patient.country)#">
                        </div>
                    </div>

                    <hr>
                    <h6 class="fw-bold mb-3"><i class="bi bi-telephone-fill me-2"></i>Emergency Contact</h6>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Contact Name</label>
                            <input type="text" name="emergency_contact_name" class="form-control"
                                   value="#encodeForHTML(patient.emergency_contact_name)#">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Contact Phone</label>
                            <input type="text" name="emergency_contact_phone" class="form-control"
                                   value="#encodeForHTML(patient.emergency_contact_phone)#">
                            <small class="text-danger" id="emergencyPhoneError"></small>
                        </div>
                    </div>

                    <button type="submit" id="updateDetailsBtn" class="btn btn-primary">
                        <span id="updateDetailsBtnText">Update Profile</span>
                        <span id="updateDetailsSpinner"
                              class="spinner-border spinner-border-sm d-none ms-1"></span>
                    </button>
                </form>
            </div>
        </div>

        <!--- Change Password --->
        <div class="card mb-4">
            <div class="card-body fw-semibold">
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
</div>
</cfoutput>

<cfinclude template="../../includes/footer.cfm">

<script>
$(document).ready(function () {

    function showMessage(type, msg) {
        $('#formMessage')
            .removeClass('d-none alert-success alert-danger alert-warning')
            .addClass('alert alert-' + type)
            .html(msg);
        $('html,body').animate({ scrollTop: 0 }, 300);
        setTimeout(function () { $('#formMessage').addClass('d-none'); }, 5000);
    }

    function clearErrors() {
        $('small.text-danger[id$="Error"]').text('');
    }

    function showError(id, msg) {
        $('#' + id).text(msg);
    }

    function btnLoad(btnId, spinnerId, textId, label) {
        $('#' + btnId).prop('disabled', true);
        $('#' + textId).text(label);
        $('#' + spinnerId).removeClass('d-none');
    }

    function btnReset(btnId, spinnerId, textId, label) {
        $('#' + btnId).prop('disabled', false);
        $('#' + textId).text(label);
        $('#' + spinnerId).addClass('d-none');
    }

    function getVal(res, key) {
        return res[key] !== undefined ? res[key] : res[key.toUpperCase()];
    }

    //  Update Profile 
    $('#updateDetailsForm').on('submit', function (e) {
        e.preventDefault();
        clearErrors();

        var fullName       = $('input[name="full_name"]').val().trim();
        var email          = $('input[name="email"]').val().trim();
        var phone          = $('input[name="phone"]').val().trim();
        var emergencyPhone = $('input[name="emergency_contact_phone"]').val().trim();
        var city           = $('input[name="city"]').val().trim();
        var nameRx         = /^[A-Za-z.\- ]+$/;
        var emailRx = /^(?!.*\.\.)([A-Za-z0-9]+)@[A-Za-z0-9-]+\.[A-Za-z]{2,}$/;
        var phoneRx = /^(?!0+$)[6-9]\d{9}$/;
        var cityRx         = /^[A-Za-z\s]*$/;
        var valid          = true;

        if (!fullName) {
            showError('fullNameError', 'Full Name is required.'); valid = false;
        } else if (!nameRx.test(fullName)) {
            showError('fullNameError', 'Only letters, spaces, dot and hyphen allowed.'); valid = false;
        }
        if (!emailRx.test(email)) {
            showError('emailError', 'Enter a valid email address.'); valid = false;
        }
        if (!phoneRx.test(phone)) {
            showError('phoneError', 'Phone No must be 10 digits and valid.'); valid = false;
        }
        if (emergencyPhone && !phoneRx.test(emergencyPhone)) {
            showError('emergencyPhoneError', 'Phone No must be 10 digits and valid.'); valid = false;
        }
        if (city && !cityRx.test(city)) {
            showError('cityError', 'City can only contain letters and spaces.'); valid = false;
        }
        if (!valid) return;

        btnLoad('updateDetailsBtn','updateDetailsSpinner','updateDetailsBtnText','Updating...');

        $.ajax({
            url:      '/MedicalManagementSystem/components/patientAccountService.cfc?method=updatePatientDetails&returnformat=json',
            type:     'POST',
            dataType: 'json',
            data:     $(this).serialize() ,
            success: function (res) {
                btnReset('updateDetailsBtn','updateDetailsSpinner','updateDetailsBtnText','Update Profile');
                showMessage(getVal(res,'success') ? 'success' : 'danger', getVal(res,'message'));
            },
            error: function () {
                btnReset('updateDetailsBtn','updateDetailsSpinner','updateDetailsBtnText','Update Profile');
                showMessage('danger', 'Server error. Please try again.');
            }
        });
    });

});
</script>