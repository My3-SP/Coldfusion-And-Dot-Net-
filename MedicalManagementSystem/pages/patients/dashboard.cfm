<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="patientSidebar.cfm">


<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 4>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset dashboardService = createObject("component","MedicalManagementSystem.components.PatientDashboardService")>
<cfset userID = session.user.user_id>

<cfset upcomingAppointments  = dashboardService.getUpcomingAppointments(userID)>
<cfset previousAppointments  = dashboardService.getPreviousAppointments(userID)>
<cfset recentPrescriptions   = dashboardService.getRecentPrescriptions(userID)>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    .dashboard-table thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    .dashboard-table tbody tr:hover {
        background-color: #f0f0ff;
    }
    .dashboard-table tbody td {
        font-size: 15px;
        vertical-align: middle;
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
        <h3>Patient Dashboard</h3>
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

    <!--- Stats Cards --->
    <div class="row g-3 mb-4">
        <div class="col-md-4 col-6">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-4">
                    <div class="mb-1 text-muted small">
                        <i class="bi bi-calendar-check me-1"></i>Upcoming Appointments
                    </div>
                    <h3 class="fw-bold text-primary mb-0">#upcomingAppointments.recordCount#</h3>
                </div>
            </div>
        </div>
        <div class="col-md-4 col-6">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-4">
                    <div class="mb-1 text-muted small">
                        <i class="bi bi-calendar2-check me-1"></i>Previous Appointments
                    </div>
                    <h3 class="fw-bold text-success mb-0">#previousAppointments.recordCount#</h3>
                </div>
            </div>
        </div>
        <div class="col-md-4 col-6">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-4">
                    <div class="mb-1 text-muted small">
                        <i class="bi bi-file-medical me-1"></i>Prescriptions
                    </div>
                    <h3 class="fw-bold text-warning mb-0">#recentPrescriptions.recordCount#</h3>
                </div>
            </div>
        </div>
    </div>

    <!--- Upcoming Appointments --->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body fw-semibold">
            <i class="bi bi-calendar-check me-2 text-primary"></i>Upcoming Appointments
        </div>
        <div class="card-body">
            <cfif upcomingAppointments.recordCount EQ 0>
                <p class="text-muted mb-0">No upcoming appointments.</p>
            <cfelse>
                <div class="table-responsive">
                    <table class="table table-hover align-middle dashboard-table">
                        <thead>
                            <tr>
                                <th>Doctor</th>
                                <th>Date &amp; Time</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="upcomingAppointments">
                            <tr>
                                <td>#encodeForHTML(doctor_name)#</td>
                                <td>
                                    #dateFormat(appointment_datetime,"dd-mmm-yyyy")#
                                    <br>
                                    <small class="text-muted">
                                        #timeFormat(appointment_datetime,"hh:mm tt")#
                                    </small>
                                </td>
                                <td>
                                    <cfif status EQ "Booked">
                                        <span class="badge bg-primary">Booked</span>
                                    <cfelseif status EQ "In Progress">
                                        <span class="badge bg-warning text-dark">In Progress</span>
                                    <cfelse>
                                        <span class="badge bg-secondary">#encodeForHTML(status)#</span>
                                    </cfif>
                                </td>
                            </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </cfif>
        </div>
    </div>

    <!--- Previous Appointments --->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body fw-semibold">
            <i class="bi bi-calendar2-check me-2 text-success"></i>Previous Appointments
            <small class="text-muted fw-normal ms-1">(last 3)</small>
        </div>
        <div class="card-body">
            <cfif previousAppointments.recordCount EQ 0>
                <p class="text-muted mb-0">No previous appointments.</p>
            <cfelse>
                <div class="table-responsive">
                    <table class="table table-hover align-middle dashboard-table">
                        <thead>
                            <tr>
                                <th>Doctor</th>
                                <th>Date &amp; Time</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="previousAppointments">
                            <tr>
                                <td>#encodeForHTML(doctor_name)#</td>
                                <td>
                                    #dateFormat(appointment_datetime,"dd-mmm-yyyy")#
                                    <br>
                                    <small class="text-muted">
                                        #timeFormat(appointment_datetime,"hh:mm tt")#
                                    </small>
                                </td>
                                <td>
                                    <cfif status EQ "Completed">
                                        <span class="badge bg-success">Completed</span>
                                    <cfelseif status EQ "Cancelled">
                                        <span class="badge bg-danger">Cancelled</span>
                                    <cfelseif status EQ "In Progress">
                                        <span class="badge bg-warning text-dark">In Progress</span>
                                    <cfelse>
                                        <span class="badge bg-secondary">#encodeForHTML(status)# (No Show)</span>
                                    </cfif>
                                </td>
                            </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </cfif>
        </div>
    </div>

    <!--- Recent Prescriptions --->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body fw-semibold">
            <i class="bi bi-file-medical me-2 text-warning"></i>Recent Prescriptions
            <small class="text-muted fw-normal ms-1">(last 3)</small>
        </div>
        <div class="card-body">
            <cfif recentPrescriptions.recordCount EQ 0>
                <p class="text-muted mb-0">No prescriptions yet.</p>
            <cfelse>
                <div class="table-responsive">
                    <table class="table table-hover align-middle dashboard-table">
                        <thead>
                            <tr>
                                <th>Doctor</th>
                                <th>Date</th>
                                <th>Diagnosis</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="recentPrescriptions">
                            <tr>
                                <td>#encodeForHTML(doctor_name)#</td>
                                <td>#dateFormat(prescription_date,"dd-mmm-yyyy")#</td>
                                <td>#encodeForHTML(diagnosis)#</td>
                            </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </cfif>
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
