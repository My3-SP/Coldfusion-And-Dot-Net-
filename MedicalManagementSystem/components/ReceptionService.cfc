<cfcomponent displayname="Reception Service" output="false">

    <!--- Get All Receptionists --->
    <cffunction name="getAllReceptionists" access="public" returntype="query">
        <cfquery name="q" datasource="mms_db">
            SELECT user_id, full_name, username, email, phone, is_active
            FROM USERS
            WHERE role_id = 3
            ORDER BY created_at DESC
        </cfquery>
        <cfreturn q>
    </cffunction>


    <!--- Add Receptionist  --->
    <cffunction name="addReceptionistAjax" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="full_name"   type="string"  required="true">
        <cfargument name="username"    type="string"  required="true">
        <cfargument name="email"       type="string"  required="true">
        <cfargument name="phone"       type="string"  required="true">
        <cfargument name="created_by"  type="numeric" required="true">

        <cfset var result          = {}>
        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset var defaultPassword = left(replace(createUUID(),"-","","all"),8)>
        <cfset var bcrypt          = createObject("component","MedicalManagementSystem.libs.bcrypt")>
        <cfset var hashedPassword  = bcrypt.hash(defaultPassword)>

        <cftry>
            <cfset var usernameVal = trim(arguments.username)>
            <cfset var emailVal    = trim(arguments.email)>
            <cfset var fullNameVal = trim(arguments.full_name)>
            <cfset var phoneVal    = trim(arguments.phone)>

            <!--- Duplicate check --->
            <cfquery name="qDuplicate" datasource="mms_db">
                SELECT user_id, is_active FROM USERS
                WHERE (username = <cfqueryparam value="#usernameVal#" cfsqltype="cf_sql_varchar">
                OR  email    = <cfqueryparam value="#emailVal#"    cfsqltype="cf_sql_varchar">)
                AND role_id = 3
            </cfquery>

            <cfif qDuplicate.recordCount GT 0>

                <!--- Already active — block --->
                <cfif qDuplicate.is_active EQ 1>
                    <cfset result.SUCCESS   = false>
                    <cfset result.MESSAGE   = "Username or Email already exists.">
                    <cfreturn result>
                </cfif>

                <!--- Inactive — reactivate --->
                <cfquery datasource="mms_db">
                    UPDATE USERS SET
                        full_name = <cfqueryparam value="#fullNameVal#" cfsqltype="cf_sql_varchar">,
                        username  = <cfqueryparam value="#usernameVal#" cfsqltype="cf_sql_varchar">,
                        email     = <cfqueryparam value="#emailVal#"    cfsqltype="cf_sql_varchar">,
                        phone     = <cfqueryparam value="#phoneVal#"    cfsqltype="cf_sql_varchar">,
                        password  = <cfqueryparam value="#hashedPassword#" cfsqltype="cf_sql_varchar">,
                        is_active = 1
                    WHERE user_id = <cfqueryparam value="#qDuplicate.user_id#" cfsqltype="cf_sql_integer">
                </cfquery>

                <cfset result.SUCCESS     = true>
                <cfset result.MESSAGE     = "Receptionist reactivated successfully.">
                <cfset result.USER_ID     = qDuplicate.user_id>
                
                <cfset result.ENC_USER_ID = securityService.encryptID(qDuplicate.user_id)>
                <cfreturn result>
            </cfif>

            <!--- Brand new insert --->
            <cfquery name="qInsert" datasource="mms_db" result="res">
                INSERT INTO USERS
                    (username, password, role_id, full_name, email, phone, created_by, is_active)
                VALUES (
                    <cfqueryparam value="#usernameVal#"            cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#hashedPassword#"         cfsqltype="cf_sql_varchar">,
                    3,
                    <cfqueryparam value="#fullNameVal#"            cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#emailVal#"               cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#phoneVal#"               cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.created_by#"   cfsqltype="cf_sql_integer">,
                    1
                )
            </cfquery>

            <cfset var newUserID = res.generatedKey>

            <cfmail
                to      = "#emailVal#"
                from    = "cfmltest@gmail.com"
                subject = "Your Receptionist Portal Account"
                type    = "html">
                Hello #fullNameVal#,<br><br>
                Your Receptionist portal account has been created.<br><br>
                <b>Username:</b> #usernameVal#<br>
                <b>Temporary Password:</b> #defaultPassword#<br><br>
                Please login and change your password after first login.<br><br>
                <br>
                Regards,<br>Medical Management System
            </cfmail>

            <cfset result.SUCCESS     = true>
            <cfset result.MESSAGE     = "Receptionist added successfully.">
            <cfset result.USER_ID     = newUserID>
            <!---  Return encrypted ID so JS can key receptionMap correctly ★ --->
            <cfset result.ENC_USER_ID = securityService.encryptID(newUserID)>

        <cfcatch type="any">
            <cfset result.SUCCESS = false>
            <cfset result.MESSAGE = "Something went wrong: #cfcatch.message#">
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <!--- Edit Receptionist --->
    <cffunction name="editReceptionistAjax" access="remote" returntype="struct" returnformat="json">
        <cfargument name="enc_user_id" type="string" required="true">
        <cfargument name="full_name" type="string" required="true">
        <cfargument name="username" type="string" required="true">
        <cfargument name="email" type="string" required="true">
        <cfargument name="phone" type="string" required="true">

        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset var result = {}>

        <cftry>

            <cfset userID = securityService.decryptID(arguments.enc_user_id)>

            <cfquery name="qDuplicate" datasource=mms_db>
                SELECT user_id
                FROM users
                WHERE (username = <cfqueryparam value="#arguments.username#" cfsqltype="cf_sql_varchar">
                    OR email = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">)
                AND role_id = 3
                AND is_active = 1 AND user_id != <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfif qDuplicate.recordCount GT 0>
                <cfset result.success = false>
                    <cfset result.errorType = "duplicate">
                    <cfset result.message = "Username already exists.">
                    <cfreturn result>
                <cfreturn result>
            </cfif>

            <cfquery datasource="mms_db">
                UPDATE USERS
                SET full_name = <cfqueryparam value="#arguments.full_name#" cfsqltype="cf_sql_varchar">,
                    username  = <cfqueryparam value="#arguments.username#" cfsqltype="cf_sql_varchar">,
                    email     = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
                    phone     = <cfqueryparam value="#arguments.phone#" cfsqltype="cf_sql_varchar">,
                    updated_at = GETDATE()
                WHERE user_id = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.success = true>
            <cfset result.message = "Receptionist updated successfully.">

        <cfcatch>
            <cfset result.success = false>
            <cfset result.message = cfcatch.message>
        </cfcatch>

        </cftry>

        <cfreturn result>
    </cffunction>

    <!--- soft delete/ active-inactive --->
    <cffunction name="toggleStatus" access="remote" returntype="struct">
        <cfargument name="enc_user_id" type="string" required="yes">
        <cfargument name="new_status" type="string" required="yes">

        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset var result = structNew()>
        <cftry>
            <cfset var userID = securityService.decryptID(arguments.enc_user_id)>
            <cfset var isActive = (arguments.new_status EQ 'Active') ? 1 : 0>

            <cfquery name="updateStatus" datasource=mms_db>
                UPDATE users
                SET is_active = <cfqueryparam value="#isActive#" cfsqltype="cf_sql_integer">
                WHERE user_id = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.SUCCESS = true>
            <cfset result.MESSAGE = "Status updated successfully">
        <cfcatch>
            <cfset result.SUCCESS = false>
            <cfset result.MESSAGE = cfcatch.message>
        </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>
</cfcomponent>