<!--- <cfset structClear(session)>
<cfset session.flashError = "You are logged out successfully!">
<cflocation url="login.cfm"> --->

<cfset structDelete(session, "user")>
<cfset session.flashLogout = "You have been logged out successfully.">
<cflocation url="/MedicalManagementSystem/pages/login.cfm" addtoken="no">