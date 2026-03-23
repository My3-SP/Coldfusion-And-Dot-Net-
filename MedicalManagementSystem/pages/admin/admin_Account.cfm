<cfinclude template="../../includes/header.cfm">
<cfinclude template="adminSidebar.cfm">

<!---  SESSION SECURITY  --->
<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 1>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset userService = createObject("component","MedicalManagementSystem.components.AdminAccountService")>
<cfset securityService = createObject("component","MedicalManagementSystem.components.securityService")>
<cfset bcryptService = createObject("component","MedicalManagementSystem.libs.bcrypt")>

<!---  GET ADMIN DATA  --->
<cfset admin = userService.getAdminDetails(session.user.user_id)>

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
                    <i class="bi bi-person me-2"></i>My Account</a>
                </li>
                <li class="breadcrumb-item">
                    <a href="/MedicalManagementSystem/pages/logout.cfm" class="text-danger">
                    <i class="bi bi-box-arrow-right me-2"></i>Logout</a>
                </li>
            </ol>
        </nav>
    </div>
    <cfoutput>
        <div class="container mt-4">
            <h3>My Account</h3>
            <hr>
            <div id="formMessage" class="alert d-none"></div>

            <!--- PROFILE FORM --->
            <div class="card mb-4">
                <div class="card-header">Personal Details</div>
                <div class="card-body">
                    <form id="updateAdminForm">
                        <input type="hidden" name="enc_user_id" value="#securityService.encryptID(admin.user_id)#">

                        <div class="mb-3">
                            <label>Full Name</label>
                            <input type="text" name="full_name" class="form-control" value="#admin.full_name#">
                            <small class="text-danger error-msg" id="fullNameError"></small>
                        </div>

                        <div class="mb-3">
                            <label>Username</label>
                            <input type="text" name="username" class="form-control" value="#admin.username#">
                            <small class="text-danger error-msg" id="usernameError"></small>
                        </div>

                        <div class="mb-3">
                            <label>Email</label>
                            <input type="email" name="email" class="form-control" value="#admin.email#">
                            <small class="text-danger error-msg" id="emailError"></small>
                        </div>

                        <div class="mb-3">
                            <label>Phone</label>
                            <input type="text" name="phone" class="form-control" value="#admin.phone#">
                            <small class="text-danger error-msg" id="phoneError"></small>
                        </div>

                        <button type="submit" id="updateAdminBtn" class="btn btn-primary">
                            <span id="updateAdminBtnText">Update</span>
                            <span id="updateAdminSpinner" class="spinner-border spinner-border-sm d-none"></span>
                        </button>
                    </form>
                </div>
            </div>

            <!--- PASSWORD FORM --->
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
    $(document).ready(function(){

    /* UPDATE PROFILE */

    $('#updateAdminForm').on('submit', function(e){

        e.preventDefault();

        clearErrors();

        var fullName = $('input[name="full_name"]').val().trim();
        var username = $('input[name="username"]').val().trim();
        var email = $('input[name="email"]').val().trim();
        var phone = $('input[name="phone"]').val().trim();

        var nameRegex = /^[A-Za-z\s]+$/;
        var emailRegex = /^(?!.*\.\.)([A-Za-z0-9]+)@[A-Za-z0-9-]+\.[A-Za-z]{2,}$/;
        var phoneRegex = /^(?!0+$)[6-9]\d{9}$/;
        var valid = true;

        if(fullName === ""){
            showError('fullNameError',"Full name is required");
            valid = false;
        }
        else if(!nameRegex.test(fullName)){
            showError('fullNameError',"Only letters allowed");
            valid = false;
        }

        if(username.length < 4){
            showError('usernameError',"Username must be at least 4 characters");
            valid = false;
        }

        if(!emailRegex.test(email)){
            showError('emailError',"Enter a valid email");
            valid = false;
        }

        if(phone !== "" && !phoneRegex.test(phone)){
            showError('phoneError',"Phone must be 10 digits");
            valid = false;
        }

        if(!valid){
            return;
        }

        $('#updateAdminBtnText').text('Updating...');
        $('#updateAdminSpinner').removeClass('d-none');
        $('#updateAdminBtn').prop('disabled',true);

        $.ajax({

            url:'/MedicalManagementSystem/components/AdminAccountService.cfc?method=updateAdminDetailsAjax&returnformat=json',
            type:'POST',
            data:$(this).serialize(),
            dataType:'json',

            success:function(res){

                $('#updateAdminBtnText').text('Update');
                $('#updateAdminSpinner').addClass('d-none');
                $('#updateAdminBtn').prop('disabled',false);

                var ok = res.SUCCESS === true || res.SUCCESS === 'true';

                if(!ok){
                    showMessage('danger',res.MESSAGE);
                    return;
                }

                showMessage('success',res.MESSAGE);
            },

            error:function(){

                $('#updateAdminBtnText').text('Update');
                $('#updateAdminSpinner').addClass('d-none');
                $('#updateAdminBtn').prop('disabled',false);

                showMessage('danger','Server error. Please try again.');
            }

        });

    });
    });

    /*  HELPER FUNCTIONS  */
    function clearErrors(){
        $('.error-msg').text('');
    }
    function showError(id,message){
        $('#'+id).text(message);
    }
    function showMessage(type, message){
        var msgBox = $('#formMessage');
        msgBox
            .removeClass('d-none alert-success alert-danger')
            .addClass('alert alert-' + type)
            .html(message);

        setTimeout(function(){
            $('#formMessage').addClass('d-none');
        },4000);
    }
</script>
