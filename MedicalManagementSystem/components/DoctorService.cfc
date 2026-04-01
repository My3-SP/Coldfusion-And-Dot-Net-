<cfcomponent output="false">
    <!---  GET ALL DOCTORS  --->
    <cffunction name="getAllDoctors" access="public" returntype="query">
        <cfquery name="qDoctors" datasource="mms_db">
            SELECT 
                d.doctor_id,
                d.user_id,
                u.full_name,
                u.username,
                u.email,
                u.phone,
                dp.dept_name,
                d.dept_id,
                d.specialization,
                d.qualification,
                d.experience_years,
                d.consultation_fee,
                d.is_active
            FROM DOCTORS d
            INNER JOIN USERS u ON d.user_id = u.user_id
            INNER JOIN DEPARTMENTS dp ON d.dept_id = dp.dept_id
            ORDER BY u.full_name
        </cfquery>
        <cfreturn qDoctors>
    </cffunction>

    <!---  GET DEPARTMENTS  --->
    <cffunction name="getDepartments" access="public" returntype="query">
        <cfquery name="qDepartments" datasource="mms_db">
            SELECT dept_id, dept_name
            FROM DEPARTMENTS
            WHERE is_active = 1
            ORDER BY dept_name
        </cfquery>
        <cfreturn qDepartments>
    </cffunction>

    <!---  ADD DOCTOR  --->
    <cffunction name="addDoctorAjax" access="remote" returntype="struct" returnformat="json" output="false">
         <!--- Arguments --->
        <cfargument name="full_name"        type="string"  required="true">
        <cfargument name="username"         type="string"  required="true">
        <cfargument name="email"            type="string"  required="true">
        <cfargument name="phone"            type="string"  required="true">
        <cfargument name="dept_id"          type="numeric" required="true">
        <cfargument name="specialization"   type="string"  required="true">
        <cfargument name="qualification"    type="string"  required="true">
        <cfargument name="experience_years" type="string"  required="false" default="">
        <cfargument name="consultation_fee" type="string"  required="false" default="">
        <cfargument name="created_by"       type="numeric" required="false" default="0">

        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>

        <cfset var result = { SUCCESS=false, MESSAGE="" }>

        <cfset var fullNameVal = trim(arguments.full_name)>
        <cfset var usernameVal = trim(arguments.username)>
        <cfset var emailVal    = trim(arguments.email)>
        <cfset var phoneVal    = trim(arguments.phone)>
        <cfset var expVal      = trim(arguments.experience_years)>
        <cfset var feeVal      = trim(arguments.consultation_fee)>

        <cftry>
        <!--- DUPLICATE CHECK --->
            <cfquery name="qDuplicate" datasource="mms_db">
                SELECT u.user_id, u.is_active, d.doctor_id, d.dept_id, dep.dept_name
                FROM USERS u
                LEFT JOIN DOCTORS d ON d.user_id = u.user_id
                LEFT JOIN DEPARTMENTS dep ON dep.dept_id = d.dept_id
                WHERE (u.username =
                    <cfqueryparam value="#usernameVal#" cfsqltype="cf_sql_nvarchar">
                    OR u.email =
                    <cfqueryparam value="#emailVal#" cfsqltype="cf_sql_nvarchar">)
                AND u.role_id = 2
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
                        email     = <cfqueryparam value="#emailVal#" cfsqltype="cf_sql_nvarchar">,
                        phone     = <cfqueryparam value="#phoneVal#" cfsqltype="cf_sql_nvarchar">,
                        is_active = 1
                    WHERE user_id =
                    <cfqueryparam value="#qDuplicate.user_id#" cfsqltype="cf_sql_integer">
                </cfquery>

                <cfquery datasource="mms_db">
                    UPDATE DOCTORS
                    SET is_active = 1
                    WHERE user_id =
                    <cfqueryparam value="#qDuplicate.user_id#" cfsqltype="cf_sql_integer">
                </cfquery>

                <cfset result.SUCCESS = true>
                <cfset result.MESSAGE = "Doctor reactivated successfully.">
                <cfset result.USER_ID = qDuplicate.user_id>
                <cfset result.DOCTOR_ID = qDuplicate.doctor_id>
                <cfset result.STATUS = "Active">

            <cfelse>

                <!--- HASH PASSWORD --->
                <cfset var defaultPassword = left(replace(createUUID(),"-","","all"),8)>
                <cfset var bcrypt = createObject("component","MedicalManagementSystem.libs.bcrypt")>
                <cfset var hashedPwd = bcrypt.hash(trim(defaultPassword))>

                <!--- INSERT USER --->
                <cfquery name="qInsertUser" datasource="mms_db">
                    INSERT INTO USERS
                    (username,password,role_id,full_name,email,phone,is_active,created_at,created_by)
                    OUTPUT INSERTED.user_id
                    VALUES(
                        <cfqueryparam value="#usernameVal#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#hashedPwd#" cfsqltype="cf_sql_nvarchar">,
                        2,
                        <cfqueryparam value="#fullNameVal#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#emailVal#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#phoneVal#" cfsqltype="cf_sql_nvarchar">,
                        1,
                        GETDATE(),
                        <cfqueryparam value="#arguments.created_by#" cfsqltype="cf_sql_integer">
                    )
                </cfquery>

                <cfset var newUserID = qInsertUser.user_id>

                <!--- INSERT DOCTOR --->
                <cfquery name="qInsertDoctor" datasource="mms_db">
                    INSERT INTO DOCTORS
                    (user_id,dept_id,specialization,qualification,experience_years,consultation_fee,is_active)
                    OUTPUT INSERTED.doctor_id
                    VALUES(
                        <cfqueryparam value="#newUserID#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#arguments.dept_id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#trim(arguments.specialization)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#trim(arguments.qualification)#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#expVal#" cfsqltype="cf_sql_integer" null="#NOT len(expVal)#">,
                        <cfqueryparam value="#feeVal#" cfsqltype="cf_sql_decimal" null="#NOT len(feeVal)#">,
                        1
                    )
                </cfquery>
                <!--- Get department name --->
                <cfquery name="qDept" datasource="mms_db">
                    SELECT dept_name
                    FROM DEPARTMENTS
                    WHERE dept_id =
                    <cfqueryparam value="#arguments.dept_id#" cfsqltype="cf_sql_integer">
                </cfquery>

                <!--- Send login email to patient --->
                <cfmail 
                    to="#emailVal#" 
                    from="cfmltestmail@gmail.com"
                    subject="Your Doctor Portal Account"
                    type="html">

                    Hello Dr. #fullNameVal#, <br><br>

                    Your Doctor portal account has been created by the hospital receptionist.<br><br>

                    <b>Username:</b> #usernameVal# <br>
                    <b>Temporary Password:</b> #defaultPassword# <br><br>

                    Please login and change your password after first login.<br><br>

                    <br>

                    Regards,<br>
                    Medical Management System

                </cfmail>

                <cfset result.SUCCESS   = true>
                <cfset result.MESSAGE   = "Doctor added successfully.">
                <cfset result.USER_ID   = newUserID>
                <cfset result.DOCTOR_ID = qInsertDoctor.doctor_id>
                <cfset result.STATUS    = "Active">

            </cfif>
            <!--- Common section below now runs for BOTH reactivation and new insert --->
            <cfset result.FULL_NAME    = fullNameVal>
            <cfset result.USERNAME     = usernameVal>
            <cfset result.EMAIL        = emailVal>
            <cfset result.DEPT_ID      = arguments.dept_id>
            <cfset result.DEPT_NAME    = qDuplicate.recordCount ? qDuplicate.dept_name : qDept.dept_name>
            <cfset result.EXPERIENCE   = expVal>
            <cfset result.FEE          = feeVal>
            <cfset result.ENC_USER_ID  = securityService.encryptID(result.USER_ID)>
            <cfset result.ENC_DOCTOR_ID = securityService.encryptID(result.DOCTOR_ID)>

        <cfcatch type="any">
            <cfset result.SUCCESS = false>
            <cfset result.MESSAGE = "Database error: " & cfcatch.message>
        </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>

    <!---  GET DOCTOR BY ID  --->
    <cffunction name="getDoctorById" access="public" returntype="query">
        <cfargument name="doctor_id" required="true">

        <cfquery name="qDoctor" datasource="mms_db">
            SELECT d.*, u.*
            FROM DOCTORS d
            INNER JOIN USERS u ON d.user_id = u.user_id
            WHERE d.doctor_id = <cfqueryparam value="#arguments.doctor_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfreturn qDoctor>
    </cffunction>

    <!---  UPDATE DOCTOR  --->
    <cffunction name="editDoctorAjax" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="enc_doctor_id"    type="string"  required="true">
        <cfargument name="enc_user_id"      type="string"  required="true">
        <cfargument name="full_name"        type="string"  required="true">
        <cfargument name="username"         type="string"  required="true">
        <cfargument name="email"            type="string"  required="true">
        <cfargument name="phone"            type="string"  required="true">
        <cfargument name="dept_id"          type="numeric" required="true">
        <cfargument name="specialization"   type="string"  required="true">
        <cfargument name="qualification"    type="string"  required="true">
        <cfargument name="experience_years" type="string"  required="false" default="">
        <cfargument name="consultation_fee" type="string"  required="false" default="">

        <cfset var result = { SUCCESS = false, MESSAGE = "" }>

        <!--- Server-side validation --->
        <cfif NOT len(trim(arguments.full_name)) OR len(trim(arguments.full_name)) LT 3
            OR NOT reFind("^[A-Za-z\s]+$", trim(arguments.full_name))>
            <cfset result.MESSAGE = "Full name must be at least 3 letters (alphabets only).">
            <cfreturn result>
        </cfif>

        <cfif NOT len(trim(arguments.username)) OR len(trim(arguments.username)) LT 4
            OR NOT reFind("^[A-Za-z0-9_]+$", trim(arguments.username))>
            <cfset result.MESSAGE = "Username must be at least 4 characters (letters, numbers, underscore).">
            <cfreturn result>
        </cfif>

        <cfif NOT isValid("email", trim(arguments.email))>
            <cfset result.MESSAGE = "Please enter a valid email address.">
            <cfreturn result>
        </cfif>

        <cfif NOT reFind("^\d{10}$", trim(arguments.phone))>
            <cfset result.MESSAGE = "Phone must be exactly 10 digits.">
            <cfreturn result>
        </cfif>

        <cfif NOT arguments.dept_id GT 0>
            <cfset result.MESSAGE = "Please select a department.">
            <cfreturn result>
        </cfif>

        <cfif NOT len(trim(arguments.specialization)) OR len(trim(arguments.specialization)) LT 3>
            <cfset result.MESSAGE = "Specialization must be at least 3 characters.">
            <cfreturn result>
        </cfif>

        <cfif NOT len(trim(arguments.qualification))>
            <cfset result.MESSAGE = "Qualification is required.">
            <cfreturn result>
        </cfif>

        <cfif len(trim(arguments.experience_years)) AND
            (NOT isNumeric(arguments.experience_years) OR arguments.experience_years LT 0)>
            <cfset result.MESSAGE = "Experience must be a positive number.">
            <cfreturn result>
        </cfif>

        <cfif len(trim(arguments.consultation_fee)) AND
            (NOT isNumeric(arguments.consultation_fee) OR arguments.consultation_fee LT 0)>
            <cfset result.MESSAGE = "Consultation fee must be a positive number.">
            <cfreturn result>
        </cfif>

        <!--- Decrypt IDs --->
        <cfset var secSvc   = "">
        <cfset var doctorID = 0>
        <cfset var userID   = 0>

        <cftry>
            <cfset secSvc   = createObject("component","MedicalManagementSystem.components.SecurityService")>
            <cfset doctorID = secSvc.decryptID(arguments.enc_doctor_id)>
            <cfset userID   = secSvc.decryptID(arguments.enc_user_id)>
        <cfcatch type="any">
            <cfset result.MESSAGE = "Invalid request — could not decrypt IDs.">
            <cfreturn result>
        </cfcatch>
        </cftry>

        <!--- Duplicate check excluding self --->
        <cfquery name="qDupCheck" datasource="mms_db">
            SELECT user_id FROM USERS
            WHERE (username = <cfqueryparam value="#trim(arguments.username)#" cfsqltype="cf_sql_varchar">
            OR  email    = <cfqueryparam value="#trim(arguments.email)#"    cfsqltype="cf_sql_varchar">)
            AND user_id != <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif qDupCheck.recordCount GT 0>
            <cfset result.MESSAGE = "Username or Email already exists.">
            <cfreturn result>
        </cfif>

        <cfset var expVal = trim(arguments.experience_years)>
        <cfset var feeVal = trim(arguments.consultation_fee)>

        <!--- Update DB --->
        <cftry>
            <cfquery datasource="mms_db">
                UPDATE USERS SET
                    full_name = <cfqueryparam value="#trim(arguments.full_name)#" cfsqltype="cf_sql_varchar">,
                    username  = <cfqueryparam value="#trim(arguments.username)#"  cfsqltype="cf_sql_varchar">,
                    email     = <cfqueryparam value="#trim(arguments.email)#"     cfsqltype="cf_sql_varchar">,
                    phone     = <cfqueryparam value="#trim(arguments.phone)#"     cfsqltype="cf_sql_varchar">
                WHERE user_id = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfquery datasource="mms_db">
                UPDATE DOCTORS SET
                    dept_id          = <cfqueryparam value="#arguments.dept_id#"              cfsqltype="cf_sql_integer">,
                    specialization   = <cfqueryparam value="#trim(arguments.specialization)#" cfsqltype="cf_sql_varchar">,
                    qualification    = <cfqueryparam value="#trim(arguments.qualification)#"  cfsqltype="cf_sql_varchar">,
                    experience_years = <cfqueryparam value="#expVal#" cfsqltype="cf_sql_integer"
                                                    null="#NOT len(expVal)#">,
                    consultation_fee = <cfqueryparam value="#feeVal#" cfsqltype="cf_sql_decimal"
                                                    null="#NOT len(feeVal)#">
                WHERE doctor_id = <cfqueryparam value="#doctorID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfquery name="qDept" datasource="mms_db">
                SELECT dept_name FROM DEPARTMENTS
                WHERE dept_id = <cfqueryparam value="#arguments.dept_id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.SUCCESS    = true>
            <cfset result.MESSAGE    = "Doctor updated successfully.">
            <cfset result.DEPT_NAME  = qDept.dept_name>
            <cfset result.EXPERIENCE = expVal>
            <cfset result.FEE        = feeVal>

        <cfcatch type="any">
            <cfset result.SUCCESS = false>
            <cfset result.MESSAGE = "Database error: " & cfcatch.message>
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>


