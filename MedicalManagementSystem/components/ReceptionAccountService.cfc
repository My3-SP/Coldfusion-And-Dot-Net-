<cfcomponent displayname="AdminAccountService">

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

    <!--- Get Admin Details --->
    <cffunction name="getReceptionDetails" access="public" returntype="struct" output="false">
        <cfargument name="user_id" type="numeric" required="true">
        <cfquery name="q" datasource="mms_db">
            SELECT u.user_id, u.username, u.full_name, u.email, u.phone, u.password
            FROM USERS u
            WHERE u.user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
            AND role_id = 3
        </cfquery>
        <cfreturn q.recordCount ? q.getRow(1) : structNew()>
    </cffunction>

<!---  Update personal details  --->
    <cffunction name="updateReceptionDetailsAjax" access="remote" returntype="struct" returnformat="json" output="false">

        <cfargument name="enc_user_id" required="true">
        <cfargument name="full_name" required="true">
        <cfargument name="username" required="true">
        <cfargument name="email" required="true">
        <cfargument name="phone" required="true">

        <cfset var result = {SUCCESS=false, MESSAGE=""}>
        <cfset var securityService = createObject("component","MedicalManagementSystem.components.securityService")>
        <cfset var userID = securityService.decryptID(arguments.enc_user_id)>

        <cfif NOT hasPermission("UPDATE_PROFILE")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cftry>

            <!--- Trim values --->
            <cfset var full_name = trim(arguments.full_name)>
            <cfset var username = trim(arguments.username)>
            <cfset var email = trim(arguments.email)>
            <cfset var phone = trim(arguments.phone)>

            <!--- VALIDATIONS --->
            <cfif NOT len(full_name)>
                <cfset result.MESSAGE = "Full name is required">
                <cfreturn result>
            </cfif>
            <cfif NOT reFind("^[A-Za-z.\- ]+$", full_name)>
                <cfset result.MESSAGE = "Invalid full name format">
                <cfreturn result>
            </cfif>
            <cfif NOT isValid("email", email)>
                <cfset result.MESSAGE = "Invalid email address">
                <cfreturn result>
            </cfif>
            <cfif NOT reFind("^\d{10}$", phone)>
                <cfset result.MESSAGE = "Phone must be 10 digits">
                <cfreturn result>
            </cfif>
            <!--- DUPLICATE USERNAME CHECK --->
            <cfquery name="qUserCheck" datasource="mms_db">
                SELECT user_id
                FROM USERS
                WHERE username =
                <cfqueryparam value="#username#" cfsqltype="cf_sql_varchar">
                AND user_id !=
                <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfif qUserCheck.recordCount>
                <cfset result.MESSAGE = "Username already exists">
                <cfreturn result>
            </cfif>
            <!--- DUPLICATE EMAIL CHECK --->
            <cfquery name="qEmailCheck" datasource="mms_db">
                SELECT user_id
                FROM USERS
                WHERE email =
                <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
                AND user_id !=
                <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfif qEmailCheck.recordCount>
                <cfset result.MESSAGE = "Email already exists">
                <cfreturn result>
            </cfif>
            <!--- UPDATE USER --->
            <cfquery datasource="mms_db">
                UPDATE USERS
                SET
                full_name =
                <cfqueryparam value="#full_name#" cfsqltype="cf_sql_varchar">,
                username =
                <cfqueryparam value="#username#" cfsqltype="cf_sql_varchar">,
                email =
                <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">,
                phone =
                <cfqueryparam value="#phone#" cfsqltype="cf_sql_varchar">,
                updated_at = GETDATE(),
                updated_by =
                <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
                WHERE user_id =
                <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset result.SUCCESS = true>
            <cfset result.MESSAGE = "Profile updated successfully">
            <cfcatch>
                <cfset result.MESSAGE = "Error updating profile">
            </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>
</cfcomponent>