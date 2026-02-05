<cfset num = val(form.primeNum)>
<cfset isPrime = true>

<cfif num LTE 1>
    <cfset isPrime = false>
<cfelse>
    <cfset limit = int(sqr(num))>
    <cfloop from="2" to="#limit#" index="i">
        <cfif num MOD i EQ 0>
            <cfset isPrime = false>
        </cfif>
    </cfloop>
</cfif>

<cfif isPrime>
    <cfset session.primeResult = num & " is Prime">
<cfelse>
    <cfset session.primeResult = num & " is NOT Prime">
</cfif>

<cflocation url="primeOutput.cfm" addtoken="no">
