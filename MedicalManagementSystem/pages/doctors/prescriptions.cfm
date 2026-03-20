<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="doctorSidebar.cfm">


<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 2>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<cfset secureService       = createObject("component","MedicalManagementSystem.components.SecurityService")>
<cfset prescriptionService = createObject("component","MedicalManagementSystem.components.PrescriptionService")>

<cfif NOT structKeyExists(url,"appointmentID")>
    <cflocation url="Appointments.cfm" addtoken="no">
</cfif>

<cftry>
    <cfset appointmentID = secureService.decryptID(url.appointmentID)>
<cfcatch>
    <cflocation url="Appointments.cfm" addtoken="no">
</cfcatch>
</cftry>

<cfset appointment = prescriptionService.getAppointmentDetails(appointmentID)>

<cfif appointment.recordCount EQ 0>
    <cflocation url="Appointments.cfm" addtoken="no">
</cfif>

<cfif trim(lcase(appointment.status_name)) NEQ "in progress">
    <cflocation url="Appointments.cfm" addtoken="no">
</cfif>

<cfset drugs = prescriptionService.getActiveDrugs()>


<div id="main">
    <header class="mb-3">
        <a href="#" class="burger-btn d-block d-xl-none">
            <i class="bi bi-justify fs-3"></i>
        </a>
    </header>
