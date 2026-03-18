<cfcomponent displayname="forgotPasswordService" output="false">

    <!---  Send Password Reset OTP  --->
    <cffunction name="sendPasswordResetOTP" access="remote" returntype="struct" returnformat="json" output="false">
        <cfargument name="email" type="string" required="true">

        <cfset var result = { SUCCESS=false, MESSAGE="" }>
        <cfset var bcrypt = createObject("component","MedicalManagementSystem.libs.bcrypt")>

        <cftry>
            <!--- Check if email exists and account is active --->
            <cfquery name="qUser" datasource="mms_db">
                SELECT user_id, full_name
                FROM   USERS
                WHERE  email     = <cfqueryparam value="#trim(arguments.email)#" cfsqltype="cf_sql_varchar">
                AND    is_active = 1
            </cfquery>

            <cfif NOT qUser.recordCount>
                <cfset result.MESSAGE = "No active account found with that email address.">
                <cfreturn result>
            </cfif>

            <cfset var userID = qUser.user_id>
            <!--- Invalidate any existing unused OTPs for this user --->
            <cfquery datasource="mms_db">
                UPDATE OTP_VERIFICATION
                SET    is_consumed = 1
                WHERE  user_id    = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
                AND    purpose    = 'Reset'
                AND    is_consumed = 0
            </cfquery>
            <!--- Generate and hash OTP --->
            <cfset var otp     = RandRange(100000, 999999)>
            <cfset var otpHash = bcrypt.hash(toString(otp))>

            <!--- Insert new OTP --->
            <cfquery datasource="mms_db">
                INSERT INTO OTP_VERIFICATION
                    (user_id, otp_hash, purpose, expiry_time, is_consumed, created_at, request_ip)
                VALUES (
                    <cfqueryparam value="#userID#"                          cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#otpHash#"                         cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="Reset"                             cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#DateAdd('n',10,Now())#"           cfsqltype="cf_sql_timestamp">,
                    0,
                    GETDATE(),
                    <cfqueryparam value="#cgi.remote_addr#"                 cfsqltype="cf_sql_varchar">
                )
            </cfquery>

            <!--- Send OTP email --->
            <cfmail to    = "#trim(arguments.email)#"
                    from  = "cfmltestmail@gmail.com"
                    subject = "Your Password Reset OTP"
                    type  = "html">
                Hello #qUser.full_name#,<br><br>
                Your OTP for password reset is: <strong>#otp#</strong><br>
                This OTP is valid for <strong>10 minutes</strong>.<br><br>
                If you did not request this, please ignore this email.<br><br>
                Regards,<br>Medical Management System
            </cfmail>

            <cfset result.SUCCESS = true>
            <cfset result.MESSAGE = "OTP sent to your email address.">

        <cfcatch type="any">
            <cfset result.MESSAGE = "Error sending OTP. Please try again.">
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <!---  Verify OTP  --->
    <cffunction name="verifyPasswordResetOTP" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="email" type="string" required="true">
        <cfargument name="otp"   type="string" required="true">

        <cfset var result = { SUCCESS=false, MESSAGE="" }>
        <cfset var bcrypt = createObject("component","MedicalManagementSystem.libs.bcrypt")>

        <cftry>
            <!--- Get user --->
            <cfquery name="qUser" datasource="mms_db">
                SELECT user_id
                FROM   USERS
                WHERE  email     = <cfqueryparam value="#trim(arguments.email)#" cfsqltype="cf_sql_varchar">
                AND    is_active = 1
            </cfquery>

            <cfif NOT qUser.recordCount>
                <cfset result.MESSAGE = "Invalid email address.">
                <cfreturn result>
            </cfif>

            <cfset var userID = qUser.user_id>

            <!--- Get latest unconsumed OTP --->
            <cfquery name="qOTP" datasource="mms_db">
                SELECT TOP 1 otp_id, otp_hash, expiry_time
                FROM   OTP_VERIFICATION
                WHERE  user_id    = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
                AND    purpose    = 'Reset'
                AND    is_consumed = 0
                ORDER BY created_at DESC
            </cfquery>

            <cfif NOT qOTP.recordCount>
                <cfset result.MESSAGE = "No active OTP found. Please request a new one.">
                <cfreturn result>
            </cfif>

            <cfset var otpID      = qOTP.otp_id[1]>
            <cfset var otpHash    = qOTP.otp_hash[1]>
            <cfset var expiryTime = qOTP.expiry_time[1]>

            <!--- Check expiry --->
            <cfif now() GT expiryTime>
                <cfquery datasource="mms_db">
                    UPDATE OTP_VERIFICATION
                    SET    is_consumed = 1
                    WHERE  otp_id     = <cfqueryparam value="#otpID#" cfsqltype="cf_sql_integer">
                </cfquery>
                <cfset result.MESSAGE = "OTP has expired. Please request a new one.">
                <cfreturn result>
            </cfif>

            <!--- Verify OTP --->
            <cfif NOT bcrypt.check(trim(arguments.otp), otpHash)>
                <cfset result.MESSAGE = "Invalid OTP. Please try again.">
                <cfreturn result>
            </cfif>

            <!--- Mark consumed --->
            <cfquery datasource="mms_db">
                UPDATE OTP_VERIFICATION
                SET    is_consumed = 1
                WHERE  otp_id     = <cfqueryparam value="#otpID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.SUCCESS = true>
            <cfset result.MESSAGE = "OTP verified successfully.">

        <cfcatch type="any">
            <cfset result.MESSAGE = "Error verifying OTP: " & cfcatch.message>
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

    <!---  Reset Password  --->
    <cffunction name="resetPassword" access="remote" returntype="struct"
                returnformat="json" output="false">
        <cfargument name="email"        type="string" required="true">
        <cfargument name="new_password" type="string" required="true">

        <cfset var result = { SUCCESS=false, MESSAGE="" }>
        <cfset var bcrypt = createObject("component","MedicalManagementSystem.libs.bcrypt")>

        <cftry>
            <!--- Strong password: min 6 chars, upper, lower, digit, special --->
            <cfif len(trim(arguments.new_password)) LT 6>
                <cfset result.MESSAGE = "Password must be at least 6 characters.">
                <cfreturn result>
            </cfif>

            <cfif NOT reFind("[A-Z]", arguments.new_password)>
                <cfset result.MESSAGE = "Password must contain at least one uppercase letter.">
                <cfreturn result>
            </cfif>

            <cfif NOT reFind("[a-z]", arguments.new_password)>
                <cfset result.MESSAGE = "Password must contain at least one lowercase letter.">
                <cfreturn result>
            </cfif>

            <cfif NOT reFind("[0-9]", arguments.new_password)>
                <cfset result.MESSAGE = "Password must contain at least one number.">
                <cfreturn result>
            </cfif>

            <cfif NOT reFind("[!@##$%^&*()\-_=+\[\]{};':""\\|,.<>/?]", arguments.new_password)>
                <cfset result.MESSAGE = "Password must contain at least one special character.">
                <cfreturn result>
            </cfif>

            <cfif len(arguments.new_password) GT 64>
                <cfset result.MESSAGE = "Password must not exceed 64 characters.">
                <cfreturn result>
            </cfif>

            <cfquery name="qUser" datasource="mms_db">
                SELECT user_id
                FROM   USERS
                WHERE  email     = <cfqueryparam value="#trim(arguments.email)#" cfsqltype="cf_sql_varchar">
                AND    is_active = 1
            </cfquery>

            <cfif NOT qUser.recordCount>
                <cfset result.MESSAGE = "Invalid email address.">
                <cfreturn result>
            </cfif>

            <cfset var userID  = qUser.user_id>
            <cfset var newHash = bcrypt.hash(arguments.new_password)>

            <cfquery datasource="mms_db">
                UPDATE USERS
                SET password   = <cfqueryparam value="#newHash#"  cfsqltype="cf_sql_varchar">,
                    updated_at = GETDATE(),
                    updated_by = <cfqueryparam value="#userID#"   cfsqltype="cf_sql_integer">
                WHERE user_id  = <cfqueryparam value="#userID#"   cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.SUCCESS = true>
            <cfset result.MESSAGE = "Password reset successfully.">

        <cfcatch type="any">
            <cfset result.MESSAGE = "Error resetting password. Please try again.">
        </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>