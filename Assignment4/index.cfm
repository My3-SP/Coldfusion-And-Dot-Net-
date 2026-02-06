<html>
    <head>
        <title>Week 3 Assignment Dashboard</title>
        <link rel="stylesheet" href="style.css">
    </head>
        <body>
            <div class="container">
                <cfinclude template="header.cfm">
                <h2>Select Operation:</h2>
                <form method="post">
                    <select name="task" required>
                        <option value="">Select an Option</option>
                        <option value="prime">Prime Number Check</option>
                        <option value="reverse">Reverse String</option>
                        <option value="palindrome">Palindrome String Check</option>
                        <option value="calculator">Simple Calculator</option>
                        <option value="sorting">Sorting Using Array/List</option>
                    </select>

                    <br><br>

                    <input type="submit" class="submitButton" value="Proceed">
                </form>

                <cfif structKeyExists(form,"task")>
                    <cfset task = form.task>

                    <!-- Redirect to corresponding input page -->
                    <cfif task EQ "prime">
                        <cflocation url="tasks/prime.cfm">
                    <cfelseif task EQ "reverse">
                        <cflocation url="tasks/reverse.cfm">
                    <cfelseif task EQ "palindrome">
                        <cflocation url="tasks/palindrome.cfm">
                    <cfelseif task EQ "calculator">
                        <cflocation url="tasks/calculator.cfm">
                    <cfelseif task EQ "sorting">
                        <cflocation url="tasks/sorting.cfm">
                    </cfif>

                </cfif>
                
            </div>
    </body>
</html>




        
