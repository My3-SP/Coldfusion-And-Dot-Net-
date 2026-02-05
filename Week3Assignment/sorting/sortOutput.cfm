<html>
    <head>
        <title>Array Sorting Result</title>
        <link rel="stylesheet" href="/style.css">
    </head>
    <body>
        <div class="container">
            <h3>Sorting Result</h3>

            <cfif structKeyExists(session,"sortResult")>
                <cfoutput>#session.sortResult#</cfoutput>
                <cfset session.sortResult = ""> <!--- clear after display --->
            </cfif>

            <br><br>
            <form action="sortInput.cfm">
                <input type="submit" class="submitBotton" value="Sort Another List">
            </form>
            <form action="../index.cfm">
                <input type="submit" class="submitBotton" value="Go to Dashboard">
            </form>
        </div>
    </body>
</html>
