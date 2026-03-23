<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="doctorSidebar.cfm">


<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 2>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset patientService  = createObject("component","MedicalManagementSystem.components.doctorDashboardService")>
<cfset securityService = createObject("component","MedicalManagementSystem.components.securityService")>

<cfquery name="qDoctor" datasource="mms_db">
    SELECT doctor_id
    FROM DOCTORS
    WHERE user_id = <cfqueryparam value="#session.user.user_id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif qDoctor.recordCount EQ 0>
    <div class="alert alert-danger">Doctor profile not found.</div>
    <cfabort>
</cfif>

<cfset doctorID = val(qDoctor.doctor_id)>
<cfset patients = patientService.getTreatedPatients(doctorID)>

<!--- SweetAlert2 --->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>

<style>
    #patientsTable thead th,
    #historyTable thead th {
        background-color: #7070db;
        color: #fff;
        font-weight: 600;
        font-size: 15px;
        letter-spacing: .4px;
        border-color: #9b96cf;
        white-space: nowrap;
    }
    #patientsTable tbody tr:hover,
    #historyTable tbody tr:hover {
        background-color: #c7d4ff4f;
    }
    #patientsTable tbody td,
    #historyTable tbody td {
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

    <div class="page-heading d-flex justify-content-between align-items-center mb-3">
        <h3>My Patients</h3>
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

    <!--- Patients Table --->
    <cfif patients.recordCount EQ 0>
        <div class="alert alert-info">No treated patients found.</div>
    <cfelse>
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body fw-semibold">
                <i class="bi bi-people me-2 text-primary"></i>Treated Patients
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table id="patientsTable" class="table table-bordered table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Patient Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Gender</th>
                                <th>Blood Group</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="patients">
                            <cfset encryptedID = securityService.encryptID(patient_id)>
                            <tr>
                                <td>#encodeForHTML(full_name)#</td>
                                <td>#encodeForHTML(email)#</td>
                                <td>#encodeForHTML(phone)#</td>
                                <td>#encodeForHTML(gender)#</td>
                                <td>#encodeForHTML(blood_group)#</td>
                                <td>
                                    <a href="viewPatientHistory.cfm?patientID=#encryptedID#"
                                       class="btn btn-sm btn-primary">
                                        <i class="bi bi-clock-history me-1"></i>View History
                                    </a>
                                </td>
                            </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </cfif>

    <!--- Patient History (when patientID is in URL) --->
    <cfif structKeyExists(url,"patientID")>
        <cftry>
            <cfset decryptedPatientID = securityService.decryptID(url.patientID)>

            <cfif decryptedPatientID LTE 0>
                <div class="alert alert-danger">Invalid Patient ID.</div>
                <cfabort>
            </cfif>

            <cfset history = patientService.getPatientHistory(doctorID, decryptedPatientID)>

            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white fw-semibold border-bottom">
                    <i class="bi bi-clock-history me-2 text-primary"></i>Patient Medical History
                </div>
                <div class="card-body">
                    <cfif history.recordCount EQ 0>
                        <p class="text-muted mb-0">No history found for this patient.</p>
                    <cfelse>
                        <div class="table-responsive">
                            <table id="historyTable" class="table table-bordered table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>Appointment Date</th>
                                        <th>Diagnosis</th>
                                        <th>Notes</th>
                                        <th>Prescription Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfoutput query="history">
                                    <tr>
                                        <td>#dateFormat(appointment_datetime,"dd-mmm-yyyy")#</td>
                                        <td>#encodeForHTML(diagnosis)#</td>
                                        <td>#len(trim(notes)) ? encodeForHTML(notes) : "—"#</td>
                                        <td>#dateFormat(prescription_date,"dd-mmm-yyyy")#</td>
                                    </tr>
                                    </cfoutput>
                                </tbody>
                            </table>
                        </div>
                    </cfif>
                </div>
            </div>

        <cfcatch type="any">
            <div class="alert alert-danger">Invalid or tampered Patient ID.</div>
        </cfcatch>
        </cftry>
    </cfif>

</div>

<cfinclude template="../../includes/footer.cfm">

<script>
$(document).ready(function () {

    var dtLanguage = {
        search:       '<i class="bi bi-search me-1"></i>Search:',
        lengthMenu:   'Show _MENU_ entries',
        info:         'Showing _START_ to _END_ of _TOTAL_ records',
        emptyTable:   'No records found.',
        paginate: {
            previous: '&lsaquo;',
            next:     '&rsaquo;'
        }
    };

    if ($('#patientsTable').length) {
        $('#patientsTable').DataTable({
            pageLength: 5,
            language:   dtLanguage,
            columnDefs: [{ orderable: false, targets: [5] }]
        });
    }

    if ($('#historyTable').length) {
        $('#historyTable').DataTable({
            pageLength: 5,
            language:   dtLanguage,
            order:      [[0, 'desc']]
        });
    }

});
<<<<<<< HEAD

</script>
=======
</script>
>>>>>>> 51a396c4c9b7cacef41c7fd89e382d7c368b3cbe
