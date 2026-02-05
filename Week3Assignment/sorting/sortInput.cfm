<html>
    <head>
        <title>Array Sorting</title>
        <link rel="stylesheet" href="/style.css">
    </head>
    <body>
        <div class="container">
            <h3>Sorting Using Array/List</h3>

            <form method="post" action="sortProcess.cfm">
                <label>Enter Numbers (comma separated):</label>
                <input type="text" name="sortList" class="inputBox" required>
                <br><br>
                <input type="submit" class="submitBotton" value="Sort">
            </form>

            <br>
            <form action="../index.cfm">
                <input type="submit" class="submitBotton" value="Go to Dashboard">
            </form>
        </div>
    </body>
</html>
