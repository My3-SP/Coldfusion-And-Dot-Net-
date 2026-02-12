<cfparam name="customerErrorMsg" default="">
<cfparam name="SearchErrorMsg" default="">
<!-- ================= DELETE ================= -->
<cfif structKeyExists(form,"deleteID") AND isNumeric(form.deleteID) >

    <cfstoredproc procedure="sp_DeleteCustomer" datasource="ordersdsn">
        <cfprocparam value="#form.deleteID#" cfsqltype="cf_sql_integer">
    </cfstoredproc>

    <cflocation url="customer_crud.cfm" addtoken="false">
</cfif>


<!-- ================= SAVE ================= -->
<cfif structKeyExists(form,"save")>

    <!-- Name validation -->
    <cfif NOT reFind("^[A-Za-z ]+$", trim(form.CustomerName))>
        <cfset customerErrorMsg = "Customer name must contain only alphabets and spaces.">
    </cfif>

    <!-- Phone validation -->
    <cfif NOT len(customerErrorMsg) AND NOT reFind("^[0-9]{10,15}$", trim(form.PhoneNo))>
        <cfset customerErrorMsg = "Phone number must be 10–15 digits.">
    </cfif>

    <!-- Email validation -->
    <cfif NOT len(customerErrorMsg) AND NOT reFind("^[^@]+@[^@]+\.[^@]+$", trim(form.Email))>
        <cfset customerErrorMsg = "Invalid email format.">
    </cfif>

    <!-- Duplicate Email Check -->
    <cfif NOT len(customerErrorMsg)>
        <cfstoredproc procedure="sp_CheckCustomerExists" datasource="ordersdsn">
            <cfprocparam value="#trim(form.Email)#" cfsqltype="cf_sql_varchar">
            <cfprocparam value="#structKeyExists(form,'CustomerID') ? form.CustomerID : ''#"
                         cfsqltype="cf_sql_integer"
                         null="#NOT structKeyExists(form,'CustomerID')#">
            <cfprocresult name="qExists">
        </cfstoredproc>

        <cfif qExists.recordcount>
            <cfset customerErrorMsg = "Email already exists. Please use another email.">
        </cfif>
    </cfif>

    <!-- Insert / Update -->
    <cfif NOT len(customerErrorMsg)>
        <cfif structKeyExists(form,"CustomerID") AND isNumeric(form.CustomerID)>
            <cfstoredproc procedure="sp_UpdateCustomer" datasource="ordersdsn">
                <cfprocparam value="#form.CustomerID#" cfsqltype="cf_sql_integer">
                <cfprocparam value="#trim(form.CustomerName)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#trim(form.Email)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#trim(form.PhoneNo)#" cfsqltype="cf_sql_varchar">
            </cfstoredproc>
        <cfelse>
            <cfstoredproc procedure="sp_InsertCustomer" datasource="ordersdsn">
                <cfprocparam value="#trim(form.CustomerName)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#trim(form.Email)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#trim(form.PhoneNo)#" cfsqltype="cf_sql_varchar">
            </cfstoredproc>
        </cfif>

        <cflocation url="customer_crud.cfm" addtoken="false">
    </cfif>

</cfif>


<!-- ================= SEARCH ================= -->
<cfif structKeyExists(form,"search")>
    <cfset searchValue = trim(form.searchText)>
    <!-- Validation -->
    <cfif NOT len(searchValue)>
        <cfset SearchErrorMsg = "Search text cannot be empty or spaces only.">
    <cfelseif NOT reFind("^(?=.*[A-Za-z0-9])[A-Za-z0-9@._\- ]+$", searchValue)>
        <cfset SearchErrorMsg = "Search must contain at least one letter or number.">
    </cfif>

    <!-- If valid, perform search -->
    <cfif NOT len(SearchErrorMsg)>
        <cfstoredproc procedure="sp_SearchCustomer" datasource="ordersdsn">
            <cfprocparam value="#searchValue#" cfsqltype="cf_sql_varchar">
            <cfprocresult name="qCustomer">
        </cfstoredproc>
    <cfelse>
        <cfstoredproc procedure="sp_SelectCustomer" datasource="ordersdsn">
            <cfprocresult name="qCustomer">
        </cfstoredproc>
    </cfif>    
