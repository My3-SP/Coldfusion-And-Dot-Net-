<html>
    <head>
        <link rel="stylesheet" href="/style.css">
        <title>Simple Calculator</title>
    </head>
    <body>
        <div class="container">
            <h3>Simple Calculator</h3>

            <!--- Initialize session variable if not exists --->
            <cfif NOT structKeyExists(session, "calcExpression")>
                <cfset session.calcExpression = "">
            </cfif>

            <form method="post" action="calculatorProcess.cfm">
                <!-- Display -->
                <input type="text" class="calcDisplay" value="<cfoutput>#session.calcExpression#</cfoutput>" readonly>

                <br><br>

                <!-- Buttons -->
                <input type="submit" name="btn" class="submitBotton" value="7">
                <input type="submit" name="btn" class="submitBotton" value="8">
                <input type="submit" name="btn" class="submitBotton" value="9">
                <input type="submit" name="btn" class="submitBotton" value="/"><br>

                <input type="submit" name="btn" class="submitBotton" value="4">
                <input type="submit" name="btn" class="submitBotton" value="5">
                <input type="submit" name="btn" class="submitBotton" value="6">
                <input type="submit" name="btn" class="submitBotton" value="*"><br>

                <input type="submit" name="btn" class="submitBotton" value="1">
                <input type="submit" name="btn" class="submitBotton" value="2">
                <input type="submit" name="btn" class="submitBotton" value="3">
                <input type="submit" name="btn" class="submitBotton" value="-"><br>

                <input type="submit" name="btn" class="submitBotton" value="0">
                <input type="submit" name="btn" class="submitBotton" value=".">
                <input type="submit" name="btn" class="submitBotton" value="%">
                <input type="submit" name="btn" class="submitBotton" value="+"><br><br>

                <input type="submit" name="btn" class="submitBotton" value="Clear">
                <input type="submit" name="btn" class="submitBotton" value="=">
            </form>

            <br>
            <form action="../index.cfm">
                <input type="submit" class="submitBotton" value="Go to Dashboard">
            </form>
        </div>
    </body>
</html>
