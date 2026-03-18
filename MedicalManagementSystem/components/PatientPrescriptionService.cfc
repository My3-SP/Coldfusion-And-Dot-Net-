<cfcomponent displayname="PatientPrescriptionService" output="false">

    <!--- patient id  --->
    <cffunction name="getPatientID" access="private" returntype="numeric" output="false">
        <cfargument name="userID" type="numeric" required="true">
        <cfquery name="q" datasource="mms_db">
            SELECT patient_id FROM PATIENTS
            WHERE user_id = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn q.recordCount GT 0 ? q.patient_id : 0>
    </cffunction>


    <!--- get all prescriptions --->
    <cffunction name="getPatientPrescriptions" access="public" returntype="query" output="false">
        <cfargument name="userID" type="numeric" required="true">

        <cfset var patientID = getPatientID(arguments.userID)>

        <cfquery name="q" datasource="mms_db">
            SELECT
                pr.prescription_id,
                pr.diagnosis,
                pr.prescription_date,
                a.appointment_datetime,
                u.full_name AS doctor_name,
                dept.dept_name
            FROM  PRESCRIPTIONS pr
            JOIN  APPOINTMENTS  a    ON pr.appointment_id = a.appointment_id
            JOIN  DOCTORS       d    ON pr.doctor_id      = d.doctor_id
            JOIN  USERS         u    ON d.user_id         = u.user_id
            JOIN  DEPARTMENTS   dept ON d.dept_id         = dept.dept_id
            WHERE a.patient_id =
                <cfqueryparam value="#patientID#" cfsqltype="cf_sql_integer">
            ORDER BY a.appointment_datetime DESC
        </cfquery>

        <cfreturn q>
    </cffunction>

    <!--- get patient details --->
    <cffunction name="getPatientDetails" access="private" returntype="query" output="false">
        <cfargument name="patientID" type="numeric" required="true">
        <cfquery name="q" datasource="mms_db">
            SELECT
                u.full_name,
                p.gender,
                p.date_of_birth
            FROM  PATIENTS p
            JOIN  USERS    u ON p.user_id = u.user_id
            WHERE p.patient_id = <cfqueryparam value="#arguments.patientID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn q>
    </cffunction>

    <!--- Format age : days < 30, months < 12, years >= 1 --->
    <cffunction name="formatAge" access="private" returntype="string" output="false">
        <cfargument name="dob" type="date" required="true">

        <cfset var today      = now()>
        <cfset var totalDays  = dateDiff("d", arguments.dob, today)>
        <cfset var years      = dateDiff("yyyy", arguments.dob, today)>
        <cfset var months     = dateDiff("m",    arguments.dob, today)>

        <!--- Adjust years if birthday hasn't occurred yet this year --->
        <cfif dateAdd("yyyy", years, arguments.dob) GT today>
            <cfset years = years - 1>
        </cfif>

        <!--- Adjust months if day hasn't occurred yet this month --->
        <cfif dateAdd("m", months, arguments.dob) GT today>
            <cfset months = months - 1>
        </cfif>

        <cfif years GTE 1>
            <cfreturn years & " yr" & (years GT 1 ? "s" : "")>
        <cfelseif months GTE 1>
            <cfreturn months & " month" & (months GT 1 ? "s" : "")>
        <cfelse>
            <cfreturn totalDays & " day" & (totalDays GT 1 ? "s" : "")>
        </cfif>
    </cffunction>
    <!--- Used internally and by PDF generation --->
    <cffunction name="getPrescriptionDetail" access="public" returntype="struct" output="false">
    <cfargument name="prescriptionID" type="numeric" required="true">
    <cfargument name="userID"         type="numeric" required="true">

    <cfset var result    = {}>
    <cfset var patientID = getPatientID(arguments.userID)>

    <cfquery name="qPrescription" datasource="mms_db">
        SELECT
            pr.prescription_id,
            pr.diagnosis,
            pr.notes,
            pr.prescription_date,
            a.appointment_datetime,
            u.full_name AS doctor_name,
            dept.dept_name
        FROM  PRESCRIPTIONS pr
        JOIN  APPOINTMENTS  a    ON pr.appointment_id = a.appointment_id
        JOIN  DOCTORS       d    ON pr.doctor_id      = d.doctor_id
        JOIN  USERS         u    ON d.user_id         = u.user_id
        JOIN  DEPARTMENTS   dept ON d.dept_id         = dept.dept_id
        WHERE pr.prescription_id =
            <cfqueryparam value="#arguments.prescriptionID#" cfsqltype="cf_sql_integer">
        AND   a.patient_id =
            <cfqueryparam value="#patientID#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfquery name="qItems" datasource="mms_db">
        SELECT
            pi.item_id,
            pi.dosage,
            pi.frequency,
            pi.duration,
            pi.instructions,
            d.drug_name,
            d.strength,
            d.form AS drug_form
        FROM  PRESCRIPTION_ITEMS pi
        JOIN  DRUGS d ON pi.drug_id = d.drug_id
        WHERE pi.prescription_id =
            <cfqueryparam value="#arguments.prescriptionID#" cfsqltype="cf_sql_integer">
        ORDER BY pi.item_id ASC
    </cfquery>

    <!--- Fetch patient details --->
    <cfset var qPatient = getPatientDetails(patientID)>

    <cfset result.prescription = qPrescription>
    <cfset result.items        = qItems>
    <cfset result.patient      = qPatient>

    <cfreturn result>
