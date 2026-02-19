<cfset empService = createObject("component","EmployeeBonusSystem.components.EmployeeService")> 
<cfset util = createObject("component","EmployeeBonusSystem.components.Utility")>
<!-- ================= INITIALIZE VARIABLES ================= -->
<cfparam name="url.id" default="">
<cfparam name="url.successMsg" default="">
<cfparam name="form.searchText" default="">

<!-- ================= HANDLE URL ID SECURELY ================= -->
<cfset decryptedID = "">
<cfif len(url.id)>
    <cfif url.id EQ "0">
        <cfset decryptedID = "0">
    <cfelse>
        <cftry>
            <cfset decryptedID = util.decryptValue(url.id)>
            <cfif NOT isNumeric(decryptedID) OR decryptedID LTE 0>
                <cfthrow message="Invalid ID">
            </cfif>
        <cfcatch>
            <cfheader statuscode="404" statustext="Not Found">
            <cfinclude template="404.cfm">
            <cfabort>
        </cfcatch>
        </cftry>
    </cfif>
</cfif>

<!-- ================= INITIALIZE FORM VARIABLES ================= -->
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

<!-- ================= DELETE SECURELY ================= -->
<cfif structKeyExists(form,"deleteID") AND len(form.deleteID)>
    <cftry>
        <cfset deleteRealID = util.decryptValue(form.deleteID)>
        <cfif NOT isNumeric(deleteRealID)>
            <cfthrow message="Invalid delete ID">
        </cfif>
        <cfset empService.deleteEmployee(deleteRealID)>
        <cflocation url="employee_crud.cfm?successMsg=#urlEncodedFormat('Employee Deleted Successfully')#" addToken="false">
    <cfcatch>
        <cfheader statuscode="404">
        <cfinclude template="404.cfm">
        <cfabort>
    </cfcatch>
    </cftry>
</cfif>

