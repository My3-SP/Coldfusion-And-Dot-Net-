<cfset empService = createObject("component","EmployeeBonusSystem.components.EmployeeService")> 

<!-- ================= INITIALIZE VARIABLES ================= -->
<cfparam name="url.id" default="">
<cfparam name="url.successMsg" default="">
<cfparam name="form.searchText" default="">

<cfset cleanName   = "">
<cfset cleanDept   = "">
<cfset cleanSalary = "">
<cfset cleanRating = "">
<cfset nameError   = "">
<cfset deptError   = "">
<cfset salaryError = "">
<cfset ratingError = "">
<cfset searchErrorMsg = "">
<cfset successMsg = url.successMsg>

<!-- ================= HANDLE DELETE ================= -->
<cfif structKeyExists(form,"deleteID") AND isNumeric(form.deleteID)>
    <cfset empService.deleteEmployee(form.deleteID)>
    <cflocation url="employee_crud.cfm?successMsg=#urlEncodedFormat('Employee Deleted Successfully')#" addToken="false">
</cfif>

<!-- ================= HANDLE ADD / UPDATE ================= -->
<cfif structKeyExists(form,"EmployeeName")>
    <cfset res = empService.saveEmployee(
        employeeID = form.EmployeeID,
        name       = form.EmployeeName,
        department = form.Department,
        salary     = form.Salary,
        rating     = form.Rating
    )>

    <cfif structKeyExists(res,"errors")>
        <cfset nameError   = res.errors.name ?: "">
        <cfset deptError   = res.errors.department ?: "">
        <cfset salaryError = res.errors.salary ?: "">
        <cfset ratingError = res.errors.rating ?: "">

        <!--- Focus on first invalid field --->
        <cfset focusField = len(nameError) ? "EmployeeName" : len(deptError) ? "Department" : len(salaryError) ? "Salary" : "Rating">
    <cfelse>
        <cfset msg = len(form.EmployeeID) ? "Employee Updated Successfully" : "Employee Added Successfully">
        <cflocation url="employee_crud.cfm?successMsg=#urlEncodedFormat(msg)#" addToken="false">
    </cfif>
</cfif>

<!-- ================= FETCH EMPLOYEE FOR EDIT ================= -->
<cfif len(url.id) AND isNumeric(url.id)>
    <cfset qEdit = empService.getEmployee(url.id)>
    <cfif qEdit.recordCount>
        <cfset cleanName   = qEdit.name>
        <cfset cleanDept   = qEdit.department>
        <cfset cleanSalary = qEdit.salary>
        <cfset cleanRating = qEdit.rating>
    </cfif>
</cfif>

<!-- ================= SEARCH / FETCH EMPLOYEE TABLE ================= -->
<cfif structKeyExists(form,"searchBtn")>
    <cfset searchText = trim(form.searchText)>
    <cfif NOT len(searchText)>
        <cfset searchErrorMsg = "Search cannot be empty.">
        <cfset qEmployee = empService.searchEmployees()>
    <cfelseif NOT reFind("^(?=.*[A-Za-z0-9])[A-Za-z0-9@._\- ]+$", searchText)>
        <cfset searchErrorMsg = "Invalid search text.">
        <cfset qEmployee = empService.searchEmployees()>
    <cfelse>
        <cfset qEmployee = empService.searchEmployees(searchText)>
    </cfif>
<cfelse>
    <cfset qEmployee = empService.searchEmployees()>
</cfif>

