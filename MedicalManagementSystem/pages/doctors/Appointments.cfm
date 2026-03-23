<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="doctorSidebar.cfm">

<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 2>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset doctorService      = createObject("component","MedicalManagementSystem.components.doctorDashboardService")>
<cfset appointmentService = createObject("component","MedicalManagementSystem.components.doctorDashboardService")>
<cfset secureService      = createObject("component","MedicalManagementSystem.components.SecurityService")>

<cfset doctorID     = doctorService.getDoctorID(session.user.user_id)>
<cfset appointments = appointmentService.getAppointments(doctorID)>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    #appointmentsTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #appointmentsTable tbody tr:hover {
        background-color: #c7d4ff4f;
    }
    #appointmentsTable tbody td {
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
        <h3>My Appointments</h3>
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

    <div class="card border-0 shadow-sm">
        <div class="card-body fw-semibold">
            <span class="fw-semibold">
                <i class="bi bi-calendar3 me-2 text-primary"></i>Appointments List
            </span>
            <select id="statusFilter" class="form-select form-select-sm w-auto">
                <option value="">All Statuses</option>
                <option value="Booked">Booked</option>
                <option value="In Progress">In Progress</option>
                <option value="Completed">Completed</option>
            </select>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table id="appointmentsTable" class="table table-bordered table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Patient</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Status</th>
                            <th width="260">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="appointments">
                        <tr>
                            <td>#encodeForHTML(patient_name)#</td>
                            <td>#dateFormat(appointment_datetime,"dd-mmm-yyyy")#</td>
                            <td>#timeFormat(appointment_datetime,"hh:mm tt")#</td>
                            <td>
                                <cfif status_name EQ "Booked">
                                    <span class="badge bg-primary">Booked</span>
                                <cfelseif status_name EQ "Completed">
                                    <span class="badge bg-success">Completed</span>
                                <cfelseif status_name EQ "In Progress">
                                    <span class="badge bg-warning text-dark">In Progress</span>
                                <cfelse>
                                    <span class="badge bg-secondary">#encodeForHTML(status_name)#</span>
                                </cfif>
                            </td>
                            <td>
                                <cfset encryptedID = secureService.encryptID(appointment_id)>

                                <cfif status_name EQ "Booked">
                                    <button class="btn btn-sm btn-primary startConsultBtn"
                                            data-id="#encryptedID#">
                                        <i class="bi bi-play-circle me-1"></i>Start
                                    </button>
                                    <button class="btn btn-sm btn-danger deleteBtn"
                                            data-id="#encryptedID#">
                                        <i class="bi bi-trash me-1"></i>Delete
                                    </button>
                                </cfif>

                                <cfif status_name EQ "In Progress">
                                    <a href="prescriptions.cfm?appointmentID=#urlEncodedFormat(encryptedID)#"
                                       class="btn btn-sm btn-warning">
                                        <i class="bi bi-file-medical me-1"></i>Write Rx
                                    </a>
                                    <button class="btn btn-sm btn-success completeBtn"
                                            data-id="#encryptedID#">
                                        <i class="bi bi-check-circle me-1"></i>Complete
                                    </button>
                                </cfif>

                                <cfif status_name EQ "Completed">
                                    <a href="viewPrescription.cfm?appointmentID=#urlEncodedFormat(encryptedID)#"
                                       class="btn btn-sm btn-info">
                                        <i class="bi bi-eye me-1"></i>View
                                    </a>
                                    <a href="editPrescription.cfm?appointmentID=#urlEncodedFormat(encryptedID)#"
                                       class="btn btn-sm btn-primary">
                                        <i class="bi bi-pencil me-1"></i>Edit
                                    </a>
                                </cfif>
                            </td>
                        </tr>
                        </cfoutput>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    </cfoutput>
</div>

<cfinclude template="../../includes/footer.cfm">