<cfoutput>
    <div class="page-heading d-flex justify-content-between align-items-center">
        <h2>Doctor Dashboard</h2>
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

    <div class="page-heading d-flex justify-content-between align-items-center mb-3">
        <h3>Write Prescription &mdash; #encodeForHTML(appointment.patient_name)#</h3>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item"><a href="Appointments.cfm">My Appointments</a></li>
            </ol>
        </nav>
    </div>

    <p class="text-muted">
        <i class="bi bi-calendar me-1"></i>#dateFormat(appointment.appointment_datetime,"dd-mmm-yyyy")#
        &nbsp;|&nbsp;
        <i class="bi bi-clock me-1"></i>#timeFormat(appointment.appointment_datetime,"hh:mm tt")#
    </p>

    <div id="toastContainer" style="position:fixed;top:20px;right:20px;z-index:9999;min-width:280px;"></div>

    <div class="card p-4 shadow-sm">

        <div class="mb-3">
            <label class="form-label fw-bold">Diagnosis <span class="text-danger">*</span></label>
            <textarea id="diagnosis" class="form-control" rows="3"
                      placeholder="Enter diagnosis..."></textarea>
        </div>

        <div class="mb-4">
            <label class="form-label fw-bold">Notes</label>
            <textarea id="notes" class="form-control" rows="2"
                      placeholder="Optional notes..."></textarea>
        </div>

        <h5 class="mb-2">Medicines</h5>
        <div class="table-responsive mb-2">
            <table class="table table-bordered align-middle" id="medicineTable">
                <thead class="table-light">
                    <tr>
                        <th>Drug <span class="text-danger">*</span></th>
                        <th>Dosage <span class="text-danger">*</span></th>
                        <th>Frequency <span class="text-danger">*</span></th>
                        <th>Duration <span class="text-danger">*</span></th>
                        <th>Instructions</th>
                        <th width="70"></th>
                    </tr>
                </thead>
                <tbody id="medicineBody">
                    <tr>
                        <td>
                            <select class="form-select med-drug">
                                <option value="">-- Select Drug --</option>
                                <cfloop query="drugs">
                                    <option value="#drug_id#">
                                        #encodeForHTML(drug_name)#
                                        <cfif len(trim(strength))> (#encodeForHTML(strength)#)</cfif>
                                        <cfif len(trim(drug_form))> - #encodeForHTML(drug_form)#</cfif>
                                    </option>
                                </cfloop>
                            </select>
                        </td>
                        <td><input type="text" class="form-control med-dosage"
                                   placeholder="e.g. 500mg"></td>
                        <td><input type="text" class="form-control med-frequency"
                                   placeholder="e.g. Twice daily"></td>
                        <td><input type="text" class="form-control med-duration"
                                   placeholder="e.g. 5 days"></td>
                        <td><input type="text" class="form-control med-instructions"
                                   placeholder="e.g. After meals"></td>
                        <td class="text-center">
                            <button type="button"
                                    class="btn btn-sm btn-outline-danger btn-remove-row">
                                <i class="bi bi-trash"></i>
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="mb-4">
            <button type="button" id="addRowBtn" class="btn btn-sm btn-outline-secondary">
                <i class="bi bi-plus-circle me-1"></i> Add Medicine
            </button>
        </div>

        <div class="d-flex gap-2">
            <button type="button" id="savePrescriptionBtn" class="btn btn-success">
                <i class="bi bi-check-circle me-1"></i> Save Prescription
            </button>
            <a href="Appointments.cfm" class="btn btn-secondary">Cancel</a>
        </div>

    </div>
</div>

<script>
    var APPOINTMENT_ID = #appointmentID#;
    var DRUGS_HTML     = document.querySelector('.med-drug').innerHTML;
    var CFC_URL        = '/MedicalManagementSystem/components/PrescriptionService.cfc';
</script>
</cfoutput>

<cfinclude template="../../includes/footer.cfm">

<script>
$(document).ready(function () {

    function showToast(msg, type) {
        var bg = type === 'success' ? '#198754' : '#dc3545';
        var id = 'toast-' + Date.now();
        $('#toastContainer').append(
            '<div id="' + id + '" style="background:' + bg + ';color:#fff;'
            + 'padding:12px 20px;border-radius:6px;margin-bottom:8px;'
            + 'box-shadow:0 2px 8px rgba(0,0,0,.2);font-size:14px;">'
            + msg + '</div>'
        );
        setTimeout(function () {
            $('#' + id).fadeOut(400, function () { $(this).remove(); });
        }, 3500);
    }

    function getVal(res, key) {
        return res[key] !== undefined ? res[key] : res[key.toUpperCase()];
    }

    // ── Add row 
    $('#addRowBtn').on('click', function () {
        var $newRow = $('#medicineBody tr:first').clone();
        $newRow.find('.med-drug').html(DRUGS_HTML).val('');
        $newRow.find('input').val('');
        $newRow.find('.is-invalid').removeClass('is-invalid');
        $('#medicineBody').append($newRow);
    });

    //  Remove row 
    $(document).on('click', '.btn-remove-row', function () {
        if ($('#medicineBody tr').length > 1) {
            $(this).closest('tr').remove();
        } else {
            showToast('At least one medicine row is required.', 'error');
        }
    });

    //  Clear invalid on change 
    $(document).on('change input', '.is-invalid', function () {
        $(this).removeClass('is-invalid');
    });
    $('#diagnosis').on('input', function () {
        $(this).removeClass('is-invalid');
    });

    //  Save Prescription 
    $('#savePrescriptionBtn').on('click', function () {
        var $btn      = $(this);
        var diagnosis = $('#diagnosis').val().trim();
        var valid     = true;

        if (!diagnosis) {
            $('#diagnosis').addClass('is-invalid');
            valid = false;
        }

        var medicines = [];
        $('#medicineBody tr').each(function () {
            var drugID    = $(this).find('.med-drug').val();
            var dosage    = $(this).find('.med-dosage').val().trim();
            var frequency = $(this).find('.med-frequency').val().trim();
            var duration  = $(this).find('.med-duration').val().trim();
            var instr     = $(this).find('.med-instructions').val().trim();

            $(this).find('.med-drug').toggleClass('is-invalid', !drugID);
            $(this).find('.med-dosage').toggleClass('is-invalid', dosage === '');
            $(this).find('.med-frequency').toggleClass('is-invalid', frequency === '');
            $(this).find('.med-duration').toggleClass('is-invalid', duration === '');

            if (!drugID || dosage === '' || frequency === '' || duration === '') valid = false;

            medicines.push({
                drug_id:      drugID,
                dosage:       dosage,
                frequency:    frequency,
                duration:     duration,
                instructions: instr
            });
        });

        if (!valid) {
            showToast('Please fill in all required fields.', 'error');
            return;
        }

        $btn.prop('disabled', true)
            .html('<span class="spinner-border spinner-border-sm me-1"></span> Saving...');

        $.ajax({
            url:      CFC_URL,
            type:     'POST',
            dataType: 'json',
            data: {
                method:        'savePrescription',
                returnformat:  'json',
                appointmentID: APPOINTMENT_ID,
                diagnosis:     diagnosis,
                notes:         $('#notes').val().trim(),
                medicines:     JSON.stringify(medicines)
            },
            success: function (res) {
            if (getVal(res, 'success')) {
                Swal.fire({
                    icon:               'success',
                    title:              'Saved!',
                    text:               'Prescription saved successfully.',
                    confirmButtonColor: '#4f46e5',
                    timer:              1800,
                    timerProgressBar:   true
                }).then(function () {
                    window.location = 'Appointments.cfm';
                });
            } else {
                Swal.fire({
                    icon:               'error',
                    title:              'Failed',
                    text:               getVal(res, 'message') || 'Something went wrong.',
                    confirmButtonColor: '#4f46e5'
                });
                $btn.prop('disabled', false)
                    .html('<i class="bi bi-check-circle me-1"></i> Save Prescription');
            }
        },
        error: function () {
            Swal.fire({
                icon:               'error',
                title:              'Server Error',
                text:               'Something went wrong. Please try again.',
                confirmButtonColor: '#4f46e5'
            });
            $btn.prop('disabled', false)
                .html('<i class="bi bi-check-circle me-1"></i> Save Prescription');
        }
        });
    });

});
</script>
<script>
    const toggleBtn = document.getElementById('sidebarToggle');
    const sidebar = document.querySelector('.sidebar-wrapper');

    toggleBtn.addEventListener('click', () => {
        sidebar.classList.toggle('hide-sidebar');
    });
</script>
