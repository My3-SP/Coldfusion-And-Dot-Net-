<cfcomponent displayname="PatientDashboardService" output="false">

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

    <!---  UPCOMING APPOINTMENTS  --->
    <cffunction name="getUpcomingAppointments" access="public" returntype="query" output="false">
        <cfargument name="user_id" type="numeric" required="true">

        <cfif NOT hasPermission("VIEW_OWN_APPOINTMENTS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="qUpcoming" datasource="mms_db">
            SELECT
                a.appointment_id,
                d.full_name        AS doctor_name,
                a.appointment_datetime,
                s.status_name      AS status
            FROM  APPOINTMENTS      a
            JOIN  DOCTORS           doc ON a.doctor_id  = doc.doctor_id
            JOIN  USERS             d   ON doc.user_id  = d.user_id
            JOIN  APPOINTMENT_STATUS s  ON a.status_id  = s.status_id
            JOIN  PATIENTS          p   ON a.patient_id = p.patient_id
            WHERE p.user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
            AND CAST(a.appointment_datetime AS DATE) >= CAST(GETDATE() AS DATE)
            AND s.status_name IN ('Booked', 'In Progress')
            ORDER BY a.appointment_datetime ASC
        </cfquery>

        <cfreturn qUpcoming>
    </cffunction>

    <!---  PREVIOUS APPOINTMENTS  --->
    <cffunction name="getPreviousAppointments" access="public" returntype="query" output="false">
        <cfargument name="user_id" type="numeric" required="true">

        <cfif NOT hasPermission("VIEW_OWN_APPOINTMENTS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="qPrevious" datasource="mms_db">
            SELECT TOP 3 
                a.appointment_id, 
                d.full_name AS doctor_name, 
                a.appointment_datetime, 
                s.status_name AS status
            FROM APPOINTMENTS a
            INNER JOIN DOCTORS doc ON a.doctor_id = doc.doctor_id
            INNER JOIN USERS d ON doc.user_id = d.user_id
            INNER JOIN APPOINTMENT_STATUS s ON a.status_id = s.status_id
            INNER JOIN PATIENTS p ON a.patient_id = p.patient_id
            WHERE p.user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
              AND CAST(a.appointment_datetime AS DATE) < CAST( GETDATE() AS DATE)
            ORDER BY a.appointment_datetime DESC
        </cfquery>

        <cfreturn qPrevious>
    </cffunction>

    <!--- fetch all appointments for display --->
    <cffunction name="getAllAppointments" access="public" returntype="query" output="false">
        <cfargument name="user_id" type="numeric" required="true">

        <cfif NOT hasPermission("VIEW_OWN_APPOINTMENTS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="qAll" datasource="mms_db">
            SELECT 
                a.appointment_id, 
                d.full_name AS doctor_name, 
                a.appointment_datetime, 
                s.status_name AS status
            FROM APPOINTMENTS a
            INNER JOIN DOCTORS doc ON a.doctor_id = doc.doctor_id
            INNER JOIN USERS d ON doc.user_id = d.user_id
            INNER JOIN APPOINTMENT_STATUS s ON a.status_id = s.status_id
            INNER JOIN PATIENTS p ON a.patient_id = p.patient_id
            WHERE p.user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
               AND s.status_name = 'completed'
            ORDER BY a.appointment_datetime ASC
        </cfquery>

        <cfreturn qAll>
    </cffunction>

    <!---  RECENT PRESCRIPTIONS  --->
    <cffunction name="getRecentPrescriptions" access="public" returntype="query" output="false">
        <cfargument name="user_id" type="numeric" required="true">

        <cfquery name="qPrescriptions" datasource="mms_db">
            SELECT TOP 3 
                pr.prescription_id, 
                d.full_name AS doctor_name, 
                pr.prescription_date, 
                pr.diagnosis, 
                pr.notes,
                a.appointment_datetime
            FROM PRESCRIPTIONS pr
            INNER JOIN APPOINTMENTS a ON pr.appointment_id = a.appointment_id
            INNER JOIN DOCTORS doc ON a.doctor_id = doc.doctor_id
            INNER JOIN USERS d ON doc.user_id = d.user_id
            INNER JOIN PATIENTS p ON a.patient_id = p.patient_id
            WHERE p.user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
            ORDER BY pr.prescription_date DESC
        </cfquery>

        <cfreturn qPrescriptions>
    </cffunction>

    <!---  ALL PATIENT PRESCRIPTIONS  --->
    <cffunction name="getPatientPrescriptions" access="public" returntype="query" output="false">
        <cfargument name="user_id" type="numeric" required="true">

        <cfif NOT hasPermission("VIEW_OWN_PRESCRIPTIONS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="qPrescriptions" datasource="mms_db">
            SELECT 
                pr.prescription_id,
                pr.prescription_date,
                pr.diagnosis,
                pr.notes,
                d.full_name AS doctor_name,
                a.appointment_datetime
            FROM PRESCRIPTIONS pr
            INNER JOIN APPOINTMENTS a ON pr.appointment_id = a.appointment_id
            INNER JOIN DOCTORS doc ON a.doctor_id = doc.doctor_id
            INNER JOIN USERS d ON doc.user_id = d.user_id
            INNER JOIN PATIENTS p ON a.patient_id = p.patient_id
            WHERE p.user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
            ORDER BY pr.prescription_date DESC
        </cfquery>

        <cfreturn qPrescriptions>
    </cffunction>

    <!---  BILLING SUMMARY  --->
    <cffunction name="getBillingSummary" access="public" returntype="query" output="false">
        <cfargument name="user_id" type="numeric" required="true">

        <cfif NOT hasPermission("VIEW_OWN_BILLS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="qBilling" datasource="mms_db">
            SELECT 
                b.bill_id, 
                b.invoice_no, 
                b.total_amount, 
                b.bill_date, 
                s.status_name AS status
            FROM BILLS b
            INNER JOIN APPOINTMENTS a ON b.appointment_id = a.appointment_id
            INNER JOIN PATIENTS p ON a.patient_id = p.patient_id
            INNER JOIN APPOINTMENT_STATUS s ON b.status_id = s.status_id
            WHERE p.user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
            ORDER BY b.bill_date DESC
        </cfquery>

        <cfreturn qBilling>
    </cffunction>    
</cfcomponent>