<html>
    <head>
        <title>Employee Bonus System</title>
        <link rel="stylesheet" href="style.css">
        <script>
            function confirmDelete(id){
                if(confirm("Are you sure you want to delete this employee?")){
                    document.getElementById("deleteID").value = id;
                    document.getElementById("deleteForm").submit();
                }
            }

            window.onload = function(){
                // Auto-hide success message
                let msg = document.querySelector(".success");
                if(msg) setTimeout(() => { msg.style.display = "none"; }, 3000);

                // Focus on first invalid field if errors exist
                <cfif structKeyExists(form,"EmployeeName") AND structKeyExists(res,"errors")>
                    document.getElementsByName("#focusField#")[0].focus();
                </cfif>
            }
        </script>
    </head>
    <body>
        <cfoutput>
            <div class="container">
                <div class="header-card">
                    <h2>Employee Bonus Management</h2>
                </div>

                <!-- DELETE FORM -->
                <form method="post" id="deleteForm">
                    <input type="hidden" name="deleteID" id="deleteID">
                </form>

                <!-- SUCCESS MESSAGE -->
                <cfif len(successMsg)>
                    <cf_messageBox msg="#successMsg#" type="success">
                </cfif>

                <!-- ================= EMPLOYEE FORM ================= -->
                <cfif len(url.id)>
                    <div class="employee-form">
                        <h3><cfif url.id EQ 0>Add Employee<cfelse>Edit Employee</cfif></h3>
                        <form method="post">
                            <input type="hidden" name="EmployeeID" value="#url.id#">

                            <!-- Name -->
                            <div class="form-group">
                                <label>Name</label>
                                <input type="text" name="EmployeeName" value="#cleanName#" placeholder="Enter full name" required>
                                <cf_messageBox msg="#nameError#" type="error">
                            </div>

                            <!-- Department -->
                            <div class="form-group">
                                <label>Department</label>
                                <input type="text" name="Department" value="#cleanDept#" placeholder="Enter department name" required>
                                <cf_messageBox msg="#deptError#" type="error">
                            </div>

                            <!-- Salary -->
                            <div class="form-group">
                                <label>Salary</label>
                                <input type="number" name="Salary" value="#cleanSalary#" placeholder="Salary > 15000" required>
                                <cf_messageBox msg="#salaryError#" type="error">
                            </div>

                            <!-- Rating -->
                            <div class="form-group">
                                <label>Rating</label>
                                <input type="number" name="Rating" value="#cleanRating#" placeholder="1 to 5" required>
                                <cf_messageBox msg="#ratingError#" type="error">
                            </div>

                            <button type="submit" class="btn"><cfif url.id EQ 0>Save<cfelse>Update</cfif></button>
                            <a href="employee_crud.cfm" class="btn">Cancel</a>
                        </form>
                    </div>

                <!-- ================= EMPLOYEE TABLE + SEARCH ================= -->
                <cfelse>
                    <div class="search-add">
                        <form method="post" class="search-form">
                            <div class="search-input-wrapper">
                                <input type="text" name="searchText" value="#searchText#" placeholder="Search by name or department">
                                <cf_messageBox msg="#searchErrorMsg#" type="error">
                            </div>

                            <div class="search-buttons">
                                <button type="submit" name="searchBtn" class="btn">Search</button>
                                <a href="employee_crud.cfm" class="btn">Reset</a>
                            </div>
                        </form>
                        <a href="employee_crud.cfm?id=0" class="btn add-btn">Add New Employee</a>
                    </div>

                    <table class="employee-table" border="1" cellspacing="0" cellpadding="5">
                        <tr>
                            <th>SL NO</th>
                            <th>Name</th>
                            <th>Department</th>
                            <th>Salary</th>
                            <th>Rating</th>
                            <th>Bonus %</th>
                            <th>Bonus</th>
                            <th>Final Salary</th>
                            <th>Action</th>
                        </tr>

                        <cfset sl = 1>
                        <cfloop query="qEmployee">
                            <tr>
                                <td>#sl#</td>
                                <td>#qEmployee.name#</td>
                                <td>#qEmployee.department#</td>
                                <td>#NumberFormat(qEmployee.salary,"9,999.00")#</td>
                                <td>#qEmployee.rating#</td>
                                <td>#qEmployee.bonus_percent#%</td>
                                <td>#NumberFormat(qEmployee.bonus_amount,"9,999.00")#</td>
                                <td>#NumberFormat(qEmployee.final_salary,"9,999.00")#</td>
                                <td>
                                    <a href="employee_crud.cfm?id=#id#" class="btn">Edit</a>
                                    <button type="button" onclick="confirmDelete(#id#)" class="btn">Delete</button>
                                </td>
                            </tr>
                            <cfset sl++>
                        </cfloop>
                    </table>
                </cfif>

            </div>
        </cfoutput>
    </body>
</html>
