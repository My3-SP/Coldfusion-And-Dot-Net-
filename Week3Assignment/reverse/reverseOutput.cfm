<html>
    <head>
        <title>Reverse String Result</title>
        <link rel="stylesheet" href="/style.css">
    </head>
    <body>
        <div class="container">
            <h3>Reverse String Result</h3>

            <cfif structKeyExists(session,"reverseResult")>
                <cfoutput>#session.reverseResult#</cfoutput>
                <cfset session.reverseResult = ""> <!-- clear after display -->
            </cfif>

            <br><br>
            <form action="reverseInput.cfm">
                <input type="submit" class="submitBotton" value="Reverse Another String">
            </form>
            <form action="../index.cfm">
                <input type="submit" class="submitBotton" value="Go to Dashboard">
            </form>
        </div>
    </body>
</html>