</cffunction>

<!--- Prescription details for pdf (remote)--->
    <cffunction name="getPrescriptionDetailRemote" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="enc_prescription_id" type="string"  required="true">

        <cfset var result          = { success = false, message = "", data = {} }>
        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset var prescriptionID  = 0>

        <cftry>
            <cfset prescriptionID = securityService.decryptID(arguments.enc_prescription_id)>
        <cfcatch>
            <cfset result.message = "Invalid prescription ID.">
            <cfreturn result>
        </cfcatch>
        </cftry>

        <cftry>
            <cfset var detail = getPrescriptionDetail(prescriptionID, session.user.user_id)>

            <cfif detail.prescription.recordCount EQ 0>
                <cfset result.message = "Prescription not found.">
                <cfreturn result>
            </cfif>

            <cfset var p   = detail.prescription>
            <cfset var pat = detail.patient>

            <cfset var patAge = "">
            <cfif isDate(pat.date_of_birth) AND len(trim(pat.date_of_birth))>
                <cfset patAge = formatAge(pat.date_of_birth)>
            <cfelse>
                <cfset patAge = "N/A">
            </cfif>

            <cfset var d = {
                prescription_id   = p.prescription_id,
                diagnosis         = p.diagnosis,
                notes             = p.notes,
                prescription_date = dateFormat(p.prescription_date, "dd-mmm-yyyy"),
                doctor_name       = p.doctor_name,
                dept_name         = p.dept_name,
                appointment_date  = dateFormat(p.appointment_datetime, "dd-mmm-yyyy"),
                appointment_time  = timeFormat(p.appointment_datetime, "hh:mm tt"),
                patient_name      = pat.full_name,
                patient_gender    = pat.gender,
                patient_age       = patAge
            }>

            <!--- Medicines array --->
            <cfset var medArray = []>
            <cfloop query="detail.items">
                <cfset arrayAppend(medArray, {
                    drug_name    = drug_name,
                    strength     = strength,
                    drug_form    = drug_form,
                    dosage       = dosage,
                    frequency    = frequency,
                    duration     = duration,
                    instructions = instructions
                })>
            </cfloop>
            <cfset d.medicines = medArray>

            <cfset result.success = true>
            <cfset result.data    = d>

        <cfcatch type="any">
            <cfset result.message = cfcatch.message>
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <!--- PDF generation --->
    <cffunction name="generatePrescriptionPDF" access="public" returntype="void" output="true">
        <cfargument name="enc_prescription_id" type="string"  required="true">
        <cfargument name="userID"              type="numeric" required="true">

        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset var prescriptionID  = securityService.decryptID(arguments.enc_prescription_id)>
        <cfset var detail          = getPrescriptionDetail(prescriptionID, arguments.userID)>
        

        <cfif detail.prescription.recordCount EQ 0>
            <cflocation url="prescriptions.cfm" addtoken="no">
        </cfif>

        <cfset var pt = detail.patient>
        <cfset var patAge = (isDate(pt.date_of_birth) AND len(trim(pt.date_of_birth))) ? formatAge(pt.date_of_birth) : "N/A">
        <cfset var p  = detail.prescription>
        <cfset var it = detail.items>
        <cfset var fileName = "Prescription_#prescriptionID#_#dateFormat(now(),'yyyymmdd')#.pdf">

        <cfsavecontent variable="local.pdfHTML">
            <!DOCTYPE html>
            <html>
                <head>
                    <style>
                        body  { font-family:Arial,sans-serif; font-size:15px; color:##333; margin:30px; }
                        h2    { color:##00123a; border-bottom:2px solid ##020083; padding-bottom:6px; }
                        h4    { margin-bottom:4px; }
                        .label { color:##666; font-size:11px; }
                        .val   { font-weight:bold; }
                        table  { width:100%; border-collapse:collapse; margin-top:12px; }
                        th     { background:##b19cfc; color:##000; padding:8px; text-align:left; font-size:12px; }
                        td     { padding:7px 8px; border-bottom:1px solid ##ddd; font-size:14px; }
                        tr:nth-child(even) td { background:##f8f9fa; }
                        .footer { margin-top:30px; font-size:11px; color:##999; text-align:center; }
                    </style>
                </head>
                <body>
                    <h2>Prescription</h2>

                    <cfoutput>

                    <!--- Patient Info --->
                    <table style="margin-bottom:16px; border:1px solid ##ddd; background:##f0f4ff;">
                        <tr>
                            <td style="border:none; width:34%">
                                <span class="label">Patient Name</span><br>
                                <span class="val">#encodeForHTML(pt.full_name)#</span>
                            </td>
                            <td style="border:none; width:33%">
                                <span class="label">Gender</span><br>
                                <span class="val">#encodeForHTML(pt.gender)#</span>
                            </td>
                            <td style="border:none; width:33%">
                                <span class="label">Age</span><br>
                                <span class="val">#patAge#</span>
                            </td>
                        </tr>
                    </table>

                    <!--- Doctor & Appointment Info --->
                    <table style="margin-bottom:16px; border:none;">
                        <tr>
                            <td style="border:none; width:50%">
                                <span class="label">Doctor</span><br>
                                <span class="val">#encodeForHTML(p.doctor_name)#</span>
                            </td>
                            <td style="border:none; width:50%">
                                <span class="label">Department</span><br>
                                <span class="val">#encodeForHTML(p.dept_name)#</span>
                            </td>
                        </tr>
                        <tr>
                            <td style="border:none;">
                                <span class="label">Appointment Date</span><br>
                                <span class="val">
                                    #dateFormat(p.appointment_datetime,"dd-mmm-yyyy")#
                                    #timeFormat(p.appointment_datetime,"hh:mm tt")#
                                </span>
                            </td>
                            <td style="border:none;">
                                <span class="label">Prescription Date</span><br>
                                <span class="val">#dateFormat(p.prescription_date,"dd-mmm-yyyy")#</span>
                            </td>
                        </tr>
                        <tr>
                            <td style="border:none;" colspan="2">
                                <span class="label">Diagnosis</span><br>
                                <span class="val">#encodeForHTML(p.diagnosis)#</span>
                            </td>
                        </tr>
                        <cfif len(trim(p.notes))>
                        <tr>
                            <td style="border:none;" colspan="2">
                                <span class="label">Notes</span><br>
                                <span>#encodeForHTML(p.notes)#</span>
                            </td>
                        </tr>
                        </cfif>
                    </table>

                    <!--- Medicines --->
                    <h4>Medicines Prescribed</h4>
                    <table>
                        <thead>
                            <tr>
                                <th>Sl No.</th>
                                <th>Drug</th>
                                <th>Dosage</th>
                                <th>Frequency</th>
                                <th>Duration</th>
                                <th>Instructions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfset mi = 0>
                            <cfloop query="it">
                                <cfset mi++>
                                <tr>
                                    <td>#mi#</td>
                                    <td>
                                        #encodeForHTML(drug_name)#
                                        <cfif len(trim(strength))>
                                            <br><small style="color:red">#encodeForHTML(strength)#</small>
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

                    <div class="footer">
                        Generated on #dateFormat(now(),"dd-mmm-yyyy")# &mdash; Medical Management System
                    </div>

                    </cfoutput>
                </body>
            </html>
        </cfsavecontent>

        <cfoutput>
            <cfdocument format="pdf" name="local.pdfFile">
                #local.pdfHTML#
            </cfdocument>
        </cfoutput>

        <cfheader name="Content-Disposition" value="attachment; filename=#fileName#">
        <cfcontent type="application/pdf" variable="#local.pdfFile#">
    </cffunction>

</cfcomponent>