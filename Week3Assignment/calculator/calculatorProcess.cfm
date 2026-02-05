<cfparam name="form.btn" default="">

<!--- Initialize session expression if not exists --->
<cfif NOT structKeyExists(session, "calcExpression")>
    <cfset session.calcExpression = "">
</cfif>

<cfset btn = form.btn>
<cfif btn EQ "Clear">
    <cfset session.calcExpression = "">

<cfelseif btn EQ "=">
    <!--- Evaluate expression safely --->
    <cftry>
        <cfset session.calcExpression = evaluate(session.calcExpression)>
        <cfcatch>
            <cfset session.calcExpression = "Error">
        </cfcatch>
    </cftry>

<cfelse>
    <cfif btn EQ "%">
        <cfset session.calcExpression = session.calcExpression & " MOD ">
    <cfelse>
        <cfset session.calcExpression = session.calcExpression & btn>
    </cfif>
</cfif>

<!--- Redirect back to input page to display updated expression --->
<cflocation url="calculatorInput.cfm" addtoken="no">
