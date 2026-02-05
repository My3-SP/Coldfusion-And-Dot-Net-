<html>
    <head>
        <title>Prime Number Check</title>
        <link rel="stylesheet" href="/style.css">
    </head>
    <body>
        <div class="container">
            <h3>Prime Number Check</h3>

            <form method="post" action="primeProcess.cfm">
                <label>Enter Number:</label>
                <input type="number" name="primeNum" class="inputBox" required>
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
