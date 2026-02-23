<cfcomponent>

<cfset this.name = "ImageManagerApp">
<cfset this.sessionManagement = true>
<cfset this.applicationTimeout = createTimeSpan(0,2,0,0)>

<cffunction name="onApplicationStart">
    <cfset application.uploadPath = expandPath("./uploads/")>
    <cfset application.archivePath = expandPath("./archive/")>
    <cfset application.logPath = expandPath("./logs/errorLog.txt")>
</cffunction>

</cfcomponent>