<cffunction name="toggleStatus" access="remote" returntype="struct" returnformat="json" output="false">
    <cfargument name="enc_doctor_id" type="string" required="yes">
    <cfargument name="enc_user_id"   type="string" required="yes">
    <cfargument name="new_status"    type="string" required="yes">

    <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
    <cfset var result = { SUCCESS=false, MESSAGE="" }>

    <cftry>
        <cfset var doctorID = securityService.decryptID(arguments.enc_doctor_id)>
        <cfset var userID   = securityService.decryptID(arguments.enc_user_id)>
        <cfset var isActive = (arguments.new_status EQ "Active") ? 1 : 0>

        <!--- Block inactivation if doctor has upcoming/active appointments --->
        <cfif isActive EQ 0>
            <cfquery name="qCheck" datasource="mms_db">
                SELECT COUNT(*) AS apptCount
                FROM   APPOINTMENTS a
                JOIN   APPOINTMENT_STATUS s ON a.status_id = s.status_id
                WHERE  a.doctor_id = <cfqueryparam value="#doctorID#" cfsqltype="cf_sql_integer">
                AND    s.status_name IN ('Booked', 'In Progress')
            </cfquery>

            <cfif qCheck.apptCount GT 0>
                <cfset result.MESSAGE = "Cannot deactivate. This doctor has #qCheck.apptCount# active or upcoming appointment(s).">
                <cfreturn result>
            </cfif>
        </cfif>

        <cfquery datasource="mms_db">
            UPDATE USERS SET
                is_active = <cfqueryparam value="#isActive#" cfsqltype="cf_sql_integer">
            WHERE user_id = <cfqueryparam value="#userID#"   cfsqltype="cf_sql_integer">
        </cfquery>

        <cfquery datasource="mms_db">
            UPDATE DOCTORS SET
                is_active = <cfqueryparam value="#isActive#" cfsqltype="cf_sql_integer">
            WHERE doctor_id = <cfqueryparam value="#doctorID#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.SUCCESS    = true>
        <cfset result.MESSAGE    = "Doctor status updated successfully.">
        <cfset result.NEW_STATUS = arguments.new_status>

    <cfcatch type="any">
        <cfset result.SUCCESS = false>
        <cfset result.MESSAGE = "Error: " & cfcatch.message>
    </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>

</cfcomponent>