<script>
$(document).ready(function () {

    //  DataTable
    var table = $('#appointmentsTable').DataTable({
        pageLength: 5,
        order: [[1, 'asc'], [2, 'asc']],
        columnDefs: [{ orderable: false, targets: [4] }],
        language: {
            emptyTable: 'No appointments found.',
            search:     '<i class="bi bi-search me-1"></i>Search:',
            lengthMenu: 'Show _MENU_ entries',
            info:       'Showing _START_ to _END_ of _TOTAL_ appointments',
            paginate: {
                previous: '&lsaquo;',
                next:     '&rsaquo;'
            }
        }
    });

    //  Status filter 
    $('#statusFilter').on('change', function () {
        table.column(3).search(this.value).draw();
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

    //  Start Consultation 
    $(document).on('click', '.startConsultBtn', function () {
        var $btn          = $(this);
        var appointmentID = $btn.data('id');
        var row           = $btn.closest('tr');

        Swal.fire({
            title:              'Start Consultation?',
            text:               'This will move the appointment to In Progress.',
            icon:               'question',
            showCancelButton:   true,
            confirmButtonColor: '#4f46e5',
            cancelButtonColor:  '#6c757d',
            confirmButtonText:  'Yes, start',
            cancelButtonText:   'Cancel'
        }).then(function (result) {
            if (!result.isConfirmed) return;

            $.ajax({
                url:    '/MedicalManagementSystem/components/doctorDashboardService.cfc'
                      + '?method=startConsultation&returnformat=json',
                method: 'POST',
                data:   { appointmentID: appointmentID },
                success: function (res) {
                    if (res.SUCCESS || res.success) {
                        location.reload();
                    } else {
                        swAlert('error', 'Failed', res.MESSAGE || res.message || 'Something went wrong.');
                    }
                },
                error: function () {
                    swAlert('error', 'Server Error', 'Please try again.');
                }
            });
        });
    });

    //  Complete Appointment 
    $(document).on('click', '.completeBtn', function () {
        var $btn          = $(this);
        var appointmentID = $btn.data('id');
        var row           = $btn.closest('tr');

        Swal.fire({
            title:              'Complete Appointment?',
            text:               'Mark this appointment as completed.',
            icon:               'question',
            showCancelButton:   true,
            confirmButtonColor: '#198754',
            cancelButtonColor:  '#6c757d',
            confirmButtonText:  'Yes, complete',
            cancelButtonText:   'Cancel'
        }).then(function (result) {
            if (!result.isConfirmed) return;

            $.ajax({
                url:    '/MedicalManagementSystem/components/doctorDashboardService.cfc'
                      + '?method=completeAppointment&returnformat=json',
                method: 'POST',
                data:   { appointmentID: appointmentID },
                success: function (res) {
                    if (res.SUCCESS || res.success) {
                        row.find('td:eq(3)').html(
                            '<span class="badge bg-success">Completed</span>'
                        );
                        row.find('td:eq(4)').html(
                            '<a href="viewPrescription.cfm?appointmentID='
                            + encodeURIComponent(appointmentID)
                            + '" class="btn btn-sm btn-info"><i class="bi bi-eye me-1"></i>View</a> '
                            + '<a href="editPrescription.cfm?appointmentID='
                            + encodeURIComponent(appointmentID)
                            + '" class="btn btn-sm btn-primary"><i class="bi bi-pencil me-1"></i>Edit</a>'
                        );
                        swAlert('success', 'Done!', 'Appointment marked as completed.');
                    } else {
                        swAlert('error', 'Failed', res.MESSAGE || res.message || 'Something went wrong.');
                    }
                },
                error: function () {
                    swAlert('error', 'Server Error', 'Please try again.');
                }
            });
        });
    });

    //  Delete Appointment 
    $(document).on('click', '.deleteBtn', function () {
        var $btn          = $(this);
        var appointmentID = $btn.data('id');
        var row           = $btn.closest('tr');

        Swal.fire({
            title:              'Delete Appointment?',
            text:               'This action cannot be undone.',
            icon:               'warning',
            showCancelButton:   true,
            confirmButtonColor: '#dc3545',
            cancelButtonColor:  '#6c757d',
            confirmButtonText:  'Yes, delete',
            cancelButtonText:   'Cancel'
        }).then(function (result) {
            if (!result.isConfirmed) return;

            $.ajax({
                url:    '/MedicalManagementSystem/components/doctorDashboardService.cfc'
                      + '?method=deleteAppointment&returnformat=json',
                method: 'POST',
                data:   { appointmentID: appointmentID },
                success: function (res) {
                    if (res.SUCCESS || res.success) {
                        table.row(row).remove().draw();
                        swAlert('success', 'Deleted!', 'Appointment has been removed.');
                    } else {
                        swAlert('error', 'Failed', res.MESSAGE || res.message || 'Something went wrong.');
                    }
                },
                error: function () {
                    swAlert('error', 'Server Error', 'Please try again.');
                }
            });
        });
    });

});

</script>