<cfelse>
    <cfstoredproc procedure="sp_SelectCustomer" datasource="ordersdsn">
        <cfprocresult name="qCustomer">
    </cfstoredproc>
</cfif>


<html>
    <head>
        <title>Customer Records</title>
        <link rel="stylesheet" href="style.css">

        <script>
            function showAddForm(){
                document.getElementById("formTitle").innerText = "Add New Customer";
                document.getElementById("CustomerID").value = "";
                document.getElementById("CustomerName").value = "";
                document.getElementById("Email").value = "";
                document.getElementById("PhoneNo").value = "";
                document.getElementById("customerFormContainer").style.display = "block";
            }

            function editCustomer(id,name,email,phone){
                document.getElementById("formTitle").innerText = "Edit Customer";
                document.getElementById("CustomerID").value = id;
                document.getElementById("CustomerName").value = name;
                document.getElementById("Email").value = email;
                document.getElementById("PhoneNo").value = phone;
                document.getElementById("customerFormContainer").style.display = "block";
            }

            function deleteCustomer(id){
                if(confirm("Delete this customer?")){
                    document.getElementById("deleteID").value = id;
                    document.getElementById("deleteForm").submit();
                }
            }

            function hideForm(){
                document.getElementById("customerFormContainer").style.display = "none";
            }
        </script>
    </head>

    <body>
        <cfoutput>

        <div class="container">
            <h2 class="page-title">Customer Records - CRUD Operations</h2>

            <!-- SEARCH + ADD -->
            <div class="search-add">
                <form method="post" id="searchForm">
                    <input type="text"
                        name="searchText"
                        class="input-box search-input"
                        placeholder="Search by name or email"
                        value="#structKeyExists(form,'searchText') ? form.searchText : ''#">

                    <button type="submit" name="search" class="btn">Search</button>
                    <button type="button" class="btn"
                            onclick="window.location='customer_crud.cfm'">Reset</button>
                </form>
                <button type="button" class="btn" onclick="showAddForm()">Add New Customer</button>
            </div>
            <form method="post" id="deleteForm">
                <input type="hidden" name="deleteID" id="deleteID">
            </form>
            
            

            <!-- ERROR -->
            <cfif len(SearchErrorMsg)>
                <div class="error">#SearchErrorMsg#</div>
            </cfif>
            <cfif len(customerErrorMsg)>
                <div class="error">#customerErrorMsg#</div>
                    <script>
                        document.addEventListener("DOMContentLoaded", function(){
                            document.getElementById("customerFormContainer").style.display = "block";
                        });
                    </script>
            </cfif>

            <p class="nav">
                <a href="product_crud.cfm" class="button">Go to Product Records</a>
            </p>

            <!-- TOGGLE FORM -->
            <div id="customerFormContainer" class="product-form" style="display:none;">

                <h3 id="formTitle" class="form-title">Add New Customer</h3>
                <form method="post">
                    <input type="hidden" name="CustomerID" id="CustomerID">
                    <div>
                        <label class="form-label">Customer Name:</label>
                        <input type="text" name="CustomerName" id="CustomerName"
                            class="input-box" required>
                    </div><br>

                    <div>
                        <label class="form-label">Email:</label>
                        <input type="text" name="Email" id="Email"
                            class="input-box" required>
                    </div>

                    <br>

                    <div>
                    <label class="form-label">Phone:</label>
                    <input type="text" name="PhoneNo" id="PhoneNo"
                        class="input-box" required>
                    </div>

                    <br>

                    <button type="submit" name="save" class="btn">Save</button>
                    <button type="button" onclick="hideForm()" class="btn">Cancel</button>

                </form>
            </div>

            <!-- TABLE -->
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
                        <td class="actions-cell">
                            <button type="button" class="btn"
                                    onclick="editCustomer('#CustomerID#','#CustomerName#','#Email#','#PhoneNo#')">
                            Edit
                            </button>

                            <button type="button" class="btn"
                                    onclick="deleteCustomer(#CustomerID#)"> Delete
                            </button>

                        </td>
                    </tr>
                    <cfset sl++>
                </cfloop>

            </table>

        </div>

        </cfoutput>
    </body>
</html>
