<cfcomponent displayname="PatientHistoryService" output="false">

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
    
    <!--- All unique patients treated by this doctor --->
    <cffunction name="getTreatedPatients" access="public" returntype="query" output="false">
        <cfargument name="doctorID" type="numeric" required="true">
        <cfquery name="q" datasource="mms_db">
            SELECT
                p.patient_id,
                u.full_name,
                u.email,
                u.phone,
                p.gender,
                p.blood_group,
                COUNT(a.appointment_id)  AS total_visits,
                MAX(a.appointment_datetime) AS last_visit
            FROM APPOINTMENTS a
            JOIN PATIENTS p             ON a.patient_id  = p.patient_id
            JOIN USERS u                ON p.user_id     = u.user_id
            JOIN APPOINTMENT_STATUS s   ON a.status_id   = s.status_id
            WHERE a.doctor_id =
                <cfqueryparam value="#arguments.doctorID#" cfsqltype="cf_sql_integer">
            AND s.status_name = 'Completed'
            GROUP BY
                p.patient_id,
                u.full_name,
                u.email,
                u.phone,
                p.gender,
                p.blood_group
            ORDER BY u.full_name ASC
        </cfquery>
        <cfreturn q>
    </cffunction>

    <!--- Full patient profile --->
    <cffunction name="getPatientDetails" access="public" returntype="query" output="false">
        <cfargument name="patientID" type="numeric" required="true">
        <cfif NOT hasPermission("VIEW_PATIENT_DETAILS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="q" datasource="mms_db">
            SELECT
                u.full_name,
                u.email,
                u.phone,
                p.gender,
                p.blood_group,
                p.date_of_birth
            FROM PATIENTS p
            JOIN USERS u ON p.user_id = u.user_id
            WHERE p.patient_id =
                <cfqueryparam value="#arguments.patientID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn q>
    </cffunction>

    <!--- All completed appointments + prescriptions for this patient with this doctor --->
    <cffunction name="getPatientInteractions" access="public" returntype="query" output="false">
        <cfargument name="doctorID"  type="numeric" required="true">
        <cfargument name="patientID" type="numeric" required="true">
        
        <cfif NOT hasPermission("VIEW_PATIENT_HISTORY")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="q" datasource="mms_db">
            SELECT
                a.appointment_id,
                a.appointment_datetime,
                pr.prescription_id,
                pr.diagnosis,
                pr.notes,
                <!--- Aggregate medicine details into pipe-delimited strings --->
                STUFF((
                    SELECT '|' + d.drug_name
                    FROM PRESCRIPTION_ITEMS pi
                    JOIN DRUGS d ON pi.drug_id = d.drug_id
                    WHERE pi.prescription_id = pr.prescription_id
                    FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'), 1, 1, ''
                ) AS drug_names,
                STUFF((
                    SELECT '|' + pi.dosage
                    FROM PRESCRIPTION_ITEMS pi
                    WHERE pi.prescription_id = pr.prescription_id
                    FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'), 1, 1, ''
                ) AS dosages,
                STUFF((
                    SELECT '|' + pi.frequency
                    FROM PRESCRIPTION_ITEMS pi
                    WHERE pi.prescription_id = pr.prescription_id
                    FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'), 1, 1, ''
                ) AS frequencies,
                STUFF((
                    SELECT '|' + pi.duration
                    FROM PRESCRIPTION_ITEMS pi
                    WHERE pi.prescription_id = pr.prescription_id
                    FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'), 1, 1, ''
                ) AS durations,
                STUFF((
                    SELECT '|' + ISNULL(pi.instructions,'')
                    FROM PRESCRIPTION_ITEMS pi
                    WHERE pi.prescription_id = pr.prescription_id
                    FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'), 1, 1, ''
                ) AS instrList
            FROM APPOINTMENTS a
            JOIN APPOINTMENT_STATUS s   ON a.status_id        = s.status_id
            LEFT JOIN PRESCRIPTIONS pr  ON a.appointment_id   = pr.appointment_id
            WHERE a.doctor_id  = <cfqueryparam value="#arguments.doctorID#"  cfsqltype="cf_sql_integer">
            AND   a.patient_id = <cfqueryparam value="#arguments.patientID#" cfsqltype="cf_sql_integer">
            AND   s.status_name = 'Completed'
            ORDER BY a.appointment_datetime DESC
        </cfquery>
        <cfreturn q>
    </cffunction>

</cfcomponent>