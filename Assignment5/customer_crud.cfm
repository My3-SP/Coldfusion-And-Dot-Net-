<cfparam name="errorMsg" default="">

<!-- ================= RESET ================= -->
<cfif structKeyExists(form,"reset")>
    <cflocation url="customer_crud.cfm" addtoken="false">
</cfif>

<!-- ================= DELETE ================= -->
<cfif structKeyExists(form,"deleteID") AND isNumeric(form.deleteID)>
    <cfstoredproc procedure="sp_DeleteCustomer" datasource="ordersdsn">
        <cfprocparam value="#form.deleteID#" cfsqltype="cf_sql_integer">
    </cfstoredproc>
    <cflocation url="customer_crud.cfm" addtoken="false">
</cfif>

<!-- ================= SAVE (INSERT / UPDATE) ================= -->
<cfif structKeyExists(form,"save")>

    <!-- Name validation -->
    <cfif NOT reFind("^[A-Za-z ]+$", trim(form.CustomerName))>
        <cfset errorMsg = "Customer name must contain only alphabets and spaces.">
    </cfif>

    <!-- Phone validation -->
    <cfif NOT len(errorMsg) AND NOT reFind("^[0-9]{10,15}$", form.PhoneNo)>
        <cfset errorMsg = "Phone number must be 10–15 digits.">
    </cfif>

    <!-- Email validation -->
    <cfif NOT len(errorMsg) AND NOT reFind("^[^@]+@[^@]+\.[^@]+$", trim(form.Email))>
        <cfset errorMsg = "Invalid email format.">
    </cfif>

    <!-- Duplicate EMAIL check -->
    <cfif NOT len(errorMsg)>
        <cfstoredproc procedure="sp_CheckCustomerExists" datasource="ordersdsn">
            <cfprocparam value="#trim(form.Email)#" cfsqltype="cf_sql_varchar">
            <cfprocparam value="#structKeyExists(form,'CustomerID') ? form.CustomerID : ''#"
                         cfsqltype="cf_sql_integer"
                         null="#NOT structKeyExists(form,'CustomerID')#">
            <cfprocresult name="qExists">
        </cfstoredproc>

        <cfif qExists.recordcount>
            <cfset errorMsg = "Email already exists. Please use another email.">
        </cfif>
    </cfif>

    <!-- Insert or Update -->
    <cfif NOT len(errorMsg)>
        <cfif structKeyExists(form,"CustomerID") AND isNumeric(form.CustomerID)>
            <!-- UPDATE -->
            <cfstoredproc procedure="sp_UpdateCustomer" datasource="ordersdsn">
                <cfprocparam value="#form.CustomerID#" cfsqltype="cf_sql_integer">
                <cfprocparam value="#trim(form.CustomerName)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#trim(form.Email)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#trim(form.PhoneNo)#" cfsqltype="cf_sql_varchar">
            </cfstoredproc>
        <cfelse>
            <!-- INSERT -->
            <cfstoredproc procedure="sp_InsertCustomer" datasource="ordersdsn">
                <cfprocparam value="#trim(form.CustomerName)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#trim(form.Email)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#trim(form.PhoneNo)#" cfsqltype="cf_sql_varchar">
            </cfstoredproc>
        </cfif>

        <cflocation url="customer_crud.cfm" addtoken="false">
    </cfif>

</cfif>

<!-- ================= DATA FETCHING ================= -->

<!-- Search / Select -->
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

<!-- Load Edit Data -->
<cfif structKeyExists(form,"editID") AND isNumeric(form.editID)>
    <cfstoredproc procedure="sp_GetCustomerById" datasource="ordersdsn">
        <cfprocparam value="#form.editID#" cfsqltype="cf_sql_integer">
        <cfprocresult name="qEdit">
    </cfstoredproc>
</cfif>

<!-- ================= HTML ================= -->

