<cfcomponent output="false">

    <!--- Application Settings --->
    <cfset this.name = "EmployeeBonusApp">
    <cfset this.applicationTimeout = createTimeSpan(0,2,0,0)> <!--- 2 hours --->
    <cfset this.sessionManagement = true>
    <cfset this.sessionTimeout = createTimeSpan(0,1,0,0)> <!-- 1 hour -->
    <cfset this.datasource = "employeedsn"> <!--- Default datasource --->

    <!--- On Application Start --->
    <cffunction name="onApplicationStart" returntype="boolean" output="false">
        <cfset application.customTagsPath = expandPath("./customtags")>
        <cfreturn true>
    </cffunction>

    <!--- On Session Start --->
    <cffunction name="onSessionStart" returntype="boolean" output="false">
        <cfset session.startTime = now()>
        <cfreturn true>
    </cffunction>

    <!--- On Request Start --->
    <cffunction name="onRequestStart" returntype="boolean" output="false">
        <cfreturn true>
    </cffunction>

    <!--- On Request End --->
    <cffunction name="onRequestEnd" returntype="boolean" output="false">
        <cfreturn true>
    </cffunction>

    <!--- On Error --->
    <cffunction name="onError" returntype="void" output="true">
        <cfargument name="exception" required="true">
        <cfargument name="eventName" required="true">
        <cfoutput>
            <h2>Application Error!</h2>
            <p>#arguments.exception.message#</p>
        </cfoutput>
    </cffunction>

</cfcomponent>
