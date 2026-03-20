<cfinclude template="../../includes/sessionCheck.cfm">
<cfinclude template="../../includes/header.cfm">
<cfinclude template="doctorSidebar.cfm">


<cfif  NOT structKeyExists(session,"user") OR session.user.role_id NEQ 2>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>

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

<cfset appointment  = prescriptionService.getAppointmentDetails(appointmentID)>
<cfset prescription = prescriptionService.getPrescriptionByAppointment(appointmentID)>

<cfif appointment.recordCount EQ 0 OR prescription.recordCount EQ 0>
    <cflocation url="Appointments.cfm" addtoken="no">
</cfif>

<cfset items = prescriptionService.getPrescriptionItems(prescription.prescription_id)>


<div id="main">
    <header class="mb-3">
        <a href="#" class="burger-btn d-block d-xl-none">
            <i class="bi bi-justify fs-3"></i>
        </a>
    </header>
<cfoutput>
    <div class="page-heading d-flex justify-content-between align-items-center mb-3">
        <h3>Prescription &mdash; #encodeForHTML(appointment.patient_name)#</h3>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item">
                    <a href="/MedicalManagementSystem/pages/doctors/doctor_Account.cfm">
                        <i class="bi bi-person me-2"></i>My Account
                    </a>
                </li>
                <li class="breadcrumb-item">
                    <a href="Appointments.cfm">My Appointments</a>
                </li>
                <li class="breadcrumb-item">
                    <a href="/MedicalManagementSystem/pages/logout.cfm" class="text-danger">
                        <i class="bi bi-box-arrow-right me-2"></i>Logout
                    </a>
                </li>
            </ol>
        </nav>
    </div>

    <p class="text-muted mb-4">
        <i class="bi bi-calendar me-1"></i>#dateFormat(appointment.appointment_datetime,"dd-mmm-yyyy")#
        &nbsp;|&nbsp;
        <i class="bi bi-clock me-1"></i>#timeFormat(appointment.appointment_datetime,"hh:mm tt")#
    </p>

    <div class="card border-0 shadow-sm p-4 mb-4">

        <div class="row mb-3">
            <div class="col-md-6 mb-3">
                <label class="fw-bold text-muted small">Diagnosis</label>
                <p class="border rounded p-2 bg-light mb-0">#encodeForHTML(prescription.diagnosis)#</p>
            </div>
            <div class="col-md-6 mb-3">
                <label class="fw-bold text-muted small">Notes</label>
                <p class="border rounded p-2 bg-light mb-0">
                    #len(trim(prescription.notes)) ? encodeForHTML(prescription.notes) : "—"#
                </p>
            </div>
        </div>

        <h5 class="mb-3">Medicines Prescribed</h5>

        <cfif items.recordCount GT 0>
            <div class="table-responsive">
                <table class="table table-bordered align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>##</th>
                            <th>Drug</th>
                            <th>Dosage</th>
                            <th>Frequency</th>
                            <th>Duration</th>
                            <th>Instructions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfset counter = 0>
                        <cfloop query="items">
                            <cfset counter++>
                            <tr>
                                <td>#counter#</td>
                                <td>
                                    #encodeForHTML(drug_name)#
                                    <cfif len(trim(strength))>
                                        <br><small class="text-muted">#encodeForHTML(strength)#</small>
                                    </cfif>
                                </td>
                                <td>#encodeForHTML(dosage)#</td>
                                <td>#encodeForHTML(frequency)#</td>
                                <td>#encodeForHTML(duration)#</td>
                                <td>#len(trim(instructions)) ? encodeForHTML(instructions) : "—"#</td>
                            </tr>
                        </cfloop>
                    </tbody>
                </table>
            </div>
        <cfelse>
            <p class="text-muted">No medicines recorded.</p>
        </cfif>

        <div class="mt-3 d-flex gap-2">
            <a href="editPrescription.cfm?appointmentID=#urlEncodedFormat(url.appointmentID)#"
               class="btn btn-primary">
                <i class="bi bi-pencil me-1"></i> Edit Prescription
            </a>
            <a href="Appointments.cfm" class="btn btn-secondary">
                <i class="bi bi-arrow-left me-1"></i> Back
            </a>
        </div>

    </div>
</div>
</cfoutput>
<cfinclude template="../../includes/footer.cfm">
