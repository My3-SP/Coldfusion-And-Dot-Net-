<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="doctorSidebar.cfm">

<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 2>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

<cfset doctorService  = createObject("component","MedicalManagementSystem.components.doctorDashboardService")>
<cfset historyService = createObject("component","MedicalManagementSystem.components.PatientHistoryService")>
<cfset secureService  = createObject("component","MedicalManagementSystem.components.SecurityService")>

<cfif NOT structKeyExists(url,"patientID")>
    <cflocation url="patient_history.cfm" addtoken="no">
</cfif>

<cftry>
    <cfset patientID = secureService.decryptID(url.patientID)>
<cfcatch>
    <cflocation url="patient_history.cfm" addtoken="no">
</cfcatch>
</cftry>

<cfset doctorID     = doctorService.getDoctorID(session.user.user_id)>
<cfset patient      = historyService.getPatientDetails(patientID)>
<cfset interactions = historyService.getPatientInteractions(doctorID, patientID)>

<cfif patient.recordCount EQ 0>
    <cflocation url="patient_history.cfm" addtoken="no">
</cfif>


<div id="main">
<header class="mb-3">
        <a href="#" class="burger-btn d-block d-xl-none">
            <i class="bi bi-justify fs-3"></i>
        </a>
    </header>
    <div class="page-heading d-flex justify-content-between align-items-center">
        <h2>Doctor Dashboard</h2>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item">
                    <a href="/MedicalManagementSystem/pages/doctors/doctor_Account.cfm">
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
    <div class="page-heading d-flex justify-content-between align-items-center mb-3">
        <h3>Patient History &mdash; #encodeForHTML(patient.full_name)#</h3>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item">
                    <a href="patient_history.cfm">Patient History</a>
                </li>
            </ol>
        </nav>
    </div>

    <!--- Patient Details Card --->
    <div class="card p-4 shadow-sm mb-4">
        <h5 class="mb-3"><i class="bi bi-person-circle me-2"></i>Patient Details</h5>
        <div class="row">
            <div class="col-md-3 mb-3">
                <label class="text-muted small">Full Name</label>
                <p class="fw-bold mb-0">#encodeForHTML(patient.full_name)#</p>
            </div>
            <div class="col-md-3 mb-3">
                <label class="text-muted small">Email</label>
                <p class="fw-bold mb-0">#encodeForHTML(patient.email)#</p>
            </div>
            <div class="col-md-3 mb-3">
                <label class="text-muted small">Phone</label>
                <p class="fw-bold mb-0">#encodeForHTML(patient.phone)#</p>
            </div>
            <div class="col-md-3 mb-3">
                <label class="text-muted small">Date of Birth</label>
                <p class="fw-bold mb-0">
                    #len(trim(patient.date_of_birth)) ? dateFormat(patient.date_of_birth,"dd-mmm-yyyy") : "--"#
                </p>
            </div>
            <div class="col-md-3 mb-3">
                <label class="text-muted small">Gender</label>
                <p class="fw-bold mb-0">#encodeForHTML(patient.gender)#</p>
            </div>
            <div class="col-md-3 mb-3">
                <label class="text-muted small">Blood Group</label>
                <p class="fw-bold mb-0">#encodeForHTML(patient.blood_group)#</p>
            </div>
        </div>
    </div>
    <!--- Interactions --->
    <div class="card p-4 shadow-sm">
        <h5 class="mb-3"><i class="bi bi-clock-history me-2"></i>Appointment History</h5>
        <cfif interactions.recordCount EQ 0>
    <p class="text-muted">No interactions found.</p>
<cfelse>
    <cfset counter = 0>
    <cfloop query="interactions">
        <cfset counter++>
        <div class="card mb-3 shadow-sm">
            <!-- Card Header -->
            <div class="card-header d-flex justify-content-between align-items-center">
                <div>
                    <strong> #counter#</strong>
                    <i class="bi bi-calendar ms-2"></i>
                    #dateFormat(appointment_datetime,"dd-mmm-yyyy")#
                    <i class="bi bi-clock ms-2"></i>
                    #timeFormat(appointment_datetime,"hh:mm tt")#
                    <span class="badge bg-success ms-3">
                        Completed
                    </span>
                </div>
                <!-- Mazer Dropdown Toggle -->
                <button class="btn btn-sm btn-primary toggleHistory"
                        data-target="history#appointment_id#">
                    View Details
                </button>
            </div>
            <!-- Hidden Body -->
            <div class="card-body historyBody"
                 id="history#appointment_id#"
                 style="display:none;">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="text-muted small fw-bold">Diagnosis</label>
                        <p>
                            #len(trim(diagnosis)) ? encodeForHTML(diagnosis) : "<span class='text-muted'>—</span>"#
                        </p>
                    </div>
                    <div class="col-md-6">
                        <label class="text-muted small fw-bold">Notes</label>
                        <p>
                            #len(trim(notes)) ? encodeForHTML(notes) : "<span class='text-muted'>—</span>"#
                        </p>
                    </div>
                </div>
                <label class="text-muted small fw-bold">Medicines</label>
                <cfif len(trim(drug_names))>
                    <cfset dList_names = listToArray(drug_names,"|")>
                    <cfset dList_dosage = listToArray(dosages,"|")>
                    <cfset dList_freq = listToArray(frequencies,"|")>
                    <cfset dList_dur = listToArray(durations,"|")>
                    <cfset dList_instr = listToArray(instrList,"|")>
                    <div class="table-responsive mt-2">
                        <table class="table table-sm table-bordered">
                            <thead class="table-light">
                                <tr>
                                    <th>SL NO</th>
                                    <th>Drug</th>
                                    <th>Dosage</th>
                                    <th>Frequency</th>
                                    <th>Duration</th>
                                    <th>Instructions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop from="1" to="#arrayLen(dList_names)#" index="mi">
                                    <tr>
                                        <td>#mi#</td>
                                        <td>#encodeForHTML(dList_names[mi])#</td>
                                        <td>
                                        #encodeForHTML(arrayLen(dList_dosage) GTE mi ? dList_dosage[mi] : "—")#
                                        </td>
                                        <td>
                                        #encodeForHTML(arrayLen(dList_freq) GTE mi ? dList_freq[mi] : "—")#
                                        </td>
                                        <td>
                                        #encodeForHTML(arrayLen(dList_dur) GTE mi ? dList_dur[mi] : "—")#
                                        </td>
                                        <td>
                                        #(arrayLen(dList_instr) GTE mi AND len(trim(dList_instr[mi])))
                                        ? encodeForHTML(dList_instr[mi])
                                        : "--"#
                                        </td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                    </div>
                <cfelse>
                    <p class="text-muted mt-1">No medicines recorded.</p>
                </cfif>
            </div>
        </div>
    </cfloop>
</cfif>
        <div class="mt-3">
            <a href="patient_history.cfm" class="btn btn-secondary">
                <i class="bi bi-arrow-left me-1"></i> Back
            </a>
        </div>
    </div>
</div>
</cfoutput>

<cfinclude template="../../includes/footer.cfm">

<script>
    $(document).on("click",".toggleHistory",function(){
        let target = $(this).data("target");
        $("#" + target).slideToggle(200);
    });
</script>
