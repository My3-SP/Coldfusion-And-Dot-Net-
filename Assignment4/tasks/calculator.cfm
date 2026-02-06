<html>
<head>
    <title>Simple Calculator</title>
    <link rel="stylesheet" href="../style.css">
    <script>
        // JS functions to handle button click
        function appendToDisplay(val) {
            document.getElementById('calcDisplay').value += val;
        }

        function clearDisplay() {
            document.getElementById('calcDisplay').value = '';
        }

        function calculate() {
            var displayVal = document.getElementById('calcDisplay').value;
            document.getElementById('calcFormInput').value = displayVal;
            document.getElementById('calcForm').submit();
        }
    </script>
</head>

<body>
    <div class="container">
        <cfinclude template="../header.cfm">
        <h2>Simple Calculator</h2>

        <form id="calcForm" method="post">
            <input type="hidden" name="expression" id="calcFormInput" />

            <input type="text" id="calcDisplay" class="calcDisplay" 
                   value="<cfoutput><cfif structKeyExists(session,'calcResult')>#session.calcResult#<cfelse></cfif></cfoutput>" readonly>

            <br><br>

            <div class="calcButtons">
                <button type="button" class=" calcButton" onclick="appendToDisplay('7')">7</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('8')">8</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('9')">9</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('/')">/</button>

                <button type="button" class=" calcButton" onclick="appendToDisplay('4')">4</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('5')">5</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('6')">6</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('*')">*</button>

                <button type="button" class=" calcButton" onclick="appendToDisplay('1')">1</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('2')">2</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('3')">3</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('-')">-</button>

                <button type="button" class=" calcButton" onclick="appendToDisplay('0')">0</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('.')">.</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('%')">%</button>
                <button type="button" class=" calcButton" onclick="appendToDisplay('+')">+</button>

                <button type="button" class=" calcButton" onclick="clearDisplay()"><b>Clear</b></button>
                <button type="button" class=" calcButton" onclick="calculate()">=</button>
            </div>
        </form>

        <p>
            <a href="../index.cfm" class="button"><b>Go to Dashboard</b></a>
        </p>

        <cfif structKeyExists(form, "expression")>
            <cfset expr = form.expression>
            <cftry>
                <cfset session.calcResult = evaluate(replace(expr, "%", " MOD ", "all"))>
                <cfcatch>
                    <cfset session.calcResult = "Error">
                </cfcatch>
            </cftry>
            <cflocation url="#cgi.script_name#" addtoken="false">
        </cfif>

        <cfif structKeyExists(session, "calcResult")>
            <cfset structDelete(session, "calcResult")>
        </cfif>

    </div>
</body>
</html>