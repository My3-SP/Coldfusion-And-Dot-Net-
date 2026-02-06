<html>
    <head>
        <title>Palindrome Check</title>
        <link rel="stylesheet" href="../style.css">
    </head>

    <body>
        <div class="container">
            <cfinclude template="../header.cfm">
            <h2>Palindrome Checker</h2>

            <form id="palindromeForm" method="post">
                <label for="palindromeInput"><h3>Enter String:</h3></label>
                <input id="palindromeInput" type="text" name="palindromeStr" required /><br><br>
                <button type="submit" class="submitButton" value="Submit">Check!</button>
            </form>

            <cfif structKeyExists(form, "palindromeStr")>
                <cfset session.palResult = {}>

                <cfset str = trim(form.palindromeStr)>
                <cfset session.palResult.original = str>

                <cfif len(str) eq 0>
                    <cfset session.palResult.isPalindrome = "Enter a valid string!">
                <cfelse>
                    <cfset cleaned = rereplace(lcase(str), "\s+", "", "all")>
                    <cfset reversed = "">
                    <cfloop from="#len(cleaned)#" to="1" step="-1" index="i">
                        <cfset reversed &= mid(cleaned, i, 1)>
                    </cfloop>
                    <cfif cleaned eq reversed>
                        <cfset session.palResult.isPalindrome = str & " is a Palindrome">
                    <cfelse>
                        <cfset session.palResult.isPalindrome = str & " is a NOT a Palindrome">
                    </cfif>
                </cfif>

                <cflocation url="#cgi.script_name#" addtoken="false">
            </cfif>

            <!--- Show output if session struct exists --->
            <cfif structKeyExists(session, "palResult")>
                <cfoutput>
                    <p><b>Input:</b> #session.palResult.original#</p>
                    <p><b>Result:</b> #session.palResult.isPalindrome#</p>
                </cfoutput>

                <cfset structDelete(session, "palResult")>
            </cfif>

            <p>
                <a href="../index.cfm" class="button"><b>Go to Dashboard</b></a>
            </p>
        </div>
    </body>
</html>