<!--- PDF download --->
<cfif structKeyExists(url,"download") AND url.download EQ "1" AND structKeyExists(url,"prescriptionID")>
    <cfset prescService = createObject("component","MedicalManagementSystem.components.PatientPrescriptionService")>
    <cftry>
        <cfset prescService.generatePrescriptionPDF(
            enc_prescription_id = url.prescriptionID,
            userID              = session.user.user_id
        )>
    <cfcatch type="any">
        <cflocation url="prescriptions.cfm" addtoken="no">
    </cfcatch>
    </cftry>
    <cfabort>
</cfif>

<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="patientSidebar.cfm">

<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 4>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset prescService  = createObject("component","MedicalManagementSystem.components.PatientPrescriptionService")>
<cfset secureService = createObject("component","MedicalManagementSystem.components.SecurityService")>
<cfset prescriptions = prescService.getPatientPrescriptions(session.user.user_id)>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    #prescriptionsTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #prescriptionsTable tbody tr:hover {
        background-color: #c7d4ff4f;
    }
    #prescriptionsTable tbody td {
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
    <cfoutput>
    <div class="page-heading d-flex justify-content-between align-items-center mb-3">
        <h3>My Prescriptions</h3>
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

    <div class="card border-0 shadow-sm mt-3">
        <div class="card-body fw-semibold">
            <i class="bi bi-file-medical me-2 text-primary"></i>Prescriptions List
        </div>
        <div class="card-body">
            <cfif prescriptions.recordCount EQ 0>
                <p class="text-muted mb-0">No prescriptions found.</p>
            <cfelse>
                <div class="table-responsive">
                    <table id="prescriptionsTable" class="table table-bordered table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Sl No</th>
                                <th>Appointment Date</th>
                                <th>Doctor</th>
                                <th>Department</th>
                                <th>Diagnosis</th>
                                <th>Prescription Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfset counter = 0>
                            <cfloop query="prescriptions">
                                <cfset counter++>
                                <cfset encPrescID = secureService.encryptID(prescription_id)>
                                <tr>
                                    <td>#counter#</td>
                                    <td>
                                        #dateFormat(appointment_datetime,"dd-mmm-yyyy")#<br>
                                        <small class="text-muted">
                                            #timeFormat(appointment_datetime,"hh:mm tt")#
                                        </small>
                                    </td>
                                    <td>#encodeForHTML(doctor_name)#</td>
                                    <td>#encodeForHTML(dept_name)#</td>
                                    <td>#encodeForHTML(diagnosis)#</td>
                                    <td>#dateFormat(prescription_date,"dd-mmm-yyyy")#</td>
                                    <td>
                                        <button class="btn btn-sm btn-primary btn-view-prescription"
                                                data-id="#encPrescID#">
                                            <i class="bi bi-eye me-1"></i> View
                                        </button>
                                    </td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            </cfif>
        </div>
    </div>

    <!--- View Modal --->
    <div class="modal fade" id="prescriptionModal" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-file-medical me-2"></i>Prescription Details
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="modalBody">
                    <div class="text-center py-4">
                        <div class="spinner-border text-primary"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <a href="##" id="modalDownloadBtn" class="btn btn-success">
                        <i class="bi bi-download me-1"></i> Download PDF
                    </a>
                    <button type="button" class="btn btn-secondary"
                            data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

</div>

</cfoutput>

<cfinclude template="../../includes/footer.cfm">

