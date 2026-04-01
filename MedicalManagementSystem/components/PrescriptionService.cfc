<cfcomponent displayname="PrescriptionService" output="false">

    <cffunction name="hasPermission" access="private" returntype="boolean" output="false">
        <cfargument name="permName" type="string" required="true">

        <!--- If no session user, deny --->
        <cfif NOT structKeyExists(session, "user")>
            <cfreturn false>
        </cfif>
        <cfquery name="qPerm" datasource="mms_db">
            SELECT COUNT(*) AS hasIt
            FROM   ROLE_PERMISSIONS rp
            JOIN   PERMISSIONS p ON rp.permission_id = p.permission_id
            WHERE  rp.role_id        = <cfqueryparam value="#session.user.role_id#" cfsqltype="cf_sql_integer">
            AND    p.permission_name = <cfqueryparam value="#arguments.permName#"   cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfreturn qPerm.hasIt GT 0>
    </cffunction>


    <cffunction name="getAppointmentDetails" access="public" returntype="query" output="false">
        <cfargument name="appointmentID" type="numeric" required="true">
        <cfquery name="q" datasource="mms_db">
            SELECT
                a.appointment_id,
                a.appointment_datetime,
                p.patient_id,
                u.full_name AS patient_name,
                aps.status_name
            FROM APPOINTMENTS a
            JOIN PATIENTS p             ON a.patient_id = p.patient_id
            JOIN USERS u                ON p.user_id    = u.user_id
            JOIN APPOINTMENT_STATUS aps ON a.status_id  = aps.status_id
            WHERE a.appointment_id =
                <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn q>
    </cffunction>

    <cffunction name="getActiveDrugs" access="public" returntype="query" output="false">
        <cfquery name="q" datasource="mms_db">
            SELECT drug_id, drug_name, form AS drug_form, strength
            FROM DRUGS
            WHERE is_active = 1
            ORDER BY drug_name ASC
        </cfquery>
        <cfreturn q>
    </cffunction>

    <cffunction name="savePrescription" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="appointmentID" type="numeric" required="true">
        <cfargument name="diagnosis"     type="string"  required="true">
        <cfargument name="notes"         type="string"  required="false" default="">
        <cfargument name="medicines"     type="string"  required="true">

        <cfset var result         = { success = false, message = "" }>
        <cfset var prescriptionID = 0>
        <cfset var med            = "">
        <cfset var drugID         = 0>
        <cfset var medList        = []>

        <!--- Validation --->
        <cfif NOT len(trim(arguments.diagnosis))>
            <cfset result.message = "Diagnosis is required.">
            <cfreturn result>
        </cfif>

        <!--- Deserialize medicines JSON string --->
        <cftry>
            <cfset medList = deserializeJSON(arguments.medicines)>
        <cfcatch>
            <cfset result.message = "Invalid medicines data.">
            <cfreturn result>
        </cfcatch>
        </cftry>

        <cfif NOT isArray(medList) OR arrayLen(medList) EQ 0>
            <cfset result.message = "At least one medicine is required.">
            <cfreturn result>
        </cfif>

        <cftry>
            <!--- Get doctor record --->
            <cfquery name="qDoctor" datasource="mms_db">
                SELECT doctor_id FROM DOCTORS
                WHERE user_id = <cfqueryparam value="#session.user.user_id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif qDoctor.recordCount EQ 0>
                <cfset result.message = "Doctor record not found.">
                <cfreturn result>
            </cfif>

            <!--- Insert prescription header --->
            <cfquery name="insertPrescription" datasource="mms_db">
                INSERT INTO PRESCRIPTIONS
                    (appointment_id, doctor_id, diagnosis, notes, prescription_date, created_at)
                OUTPUT INSERTED.prescription_id AS prescriptionID
                VALUES (
                    <cfqueryparam value="#arguments.appointmentID#"        cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#qDoctor.doctor_id#"              cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#trim(arguments.diagnosis)#"      cfsqltype="cf_sql_longnvarchar">,
                    <cfqueryparam value="#trim(arguments.notes)#"          cfsqltype="cf_sql_longnvarchar">,
                    CAST(GETDATE() AS DATE),
                    GETDATE()
                )
            </cfquery>

            <cfset prescriptionID = val(insertPrescription.prescriptionID)>

            <cfif prescriptionID EQ 0>
                <cfset result.message = "Failed to retrieve prescription ID.">
                <cfreturn result>
            </cfif>

            <!--- Insert medicine items --->
            <cfloop array="#medList#" index="med">
                <cfset drugID = val(med["DRUG_ID"])>

                <cfif drugID EQ 0>
                    <cfset result.message = "Invalid drug selected.">
                    <cfreturn result>
                </cfif>

                <cfquery datasource="mms_db">
                    INSERT INTO PRESCRIPTION_ITEMS
                        (prescription_id, drug_id, dosage, frequency, duration, instructions)
                    VALUES (
                        <cfqueryparam value="#prescriptionID#"       cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#drugID#"               cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#med['DOSAGE']#"        cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#med['FREQUENCY']#"     cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#med['DURATION']#"      cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#med['INSTRUCTIONS']#"  cfsqltype="cf_sql_varchar">
                    )
                </cfquery>
            </cfloop>

            <!--- Get consultation fee --->
            <cfquery name="qAppointment" datasource="mms_db">
                SELECT a.appointment_id, a.doctor_id, d.consultation_fee
                FROM   APPOINTMENTS a
                JOIN   DOCTORS d ON a.doctor_id = d.doctor_id
                WHERE  a.appointment_id =
                    <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset var consultationFee = qAppointment.consultation_fee>

            <!--- Create bill only if one does not exist yet --->
            <cfquery name="qCheckBill" datasource="mms_db">
                SELECT bill_id FROM BILLS
                WHERE appointment_id =
                    <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif qCheckBill.recordCount EQ 0>
                <cfquery datasource="mms_db" result="billResult">
                    INSERT INTO BILLS
                        (appointment_id, status_id, invoice_no, total_amount, created_by)
                    VALUES (
                        <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">,
                        1,
                        <cfqueryparam value="INV#dateFormat(now(),'yyyymmdd')##arguments.appointmentID#"
                                      cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#consultationFee#"         cfsqltype="cf_sql_decimal">,
                        <cfqueryparam value="#session.user.user_id#"    cfsqltype="cf_sql_integer">
                    )
                </cfquery>

                <cfset var billID = billResult.generatedKey>

                <cfquery datasource="mms_db">
                    INSERT INTO BILL_ITEMS
                        (bill_id, item_type, item_description, quantity,
                         unit_price, tax_amount, total_amount)
                    VALUES (
                        <cfqueryparam value="#billID#"             cfsqltype="cf_sql_integer">,
                        'Consultation',
                        'Doctor Consultation Fee',
                        1,
                        <cfqueryparam value="#consultationFee#"   cfsqltype="cf_sql_decimal">,
                        0,
                        <cfqueryparam value="#consultationFee#"   cfsqltype="cf_sql_decimal">
                    )
                </cfquery>
            </cfif>

            <cfset result.success = true>
            <cfset result.message = "Prescription saved successfully.">

        <cfcatch type="any">
            <cfset result.success = false>
            <cfset result.message = cfcatch.message & " | " & cfcatch.detail>
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <cffunction name="getPrescriptionByAppointment" access="public" returntype="query" output="false">
        <cfargument name="appointmentID" type="numeric" required="true">
        <cfquery name="q" datasource="mms_db">
            SELECT prescription_id, diagnosis, notes, prescription_date
            FROM   PRESCRIPTIONS
            WHERE  appointment_id =
                <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn q>
    </cffunction>

    <cffunction name="getPrescriptionItems" access="public" returntype="query" output="false">
        <cfargument name="prescriptionID" type="numeric" required="true">
        <cfquery name="q" datasource="mms_db">
            SELECT
                pi.item_id,
                pi.drug_id,
                d.drug_name,
                d.strength,
                pi.dosage,
                pi.frequency,
                pi.duration,
                pi.instructions
            FROM PRESCRIPTION_ITEMS pi
            JOIN DRUGS d ON pi.drug_id = d.drug_id
            WHERE pi.prescription_id =
                <cfqueryparam value="#arguments.prescriptionID#" cfsqltype="cf_sql_integer">
            ORDER BY pi.item_id ASC
        </cfquery>
        <cfreturn q>
    </cffunction>

    <cffunction name="updatePrescription" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="prescriptionID" type="numeric" required="true">
        <cfargument name="diagnosis"      type="string"  required="true">
        <cfargument name="notes"          type="string"  required="false" default="">
        <cfargument name="medicines"      type="string"  required="true">

        <cfset var result  = { success = false, message = "" }>
        <cfset var medList = []>
        <cfset var med     = "">
        <cfset var drugID  = 0>

        <cfif NOT hasPermission("EDIT_PRESCRIPTION")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>

        <cfif NOT len(trim(arguments.diagnosis))>
            <cfset result.message = "Diagnosis is required.">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfset medList = deserializeJSON(arguments.medicines)>
        <cfcatch>
            <cfset result.message = "Invalid medicines data.">
            <cfreturn result>
        </cfcatch>
        </cftry>

        <cfif NOT isArray(medList) OR arrayLen(medList) EQ 0>
            <cfset result.message = "At least one medicine is required.">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfquery datasource="mms_db">
                UPDATE PRESCRIPTIONS SET
                    diagnosis = <cfqueryparam value="#trim(arguments.diagnosis)#" cfsqltype="cf_sql_longnvarchar">,
                    notes     = <cfqueryparam value="#trim(arguments.notes)#"     cfsqltype="cf_sql_longnvarchar">
                WHERE prescription_id =
                    <cfqueryparam value="#arguments.prescriptionID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfquery datasource="mms_db">
                DELETE FROM PRESCRIPTION_ITEMS
                WHERE prescription_id =
                    <cfqueryparam value="#arguments.prescriptionID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfloop array="#medList#" index="med">
                <cfset drugID = val(med["DRUG_ID"])>

                <cfif drugID EQ 0>
                    <cfset result.message = "Invalid drug selected.">
                    <cfreturn result>
                </cfif>

                <cfquery datasource="mms_db">
                    INSERT INTO PRESCRIPTION_ITEMS
                        (prescription_id, drug_id, dosage, frequency, duration, instructions)
                    VALUES (
                        <cfqueryparam value="#arguments.prescriptionID#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#drugID#"                   cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#med['DOSAGE']#"            cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#med['FREQUENCY']#"         cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#med['DURATION']#"          cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#med['INSTRUCTIONS']#"      cfsqltype="cf_sql_varchar">
                    )
                </cfquery>
            </cfloop>

            <cfset result.success = true>
            <cfset result.message = "Prescription updated successfully.">

        <cfcatch type="any">
            <cfset result.success = false>
            <cfset result.message = cfcatch.message & " | " & cfcatch.detail>
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>