<!-- ================= ADD / UPDATE ================= -->
<cfif structKeyExists(form,"EmployeeName")>
    <cfset realID = 0>
    <cfif len(form.EmployeeID)>
        <!-- ADD MODE -->
        <cfif form.EmployeeID EQ "0">
            <cfset realID = 0>
        <!-- EDIT MODE -->
        <cfelse>
            <cftry>
                <cfset realID = util.decryptValue(form.EmployeeID)>
                <cfif NOT isNumeric(realID)>
                    <cfthrow message="Invalid ID">
                </cfif>
            <cfcatch>
                <cfheader statuscode="404">
                <cfinclude template="404.cfm">
                <cfabort>
            </cfcatch>
            </cftry>
        </cfif>
    </cfif>
    <cfset res = empService.saveEmployee(
        employeeID = realID,
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
    <cfelse>
        <cfset msg = realID GT 0 ? "Employee Updated Successfully" : "Employee Added Successfully">
        <cflocation url="employee_crud.cfm?successMsg=#urlEncodedFormat(msg)#" addToken="false">
    </cfif>
</cfif>

<!-- ================= FETCH EMPLOYEE FOR EDIT ================= -->
<cfif len(decryptedID) AND decryptedID NEQ "0">
    <cfset qEdit = empService.getEmployee(decryptedID)>
    <cfif qEdit.recordCount EQ 0>
        <cfheader statuscode="404">
        <cfinclude template="404.cfm">
        <cfabort>
    </cfif>
    <cfset cleanName   = qEdit.name>
    <cfset cleanDept   = qEdit.department>
    <cfset cleanSalary = qEdit.salary>
    <cfset cleanRating = qEdit.rating>
</cfif>

<!-- ================= SEARCH / FETCH TABLE ================= -->
<cfif structKeyExists(form,"searchBtn")>
    <cfset searchText = trim(form.searchText)>
    <cfif NOT len(searchText) OR len(searchText) LT 2>
        <cfset searchErrorMsg = "Minimum 2 characters.">
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
            function confirmDelete(encID) {
                if(confirm("Are you sure you want to delete this employee?")){
                    document.getElementById("deleteID").value = encID;
                    document.getElementById("deleteForm").submit();
                }
            }
            window.onload = function() {
                let msg = document.querySelector(".success");
                if(msg){
                    setTimeout(() => { msg.style.display = "none"; }, 3000);
                    if(window.location.search.includes("successMsg=")){
                        const url = new URL(window.location);
                        url.searchParams.delete("successMsg");
                        window.history.replaceState({}, document.title, url.pathname);
                    }
                }
            }
        </script>
    </head>
    <body>
        <cfoutput>
            <div class="container">
                <div class="header-card">
                    <h2>Employee Bonus Management</h2>
                </div>
                <form method="post" id="deleteForm">
                    <input type="hidden" name="deleteID" id="deleteID">
                </form>
                <cfif len(successMsg)>
                    <cf_messageBox msg="#successMsg#" type="success">
                </cfif>

                <!-- ================= FORM ================= -->
                <cfif decryptedID NEQ "">
                    <div class="employee-form">
                        <h3><cfif decryptedID EQ "0">Add Employee<cfelse>Edit Employee</cfif></h3>
                        <form method="post">
                            <input type="hidden" name="EmployeeID" value="#util.encryptValue(decryptedID)#">
                            <div class="form-group">
                                <label>Name</label>
                                <input type="text" name="EmployeeName" class="input-emp" value="#cleanName#" required>
                                <cf_messageBox msg="#nameError#" type="error">
                            </div>
                            <div class="form-group">
                                <label>Department</label>
                                <input type="text" name="Department" class="input-emp" value="#cleanDept#" required>
                                <cf_messageBox msg="#deptError#" type="error">
                            </div>
                            <div class="form-group">
                                <label>Salary</label>
                                <input type="number" name="Salary" class="input-emp" value="#cleanSalary#" required>
                                <cf_messageBox msg="#salaryError#" type="error">
                            </div>
                            <div class="form-group">
                                <label>Rating</label>
                                <input type="number" name="Rating" class="input-emp" value="#cleanRating#" required>
                                <cf_messageBox msg="#ratingError#" type="error">
                            </div>
                            <button type="submit" class="btn">Save</button>
                            <a href="employee_crud.cfm" class="btn">Cancel</a>
                        </form>
                    </div>
                <cfelse>

                <!-- ================= TABLE ================= -->
                <div class="search-add">
                    <form method="post" class="search-form">
                            <div class="search-input-wrapper">
                                <input type="text" name="searchText" class="input-emp" value="#searchText#">
                                <cf_messageBox msg="#searchErrorMsg#" type="error">
                            </div>
                            <div class="search-buttons">
                                <button type="submit" name="searchBtn" class="btn">Search</button>
                                <a href="employee_crud.cfm" class="btn">Reset</a>
                            </div>
                    </form>
                    <a href="employee_crud.cfm?id=0" class="btn add-btn">Add New Employee</a>
                </div>
                <table class="employee-table">
                    <tr>
                        <th>SL</th>
                        <th>Name</th>
                        <th>Department</th>
                        <th>Salary</th>
                        <th>Rating</th>
                        <th>Bonus %</th>
                        <th>Bonus</th>
                        <th>Final Salary</th>
                        <th>Action</th>
                    </tr>
                    <cfif qEmployee.recordcount EQ 0>
                            <tr>
                                <td colspan="10" align="center">No employess found.</td>
                            </tr>
                        </cfif>
                    <cfset sl=1>
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
                                <cfset encID = util.encryptValue(qEmployee.id)>
                                <a href="employee_crud.cfm?id=#urlEncodedFormat(encID)#" class="btn edit-btn">Edit</a>
                                <button type="button" onclick="confirmDelete('#encID#')" class="btn delete-btn">Delete</button>
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

