<cfcomponent output="false">
    <!--- Get Dashboard Stats --->
    <cffunction name="getStats" access="public" returntype="query">
        <cfquery name="qStats" datasource="mms_db">
            SELECT 
                (SELECT COUNT(*) FROM USERS) AS totalUsers,
                (SELECT COUNT(*) FROM DOCTORS) AS totalDoctors,
                (SELECT COUNT(*) FROM PATIENTS) AS totalPatients,
                (SELECT COUNT(*) FROM DEPARTMENTS) AS totalDepartments
        </cfquery>

        <cfreturn qStats>
    </cffunction>

    <!--- Get All Users --->
    <cffunction name="getUsers" access="public" returntype="query">
        <cfquery name="qUsers" datasource="mms_db">
            SELECT u.user_id, u.username, u.full_name, r.role_name, 
                   u.email, u.phone, u.is_active
            FROM USERS u
            JOIN ROLES r ON u.role_id = r.role_id
            ORDER BY u.user_id DESC
        </cfquery>

        <cfreturn qUsers>
    </cffunction>

    <!--- Update User --->
    <cffunction name="updateUser" access="remote" returntype="struct" returnformat="json" output="false">

        <cfargument name="enc_user_id" type="string" required="true">
        <cfargument name="fullName"    type="string" required="true">
        <cfargument name="email"       type="string" required="true">
        <cfargument name="phone"       type="string" required="false" default="">
        <cfargument name="isActive"    type="numeric" required="false" default="1">
        <cfargument name="updatedBy"   type="numeric" required="false" default="0">

        <cfset var result = { SUCCESS=false, MESSAGE="" }>
        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>

        <cftry>

            <!--- Decrypt ID --->
            <cfset var userID = securityService.decryptID(arguments.enc_user_id)>

            <!--- Validation --->
            <cfif NOT len(trim(arguments.fullName)) OR len(trim(arguments.fullName)) LT 3>
                <cfset result.MESSAGE = "Full Name must be at least 3 characters.">
                <cfreturn result>
            </cfif>

            <cfif NOT isValid("email", trim(arguments.email))>
                <cfset result.MESSAGE = "Please enter a valid email address.">
                <cfreturn result>
            </cfif>

            <!--- Duplicate email check --->
            <cfquery name="qCheckEmail" datasource="mms_db">
                SELECT user_id
                FROM USERS
                WHERE email = <cfqueryparam value="#trim(arguments.email)#" cfsqltype="cf_sql_varchar">
                AND user_id != <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif qCheckEmail.recordCount GT 0>
                <cfset result.MESSAGE = "This email is already used by another user.">
                <cfreturn result>
            </cfif>
            <!--- Update query --->
            <cfquery datasource="mms_db">
                UPDATE USERS
                SET
                    full_name = <cfqueryparam value="#trim(arguments.fullName)#" cfsqltype="cf_sql_varchar">,
                    email     = <cfqueryparam value="#trim(arguments.email)#" cfsqltype="cf_sql_varchar">,
                    phone     = <cfqueryparam value="#trim(arguments.phone)#" cfsqltype="cf_sql_varchar">,
                    is_active = <cfqueryparam value="#arguments.isActive#" cfsqltype="cf_sql_integer">
                WHERE user_id = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset result.SUCCESS = true>
            <cfset result.MESSAGE = "User updated successfully">
        <cfcatch>
            <cfset result.SUCCESS = false>
            <cfset result.MESSAGE = cfcatch.message>
        </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>

    <!--- soft delete/ active-inactive --->

    <cffunction name="toggleStatus" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="enc_user_id" type="string" required="yes">
        <cfargument name="new_status"  type="string" required="yes">

        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset var result = { SUCCESS=false, MESSAGE="" }>

        <cftry>
            <cfset var userID   = securityService.decryptID(arguments.enc_user_id)>
            <cfset var isActive = (arguments.new_status EQ "Active") ? 1 : 0>

            <!--- Block deactivation if user has active appointments --->
            <cfif isActive EQ 0>

                <!--- Check if this user is a doctor --->
                <cfquery name="qDoctor" datasource="mms_db">
                    SELECT doctor_id
                    FROM   DOCTORS
                    WHERE  user_id   = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
                    AND    is_active = 1
                </cfquery>

                <cfif qDoctor.recordCount GT 0>
                    <cfquery name="qDoctorAppt" datasource="mms_db">
                        SELECT COUNT(*) AS apptCount
                        FROM   APPOINTMENTS a
                        JOIN   APPOINTMENT_STATUS s ON a.status_id = s.status_id
                        WHERE  a.doctor_id     = <cfqueryparam value="#qDoctor.doctor_id#" cfsqltype="cf_sql_integer">
                        AND    s.status_name  IN ('Booked', 'In Progress')
                    </cfquery>

                    <cfif qDoctorAppt.apptCount GT 0>
                        <cfset result.MESSAGE = "Cannot deactivate. This doctor has #qDoctorAppt.apptCount# active or upcoming appointment(s).">
                        <cfreturn result>
                    </cfif>
                </cfif>

                <!--- Check if this user is a patient --->
                <cfquery name="qPatient" datasource="mms_db">
                    SELECT patient_id
                    FROM   PATIENTS
                    WHERE  user_id   = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
                    AND    is_active = 1
                </cfquery>

                <cfif qPatient.recordCount GT 0>
                    <cfquery name="qPatientAppt" datasource="mms_db">
                        SELECT COUNT(*) AS apptCount
                        FROM   APPOINTMENTS a
                        JOIN   APPOINTMENT_STATUS s ON a.status_id = s.status_id
                        WHERE  a.patient_id    = <cfqueryparam value="#qPatient.patient_id#" cfsqltype="cf_sql_integer">
                        AND    s.status_name  IN ('Booked', 'In Progress')
                    </cfquery>

                    <cfif qPatientAppt.apptCount GT 0>
                        <cfset result.MESSAGE = "Cannot deactivate. This patient has #qPatientAppt.apptCount# active or upcoming appointment(s).">
                        <cfreturn result>
                    </cfif>
                </cfif>

            </cfif>

            <cfquery datasource="mms_db">
                UPDATE USERS
                SET    is_active = <cfqueryparam value="#isActive#" cfsqltype="cf_sql_integer">
                WHERE  user_id   = <cfqueryparam value="#userID#"   cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.SUCCESS = true>
            <cfset result.MESSAGE = "Status updated successfully.">

        <cfcatch type="any">
            <cfset result.SUCCESS = false>
            <cfset result.MESSAGE = cfcatch.message>
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>
