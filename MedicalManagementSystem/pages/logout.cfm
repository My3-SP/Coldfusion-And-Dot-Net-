<cfset structDelete(session, "user")>
<cfset session.flashLogout = "You have been logged out successfully.">
<cflocation url="/MedicalManagementSystem/pages/login.cfm" addtoken="no">
