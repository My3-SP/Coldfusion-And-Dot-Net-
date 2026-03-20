<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="receptionistSidebar.cfm">

<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 3>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset dashboardService  = createObject("component","MedicalManagementSystem.components.ReceptionistDashboardService")>
<cfset todayCount        = dashboardService.getTodayAppointmentsCount()>
<cfset totalPatients     = dashboardService.getTotalPatientsCount()>
<cfset weeklyPatients    = dashboardService.getWeeklyPatientsCount()>
<!--- <cfset pendingBills      = dashboardService.getPendingBillsCount()> --->
<cfset todayAppointments = dashboardService.getTodayAppointments()>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    #todayAppointmentsTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #todayAppointmentsTable tbody tr:hover {
        background-color: #f0f0ff;
    }
    #todayAppointmentsTable tbody td {
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
        <h3>Receptionist Dashboard</h3>
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

    <!--- Stats Cards --->
    <div class="row g-3 mb-4">
        <div class="col-md-4 col-6">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-4">
                    <div class="mb-1 text-muted small">
                        <i class="bi bi-calendar-check me-1"></i>Today's Appointments
                    </div>
                    <h3 class="fw-bold text-primary mb-0">#todayCount#</h3>
                </div>
            </div>
        </div>
        <div class="col-md-4 col-6">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-4">
                    <div class="mb-1 text-muted small">
                        <i class="bi bi-people me-1"></i>Total Patients
                    </div>
                    <h3 class="fw-bold text-success mb-0">#totalPatients#</h3>
                </div>
            </div>
        </div>
        <div class="col-md-4 col-6">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-4">
                    <div class="mb-1 text-muted small">
                        <i class="bi bi-person-plus me-1"></i>This Week Registrations
                    </div>
                    <h3 class="fw-bold text-warning mb-0">#weeklyPatients#</h3>
                </div>
            </div>
        </div>
    </div>

    <!--- Today's Appointments Table --->
    <div class="card border-0 shadow-sm">
        <div class="card-body fw-semibold">
            <i class="bi bi-calendar3 me-2 text-primary"></i>Today's Appointments
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table id="todayAppointmentsTable"
                       class="table table-bordered table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Patient</th>
                            <th>Doctor</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="todayAppointments">
                        <tr>
                            <td>#encodeForHTML(patient_name)#</td>
                            <td>#encodeForHTML(doctor_name)#</td>
                            <td>#dateFormat(appointment_datetime,"dd-mmm-yyyy")#</td>
                            <td>#timeFormat(appointment_datetime,"hh:mm tt")#</td>
                            <td>
                                <cfif status_name EQ "Booked">
                                    <span class="badge bg-primary">Booked</span>
                                <cfelseif status_name EQ "Completed">
                                    <span class="badge bg-success">Completed</span>
                                <cfelseif status_name EQ "Cancelled">
                                    <span class="badge bg-danger">Cancelled</span>
                                <cfelseif status_name EQ "In Progress">
                                    <span class="badge bg-warning text-dark">In Progress</span>
                                <cfelse>
                                    <span class="badge bg-secondary">
                                        #encodeForHTML(status_name)#
                                    </span>
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
    $('#todayAppointmentsTable').DataTable({
        pageLength: 5,
        order:      [[3, 'asc']],
        columnDefs: [{ orderable: false, targets: [4] }],
        language: {
            emptyTable: 'No appointments scheduled for today.',
            search:     '<i class="bi bi-search me-1"></i>Search:',
            lengthMenu: 'Show _MENU_ entries',
            info:       'Showing _START_ to _END_ of _TOTAL_ appointments',
            paginate: {
                previous: '&lsaquo;',
                next:     '&rsaquo;'
            }
        }
    });
});

</script>
