<cfcomponent displayname="doctorDashboardService" output="false">

<!--- permissions check --->
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


    <!--- Get Doctor ID from User ID --->
    <cffunction name="getDoctorID" access="public" returntype="numeric" output="false">
        <cfargument name="userID" type="numeric" required="true">
        <cfquery name="qDoctor" datasource="mms_db">
            SELECT doctor_id
            FROM DOCTORS
            WHERE user_id = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfif qDoctor.recordCount EQ 0>
            <cfreturn 0>
        </cfif>
        <cfreturn qDoctor.doctor_id>
    </cffunction>


    <!--- Dashboard Summary --->
    <cffunction name="getDashboardStats" access="public" returntype="struct" output="false">
        <cfargument name="doctorID" type="numeric" required="true">

        <cfset var result = structNew()>

        <!--- Today's Appointments --->
        <cfquery name="qToday" datasource="mms_db">
            SELECT COUNT(*) AS total
            FROM APPOINTMENTS
            WHERE doctor_id = <cfqueryparam value="#arguments.doctorID#" cfsqltype="cf_sql_integer">
            AND CAST(appointment_datetime AS DATE) = CAST(GETDATE() AS DATE)
        </cfquery>

        <!--- Upcoming Appointments --->
        <cfquery name="qUpcoming" datasource="mms_db">
            SELECT COUNT(*) AS total
            FROM APPOINTMENTS
            WHERE doctor_id = <cfqueryparam value="#arguments.doctorID#" cfsqltype="cf_sql_integer">
            AND appointment_datetime > GETDATE()
        </cfquery>

        <!--- Total Unique Patients --->
        <cfquery name="qPatients" datasource="mms_db">
            SELECT COUNT(DISTINCT patient_id) AS total
            FROM APPOINTMENTS
            WHERE doctor_id = <cfqueryparam value="#arguments.doctorID#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Total Prescriptions --->
        <cfquery name="qPrescriptions" datasource="mms_db">
            SELECT COUNT(*) AS total
            FROM PRESCRIPTIONS PR
            INNER JOIN APPOINTMENTS A 
                ON PR.appointment_id = A.appointment_id
            WHERE A.doctor_id = <cfqueryparam value="#arguments.doctorID#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.todayAppointments = qToday.total>
        <cfset result.upcomingAppointments = qUpcoming.total>
        <cfset result.totalPatients = qPatients.total>
        <cfset result.totalPrescriptions = qPrescriptions.total>

        <cfreturn result>
    </cffunction>

    <!--- Get todats appointments --->
    <cffunction name="getTodayAppointmentsList" access="public" returntype="query" output="false">
        <cfargument name="doctorID" type="numeric" required="true">

        <cfif NOT hasPermission("VIEW_MY_APPOINTMENTS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="qTodayList" datasource="mms_db">
            SELECT TOP 5
                A.appointment_id,
                A.appointment_datetime,
                S.status_name,
                U.full_name AS patient_name
            FROM APPOINTMENTS A
            INNER JOIN PATIENTS P ON A.patient_id = P.patient_id
            INNER JOIN USERS U ON P.user_id = U.user_id
            INNER JOIN APPOINTMENT_STATUS S ON A.status_id = S.status_id
            WHERE A.doctor_id = <cfqueryparam value="#arguments.doctorID#" cfsqltype="cf_sql_integer">
            AND CAST(A.appointment_datetime AS DATE) = CAST(GETDATE() AS DATE)
            ORDER BY A.appointment_datetime ASC
        </cfquery>

        <cfreturn qTodayList>
    </cffunction>

    <!--- Get Appointments for Doctor (appointments page) --->
    <cffunction name="getAppointments" access="public" returntype="query" output="false">
        <cfargument name="doctorID" type="numeric" required="true">

        <cfif NOT hasPermission("VIEW_MY_APPOINTMENTS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cfquery name="qAppointments" datasource="mms_db">
            SELECT 
                A.appointment_id,
                A.appointment_datetime,
                S.status_name,
                S.status_id,
                U.full_name AS patient_name
            FROM APPOINTMENTS A
            INNER JOIN PATIENTS P ON A.patient_id = P.patient_id
            INNER JOIN USERS U ON P.user_id = U.user_id
            INNER JOIN APPOINTMENT_STATUS S ON A.status_id = S.status_id
            WHERE A.doctor_id = 
            <cfqueryparam value="#arguments.doctorID#" cfsqltype="cf_sql_integer">
            AND CAST(A.appointment_datetime AS DATE)  = CAST(GETDATE() AS DATE)
            ORDER BY A.appointment_datetime ASC
        </cfquery>

        <cfreturn qAppointments>
    </cffunction>

    <!--- start consultaion button to update status and get write prescription --->
    <cffunction name="startConsultation" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="appointmentID" type="string" required="true">
        <cfset var result = {success=false,message=""}>
        <cfset secureService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset appointmentID = secureService.decryptID(arguments.appointmentID)>

        <cfif NOT hasPermission("UPDATE_APPOINTMENT_STATUS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfquery datasource="mms_db">
                UPDATE APPOINTMENTS
                SET status_id =
                (
                SELECT status_id
                FROM APPOINTMENT_STATUS
                WHERE status_name = 'In Progress'
                )
                WHERE appointment_id =
                <cfqueryparam value="#appointmentID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset result.success = true>
            <cfset result.message = "Consultation started">
        <cfcatch>
            <cfset result.message = cfcatch.message>
        </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>

    <!--- Complete Appointment  --->
    <cffunction name="completeAppointment" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="appointmentID" type="string" required="true">
        <cfset secureService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset appointmentID = secureService.decryptID(arguments.appointmentID)>
        <cfset var result = {success=false,message=""}>

        <cfif NOT hasPermission("UPDATE_APPOINTMENT_STATUS")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>

        <cftry>
            <cfquery datasource="mms_db">
                UPDATE APPOINTMENTS
                SET status_id = (
                    SELECT status_id 
                    FROM APPOINTMENT_STATUS
                    WHERE status_name = 'Completed'
                )
                WHERE appointment_id =
                <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset result.success = true>
            <cfset result.message = "Appointment marked completed">
            <cfcatch>
                <cfset result.message = cfcatch.message>
            </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>

    <!--- Delete Appointment --->
    <cffunction name="deleteAppointment" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="appointmentID" type="string" required="true">
        <cfset secureService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset appointmentID = secureService.decryptID(arguments.appointmentID)>
        <cfset var result = {success=false,message=""}>
        <cfif NOT hasPermission("DELETE_APPOINTMENT")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cftry>
            <cfquery datasource="mms_db">
                DELETE FROM APPOINTMENTS
                WHERE appointment_id =
                <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset result.success = true>
            <cfset result.message = "Appointment deleted">
            <cfcatch>
                <cfset result.message = cfcatch.message>
            </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>

    <cffunction name="prescriptionExists" access="public" returntype="boolean" output="false">
        <cfargument name="appointmentID" type="numeric" required="true">
        <cfquery name="qCheck" datasource="mms_db">
            SELECT prescription_id
            FROM PRESCRIPTIONS
            WHERE appointment_id = 
            <cfqueryparam value="#arguments.appointmentID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn qCheck.recordCount GT 0>
    </cffunction>

    <!--- Get Treated Patients List --->
    <cffunction name="getTreatedPatients" access="public" returntype="query">
        <cfargument name="doctorID" type="numeric" required="true">
        <cfquery name="qPatients" datasource="mms_db">
            SELECT DISTINCT
                p.patient_id,
                u.full_name,
                u.email,
                u.phone,
                p.gender,
                p.blood_group
            FROM APPOINTMENTS a
            INNER JOIN PATIENTS p ON a.patient_id = p.patient_id
            INNER JOIN USERS u ON p.user_id = u.user_id
            INNER JOIN PRESCRIPTIONS pr ON a.appointment_id = pr.appointment_id
            INNER JOIN APPOINTMENT_STATUS s ON a.status_id = s.status_id
            WHERE a.doctor_id = <cfqueryparam value="#arguments.doctorID#" cfsqltype="cf_sql_integer">
            AND s.status_name = 'Completed'
            ORDER BY u.full_name
        </cfquery>
        <cfreturn qPatients>
    </cffunction>


    <!--- Get Patient Full History --->
    <cffunction name="getPatientHistory" access="public" returntype="query">
        <cfargument name="doctorID" type="numeric" required="true">
        <cfargument name="patientID" type="numeric" required="true">

        <cfquery name="qHistory" datasource="mms_db">
            SELECT
                a.appointment_id,
                a.appointment_datetime,
                pr.prescription_id,
                pr.diagnosis,
                pr.notes,
                pr.prescription_date
            FROM APPOINTMENTS a
            INNER JOIN PRESCRIPTIONS pr ON a.appointment_id = pr.appointment_id
            WHERE a.doctor_id = <cfqueryparam value="#arguments.doctorID#" cfsqltype="cf_sql_integer">
            AND a.patient_id = <cfqueryparam value="#arguments.patientID#" cfsqltype="cf_sql_integer">
            ORDER BY a.appointment_datetime DESC
        </cfquery>

        <cfreturn qHistory>
    </cffunction>

</cfcomponent>