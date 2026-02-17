<cfparam name="customerErrorMsg" default="">
<cfparam name="SearchErrorMsg" default="">

<!-- ================= ENCRYPTION KEY ================= -->
<cfset encryptionKey = "MySecretKey123456789012345678iuh">
<cfset decryptedID = "">

<!-- ================= SAFE DECRYPT ================= -->
<cffunction name="safeDecrypt" returntype="string">
    <cfargument name="value" required="true">
    <cftry>
        <cfreturn decrypt(arguments.value, encryptionKey, "AES/CBC/PKCS5Padding", "Base64")>
        <cfcatch>
            <cfreturn "">
        </cfcatch>
    </cftry>
</cffunction>

<!-- ================= SAFE ENCRYPT ================= -->
<cffunction name="safeEncrypt" returntype="string">
    <cfargument name="value" required="true">
    <cfreturn encrypt(arguments.value, encryptionKey, "AES/CBC/PKCS5Padding", "Base64")>
</cffunction>

<!-- ================= HANDLE URL ID ================= -->
<cfif structKeyExists(url,"id") AND len(url.id)>
    <cfif url.id EQ "0">
        <cfset decryptedID = "0">
    <cfelse>
        <cfset decryptedID = safeDecrypt(url.id)>
    </cfif>
</cfif>

<!-- ================= DELETE ================= -->
<cfif structKeyExists(form,"deleteID") AND len(form.deleteID)>
    <cfset realID = safeDecrypt(form.deleteID)>
    <cfif isNumeric(realID)>
        <cfstoredproc procedure="sp_DeleteCustomer" datasource="ordersdsn">
            <cfprocparam value="#realID#" cfsqltype="cf_sql_integer">
        </cfstoredproc>
        <cflocation url="customer_crud.cfm?msg=deleted" addtoken="no">
    </cfif>
</cfif>

<!-- ================= SAVE ================= -->
<cfif structKeyExists(form,"CustomerName")>

    <cfset cleanName  = trim(form.CustomerName)>
    <cfset cleanEmail = trim(form.Email)>
    <cfset cleanPhone = trim(form.PhoneNo)>

    <!-- VALIDATION -->
    <cfif len(cleanName) LT 2 OR NOT reFind("^[A-Za-z ]+$", cleanName)>
        <cfset customerErrorMsg = "Customer name must contain only alphabets and be at least 2 characters.">
    <cfelseif NOT reFind("^[0-9]{10,15}$", cleanPhone)>
        <cfset customerErrorMsg = "Phone number must be 10-15 digits.">
    <cfelseif NOT reFind("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$", cleanEmail)>
        <cfset customerErrorMsg = "Invalid email format.">
    </cfif>

    <!-- CHECK DUPLICATE -->
    <cfif NOT len(customerErrorMsg)>
        <cfstoredproc procedure="sp_CheckCustomerExists" datasource="ordersdsn">
            <cfprocparam value="#cleanEmail#" cfsqltype="cf_sql_varchar">
            <cfprocparam value="#structKeyExists(form,'CustomerID') ? form.CustomerID : ''#"
                         cfsqltype="cf_sql_integer"
                         null="#NOT structKeyExists(form,'CustomerID')#">
            <cfprocresult name="qExists">
        </cfstoredproc>

        <cfif qExists.recordcount GT 0>
            <cfset customerErrorMsg = "Email already exists. Please use another email.">
        </cfif>
    </cfif>

    <!-- INSERT / UPDATE -->
    <cfif NOT len(customerErrorMsg)>
        <cfif structKeyExists(form,"CustomerID") AND len(form.CustomerID)>
            <cfstoredproc procedure="sp_UpdateCustomer" datasource="ordersdsn">
                <cfprocparam value="#form.CustomerID#" cfsqltype="cf_sql_integer">
                <cfprocparam value="#cleanName#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#cleanEmail#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#cleanPhone#" cfsqltype="cf_sql_varchar">
            </cfstoredproc>
            <cflocation url="customer_crud.cfm?msg=updated" addtoken="no">
        <cfelse>
            <cfstoredproc procedure="sp_InsertCustomer" datasource="ordersdsn">
                <cfprocparam value="#cleanName#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#cleanEmail#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#cleanPhone#" cfsqltype="cf_sql_varchar">
            </cfstoredproc>
            <cflocation url="customer_crud.cfm?msg=added" addtoken="no">
        </cfif>
    </cfif>
</cfif>

<!-- ================= SEARCH ================= -->
<cfif structKeyExists(form,"search")>
    <cfset searchValue = trim(form.searchText)>

    <cfif NOT len(searchValue)>
        <cfset SearchErrorMsg = "Search cannot be empty.">
    <cfelseif NOT reFind("^(?=.*[A-Za-z0-9])[A-Za-z0-9@._\- ]+$", searchValue)>
        <cfset SearchErrorMsg = "Invalid search text.">
    </cfif>

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

