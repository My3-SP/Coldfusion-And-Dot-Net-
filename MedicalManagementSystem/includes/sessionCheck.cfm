<!--- Not logged in at all — send to login --->
<cfif NOT structKeyExists(session, "user")>
    <cflocation url="/MedicalManagementSystem/pages/login.cfm" addtoken="no">
</cfif>

<!--- Logged in but invalid role — send to unauthorized --->
<cfif session.user.role_id GT 4>
    <cflocation url="/MedicalManagementSystem/pages/error/unauthorized.cfm" addtoken="no">
</cfif>