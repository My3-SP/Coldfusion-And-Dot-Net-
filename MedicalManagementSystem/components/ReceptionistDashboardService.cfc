<cfcomponent displayname="ReceptionistDashboardService" output="false">


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

    <!---  DASHBOARD STATS  --->

    <cffunction name="getTodayAppointmentsCount" access="public" returntype="numeric" output="false">
        <cfquery name="q" datasource="mms_db">
            SELECT COUNT(*) AS total
            FROM   APPOINTMENTS
            WHERE  CAST(appointment_datetime AS DATE) = CAST(GETDATE() AS DATE)
        </cfquery>
        <cfreturn q.total>
    </cffunction>

    <cffunction name="getTotalPatientsCount" access="public" returntype="numeric" output="false">
        <cfquery name="q" datasource="mms_db">
            SELECT COUNT(*) AS total
            FROM   PATIENTS
            WHERE  is_active = 1
        </cfquery>
        <cfreturn q.total>
    </cffunction>

    <cffunction name="getWeeklyPatientsCount" access="public" returntype="numeric" output="false">
        <cfquery name="q" datasource="mms_db">
            SELECT COUNT(*) AS total
            FROM   PATIENTS
            WHERE  registration_date >= DATEADD(DAY, -7, GETDATE())
            AND    is_active = 1
        </cfquery>
        <cfreturn q.total>
    </cffunction>

    <!--- Todays appointments for display --->
    <cffunction name="getTodayAppointments" access="public" returntype="query" output="false">
        <cfif NOT hasPermission("VIEW_APPOINTMENTS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="q" datasource="mms_db">
            SELECT a.appointment_id,
                   u.full_name  AS patient_name,
                   du.full_name AS doctor_name,
                   a.appointment_datetime,
                   s.status_name
            FROM   APPOINTMENTS a
            JOIN   PATIENTS p          ON a.patient_id  = p.patient_id
            JOIN   USERS u             ON p.user_id     = u.user_id
            JOIN   DOCTORS d           ON a.doctor_id   = d.doctor_id
            JOIN   USERS du            ON d.user_id     = du.user_id
            JOIN   APPOINTMENT_STATUS s ON a.status_id  = s.status_id
            WHERE  CAST(a.appointment_datetime AS DATE) = CAST(GETDATE() AS DATE)
            ORDER BY a.appointment_datetime ASC
        </cfquery>
        <cfreturn q>
    </cffunction>

    <!--- <cffunction name="getPatients" access="public" returntype="query" output="false">
        <cfargument name="filterType" type="string" required="true">
        
        <cfif NOT hasPermission("VIEW_PATIENT")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="q" datasource="mms_db">
            SELECT p.patient_id,
                   u.full_name,
                   u.email,
                   u.phone,
                   p.registration_date
            FROM   PATIENTS p
            JOIN   USERS u ON p.user_id = u.user_id
            WHERE  p.is_active = 1
            <cfif arguments.filterType EQ "weekly">
                AND p.registration_date >= DATEADD(DAY, -7, GETDATE())
            </cfif>
            ORDER BY p.registration_date DESC
        </cfquery>
        <cfreturn q>
    </cffunction> --->

    <!---  APPOINTMENTS  --->
    <cffunction name="getAppointments" access="remote" returntype="query"
                returnformat="json" output="false">

                <cfif NOT hasPermission("VIEW_APPOINTMENTS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="q" datasource="mms_db">
            SELECT a.appointment_id,
                   a.patient_id,
                   a.doctor_id,
                   u.full_name  AS patient_name,
                   du.full_name AS doctor_name,
                   a.appointment_datetime,
                   s.status_name,
                   ISNULL(a.remarks, '') AS remarks
            FROM   APPOINTMENTS a
            JOIN   PATIENTS p          ON a.patient_id  = p.patient_id
            JOIN   USERS u             ON p.user_id     = u.user_id
            JOIN   DOCTORS d           ON a.doctor_id   = d.doctor_id
            JOIN   USERS du            ON d.user_id     = du.user_id
            JOIN   APPOINTMENT_STATUS s ON a.status_id  = s.status_id
            WHERE  a.appointment_datetime >= CAST(GETDATE() AS DATE)
            ORDER BY a.appointment_datetime ASC
        </cfquery>
        <cfreturn q>
    </cffunction>

    <!--- get patients and doctors for drop down --->
    <cffunction name="getAllPatients" access="remote" returntype="query"
                returnformat="json" output="false">
        <cfquery name="q" datasource="mms_db">
            SELECT p.patient_id,
                   u.full_name
            FROM   PATIENTS p
            JOIN   USERS u ON p.user_id = u.user_id
            WHERE  p.is_active = 1
            ORDER BY u.full_name
        </cfquery>
        <cfreturn q>
    </cffunction>

    <cffunction name="getAllDoctors" access="remote" returntype="query"
                returnformat="json" output="false">
        <cfquery name="q" datasource="mms_db">
            SELECT d.doctor_id,
                   u.full_name
            FROM   DOCTORS d
            JOIN   USERS u ON d.user_id = u.user_id
            WHERE  d.is_active = 1
            ORDER BY u.full_name
        </cfquery>
        <cfreturn q>
    </cffunction>

    <cffunction name="bookAppointment" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="patientID"       type="numeric" required="true">
        <cfargument name="doctorID"        type="numeric" required="true">
        <cfargument name="appointmentDate" type="string"  required="true">
        <cfargument name="appointmentTime" type="string"  required="true">
        <cfargument name="remarks"         type="string"  required="false" default="">

        <cfset var result        = { success=false, message="" }>
        <cfset var appointmentDT = "">

            <cfif NOT hasPermission("CREATE_APPOINTMENT")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>

        <cfif arguments.patientID LTE 0>
            <cfset result.message = "Please select a valid patient.">
            <cfreturn result>
        </cfif>
        <cfif arguments.doctorID LTE 0>
            <cfset result.message = "Please select a valid doctor.">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfset appointmentDT = arguments.appointmentDate & " " & arguments.appointmentTime>

            <cfif parseDateTime(appointmentDT) LTE now()>
                <cfset result.message = "Appointment must be scheduled in the future.">
                <cfreturn result>
            </cfif>

            <!--- Prevent double booking --->
            <cfquery name="qCheck" datasource="mms_db">
                SELECT appointment_id
                FROM   APPOINTMENTS
                WHERE  doctor_id = <cfqueryparam value="#arguments.doctorID#" cfsqltype="cf_sql_integer">
                AND    appointment_datetime = <cfqueryparam value="#appointmentDT#" cfsqltype="cf_sql_timestamp">
                AND    status_id != (
                    SELECT status_id FROM APPOINTMENT_STATUS WHERE status_name = 'Cancelled'
                )
            </cfquery>

            <cfif qCheck.recordCount GT 0>
                <cfset result.message = "Doctor already has an appointment at this time.">
                <cfreturn result>
            </cfif>

            <cfquery datasource="mms_db">
            INSERT INTO APPOINTMENTS
                (patient_id, doctor_id, appointment_datetime, status_id, remarks, created_at, created_by)
            VALUES (
                <cfqueryparam value="#arguments.patientID#"     cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.doctorID#"      cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#appointmentDT#"           cfsqltype="cf_sql_timestamp">,
                (SELECT status_id FROM APPOINTMENT_STATUS WHERE status_name = 'Booked'),
                <cfqueryparam value="#trim(arguments.remarks)#" cfsqltype="cf_sql_varchar"
                            null="#NOT len(trim(arguments.remarks))#">,
                GETDATE(),
                <cfqueryparam value="#session.user.user_id#"    cfsqltype="cf_sql_integer">
            )
        </cfquery>

            <cfset result.success = true>
            <cfset result.message = "Appointment booked successfully.">

        <cfcatch type="any">
            <cfset result.success = false>
            <cfset result.message = "Unable to book appointment. Please try again.">
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <!--- update appointments --->
    <cffunction name="updateAppointment" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="appointmentID"   type="numeric" required="true">
        <cfargument name="patientID"       type="numeric" required="true">
        <cfargument name="doctorID"        type="numeric" required="true">
        <cfargument name="appointmentDate" type="string"  required="true">
        <cfargument name="appointmentTime" type="string"  required="true">
        <cfargument name="remarks"         type="string"  required="false" default="">

        <cfset var result        = { success=false, message="" }>
        <cfset var appointmentDT = "">

         <cfif NOT hasPermission("RESCHEDULE_APPOINTMENT")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>

        <cfif arguments.appointmentID LTE 0>
            <cfset result.message = "Invalid appointment selected.">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfset appointmentDT = arguments.appointmentDate & " " & arguments.appointmentTime>

            <cfif parseDateTime(appointmentDT) LTE now()>
                <cfset result.message = "Updated appointment must be a future date/time.">
                <cfreturn result>
            </cfif>

            <cfquery name="qCheck" datasource="mms_db">
                SELECT appointment_id
                FROM   APPOINTMENTS
                WHERE  doctor_id = <cfqueryparam value="#arguments.doctorID#"       cfsqltype="cf_sql_integer">
                AND    appointment_datetime = <cfqueryparam value="#appointmentDT#"  cfsqltype="cf_sql_timestamp">
                AND    appointment_id != <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif qCheck.recordCount GT 0>
                <cfset result.message = "Doctor already has an appointment at this time.">
                <cfreturn result>
            </cfif>

            <cfquery datasource="mms_db">
                UPDATE APPOINTMENTS
                SET patient_id           = <cfqueryparam value="#arguments.patientID#"         cfsqltype="cf_sql_integer">,
                    doctor_id            = <cfqueryparam value="#arguments.doctorID#"          cfsqltype="cf_sql_integer">,
                    appointment_datetime = <cfqueryparam value="#appointmentDT#"               cfsqltype="cf_sql_timestamp">,
                    remarks              = <cfqueryparam value="#trim(arguments.remarks)#"     cfsqltype="cf_sql_varchar"
                                                        null="#NOT len(trim(arguments.remarks))#">,
                    updated_at           = GETDATE(),
                    updated_by           = <cfqueryparam value="#session.user.user_id#"        cfsqltype="cf_sql_integer">
                WHERE appointment_id     = <cfqueryparam value="#arguments.appointmentID#"     cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.success = true>
            <cfset result.message = "Appointment updated successfully.">

        <cfcatch type="any">
            <cfset result.message = "Unable to update appointment. Please try again.">
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <!--- cancel appointments --->
    <cffunction name="cancelAppointment" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="appointmentID" type="numeric" required="true">

        <cfset var result = { success=false, message="" }>

        <cfif NOT hasPermission("CANCEL_APPOINTMENT")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>

        <cfif arguments.appointmentID LTE 0>
            <cfset result.message = "Invalid appointment selected.">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfquery datasource="mms_db">
                UPDATE APPOINTMENTS
                SET status_id = (
                    SELECT status_id FROM APPOINTMENT_STATUS WHERE status_name = 'Cancelled'
                )
                WHERE appointment_id = <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset result.success = true>
            <cfset result.message = "Appointment cancelled successfully.">
        <cfcatch type="any">
            <cfset result.message = "Unable to cancel appointment.">
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <!--- reactivate canceled appointments --->
    <cffunction name="reactivateAppointment" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="appointmentID" type="numeric" required="true">

        <cfset var result = { success=false, message="" }>

        <cfif arguments.appointmentID LTE 0>
            <cfset result.message = "Invalid appointment selected.">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfquery datasource="mms_db">
                UPDATE APPOINTMENTS
                SET status_id = (
                    SELECT status_id FROM APPOINTMENT_STATUS WHERE status_name = 'Booked'
                )
                WHERE appointment_id = <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset result.success = true>
            <cfset result.message = "Appointment reactivated successfully.">
        <cfcatch type="any">
            <cfset result.message = "Unable to reactivate appointment.">
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <!--- delete the appointment --->
    <cffunction name="deleteAppointment" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="appointmentID" type="numeric" required="true">

        <cfset var result = { success=false, message="" }>

        <cfif arguments.appointmentID LTE 0>
            <cfset result.message = "Invalid appointment selected.">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfquery datasource="mms_db">
                DELETE FROM APPOINTMENTS
                WHERE appointment_id = <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset result.success = true>
            <cfset result.message = "Appointment deleted successfully.">
        <cfcatch type="any">
            <cfset result.message = "Unable to delete appointment.">
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>