<!-- ================= FETCH EDIT DATA ================= -->
<cfif len(decryptedID) AND decryptedID NEQ "0">
    <cfstoredproc procedure="sp_GetCustomerByID" datasource="ordersdsn">
        <cfprocparam value="#decryptedID#" cfsqltype="cf_sql_integer">
        <cfprocresult name="qSingle">
    </cfstoredproc>
</cfif>

<html>
    <head>
        <title>Customer Records</title>
        <link rel="stylesheet" href="style.css?v=1">
        <script>
            function confirmDelete(id){
                if(confirm("Are you sure you want to delete this customer?")){
                    document.getElementById("deleteID").value=id;
                    document.getElementById("deleteForm").submit();
                }
            }

            function closeMessage(el){
                el.parentElement.style.display="none";
            }

            window.onload=function(){
                let msg=document.querySelector(".success");
                if(msg)
                {
                    setTimeout(()=>{msg.style.display="none"},3000);
                    if(window.location.search.includes("msg=")){
                        window.history.replaceState({}, document.title, "customer_crud.cfm");
                    }
                }
            }
        </script>
    </head>
    <body>
        <cfoutput>
            <div class="container">
                <h2 class="page-title">Customer Records - CRUD Operations</h2>

                <form method="post" id="deleteForm">
                    <input type="hidden" name="deleteID" id="deleteID">
                </form>

                <cfif structKeyExists(url,"msg")>
                    <div class="success message-box">
                        <cfif url.msg EQ "added">Customer added successfully.</cfif>
                        <cfif url.msg EQ "updated">Customer updated successfully.</cfif>
                        <cfif url.msg EQ "deleted">Customer deleted successfully.</cfif>
                    </div>
                </cfif>

                <!-- FORM MODE -->
                <cfif structKeyExists(url,"id")>
                    <h3 class="form-title">
                        <cfif url.id EQ 0>Add New Customer<cfelse>Edit Customer</cfif>
                    </h3>
                    <form method="post">
                        <input type="hidden" name="CustomerID" value="#decryptedID#">

                        <label>Customer Name:</label>
                        <input type="text" name="CustomerName" class="input-box" required
                            value="#url.id GT 0? qSingle.CustomerName : ''#"><br><br>

                        <label>Email:</label>
                        <input type="text" name="Email" class="input-box" required
                            value="#url.id GT 0? qSingle.Email : ''#"><br><br>

                        <label>Phone:</label>
                        <input type="text" name="PhoneNo" class="input-box" required
                            value="#url.id GT 0? qSingle.PhoneNo : ''#"><br><br>

                        <button type="submit" class="btn">Save</button>
                        <a href="customer_crud.cfm" class="btn">Cancel</a>
                    </form>

                    <cfif len(customerErrorMsg)>
                        <div class="error message-box">
                            <span class="close-btn" onclick="closeMessage(this)">&times;</span>
                            #customerErrorMsg#
                        </div>
                    </cfif>

                <!-- TABLE MODE -->
                <cfelse>
                    <div class="search-add">
                        <form method="post">
                            <input type="text" name="searchText" class="input-box search-input"
                                placeholder="Search by name or email"
                                value="#structKeyExists(form,'searchText') ? form.searchText : ''#">
                            <button type="submit" name="search" class="btn">Search</button>
                            <a href="customer_crud.cfm" class="btn">Reset</a>
                        </form>
                        <a href="customer_crud.cfm?id=0" class="add-btn">Add New Customer</a>
                        <p class="nav">
                            <a href="product_crud.cfm" class="button">Go to Product Records</a>
                        </p>
                    </div>

                    <cfif len(SearchErrorMsg)>
                        <div class="error message-box">
                            <span class="close-btn" onclick="closeMessage(this)">&times;</span>
                            #SearchErrorMsg#
                        </div>
                    </cfif>

                    <table class="customer-table">
                        <tr>
                            <th>SL NO</th>
                            <th>NAME</th>
                            <th>EMAIL</th>
                            <th>PHONE</th>
                            <th>ACTIONS</th>
                        </tr>

                        <cfif qCustomer.recordcount EQ 0>
                            <tr><td colspan="5" align="center">No customers found.</td></tr>
                        </cfif>

                        <cfset sl=1>
                        <cfloop query="qCustomer">
                            <tr>
                                <td>#sl#</td>
                                <td>#qCustomer.CustomerName#</td>
                                <td>#qCustomer.Email#</td>
                                <td>#qCustomer.PhoneNo#</td>
                                <td>
                                    <cfset encID = safeEncrypt(qCustomer.CustomerID)>
                                    <a href="customer_crud.cfm?id=#urlEncodedFormat(encID)#" class="btn edit-btn">Edit</a>
                                    <button type="button" class="btn delete-btn" onclick="confirmDelete('#encID#')">Delete</button>
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
