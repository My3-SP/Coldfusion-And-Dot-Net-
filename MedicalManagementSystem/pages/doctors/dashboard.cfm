<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="doctorSidebar.cfm">


<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 2>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset doctorService = createObject("component","MedicalManagementSystem.components.doctorDashboardService")>
<cfset doctorID      = doctorService.getDoctorID(session.user.user_id)>

<cfset stats     = doctorService.getDashboardStats(doctorID)>
<cfset todayList = doctorService.getTodayAppointmentsList(doctorID)>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    #todayTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #todayTable tbody tr:hover {
        background-color: #c7d4ff4f;
    }
    #todayTable tbody td {
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
        <h3>Doctor Dashboard</h3>
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

    <!--- Stats Cards --->
    <div class="row g-3 mb-4">
        <div class="col-md-4 col-6">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-4">
                    <div class="mb-1 text-muted small">
                        <i class="bi bi-calendar-check me-1"></i>Today's Appointments
                    </div>
                    <h3 class="fw-bold text-primary mb-0">#stats.todayAppointments#</h3>
                </div>
            </div>
        </div>
        <div class="col-md-4 col-6">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-4">
                    <div class="mb-1 text-muted small">
                        <i class="bi bi-calendar-event me-1"></i>Upcoming Appointments
                    </div>
                    <h3 class="fw-bold text-success mb-0">#stats.upcomingAppointments#</h3>
                </div>
            </div>
        </div>
        <div class="col-md-4 col-6">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-4">
                    <div class="mb-1 text-muted small">
                        <i class="bi bi-people me-1"></i>Total Patients
                    </div>
                    <h3 class="fw-bold text-warning mb-0">#stats.totalPatients#</h3>
                </div>
            </div>
        </div>
    </div>

    <!--- Today's Schedule Table --->
    <div class="card border-0 shadow-sm">
        <div class="card-body fw-semibold">
            <i class="bi bi-clock me-2 text-primary"></i>Today's Schedule
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table id="todayTable" class="table table-bordered table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Patient</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="todayList">
                        <tr>
                            <td>#encodeForHTML(patient_name)#</td>
                            <td>#dateFormat(appointment_datetime,"dd-mmm-yyyy")#</td>
                            <td>#timeFormat(appointment_datetime,"hh:mm tt")#</td>
                            <td>
                                <cfif todayList.status_name EQ "Booked">
                                    <span class="badge bg-primary">Booked</span>
                                <cfelseif todayList.status_name EQ "Cancelled">
                                    <span class="badge bg-danger">Cancelled</span>
                                <cfelseif todayList.status_name EQ "Completed">
                                    <span class="badge bg-success">Completed</span>
                                <cfelse>
                                    <span class="badge bg-warning text-dark">In Progress</span>
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

    $(document).ready(function () {
        $('#todayTable').DataTable({
            pageLength: 5,
            order: [[2, 'asc']],
            columnDefs: [{ orderable: false, targets: [3] }],
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
<<<<<<< HEAD

</script>
=======
});
</script>
>>>>>>> 51a396c4c9b7cacef41c7fd89e382d7c368b3cbe
