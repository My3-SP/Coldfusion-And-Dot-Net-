<html>
    <head>
        <title>Customer Records - CRUD Operations</title>
        <link rel="stylesheet" href="style.css">
    </head>

    <body>
        <cfoutput>
            <div class="container">

                <h2 class="page-title">Customer Records - CRUD OPERATIONS</h2>

                <!-- ===== SEARCH + ADD NEW BUTTON ===== -->
                <form method="post" name="searchForm" class="search-add">
                    <input type="text" name="searchText" class="input-box search-input"
                        placeholder="Search by name or email"
                        value="#form.searchText ?: ''#">
                    <button type="submit" name="search" class="btn search-btn">Search</button>
                    <button type="submit" name="reset" class="btn reset-btn">Reset</button>
                </form>

                <cfif NOT structKeyExists(form,"editID") AND NOT structKeyExists(form,"addNew")>
                    <form method="post" style="margin-top:10px;">
                        <button type="submit" name="addNew" class="btn add-btn">Add New Customer</button>
                    </form>
                </cfif>

                <!-- ===== NAV BUTTON ===== -->
                <p class="nav" style="margin-top:10px;">
                    <a href="product_crud.cfm" class="button">Go to Product Records</a>
                </p>

                <br>

                <!-- ===== DISPLAY VALIDATION MESSAGES ===== -->
                <cfif structKeyExists(form,"save")>
                    <!-- Name validation -->
                    <cfif NOT reFind("^(?=.*[A-Za-z])[A-Za-z ]+$", trim(form.CustomerName))>
                        <p class="error">Customer Name must contain only alphabets and spaces.</p>
                    <cfelseif NOT reFind("^[0-9]{10,15}$", form.PhoneNo)>
                        <p class="error">Phone number must contain only digits (10–15 digits).</p>
                    <cfelseif NOT reFind("^[^@]+@[^@]+\.[^@]+$", trim(form.Email))>
                        <p class="error">Please enter a valid email address.</p>
                    <cfelse>
                        <!-- Duplicate check -->
                        <cfstoredproc procedure="sp_CheckCustomerExists" datasource="ordersdsn">
                            <cfprocparam value="#trim(form.CustomerName)#" cfsqltype="cf_sql_varchar">
                            <cfprocparam value="#trim(form.Email)#" cfsqltype="cf_sql_varchar">
                            <cfprocparam value="#trim(form.PhoneNo)#" cfsqltype="cf_sql_varchar">
                            <cfprocresult name="qExists">
                        </cfstoredproc>

                        <cfif qExists.recordcount AND (NOT structKeyExists(form,"CustomerID") OR qExists.CustomerID NEQ form.CustomerID)>
                            <p class="error">Customer with the same Name, Email, and Phone already exists!</p>
                        </cfif>
                    </cfif>
                </cfif>

                <!-- ===== ADD / EDIT FORM ABOVE TABLE ===== -->
                <cfif structKeyExists(form,"addNew") OR structKeyExists(form,"editID")>

                    <!-- Load edit data if editing -->
                    <cfif structKeyExists(form,"editID") AND isNumeric(form.editID)>
                        <cfstoredproc procedure="sp_GetCustomerById" datasource="ordersdsn">
                            <cfprocparam value="#form.editID#" cfsqltype="cf_sql_integer">
                            <cfprocresult name="qEdit">
                        </cfstoredproc>
                    </cfif>

                    <h3 class="form-title">#structKeyExists(form,"editID") ? "Edit Customer" : "Add New Customer"#</h3>

                    <form method="post" class="customer-form">
                        <cfif structKeyExists(form,"editID")>
                            <input type="hidden" name="CustomerID" value="#qEdit.CustomerID#">
                        </cfif>

                        <label class="form-label">Name:</label>
                        <input type="text" name="CustomerName" class="input-box name-input"
                            value="#structKeyExists(form,'editID') ? qEdit.CustomerName : ''#" required><br><br>

                        <label class="form-label">Email:</label>
                        <input type="text" name="Email" class="input-box email-input"
                            value="#structKeyExists(form,'editID') ? qEdit.Email : ''#" required><br><br>

                        <label class="form-label">Phone:</label>
                        <input type="text" name="PhoneNo" class="input-box phone-input"
                            value="#structKeyExists(form,'editID') ? qEdit.PhoneNo : ''#" required><br><br>

                        <button type="submit" name="save" class="btn save-btn">
                            #structKeyExists(form,"editID") ? "Update" : "Insert"#
                        </button>
                    </form>
                    <br>
                </cfif>

                <!-- ===== FETCH AND DISPLAY CUSTOMER TABLE ===== -->
                <cfif structKeyExists(form,"search") AND len(trim(form.searchText))>
                    <cfstoredproc procedure="sp_SearchCustomer" datasource="ordersdsn">
                        <cfprocparam value="#trim(form.searchText)#" cfsqltype="cf_sql_varchar">
                        <cfprocresult name="qCustomer">
                    </cfstoredproc>
                <cfelse>
                    <cfstoredproc procedure="sp_SelectCustomer" datasource="ordersdsn">
                        <cfprocresult name="qCustomer">
                    </cfstoredproc>
                </cfif>

                <table class="table customer-table">
                    <tr>
                        <th class="table-header">Sl No.</th>
                        <th class="table-header">Name</th>
                        <th class="table-header">Email</th>
                        <th class="table-header">Phone</th>
                        <th class="table-header">Action</th>
                    </tr>

                    <cfset sl = 1>
                    <cfloop query="qCustomer">
                        <tr class="table-row">
                            <td class="table-cell">#sl#</td>
                            <td class="table-cell">#CustomerName#</td>
                            <td class="table-cell">#Email#</td>
                            <td class="table-cell">#PhoneNo#</td>
                            <td class="table-cell actions-cell">
                                <!-- EDIT FORM -->
                                <form method="post" class="inline-form">
                                    <input type="hidden" name="editID" value="#CustomerID#">
                                    <button type="submit" class="btn edit-btn">Edit</button>
                                </form>
                                <!-- DELETE FORM -->
                                <form method="post" class="inline-form">
                                    <input type="hidden" name="deleteID" value="#CustomerID#">
                                    <button type="submit" class="btn delete-btn" onclick="return confirm('Delete this customer?')">Delete</button>
                                </form>
                            </td>
                        </tr>
                        <cfset sl++>
                    </cfloop>
                </table>

                <!-- ===== DELETE LOGIC ===== -->
                <cfif structKeyExists(form,"deleteID") AND isNumeric(form.deleteID)>
                    <cfstoredproc procedure="sp_DeleteCustomer" datasource="ordersdsn">
                        <cfprocparam value="#form.deleteID#" cfsqltype="cf_sql_integer">
                    </cfstoredproc>
                    <cflocation url="customer_crud.cfm" addtoken="false">
                </cfif>

            </div>
        </cfoutput>
    </body>
</html>
