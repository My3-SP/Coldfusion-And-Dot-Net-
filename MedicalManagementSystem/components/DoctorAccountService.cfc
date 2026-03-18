<cfcomponent displayname="DoctorAccountService" output="false">

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

    <!--- FETCH DETAILS --->
    <cffunction name="getDoctorDetails" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="userID" type="numeric" required="true">

        <cfquery name="q" datasource="mms_db">
            SELECT
                u.user_id,
                u.username,
                u.full_name,
                u.email,
                u.phone,
                d.doctor_id,
                d.specialization,
                d.qualification,
                d.experience_years,
                d.consultation_fee,
                d.is_active,
                dept.dept_name
            FROM       USERS       u
            JOIN       DOCTORS     d    ON u.user_id = d.user_id
            JOIN       DEPARTMENTS dept ON d.dept_id = dept.dept_id
            WHERE u.user_id = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfreturn q.recordCount GT 0 ? q.getRow(1) : structNew()>
    </cffunction>

    <!--- UPDATE DETAILS --->
    <cffunction name="updateDoctorDetails" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="enc_user_id" type="string" required="true">
        <cfargument name="full_name"   type="string" required="true">
        <cfargument name="username"    type="string" required="true">
        <cfargument name="email"       type="string" required="true">
        <cfargument name="phone"       type="string" required="false" default="">

        <cfset var result = { success = false, message = "" }>
        <cfset var securityService = createObject("component","MedicalManagementSystem.components.SecurityService")>
        <cfset var userID = securityService.decryptID(arguments.enc_user_id)>
                <cfif NOT hasPermission("UPDATE_PROFILE")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cftry>
            <!--- Validation --->
            <cfif NOT len(trim(arguments.full_name))>
                <cfset result.message = "Full name is required.">
                <cfreturn result>
            </cfif>

            <cfif NOT reFind("^[A-Za-z.\- ]+$", trim(arguments.full_name))>
                <cfset result.message = "Full name may only contain letters, spaces, dots and hyphens.">
                <cfreturn result>
            </cfif>

            <cfif len(trim(arguments.username)) LT 4>
                <cfset result.message = "Username must be at least 4 characters.">
                <cfreturn result>
            </cfif>

            <cfif NOT isValid("email", trim(arguments.email))>
                <cfset result.message = "Please enter a valid email address.">
                <cfreturn result>
            </cfif>

            <cfif len(trim(arguments.phone)) AND NOT reFind("^\d{10}$", trim(arguments.phone))>
                <cfset result.message = "Phone number must be exactly 10 digits.">
                <cfreturn result>
            </cfif>

            <!--- Duplicate checks --->
            <cfquery name="qUserCheck" datasource="mms_db">
                SELECT user_id FROM USERS
                WHERE  username = <cfqueryparam value="#trim(arguments.username)#" cfsqltype="cf_sql_varchar">
                AND    user_id != <cfqueryparam value="#userID#"                   cfsqltype="cf_sql_integer">
            </cfquery>
            <cfif qUserCheck.recordCount GT 0>
                <cfset result.message = "Username is already taken.">
                <cfreturn result>
            </cfif>

            <cfquery name="qEmailCheck" datasource="mms_db">
                SELECT user_id FROM USERS
                WHERE  email   = <cfqueryparam value="#trim(arguments.email)#" cfsqltype="cf_sql_varchar">
                AND    user_id != <cfqueryparam value="#userID#"                cfsqltype="cf_sql_integer">
            </cfquery>
            <cfif qEmailCheck.recordCount GT 0>
                <cfset result.message = "Email is already in use.">
                <cfreturn result>
            </cfif>

            <!--- Update --->
            <cfquery datasource="mms_db">
                UPDATE USERS SET
                    full_name  = <cfqueryparam value="#trim(arguments.full_name)#" cfsqltype="cf_sql_varchar">,
                    username   = <cfqueryparam value="#trim(arguments.username)#"  cfsqltype="cf_sql_varchar">,
                    email      = <cfqueryparam value="#trim(arguments.email)#"     cfsqltype="cf_sql_varchar">,
                    phone      = <cfqueryparam value="#trim(arguments.phone)#"     cfsqltype="cf_sql_varchar">,
                    updated_at = GETDATE(),
                    updated_by = <cfqueryparam value="#userID#"                    cfsqltype="cf_sql_integer">
                WHERE user_id  = <cfqueryparam value="#userID#"                    cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset session.user.full_name = trim(arguments.full_name)>
            <cfset session.user.username  = trim(arguments.username)>

            <cfset result.success = true>
            <cfset result.message = "Profile updated successfully.">

        <cfcatch type="any">
            <cfset result.success = false>
            <cfset result.message = "An error occurred: #cfcatch.message#">
        </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>

</cfcomponent>