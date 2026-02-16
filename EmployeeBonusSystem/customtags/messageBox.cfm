<cfparam name="attributes.msg" default="">
<cfparam name="attributes.type" default="success"> <!--- "success" or "error" --->

<cfif len(attributes.msg)>
    <cfif attributes.type EQ "success">
        <div class="success message-box"><cfoutput>#attributes.msg#</cfoutput></div>
    <cfelse>
        <div class="error message-box"><cfoutput>#attributes.msg#</cfoutput></div>
    </cfif>
</cfif>