<script>
$(document).ready(function () {

    //  DataTable 
    $('#prescriptionsTable').DataTable({
        pageLength: 5,
        order:      [[1, 'desc']],
        columnDefs: [{ orderable: false, targets: [6] }],
        language: {
            search:       '<i class="bi bi-search me-1"></i>Search:',
            lengthMenu:   'Show _MENU_ entries',
            info:         'Showing _START_ to _END_ of _TOTAL_ prescriptions',
            emptyTable:   'No prescriptions found.',
            paginate: {
                previous: '&lsaquo;',
                next:     '&rsaquo;'
            }
        }
    });

    function getVal(obj, key) {
        return obj[key] !== undefined ? obj[key] : obj[key.toUpperCase()];
    }

    // View prescription via AJAX 
    $(document).on('click', '.btn-view-prescription', function () {
        var encID = $(this).data('id');

        $('#modalBody').html(
            '<div class="text-center py-4">'
            + '<div class="spinner-border text-primary"></div></div>'
        );
        $('#modalDownloadBtn').attr(
            'href',
            'prescriptions.cfm?download=1&prescriptionID=' + encID
        );
        $('#prescriptionModal').modal('show');

        $.ajax({
            url:      '/MedicalManagementSystem/components/PatientPrescriptionService.cfc?method=getPrescriptionDetailRemote&returnformat=json',
            type:     'POST',
            dataType: 'json',
            data: {
                enc_prescription_id: encID
            },
            success: function (res) {
                var success = getVal(res, 'success');
                var message = getVal(res, 'message');
                var data    = getVal(res, 'data');

                if (!success) {
                    $('#prescriptionModal').modal('hide');
                    Swal.fire({
                        icon:               'error',
                        title:              'Failed',
                        text:               message || 'Could not load prescription.',
                        confirmButtonColor: '#4f46e5'
                    });
                    return;
                }

                var meds = getVal(data, 'medicines') || [];
                var html = '';

                html += '<div class="row mb-3">';
                html += '<div class="col-md-6 mb-2"><span class="text-muted small">Doctor</span>'
                      + '<p class="fw-bold mb-0">' + getVal(data,'doctor_name') + '</p></div>';
                html += '<div class="col-md-6 mb-2"><span class="text-muted small">Department</span>'
                      + '<p class="fw-bold mb-0">' + getVal(data,'dept_name') + '</p></div>';
                html += '<div class="col-md-6 mb-2"><span class="text-muted small">Appointment</span>'
                      + '<p class="fw-bold mb-0">'
                      + getVal(data,'appointment_date') + ' &nbsp; '
                      + getVal(data,'appointment_time') + '</p></div>';
                html += '<div class="col-md-6 mb-2"><span class="text-muted small">Prescription Date</span>'
                      + '<p class="fw-bold mb-0">' + getVal(data,'prescription_date') + '</p></div>';
                html += '<div class="col-12 mb-2"><span class="text-muted small">Diagnosis</span>'
                      + '<p class="fw-bold mb-0">' + getVal(data,'diagnosis') + '</p></div>';

                var notes = getVal(data,'notes') || '';
                if (notes.trim() !== '') {
                    html += '<div class="col-12"><span class="text-muted small">Notes</span>'
                          + '<p class="mb-0">' + notes + '</p></div>';
                }
                html += '</div>';

                html += '<h6 class="fw-bold mb-2">Medicines Prescribed</h6>';
                if (meds.length > 0) {
                    html += '<div class="table-responsive">'
                          + '<table class="table table-sm table-bordered align-middle">'
                          + '<thead class="table-light"><tr>'
                          + '<th>#</th><th>Drug</th><th>Dosage</th>'
                          + '<th>Frequency</th><th>Duration</th><th>Instructions</th>'
                          + '</tr></thead><tbody>';

                    $.each(meds, function (i, med) {
                        var name  = getVal(med,'drug_name')    || '';
                        var str   = getVal(med,'strength')     || '';
                        var dos   = getVal(med,'dosage')       || '';
                        var freq  = getVal(med,'frequency')    || '';
                        var dur   = getVal(med,'duration')     || '';
                        var instr = getVal(med,'instructions') || '—';

                        html += '<tr>'
                              + '<td>' + (i + 1) + '</td>'
                              + '<td>' + name + (str
                                    ? '<br><small class="text-muted">' + str + '</small>'
                                    : '') + '</td>'
                              + '<td>' + dos  + '</td>'
                              + '<td>' + freq + '</td>'
                              + '<td>' + dur  + '</td>'
                              + '<td>' + (instr || '—') + '</td>'
                              + '</tr>';
                    });

                    html += '</tbody></table></div>';
                } else {
                    html += '<p class="text-muted">No medicines recorded.</p>';
                }

                $('#modalBody').html(html);
            },
            error: function (xhr) {
                console.log('STATUS:', xhr.status);
                console.log('RESPONSE:', xhr.responseText);
                $('#prescriptionModal').modal('hide');
                Swal.fire({
                    icon:               'error',
                    title:              'Server Error',
                    text:               'Failed to load prescription. Please try again.',
                    confirmButtonColor: '#4f46e5'
                });
            }
        });
    });

});
</script>