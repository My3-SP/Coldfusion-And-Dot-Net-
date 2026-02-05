<html>
    <head>
        <title>Palindrome Result</title>
        <link rel="stylesheet" href="/style.css">
    </head>
    <body>
        <div class="container">
            <h3>Palindrome Result</h3>

            <cfif structKeyExists(session,"palindromeResult")>
                <cfoutput><b>#session.palindromeResult#</b></cfoutput>
                <cfset session.palindromeResult = ""> <!-- clear after display -->
            </cfif>

            <br><br>
            <form action="palindromeInput.cfm">
                <input type="submit" class="submitBotton" value="Check Another String">
            </form>
            <form action="../index.cfm">
                <input type="submit" class="submitBotton" value="Go to Dashboard">
            </form>
        </div>
    </body>
</html>
