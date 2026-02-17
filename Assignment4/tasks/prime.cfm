<html>
    <head>
        <title>Prime Number Check</title>
        <link rel="stylesheet" href="../style.css">
    </head>

    <body>

        <div class="container">
            <cfinclude template="../header.cfm">
            <h2>Prime Number Checker</h2>
            <form id="primeNumberForm" method="post">
                <label for="primeNumberInput"><h3>Enter Number To Check: </h3></label>
                <input id="primeNumberInput" type="number" name="primeNum" required/>
                <br><br>
                <button type="submit" class="submitButton" value="Submit">Check!</button>
            </form>
            
            <cfif structKeyExists(form, "primeNum")>
                <cfset session.primeResult = {}>
                <cfset n = int(form.primeNum)>
                <cfset session.primeResult.number = n>
                <cfif n lt 2>
                    <cfset session.primeResult.isPrime = false>
                    <cfelse>
                    <cfset isPrime = true>
                    <cfset end = int(sqr(n))>
                    <cfloop from="2" to="#end#" index="i">
                    <cfif n mod i eq 0>
                    <cfset isPrime = false>
                    <cfbreak>
                    </cfif>
                    </cfloop>
                    <cfset session.primeResult.isPrime = isPrime>
                </cfif>
            
                <cflocation url="#cgi.script_name#" addtoken="false">
            </cfif>
            
            <cfif structKeyExists(session, "primeResult")>
                <cfoutput>
                    #session.primeResult.number# is
                    <cfif session.primeResult.isPrime>
                                a prime number.
                    <cfelse>
                                not a prime number.
                    </cfif>
                </cfoutput>
                    <cfset structDelete(session, "primeResult")>
            </cfif>
            <p>
                <a href="../index.cfm" class="button"><b>Go to Dashboard</b></a>
            </p>
        </div>
    </body>
</html>

 