<html>
    <head>
        <title>Customer Records</title>
        <link rel="stylesheet" href="style.css">
    </head>

    <body>
        <cfoutput>

            <div class="container">

                <h2 class="page-title">Customer Records - CRUD OPERATIONS</h2>

                <!-- ===== SEARCH BAR ===== -->
                <form method="post" class="search-add">
                    <input type="text"
                        name="searchText"
                        class="input-box search-input"
                        placeholder="Search by name or email"
                        value="#form.searchText ?: ''#">

                    <button type="submit" name="search" class="btn search-btn">Search</button>
                    <button type="submit" name="reset" class="btn reset-btn">Reset</button>
                </form>

                <!-- ===== ERROR MESSAGE (PRODUCT STYLE) ===== -->
                <cfif len(errorMsg)>
                    <div class="error">
                        #errorMsg#
                    </div>
                </cfif>

                <!-- ===== ADD BUTTON ===== -->
                <cfif NOT structKeyExists(form,"editID") AND NOT structKeyExists(form,"addNew")>
                    <form method="post">
                        <button type="submit" name="addNew" class="btn add-btn">Add New Customer</button>
                    </form>
                </cfif>
                <br>
                <p class="nav">
                    <a href="product_crud.cfm" class="button">Go to Product Records</a>
                </p>

                <!-- ===== ADD / EDIT FORM ===== -->
                <cfif structKeyExists(form,"addNew") OR structKeyExists(form,"editID")>

                    <h3 class="form-title">
                        #structKeyExists(form,"editID") ? "Edit Customer" : "Add New Customer"#
                    </h3>

                    <form method="post" class="customer-form">

                        <cfif structKeyExists(form,"editID")>
                            <input type="hidden" name="CustomerID" value="#qEdit.CustomerID#">
                        </cfif>

                        <label class="form-label">Customer Name:</label>
                        <input type="text" name="CustomerName" class="input-box" required
                            value="#structKeyExists(form,'editID') ? qEdit.CustomerName : ''#">
                        <br><br>
                        <label class="form-label">Email:</label>
                        <input type="text" name="Email" class="input-box" required
                            value="#structKeyExists(form,'editID') ? qEdit.Email : ''#">
                        <br><br>
                        <label class="form-label">Phone:</label>
                        <input type="text" name="PhoneNo" class="input-box" required
                            value="#structKeyExists(form,'editID') ? qEdit.PhoneNo : ''#">
                        <br>
                        <button type="submit" name="save" class="btn save-btn">
                            #structKeyExists(form,"editID") ? "Update" : "Insert"#
                        </button>

                        <cfif structKeyExists(form,"editID")>
                            <button type="submit" name="cancel" class="btn cancel-btn">Cancel</button>
                        </cfif>

                    </form>
                </cfif>

                <!-- ===== CUSTOMER TABLE ===== -->
                <table class="customer-table">
                    <tr>
                        <th>SL NO</th>
                        <th>NAME</th>
                        <th>EMAIL</th>
                        <th>PHONE</th>
                        <th>ACTIONS</th>
                    </tr>

                    <cfset sl = 1>
                    <cfloop query="qCustomer">
                        <tr>
                            <td>#sl#</td>
                            <td>#CustomerName#</td>
                            <td>#Email#</td>
                            <td>#PhoneNo#</td>
                            <td>

                                <form method="post" class="inline-form">
                                    <input type="hidden" name="editID" value="#CustomerID#">
                                    <button class="btn edit-btn">Edit</button>
                                </form>

                                <form method="post" class="inline-form">
                                    <input type="hidden" name="deleteID" value="#CustomerID#">
                                    <button class="btn delete-btn"
                                            onclick="return confirm('Delete this customer?')">
                                        Delete
                                    </button>
                                </form>

                            </td>
                        </tr>
                        <cfset sl++>
                    </cfloop>
                </table>

            </div>

        </cfoutput>
    </body>
</html>
