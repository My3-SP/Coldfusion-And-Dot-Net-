<html>
    <head>
        <title>Reverse String</title>
        <link rel="stylesheet" href="../style.css">
    </head>

    <body>
        <div class="container">
            <cfinclude template="../header.cfm">
            <h2>Reverse String</h2>

            <form id="reverseForm" method="post">
                <label for="reverseInput"><h3>Enter String:</h3></label>
                <input id="reverseInput" type="text" name="reverseStr" required /><br><br>
                <button type="submit" class="submitButton" value="Submit">Reverse!</button>
            </form>

            <cfif structKeyExists(form, "reverseStr")>
                <cfset session.reverseResult = {}>

                <cfset str = trim(form.reverseStr)>
                <cfset session.reverseResult.original = str>

                <cfif len(str) eq 0>
                    <cfset session.reverseResult.reversed = "Enter a valid string!">
                <cfelse>
                    <cfset reversed = "">
                    <cfloop from="#len(str)#" to="1" step="-1" index="i">
                        <cfset reversed &= mid(str, i, 1)>
                    </cfloop>
                    <cfset session.reverseResult.reversed = reversed>
                </cfif>

                <cflocation url="#cgi.script_name#" addtoken="false">
            </cfif>

            <!--- Show output if session struct exists --->
            <cfif structKeyExists(session, "reverseResult")>
                <cfoutput>
                    <p><b>Original:</b> #session.reverseResult.original#</p>
                    <p><b>Reversed:</b> #session.reverseResult.reversed#</p>
                </cfoutput>

                <!--- Delete session struct to prevent old data on refresh --->
                <cfset structDelete(session, "reverseResult")>
            </cfif>

            <!--- Navigation links --->
            <p>
                <a href="../index.cfm" class="button"><b>Go to Dashboard</b></a>
            </p>
        </div>
    </body>
</html>