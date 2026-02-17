<html>
    <head>
        <title>Array/List Sorting</title>
        <link rel="stylesheet" href="../style.css">
    </head>

    <body>
        <div class="container">
            <cfinclude template="../header.cfm">
            <h2>Array/List Sorting</h2>

            <form id="sortForm" method="post">
                <label for="sortInput"><h3>Enter numbers (comma separated):</h3></label>
                <input id="sortInput" type="text" name="sortList" required /><br><br>
                <button type="submit" class="submitButton" value="Submit">Check!</button>
            </form>

            <cfif structKeyExists(form, "sortList")>
                <cfset session.sortResult = {}>

                <cfset rawInput = trim(form.sortList)>
                <cfset session.sortResult.original = rawInput>

                <cfif len(rawInput) eq 0>
                    <cfset session.sortResult.sorted = "Enter a valid list!">
                <cfelse>
                    <cfset cleanedInput = rereplace(rawInput, "[,\s]+", ",", "all")>
                    <cfset arr = listToArray(cleanedInput)>

                    <cfloop from="1" to="#arrayLen(arr)#" index="i">
                        <cfloop from="1" to="#arrayLen(arr)-i#" index="j">
                            <cfif arr[j] GT arr[j+1]>
                                <cfset temp = arr[j]>
                                <cfset arr[j] = arr[j+1]>
                                <cfset arr[j+1] = temp>
                            </cfif>
                        </cfloop>
                    </cfloop>

                    <cfset session.sortResult.sorted = arrayToList(arr)>
                </cfif>

                <cflocation url="#cgi.script_name#" addtoken="false">
            </cfif>

            <!--- Show output if session struct exists --->
            <cfif structKeyExists(session, "sortResult")>
                <cfoutput>
                    <p><b>Input:</b> #session.sortResult.original#</p>
                    <p><b>Sorted:</b> #session.sortResult.sorted#</p>
                </cfoutput>

                <cfset structDelete(session, "sortResult")>
            </cfif>

            <p>
                <a href="../index.cfm" class="button"><b>Go to Dashboard</b></a>
            </p>
        </div>
    </body>
</html>