<cfinclude template="../includes/header.cfm">

<cfset userService = createObject("component","MedicalManagementSystem.components.forgotPasswordService")>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">
                        <i class="bi bi-lock me-2"></i>Forgot Password
                    </h5>
                </div>
                <div class="card-body p-4">

                    <!--- Step 1: Email --->
                    <div id="step1">
                        <p class="text-muted mb-3">
                            Enter your registered email to receive an OTP.
                        </p>
                        <form id="sendOTPForm" novalidate autocomplete="off">
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Email Address</label>
                                <input type="email" name="email" id="emailInput"
                                       class="form-control" placeholder="Enter your email">
                                <div class="invalid-feedback" id="emailErr"></div>
                            </div>
                            <button type="submit" class="btn btn-primary w-100" id="sendOtpBtn">
                                <span id="sendOtpBtnText">Send OTP</span>
                                <span id="sendOtpSpinner"
                                      class="spinner-border spinner-border-sm ms-1 d-none"
                                      role="status"></span>
                            </button>
                            <div class="text-center mt-3">
                                <a href="/MedicalManagementSystem/pages/login.cfm"
                                   class="text-muted small">Back to Login</a>
                            </div>
                        </form>
                    </div>

                    <!--- Step 2: OTP --->
                    <div id="step2" class="d-none">
                        <p class="text-muted mb-3" id="otpSubtitle">
                            Enter the 6-digit OTP sent to your email.
                        </p>
                        <form id="verifyOTPForm" novalidate autocomplete="off">
                            <div class="mb-3">
                                <label class="form-label fw-semibold">OTP</label>
                                <input type="text" name="otp" id="otpInput"
                                       class="form-control" maxlength="6"
                                       placeholder="Enter 6-digit OTP">
                                <div class="invalid-feedback" id="otpErr"></div>
                            </div>
                            <button type="submit" class="btn btn-primary w-100" id="verifyOtpBtn">
                                <span id="verifyOtpBtnText">Verify OTP</span>
                                <span id="verifyOtpSpinner"
                                      class="spinner-border spinner-border-sm ms-1 d-none"
                                      role="status"></span>
                            </button>
                            <div class="text-center mt-2">
                                <button type="button" class="btn btn-link btn-sm p-0"
                                        id="resendOtpBtn">
                                    Resend OTP
                                </button>
                            </div>
                        </form>
                    </div>

                    <!--- Step 3: New Password --->
                    <div id="step3" class="d-none">
                        <p class="text-muted mb-3">Enter your new password.</p>
                        <form id="resetPasswordForm" novalidate autocomplete="off">
                            <div class="mb-3">
                                <label class="form-label fw-semibold">New Password</label>
                                <input type="password" name="new_password" id="newPassInput"
                                       class="form-control" placeholder="Enter new password">
                                <div class="invalid-feedback" id="newPassErr"></div>
                                <small class="text-muted">
                                    Min 6 characters, must include uppercase, lowercase, a number and a special character (!@#$%^&*).
                                </small>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Confirm Password</label>
                                <input type="password" name="confirm_password"
                                       id="confirmPassInput" class="form-control"
                                       placeholder="Confirm new password">
                                <div class="invalid-feedback" id="confirmPassErr"></div>
                            </div>
                            <button type="submit" class="btn btn-success w-100" id="resetBtn">
                                <span id="resetBtnText">Reset Password</span>
                                <span id="resetSpinner"
                                      class="spinner-border spinner-border-sm ms-1 d-none"
                                      role="status"></span>
                            </button>
                        </form>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<cfinclude template="../includes/footer.cfm">

<script>
    $(document).ready(function () {

        var userEmail = '';
        var CFC_URL   = '/MedicalManagementSystem/components/forgotPasswordService.cfc';

        function swAlert(icon, title, text) {
            return Swal.fire({
                icon:               icon,
                title:              title,
                text:               text,
                confirmButtonColor: '#0d6efd',
                timer:              icon === 'success' ? 2500 : undefined,
                timerProgressBar:   icon === 'success'
            });
        }

        function startBtn(btnId, spinnerId, textId, label) {
            $('#' + textId).text(label);
            $('#' + spinnerId).removeClass('d-none');
            $('#' + btnId).prop('disabled', true);
        }

        function resetBtn(btnId, spinnerId, textId, label) {
            $('#' + textId).text(label);
            $('#' + spinnerId).addClass('d-none');
            $('#' + btnId).prop('disabled', false);
        }

        //  Step 1: Send OTP 
        $('#sendOTPForm').on('submit', function (e) {
            e.preventDefault();

            var email = $('#emailInput').val().trim();
            $('#emailInput').removeClass('is-invalid');
            $('#emailErr').text('');

            if (!email) {
                $('#emailInput').addClass('is-invalid');
                $('#emailErr').text('Email is required.');
                return;
            }
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                $('#emailInput').addClass('is-invalid');
                $('#emailErr').text('Please enter a valid email address.');
                return;
            }

            userEmail = email;
            startBtn('sendOtpBtn','sendOtpSpinner','sendOtpBtnText','Sending...');

            $.ajax({
                url:      CFC_URL + '?method=sendPasswordResetOTP&returnformat=json',
                type:     'POST',
                dataType: 'json',
                data:     { email: email },
                success: function (res) {
                    resetBtn('sendOtpBtn','sendOtpSpinner','sendOtpBtnText','Send OTP');
                    var ok  = res.SUCCESS === true || res.SUCCESS === 'true';
                    var msg = res.MESSAGE || res.message || '';

                    if (!ok) {
                        $('#emailInput').addClass('is-invalid');
                        $('#emailErr').text(msg);
                        return;
                    }

                    $('#otpSubtitle').text('OTP sent to ' + email + '. Valid for 10 minutes.');
                    $('#step1').addClass('d-none');
                    $('#step2').removeClass('d-none');
                },
                error: function () {
                    resetBtn('sendOtpBtn','sendOtpSpinner','sendOtpBtnText','Send OTP');
                    swAlert('error','Server Error','Something went wrong. Please try again.');
                }
            });
        });

        //  Step 2: Verify OTP 
        $('#verifyOTPForm').on('submit', function (e) {
            e.preventDefault();

            var otp = $('#otpInput').val().trim();
            $('#otpInput').removeClass('is-invalid');
            $('#otpErr').text('');

            if (!otp || !/^\d{6}$/.test(otp)) {
                $('#otpInput').addClass('is-invalid');
                $('#otpErr').text('Please enter the 6-digit OTP.');
                return;
            }

            startBtn('verifyOtpBtn','verifyOtpSpinner','verifyOtpBtnText','Verifying...');

            $.ajax({
                url:      CFC_URL + '?method=verifyPasswordResetOTP&returnformat=json',
                type:     'POST',
                dataType: 'json',
                data:     { email: userEmail, otp: otp },
                success: function (res) {
                    resetBtn('verifyOtpBtn','verifyOtpSpinner','verifyOtpBtnText','Verify OTP');
                    var ok  = res.SUCCESS === true || res.SUCCESS === 'true';
                    var msg = res.MESSAGE || res.message || '';

                    if (!ok) {
                        $('#otpInput').addClass('is-invalid');
                        $('#otpErr').text(msg);
                        return;
                    }

                    $('#step2').addClass('d-none');
                    $('#step3').removeClass('d-none');
                },
                error: function () {
                    resetBtn('verifyOtpBtn','verifyOtpSpinner','verifyOtpBtnText','Verify OTP');
                    swAlert('error','Server Error','Something went wrong. Please try again.');
                }
            });
        });

        //  Resend OTP 
        $('#resendOtpBtn').on('click', function () {
            $('#otpInput').val('').removeClass('is-invalid');
            $('#otpErr').text('');
            $('#resendOtpBtn').prop('disabled', true).text('Sending...');

            $.ajax({
                url:      CFC_URL + '?method=sendPasswordResetOTP&returnformat=json',
                type:     'POST',
                dataType: 'json',
                data:     { email: userEmail },
                success: function (res) {
                    $('#resendOtpBtn').prop('disabled', false).text('Resend OTP');
                    var ok  = res.SUCCESS === true || res.SUCCESS === 'true';
                    var msg = res.MESSAGE || res.message || '';

                    if (ok) {
                        swAlert('success','OTP Resent','A new OTP has been sent to ' + userEmail + '.');
                    } else {
                        swAlert('error','Failed', msg || 'Could not resend OTP.');
                    }
                },
                error: function () {
                    $('#resendOtpBtn').prop('disabled', false).text('Resend OTP');
                    swAlert('error','Server Error','Something went wrong. Please try again.');
                }
            });
        });

        //  Step 3: Reset Password 
        $('#resetPasswordForm').on('submit', function (e) {
            e.preventDefault();

            var newPass     = $('#newPassInput').val();
            var confirmPass = $('#confirmPassInput').val();
            var ok          = true;

            $('#newPassInput, #confirmPassInput').removeClass('is-invalid');
            $('#newPassErr, #confirmPassErr').text('');

            if (!newPass) {
                $('#newPassInput').addClass('is-invalid');
                $('#newPassErr').text('New password is required.');
                ok = false;
            } else if (newPass.length < 6) {
                $('#newPassInput').addClass('is-invalid');
                $('#newPassErr').text('Password must be at least 6 characters.');
                ok = false;
            } else if (!/[A-Z]/.test(newPass)) {
                $('#newPassInput').addClass('is-invalid');
                $('#newPassErr').text('Password must contain at least one uppercase letter.');
                ok = false;
            } else if (!/[a-z]/.test(newPass)) {
                $('#newPassInput').addClass('is-invalid');
                $('#newPassErr').text('Password must contain at least one lowercase letter.');
                ok = false;
            } else if (!/[0-9]/.test(newPass)) {
                $('#newPassInput').addClass('is-invalid');
                $('#newPassErr').text('Password must contain at least one number.');
                ok = false;
            } else if (!/[!@##$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(newPass)) {
                $('#newPassInput').addClass('is-invalid');
                $('#newPassErr').text('Password must contain at least one special character (!@#$%^&*).');
                ok = false;
            } else if (newPass.length > 64) {
                $('#newPassInput').addClass('is-invalid');
                $('#newPassErr').text('Password must not exceed 64 characters.');
                ok = false;
            }

            if (!confirmPass) {
                $('#confirmPassInput').addClass('is-invalid');
                $('#confirmPassErr').text('Please confirm your password.');
                ok = false;
            } else if (newPass !== confirmPass) {
                $('#confirmPassInput').addClass('is-invalid');
                $('#confirmPassErr').text('Passwords do not match.');
                ok = false;
            }

            if (!ok) return;

            startBtn('resetBtn','resetSpinner','resetBtnText','Resetting...');

            $.ajax({
                url:      CFC_URL + '?method=resetPassword&returnformat=json',
                type:     'POST',
                dataType: 'json',
                data:     { email: userEmail, new_password: newPass },
                success: function (res) {
                    resetBtn('resetBtn','resetSpinner','resetBtnText','Reset Password');
                    var success = res.SUCCESS === true || res.SUCCESS === 'true';
                    var msg     = res.MESSAGE || res.message || '';

                    if (!success) {
                        swAlert('error','Failed', msg || 'Could not reset password.');
                        return;
                    }

                    Swal.fire({
                        icon:               'success',
                        title:              'Password Reset!',
                        text:               'Redirecting to login...',
                        confirmButtonColor: '#0d6efd',
                        timer:              2000,
                        timerProgressBar:   true,
                        showConfirmButton:  false
                    }).then(function () {
                        window.location.href = '/MedicalManagementSystem/pages/login.cfm';
                    });
                },
                error: function () {
                    resetBtn('resetBtn','resetSpinner','resetBtnText','Reset Password');
                    swAlert('error','Server Error','Something went wrong. Please try again.');
                }
            });
        });

        // Only digits in OTP
        $('#otpInput').on('input', function () {
            $(this).val($(this).val().replace(/[^0-9]/g, ''));
            $(this).removeClass('is-invalid');
            $('#otpErr').text('');
        });

        $('#emailInput').on('input', function () {
            $(this).removeClass('is-invalid');
            $('#emailErr').text('');
        });

    });
</script>