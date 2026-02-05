<html>
    <head>
        <title>Prime Number Result</title>
        <link rel="stylesheet" href="/style.css">
    </head>
    <body>
        <div class="container">
            <h3>Prime Number Result</h3>

            <cfif structKeyExists(session,"primeResult")>
                <cfoutput><b>#session.primeResult#</b></cfoutput>
                <cfset session.primeResult = "">
            </cfif>

            <br><br>
            <form action="primeInput.cfm">
                <input type="submit" class="submitBotton" value="Check Again">
            </form>
            <form action="../index.cfm">
                <input type="submit" class="submitBotton" value="Go to Dashboard">
            </form>
        </div>
    </body>
</html>
