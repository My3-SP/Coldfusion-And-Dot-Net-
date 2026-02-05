<cfset str = trim(form.palindromeStr)>

<cfif len(str) EQ 0>
    <cfset session.palindromeResult = "Enter a valid string!">
<cfelse>
    <cfset cleanStr = rereplace(str,"\s+","","all")> 
    <cfset cleanStr = lcase(cleanStr)>

    <cfset reversed = "">
    <cfloop from="#len(cleanStr)#" to="1" step="-1" index="i">
        <cfset reversed = reversed & mid(cleanStr,i,1)>
    </cfloop>

    <cfif cleanStr EQ reversed>
        <cfset session.palindromeResult = str & " is a Palindrome">
    <cfelse>
        <cfset session.palindromeResult = str & " is NOT a Palindrome">
    </cfif>
</cfif>

<cflocation url="palindromeOutput.cfm" addtoken="no">
