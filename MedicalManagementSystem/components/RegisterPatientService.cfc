<cfcomponent displayName="RegisterPatientService" output="false">


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

    <!--- Get All Patients --->
    <cffunction name="getAllPatients" access="public" returntype="query">
        <cfquery name="qPatients" datasource="mms_db">
            SELECT p.patient_id, p.user_id, u.username, u.full_name, 
                   u.email, u.phone, p.date_of_birth, p.gender, p.blood_group,
                   p.address_line1, p.address_line2, p.city, p.state, 
                   p.postal_code, p.country, 
                   p.emergency_contact_name, p.emergency_contact_phone,
                   p.registration_date,
                   p.is_active
            FROM PATIENTS p
            JOIN USERS u ON u.user_id = p.user_id
            ORDER BY p.patient_id DESC
        </cfquery>
        <cfreturn qPatients>
    </cffunction>

    <!--- Check Duplicate Username/Email --->
    <cffunction name="checkDuplicateUser" access="public" returntype="query">
        <cfargument name="username" required="true">
        <cfargument name="email" required="true">
        <cfargument name="excludeUserId" required="false" default="0">

        <cfquery name="checkUser" datasource="mms_db">
            SELECT user_id
            FROM USERS
            WHERE is_active = 1
            AND (
                username = <cfqueryparam value="#arguments.username#" cfsqltype="cf_sql_nvarchar">
                OR
                email = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_nvarchar">
            )

            <cfif arguments.excludeUserId GT 0>
                AND user_id != <cfqueryparam value="#arguments.excludeUserId#" cfsqltype="cf_sql_integer">
            </cfif>
        </cfquery>

        <cfreturn checkUser>
    </cffunction>

    <!--- Insert Patient --->
    <cffunction name="addPatientAjax" access="remote" returntype="struct" returnformat="json" output="false">

        <cfargument name="full_name"       type="string"  required="true">
        <cfargument name="username"        type="string"  required="true">
        <cfargument name="email"           type="string"  required="true">
        <cfargument name="phone"           type="string"  required="true">
        <cfargument name="dob"             type="string"  required="false" default="">
        <cfargument name="gender"          type="string"  required="false" default="">
        <cfargument name="blood_group"     type="string"  required="false" default="">
        <cfargument name="address1"        type="string"  required="false" default="">
        <cfargument name="address2"        type="string"  required="false" default="">
        <cfargument name="city"            type="string"  required="false" default="">
        <cfargument name="state"           type="string"  required="false" default="">
        <cfargument name="postal_code"     type="string"  required="false" default="">
        <cfargument name="country"         type="string"  required="false" default="">
        <cfargument name="emergency_name"  type="string"  required="true">
        <cfargument name="emergency_phone" type="string"  required="true">
        <cfargument name="created_by"      type="numeric" required="false" default="0">

        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <!--- Generate default password --->
        <cfset var result = { SUCCESS=false, MESSAGE="" }>

        <cfset var fullNameVal = trim(arguments.full_name)>
        <cfset var usernameVal = trim(arguments.username)>
        <cfset var emailVal    = trim(arguments.email)>
        <cfset var phoneVal    = trim(arguments.phone)>
        <cfset var dobVal      = trim(arguments.dob)>

        <cfif NOT hasPermission("ADD_PATIENT")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cftry>

            <!--- DUPLICATE CHECK --->
            <cfquery name="qDuplicate" datasource="mms_db">
                SELECT u.user_id, u.is_active, p.patient_id
                FROM USERS u
                LEFT JOIN PATIENTS p ON p.user_id = u.user_id
                WHERE (u.username = <cfqueryparam value="#usernameVal#" cfsqltype="cf_sql_nvarchar">
                    OR u.email    = <cfqueryparam value="#emailVal#"    cfsqltype="cf_sql_nvarchar">)
                AND u.role_id = 4
            </cfquery>

            <!--- IF EXISTS --->
            <cfif qDuplicate.recordCount GT 0>

                <!--- If already active --->
                <cfif qDuplicate.is_active EQ 1>
                    <cfset result.MESSAGE = "Username or Email already exists and is Active.">
                    <cfreturn result>
                </cfif>

                <!--- Reactivate --->
                <cfquery datasource="mms_db">
                    UPDATE USERS
                    SET full_name = <cfqueryparam value="#fullNameVal#" cfsqltype="cf_sql_nvarchar">,
                        email     = <cfqueryparam value="#emailVal#"    cfsqltype="cf_sql_nvarchar">,
                        phone     = <cfqueryparam value="#phoneVal#"    cfsqltype="cf_sql_nvarchar">,
                        is_active = 1
                    WHERE user_id = <cfqueryparam value="#qDuplicate.user_id#" cfsqltype="cf_sql_integer">
                </cfquery>

                <cfquery datasource="mms_db">
                    UPDATE PATIENTS
                    SET is_active = 1
                    WHERE user_id = <cfqueryparam value="#qDuplicate.user_id#" cfsqltype="cf_sql_integer">
                </cfquery>

                <cfset result.SUCCESS = true>
                <cfset result.MESSAGE = "Patient reactivated successfully.">
                <cfset result.USER_ID = qDuplicate.user_id>
                <cfset result.PATIENT_ID = qDuplicate.patient_id>
                <cfset result.STATUS = "Active">

            <cfelse>

                <!--- HASH PASSWORD --->
                <cfset var defaultPassword = left(replace(createUUID(),"-","","all"),8)>
                <cfset var bcrypt = createObject("component","MedicalManagementSystem.libs.bcrypt")>
                <cfset var hashedPwd = bcrypt.hash(defaultPassword)>

                <!--- INSERT USER --->
                <cfquery name="qInsertUser" datasource="mms_db">
                    INSERT INTO USERS
                    (username, password, role_id, full_name, email, phone, is_active, created_at, created_by)
                    OUTPUT INSERTED.user_id
                    VALUES(
                        <cfqueryparam value="#usernameVal#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#hashedPwd#"   cfsqltype="cf_sql_nvarchar">,
                        4,
                        <cfqueryparam value="#fullNameVal#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#emailVal#"    cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#phoneVal#"    cfsqltype="cf_sql_nvarchar">,
                        1, GETDATE(),
                        <cfqueryparam value="#arguments.created_by#" cfsqltype="cf_sql_integer">
                    )
                </cfquery>

                <cfset var newUserID = qInsertUser.user_id>         

                <!--- INSERT PATIENT --->
                <cfquery name="qInsertPatient" datasource="mms_db">
                    INSERT INTO PATIENTS
                    (user_id, date_of_birth, gender, blood_group,
                    address_line1, address_line2, city, state,
                    postal_code, country,
                    emergency_contact_name, emergency_contact_phone,
                    registration_date, is_active)
                    OUTPUT INSERTED.patient_id
                    VALUES(
                        <cfqueryparam value="#newUserID#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#dobVal#" cfsqltype="cf_sql_date" null="#NOT len(dobVal)#">,
                        <cfqueryparam value="#trim(arguments.gender)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#trim(arguments.blood_group)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#trim(arguments.address1)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#trim(arguments.address2)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#trim(arguments.city)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#trim(arguments.state)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#trim(arguments.postal_code)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#trim(arguments.country)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#trim(arguments.emergency_name)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#trim(arguments.emergency_phone)#" cfsqltype="cf_sql_nvarchar">,
                        GETDATE(), 1
                    )
                </cfquery>
                
                <!--- Send login email to patient --->
                
                <cfmail 
                    to="#emailVal#" 
                    from="hospital@yourdomain.com"
                    subject="Your Patient Portal Account"
                    type="html">

                    Hello #fullNameVal#, <br><br>

                    Your patient portal account has been created by the hospital receptionist.<br><br>

                    <b>Username:</b> #usernameVal# <br>
                    <b>Temporary Password:</b> #defaultPassword# <br><br>

                    Please login and change your password after first login.<br><br>
                    <br><br>

                    Regards,<br>
                    Medical Management System

                </cfmail>
                <cfset result.SUCCESS = true>
                <cfset result.MESSAGE = "Patient added successfully.Login credentials have been sent to the patient's email.">
                <cfset result.USER_ID = newUserID>
                <cfset result.PATIENT_ID = qInsertPatient.patient_id>
                <cfset result.STATUS = "Active">

            </cfif>

            <!--- COMMON RETURN VALUES --->
            <cfset result.FULL_NAME   = fullNameVal>
            <cfset result.USERNAME    = usernameVal>
            <cfset result.PHONE       = phoneVal>
            <cfset result.GENDER      = trim(arguments.gender)>
            <cfset result.DOB         = len(dobVal) ? dateFormat(dobVal,"dd-mmm-yyyy") : "">
            <cfset result.BLOOD_GROUP = trim(arguments.blood_group)>
            <cfset result.CITY        = trim(arguments.city)>
            <cfset result.ENC_USER_ID    = securityService.encryptID(result.USER_ID)>
            <cfset result.ENC_PATIENT_ID = securityService.encryptID(result.PATIENT_ID)>

            <cfcatch type="any">
                <cfset result.SUCCESS = false>
                <cfset result.MESSAGE = "Database error: " & cfcatch.message>
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <!--- Update Patient --->
    <cffunction name="editPatientAjax" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="enc_patient_id"  type="string"  required="true">
        <cfargument name="enc_user_id"     type="string"  required="true">
        <cfargument name="full_name"       type="string"  required="true">
        <cfargument name="email"           type="string"  required="true">
        <cfargument name="phone"           type="string"  required="true">
        <cfargument name="dob"             type="string"  required="false" default="">
        <cfargument name="gender"          type="string"  required="false" default="">
        <cfargument name="blood_group"     type="string"  required="false" default="">
        <cfargument name="address1"        type="string"  required="false" default="">
        <cfargument name="address2"        type="string"  required="false" default="">
        <cfargument name="city"            type="string"  required="false" default="">
        <cfargument name="state"           type="string"  required="false" default="">
        <cfargument name="postal_code"     type="string"  required="false" default="">
        <cfargument name="country"         type="string"  required="false" default="">
        <cfargument name="emergency_name"  type="string"  required="false" default="">
        <cfargument name="emergency_phone" type="string"  required="false" default="">
        <cfargument name="updated_by"      type="numeric" required="false" default="0">

        <cfset var result = { SUCCESS=false, MESSAGE="" }>

        <cfif NOT hasPermission("EDIT_PATIENT")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <!--- Server-side validation --->
        <cfif len(trim(arguments.full_name)) EQ 0>
            <cfset result.MESSAGE = "Full Name is required.">
            <cfreturn result>
        </cfif>
        <cfif len(trim(arguments.email)) EQ 0 OR NOT isValid("email", trim(arguments.email))>
            <cfset result.MESSAGE = "A valid Email is required.">
            <cfreturn result>
        </cfif>
        <cfif len(trim(arguments.phone)) EQ 0>
            <cfset result.MESSAGE = "Phone is required.">
            <cfreturn result>
        </cfif>

        <!--- Decrypt IDs server-side --->
        <cftry>
            <cfset var secSvc     = createObject("component","MedicalManagementSystem.components.SecurityService")>
            <cfset var patientID  = secSvc.decryptID(arguments.enc_patient_id)>
            <cfset var userID     = secSvc.decryptID(arguments.enc_user_id)>
        <cfcatch type="any">
            <cfset result.MESSAGE = "Invalid request — could not decrypt IDs.">
            <cfreturn result>
        </cfcatch>
        </cftry>

        <!--- Duplicate Email Check (exclude current user) --->
        <cfset var checkUser = checkDuplicateUser(
            "", 
            trim(arguments.email),
            userID
        )>

        <cfif checkUser.recordCount GT 0>
            <cfset result.SUCCESS = false>
            <cfset result.MESSAGE = "Email already exists.">
            <cfreturn result>
        </cfif>

        <cfset var dobVal = trim(arguments.dob)>

        <cftry>
            <cfquery datasource="mms_db">
                UPDATE USERS SET
                    full_name  = <cfqueryparam value="#trim(arguments.full_name)#"  cfsqltype="cf_sql_nvarchar">,
                    email      = <cfqueryparam value="#trim(arguments.email)#"      cfsqltype="cf_sql_nvarchar">,
                    phone      = <cfqueryparam value="#trim(arguments.phone)#"      cfsqltype="cf_sql_nvarchar">,
                    updated_at = GETDATE(),
                    updated_by = <cfqueryparam value="#arguments.updated_by#"       cfsqltype="cf_sql_integer">
                WHERE user_id  = <cfqueryparam value="#userID#"                     cfsqltype="cf_sql_integer">
            </cfquery>

            <cfquery datasource="mms_db">
                UPDATE PATIENTS SET
                    date_of_birth          = <cfqueryparam value="#dobVal#"                          cfsqltype="cf_sql_date"    null="#NOT len(dobVal)#">,
                    gender                 = <cfqueryparam value="#trim(arguments.gender)#"          cfsqltype="cf_sql_nvarchar">,
                    blood_group            = <cfqueryparam value="#trim(arguments.blood_group)#"     cfsqltype="cf_sql_nvarchar">,
                    address_line1          = <cfqueryparam value="#trim(arguments.address1)#"        cfsqltype="cf_sql_nvarchar">,
                    address_line2          = <cfqueryparam value="#trim(arguments.address2)#"        cfsqltype="cf_sql_nvarchar">,
                    city                   = <cfqueryparam value="#trim(arguments.city)#"            cfsqltype="cf_sql_nvarchar">,
                    state                  = <cfqueryparam value="#trim(arguments.state)#"           cfsqltype="cf_sql_nvarchar">,
                    postal_code            = <cfqueryparam value="#trim(arguments.postal_code)#"     cfsqltype="cf_sql_nvarchar">,
                    country                = <cfqueryparam value="#trim(arguments.country)#"         cfsqltype="cf_sql_nvarchar">,
                    emergency_contact_name = <cfqueryparam value="#trim(arguments.emergency_name)#"  cfsqltype="cf_sql_nvarchar">,
                    emergency_contact_phone= <cfqueryparam value="#trim(arguments.emergency_phone)#" cfsqltype="cf_sql_nvarchar">
                WHERE patient_id = <cfqueryparam value="#patientID#" cfsqltype="cf_sql_integer">
                  AND user_id    = <cfqueryparam value="#userID#"    cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.SUCCESS = true>
            <cfset result.MESSAGE = "Patient updated successfully.">

            <cfcatch type="any">
                <cfset result.MESSAGE = "Database error: " & cfcatch.message>
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <!--- Delete Patient / active-inactive--->
    <cffunction name="toggleStatus" access="remote" returntype="struct" returnformat="json" output="false">
    <cfargument name="enc_user_id" type="string" required="yes">
    <cfargument name="new_status"  type="string" required="yes">

    <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
    <cfset var result = { SUCCESS=false, MESSAGE="" }>


        <cfif NOT hasPermission("DELETE_PATIENT")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
    <cftry>
        <cfset var userID   = securityService.decryptID(arguments.enc_user_id)>
        <cfset var isActive = (arguments.new_status EQ "Active") ? 1 : 0>

        <!--- Block deactivation if patient has active/upcoming appointments --->
        <cfif isActive EQ 0>
            <cfquery name="qCheck" datasource="mms_db">
                SELECT COUNT(*) AS apptCount
                FROM   APPOINTMENTS a
                JOIN   APPOINTMENT_STATUS s ON a.status_id = s.status_id
                JOIN   PATIENTS p           ON a.patient_id = p.patient_id
                WHERE  p.user_id = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
                AND    s.status_name IN ('Booked', 'In Progress')
            </cfquery>

            <cfif qCheck.apptCount GT 0>
                <cfset result.MESSAGE = "Cannot deactivate. This patient has #qCheck.apptCount# active or upcoming appointment(s).">
                <cfreturn result>
            </cfif>
        </cfif>

        <cfquery datasource="mms_db">
            UPDATE USERS
            SET is_active = <cfqueryparam value="#isActive#" cfsqltype="cf_sql_integer">
            WHERE user_id = <cfqueryparam value="#userID#"   cfsqltype="cf_sql_integer">
        </cfquery>

        <cfquery datasource="mms_db">
            UPDATE PATIENTS
            SET is_active = <cfqueryparam value="#isActive#" cfsqltype="cf_sql_integer">
            WHERE user_id = <cfqueryparam value="#userID#"   cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.SUCCESS = true>
        <cfset result.MESSAGE = "Patient status updated successfully.">

    <cfcatch type="any">
        <cfset result.SUCCESS = false>
        <cfset result.MESSAGE = "Error: " & cfcatch.message>
    </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>

</cfcomponent>