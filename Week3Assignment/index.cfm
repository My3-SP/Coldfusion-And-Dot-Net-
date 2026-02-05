<html>
<head>
    <link rel="stylesheet" href="../style.css">
    <title>WEEK 3 Assignment Dashboard</title>
</head>
<body>
    <div class="container">
        <cfinclude template="header.cfm">

        <h3>Select Operation:</h3>

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

            <input type="submit" class="submitBotton" value="Proceed">
        </form>

        <cfif structKeyExists(form,"task")>
            <cfset task = form.task>

            <!-- Redirect to corresponding input page -->
            <cfif task EQ "prime">
                <cflocation url="prime/primeInput.cfm">
            <cfelseif task EQ "reverse">
                <cflocation url="reverse/reverseInput.cfm">
            <cfelseif task EQ "palindrome">
                <cflocation url="palindrome/palindromeInput.cfm">
            <cfelseif task EQ "calculator">
                <cflocation url="calculator/calculatorInput.cfm">
            <cfelseif task EQ "sorting">
                <cflocation url="sorting/sortInput.cfm">
            </cfif>

        </cfif>

    </div>
</body>
</html>