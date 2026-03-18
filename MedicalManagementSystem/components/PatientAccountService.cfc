<cfcomponent displayname="PatientAccountService" output="false">

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

    <!--- Feltch patient details --->
    <cffunction name="getPatientByUserID" access="public" returntype="struct" output="false">
        <cfargument name="user_id" type="numeric" required="true">

        <cfquery name="q" datasource="mms_db">
            SELECT u.user_id, u.username, u.full_name, u.email, u.phone, u.password,
                   p.patient_id, p.date_of_birth, p.gender, p.blood_group,
                   p.address_line1, p.address_line2, p.city, p.state, p.postal_code,
                   p.country, p.emergency_contact_name, p.emergency_contact_phone
            FROM   USERS u
            JOIN   PATIENTS p ON u.user_id = p.user_id
            WHERE  u.user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfreturn q.recordCount GT 0 ? q.getRow(1) : structNew()>
    </cffunction>

    <!---update patient details  --->
    <cffunction name="updatePatientDetails" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="enc_user_id"              type="string" required="true">
        <cfargument name="enc_patient_id"           type="string" required="true">
        <cfargument name="full_name"                type="string" required="true">
        <cfargument name="email"                    type="string" required="true">
        <cfargument name="phone"                    type="string" required="true">
        <cfargument name="date_of_birth"            type="string" required="false" default="">
        <cfargument name="gender"                   type="string" required="false" default="">
        <cfargument name="blood_group"              type="string" required="false" default="">
        <cfargument name="address_line1"            type="string" required="false" default="">
        <cfargument name="address_line2"            type="string" required="false" default="">
        <cfargument name="city"                     type="string" required="false" default="">
        <cfargument name="state"                    type="string" required="false" default="">
        <cfargument name="postal_code"              type="string" required="false" default="">
        <cfargument name="country"                  type="string" required="false" default="">
        <cfargument name="emergency_contact_name"   type="string" required="false" default="">
        <cfargument name="emergency_contact_phone"  type="string" required="false" default="">

        <cfset var result          = { success = false, message = "" }>
        <cfset var securityService = createObject("component","MedicalManagementSystem.components.securityService")>
        <cfset var userID          = securityService.decryptID(arguments.enc_user_id)>
        <cfset var patientID       = securityService.decryptID(arguments.enc_patient_id)>

        <cfif NOT hasPermission("UPDATE_PROFILE")>
            <cfset result.MESSAGE = "You do not have permission to perform this action.">
            <cfreturn result>
        </cfif>
        <cftry>
            <!--- Validation --->
            <cfif NOT len(trim(arguments.full_name))>
                <cfset result.message = "Full Name is required.">
                <cfreturn result>
            </cfif>

            <cfif NOT reFind("^[A-Za-z.\- ]+$", trim(arguments.full_name))>
                <cfset result.message = "Full Name can only contain letters, spaces, dot and hyphen.">
                <cfreturn result>
            </cfif>

            <cfif NOT isValid("email", trim(arguments.email))>
                <cfset result.message = "Please enter a valid email address.">
                <cfreturn result>
            </cfif>

            <cfif NOT reFind("^\d{10}$", trim(arguments.phone))>
                <cfset result.message = "Phone number must be 10 digits.">
                <cfreturn result>
            </cfif>

            <cfif len(trim(arguments.emergency_contact_phone))
              AND NOT reFind("^\d{10}$", trim(arguments.emergency_contact_phone))>
                <cfset result.message = "Emergency phone must be 10 digits.">
                <cfreturn result>
            </cfif>

            <cfif len(trim(arguments.date_of_birth)) AND trim(arguments.date_of_birth) GT now()>
                <cfset result.message = "Date of birth cannot be in the future.">
                <cfreturn result>
            </cfif>

            <cfif len(trim(arguments.city))
              AND NOT reFind("^[A-Za-z\s]+$", trim(arguments.city))>
                <cfset result.message = "City can only contain letters and spaces.">
                <cfreturn result>
            </cfif>

            <!--- Duplicate email check --->
            <cfquery name="qEmailCheck" datasource="mms_db">
                SELECT user_id FROM USERS
                WHERE  email   = <cfqueryparam value="#trim(arguments.email)#" cfsqltype="cf_sql_varchar">
                AND    user_id != <cfqueryparam value="#userID#"                cfsqltype="cf_sql_integer">
            </cfquery>
            <cfif qEmailCheck.recordCount GT 0>
                <cfset result.message = "Email is already in use by another account.">
                <cfreturn result>
            </cfif>

            <!--- Update USERS --->
            <cfquery datasource="mms_db">
                UPDATE USERS SET
                    full_name  = <cfqueryparam value="#trim(arguments.full_name)#" cfsqltype="cf_sql_varchar">,
                    email      = <cfqueryparam value="#trim(arguments.email)#"     cfsqltype="cf_sql_varchar">,
                    phone      = <cfqueryparam value="#trim(arguments.phone)#"     cfsqltype="cf_sql_varchar">,
                    updated_at = GETDATE(),
                    updated_by = <cfqueryparam value="#userID#"                    cfsqltype="cf_sql_integer">
                WHERE user_id  = <cfqueryparam value="#userID#"                    cfsqltype="cf_sql_integer">
            </cfquery>

            <!--- Update PATIENTS --->
            <cfquery datasource="mms_db">
                UPDATE PATIENTS SET
                    date_of_birth           = <cfqueryparam value="#trim(arguments.date_of_birth)#"
                                                            cfsqltype="cf_sql_date"
                                                            null="#NOT len(trim(arguments.date_of_birth))#">,
                    gender                  = <cfqueryparam value="#arguments.gender#"                        cfsqltype="cf_sql_varchar">,
                    blood_group             = <cfqueryparam value="#trim(arguments.blood_group)#"             cfsqltype="cf_sql_varchar">,
                    address_line1           = <cfqueryparam value="#trim(arguments.address_line1)#"           cfsqltype="cf_sql_varchar">,
                    address_line2           = <cfqueryparam value="#trim(arguments.address_line2)#"           cfsqltype="cf_sql_varchar">,
                    city                    = <cfqueryparam value="#trim(arguments.city)#"                    cfsqltype="cf_sql_varchar">,
                    state                   = <cfqueryparam value="#trim(arguments.state)#"                   cfsqltype="cf_sql_varchar">,
                    postal_code             = <cfqueryparam value="#trim(arguments.postal_code)#"             cfsqltype="cf_sql_varchar">,
                    country                 = <cfqueryparam value="#trim(arguments.country)#"                 cfsqltype="cf_sql_varchar">,
                    emergency_contact_name  = <cfqueryparam value="#trim(arguments.emergency_contact_name)#"  cfsqltype="cf_sql_varchar">,
                    emergency_contact_phone = <cfqueryparam value="#trim(arguments.emergency_contact_phone)#" cfsqltype="cf_sql_varchar">
                WHERE patient_id = <cfqueryparam value="#patientID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <!--- Refresh session name --->
            <cfset session.user.full_name = trim(arguments.full_name)>

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