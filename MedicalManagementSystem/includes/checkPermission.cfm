<cfif NOT structKeyExists(session,"permissions")
   OR NOT structKeyExists(session.permissions, checkPerm)>
    <cfoutput>
    <div class="alert alert-danger m-4">
        <i class="bi bi-shield-exclamation me-2"></i>
        You do not have permission to access this page.
    </div>
    </cfoutput>
    <cfabort>
</cfif>