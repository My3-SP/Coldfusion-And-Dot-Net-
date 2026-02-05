<html>
    <head>
        <title>Palindrome Check</title>
        <link rel="stylesheet" href="/style.css">
    </head>
    <body>
        <div class="container">
            <h3>Palindrome String Check</h3>

            <form method="post" action="palindromeProcess.cfm">
                <label>Enter String:</label>
                <input type="text" name="palindromeStr" class="inputBox" required>
                <br><br>
                <input type="submit" class="submitBotton" value="Check">
            </form>

            <br>
            <form action="../index.cfm">
                <input type="submit" class="submitBotton" value="Go to Dashboard">
            </form>
        </div>
    </body>
</html>
