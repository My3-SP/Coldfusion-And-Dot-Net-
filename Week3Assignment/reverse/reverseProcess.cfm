<cfset str = form.reverseStr>

<cfif len(trim(str)) EQ 0>
    <cfset session.reverseResult = "Enter valid string!">
<cfelse>
    <cfset reversed = "">
    <cfloop from="#len(str)#" to="1" step="-1" index="i">
        <cfset reversed = reversed & mid(str,i,1)>
    </cfloop>

    <cfset session.reverseResult = "<b>Original:</b> " & str & " <br> <b>Reversed:</b> " & reversed>
</cfif>

<!--- Redirect to output page --->
<cflocation url="reverseOutput.cfm" addtoken="no">
