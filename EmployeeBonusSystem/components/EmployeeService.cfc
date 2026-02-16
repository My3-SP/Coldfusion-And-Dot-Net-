<cfcomponent output="false">
    <!--- ================= PRIVATE FUNCTIONS ================= --->
    <!--- Proper Case Words --->
    <cffunction name="toProperCase" access="private" returntype="string" output="false">
        <cfargument name="str" type="string" required="true">

        <cfset local.words = listToArray(arguments.str, " ")>
        <cfloop from="1" to="#arrayLen(local.words)#" index="local.i">
            <cfif len(local.words[local.i])>
                <cfset local.words[local.i] = uCase(left(local.words[local.i],1)) 
                    & lCase(mid(local.words[local.i],2,len(local.words[local.i])-1))>
            </cfif>
        </cfloop>

        <cfreturn arrayToList(local.words," ")>
    </cffunction>

    <!--- Validate Employee Inputs --->
    <cffunction name="validateEmployee" access="private" returntype="struct" output="false">
        <cfargument name="name" type="string" required="true">
        <cfargument name="department" type="string" required="true">
        <cfargument name="salary" type="numeric" required="true">
        <cfargument name="rating" type="numeric" required="true">
        <cfargument name="employeeID" type="numeric" required="false" default="0">

        <cfset local.errors = {}>

        <!--- Basic Validations --->
        <cfif len(arguments.name) LT 2 OR NOT reFind("^[A-Za-z ]+$", arguments.name)>
            <cfset local.errors.name = "Name must contain only letters and be at least 2 characters.">
        </cfif>

        <cfif len(arguments.department) LT 2 OR NOT reFind("^[A-Za-z ]+$", arguments.department)>
            <cfset local.errors.department = "Department must contain only letters and be at least 2 characters.">
        </cfif>

        <cfif NOT isNumeric(arguments.salary) OR arguments.salary LT 15000 OR arguments.salary GT 999999999>
            <cfset local.errors.salary = "Salary must be a number greater than or equal to 15000.">
        </cfif>

        <cfif NOT isNumeric(arguments.rating) OR arguments.rating LT 1 OR arguments.rating GT 5>
            <cfset local.errors.rating = "Rating must be a number between 1 and 5.">
        </cfif>

        <!--- Duplicate Check --->
        <cfif structIsEmpty(local.errors)>
            <cfquery name="local.qDuplicate" datasource="employeedsn">
                SELECT id
                FROM employees
                WHERE UPPER(name) = 
                    <cfqueryparam value="#ucase(arguments.name)#" cfsqltype="cf_sql_varchar">
                AND UPPER(department) = 
                    <cfqueryparam value="#ucase(arguments.department)#" cfsqltype="cf_sql_varchar">

                <cfif arguments.employeeID GT 0>
                    AND id != 
                    <cfqueryparam value="#arguments.employeeID#" cfsqltype="cf_sql_integer">
                </cfif>
            </cfquery>
            <cfif local.qDuplicate.recordCount GT 0>
                <cfset local.errors.name = "Employee with this Name & Department already exists.">
            </cfif>
        </cfif>
        <cfreturn local.errors>
    </cffunction>

    <!--- Calculate Bonus --->
    <cffunction name="calculateBonus" access="private" returntype="struct" output="false">
        <cfargument name="salary" type="numeric" required="true">
        <cfargument name="rating" type="numeric" required="true">
        <cfset local.result = {}>
        <cfswitch expression="#arguments.rating#">
            <cfcase value="5">
                <cfset local.result.bonusPercent = 20>
            </cfcase>
            <cfcase value="4">
                <cfset local.result.bonusPercent = 15>
            </cfcase>
            <cfcase value="3">
                <cfset local.result.bonusPercent = 10>
            </cfcase>
            <cfcase value="2">
                <cfset local.result.bonusPercent = 5>
            </cfcase>
            <cfcase value="1">
                <cfset local.result.bonusPercent = 0>
            </cfcase>
            <cfdefaultcase>
                <cfset local.result.bonusPercent = 0>
            </cfdefaultcase>
        </cfswitch>
        <cfset local.result.bonusAmount = 
            arguments.salary * (local.result.bonusPercent / 100)>
        <cfset local.result.finalSalary = 
            arguments.salary + local.result.bonusAmount>
        <cfreturn local.result>
    </cffunction>

    <!--- ================= PUBLIC FUNCTIONS ================= --->
    <!--- Add / Update Employee --->
    <cffunction name="saveEmployee" access="public" returntype="struct" output="false">
        <cfargument name="employeeID" type="numeric" required="false" default="0">
        <cfargument name="name" type="string" required="true">
        <cfargument name="department" type="string" required="true">
        <cfargument name="salary" type="numeric" required="true">
        <cfargument name="rating" type="numeric" required="true">
        <cfset local.result = {}>
        <cfset local.errors = {}>
        <!--- Trim Inputs --->
        <cfset arguments.name = trim(arguments.name)>
        <cfset arguments.department = trim(arguments.department)>
        <!--- Validate --->
        <cfset local.errors = validateEmployee(
            name = arguments.name,
            department = arguments.department,
            salary = arguments.salary,
            rating = arguments.rating,
            employeeID = arguments.employeeID
        )>

        <cfif structIsEmpty(local.errors)>
            <cfset local.bonus = calculateBonus(arguments.salary, arguments.rating)>
            <cfif arguments.employeeID GT 0>
                <!--- UPDATE --->
                <cfquery datasource="employeedsn">
                    UPDATE employees
                    SET name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">,
                        department = <cfqueryparam value="#arguments.department#" cfsqltype="cf_sql_varchar">,
                        salary = <cfqueryparam value="#arguments.salary#" cfsqltype="cf_sql_decimal">
                    WHERE id = <cfqueryparam value="#arguments.employeeID#" cfsqltype="cf_sql_integer">
                </cfquery>
                <cfquery datasource="employeedsn">
                    UPDATE bonus
                    SET rating = <cfqueryparam value="#arguments.rating#" cfsqltype="cf_sql_integer">,
                        bonus_percent = <cfqueryparam value="#local.bonus.bonusPercent#" cfsqltype="cf_sql_decimal">,
                        bonus_amount = <cfqueryparam value="#local.bonus.bonusAmount#" cfsqltype="cf_sql_decimal">,
                        final_salary = <cfqueryparam value="#local.bonus.finalSalary#" cfsqltype="cf_sql_decimal">
                    WHERE employee_id = <cfqueryparam value="#arguments.employeeID#" cfsqltype="cf_sql_integer">
                </cfquery>
                <cfset local.result.msg = "updated">
                <cfset local.result.id = arguments.employeeID>
            <cfelse>
                <!--- INSERT --->
                <cfquery datasource="employeedsn">
                    INSERT INTO employees(name, department, salary)
                    VALUES(
                        <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.department#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.salary#" cfsqltype="cf_sql_decimal">
                    )
                </cfquery>
                <cfquery name="local.qNewID" datasource="employeedsn">
                    SELECT TOP 1 id AS newID
                    FROM employees
                    ORDER BY id DESC
                </cfquery>
                <cfset local.newID = local.qNewID.newID>
                <cfquery datasource="employeedsn">
                    INSERT INTO bonus(employee_id, rating, bonus_percent, bonus_amount, final_salary)
                    VALUES(
                        <cfqueryparam value="#local.newID#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#arguments.rating#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#local.bonus.bonusPercent#" cfsqltype="cf_sql_decimal">,
                        <cfqueryparam value="#local.bonus.bonusAmount#" cfsqltype="cf_sql_decimal">,
                        <cfqueryparam value="#local.bonus.finalSalary#" cfsqltype="cf_sql_decimal">
                    )
                </cfquery>

                <cfset local.result.msg = "added">
                <cfset local.result.id = local.newID>
            </cfif>
            <cfset local.result.bonusPercent = local.bonus.bonusPercent>
            <cfset local.result.bonusAmount = local.bonus.bonusAmount>
            <cfset local.result.finalSalary = local.bonus.finalSalary>
        <cfelse>
            <cfset local.result.errors = local.errors>
        </cfif>
        <cfreturn local.result>
    </cffunction>

    <!--- Delete Employee --->
    <cffunction name="deleteEmployee" access="public" returntype="boolean" output="false">
        <cfargument name="employeeID" type="numeric" required="true">
        <cfquery datasource="employeedsn">
            DELETE FROM bonus 
            WHERE employee_id = 
            <cfqueryparam value="#arguments.employeeID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfquery datasource="employeedsn">
            DELETE FROM employees 
            WHERE id = 
            <cfqueryparam value="#arguments.employeeID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn true>
    </cffunction>

    <!--- Get Single Employee --->
    <cffunction name="getEmployee" access="public" returntype="query" output="false">
        <cfargument name="employeeID" type="numeric" required="true">
        <cfquery name="local.qEmployee" datasource="employeedsn">
            SELECT e.*, b.rating, b.bonus_percent, 
                   b.bonus_amount, b.final_salary
            FROM employees e
            LEFT JOIN bonus b 
                ON e.id = b.employee_id
            WHERE e.id = 
                <cfqueryparam value="#arguments.employeeID#" 
                cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn local.qEmployee>
    </cffunction>

    <!--- Search Employees --->
    <cffunction name="searchEmployees" access="public" returntype="query" output="false">
        <cfargument name="searchText" type="string" required="false" default="">
        <cfquery name="local.qEmployee" datasource="employeedsn">
            SELECT e.id, e.name, e.department, e.salary,
                   b.rating, b.bonus_percent, 
                   b.bonus_amount, b.final_salary
            FROM employees e
            LEFT JOIN bonus b ON e.id=b.employee_id
            <cfif len(arguments.searchText)>
                WHERE UPPER(e.name) LIKE 
                    <cfqueryparam value="%#ucase(arguments.searchText)#%" cfsqltype="cf_sql_varchar">
                OR UPPER(e.department) LIKE 
                    <cfqueryparam value="%#ucase(arguments.searchText)#%" cfsqltype="cf_sql_varchar">
            </cfif>
            ORDER BY e.id ASC
        </cfquery>
        <cfloop query="local.qEmployee">
            <cfset local.qEmployee.name = toProperCase(local.qEmployee.name)>
            <cfset local.qEmployee.department = toProperCase(local.qEmployee.department)>
        </cfloop>
        <cfreturn local.qEmployee>
    </cffunction>
</cfcomponent>
