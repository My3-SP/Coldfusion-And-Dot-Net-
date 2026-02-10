<html>
    <head>
        <title>Product Records - CRUD Operations</title>
        <link rel="stylesheet" href="style.css">
    </head>

    <body>
        <cfoutput>
            <div class="container">

                <h2 class="page-title">Product Records - CRUD OPERATIONS</h2>

                <!-- ===== SEARCH + ADD NEW BUTTON ===== -->
                <form method="post" name="searchForm" class="search-add">
                    <input type="text" name="searchText" class="input-box search-input"
                        placeholder="Search by product name"
                        value="#form.searchText ?: ''#">
                    <button type="submit" name="search" class="btn search-btn">Search</button>
                    <button type="submit" name="reset" class="btn reset-btn">Reset</button>
                </form>

                <cfif NOT structKeyExists(form,"editID") AND NOT structKeyExists(form,"addNew")>
                    <form method="post" style="margin-top:10px;">
                        <button type="submit" name="addNew" class="btn add-btn">Add New Product</button>
                    </form>
                </cfif>

                <!-- ===== NAV BUTTON ===== -->
                <p class="nav" style="margin-top:10px;">
                    <a href="customer_crud.cfm" class="button">Go to Customer Records</a>
                </p>

                <br>

                <!-- ===== DISPLAY VALIDATION MESSAGES ===== -->
                <cfif structKeyExists(form,"save")>
                    <!-- Product Name validation -->
                    <cfif NOT reFind("^(?=.*[A-Za-z0-9])[A-Za-z0-9 \-\_\.\(\)/]+$", trim(form.ProductName))>
                        <p class="error">Invalid product name. Only letters, numbers, spaces, and - _ . ( ) / are allowed.</p>
                    <cfelseif NOT isNumeric(form.Price) OR form.Price LTE 0>
                        <p class="error">Price must be a positive number.</p>
                    <cfelse>
                        <!-- Duplicate check -->
                        <cfstoredproc procedure="sp_CheckProductExists" datasource="ordersdsn">
                            <cfprocparam value="#trim(form.ProductName)#" cfsqltype="cf_sql_varchar">
                            <cfprocparam value="#form.Price#" cfsqltype="cf_sql_decimal">
                            <cfprocresult name="qExists">
                        </cfstoredproc>

                        <cfif qExists.recordcount AND (NOT structKeyExists(form,"ProductID") OR qExists.ProductID NEQ form.ProductID)>
                            <p class="error">Product with the same Name and Price already exists!</p>
                        </cfif>
                    </cfif>
                </cfif>

                <!-- ===== ADD / EDIT FORM ABOVE TABLE ===== -->
                <cfif structKeyExists(form,"addNew") OR structKeyExists(form,"editID")>

                    <!-- Load edit data if editing -->
                    <cfif structKeyExists(form,"editID") AND isNumeric(form.editID)>
                        <cfstoredproc procedure="sp_GetProductById" datasource="ordersdsn">
                            <cfprocparam value="#form.editID#" cfsqltype="cf_sql_integer">
                            <cfprocresult name="qEdit">
                        </cfstoredproc>
                    </cfif>

                    <h3 class="form-title">#structKeyExists(form,"editID") ? "Edit Product" : "Add New Product"#</h3>

                    <form method="post" class="product-form">
                        <cfif structKeyExists(form,"editID")>
                            <input type="hidden" name="ProductID" value="#qEdit.ProductID#">
                        </cfif>

                        <label class="form-label">Product Name:</label>
                        <input type="text" name="ProductName" class="input-box name-input"
                            value="#structKeyExists(form,'editID') ? qEdit.ProductName : ''#" required><br><br>

                        <label class="form-label">Price:</label>
                        <input type="text" name="Price" class="input-box price-input"
                            value="#structKeyExists(form,'editID') ? qEdit.Price : ''#" required><br><br>

                        <button type="submit" name="save" class="btn save-btn">
                            #structKeyExists(form,"editID") ? "Update" : "Insert"#
                        </button>

                        <cfif structKeyExists(form,"editID")>
                            <button type="submit" name="cancel" class="btn cancel-btn">Cancel</button>
                        </cfif>
                    </form>
                    <br>
                </cfif>

                <!-- ===== FETCH AND DISPLAY PRODUCT TABLE ===== -->
                <cfif structKeyExists(form,"search") AND len(trim(form.searchText))>
                    <cfstoredproc procedure="sp_SearchProduct" datasource="ordersdsn">
                        <cfprocparam value="#trim(form.searchText)#" cfsqltype="cf_sql_varchar">
                        <cfprocresult name="qProduct">
                    </cfstoredproc>
                <cfelse>
                    <cfstoredproc procedure="sp_SelectProduct" datasource="ordersdsn">
                        <cfprocresult name="qProduct">
                    </cfstoredproc>
                </cfif>

                <table class="table product-table">
                    <tr>
                        <th class="table-header">SL NO</th>
                        <th class="table-header">PRODUCT NAME</th>
                        <th class="table-header">PRICE</th>
                        <th class="table-header">ACTIONS</th>
                    </tr>

                    <cfset sl = 1>
                    <cfloop query="qProduct">
                        <tr class="table-row">
                            <td class="table-cell">#sl#</td>
                            <td class="table-cell">#ProductName#</td>
                            <td class="table-cell">#Price#</td>
                            <td class="table-cell actions-cell">
                                <!-- EDIT FORM -->
                                <form method="post" class="inline-form">
                                    <input type="hidden" name="editID" value="#ProductID#">
                                    <button type="submit" class="btn edit-btn">Edit</button>
                                </form>
                                <!-- DELETE FORM -->
                                <form method="post" class="inline-form">
                                    <input type="hidden" name="deleteID" value="#ProductID#">
                                    <button type="submit" class="btn delete-btn" onclick="return confirm('Delete this product?')">Delete</button>
                                </form>
                            </td>
                        </tr>
                        <cfset sl++>
                    </cfloop>
                </table>

                <!-- ===== DELETE LOGIC ===== -->
                <cfif structKeyExists(form,"deleteID") AND isNumeric(form.deleteID)>
                    <cfstoredproc procedure="sp_DeleteProduct" datasource="ordersdsn">
                        <cfprocparam value="#form.deleteID#" cfsqltype="cf_sql_integer">
                    </cfstoredproc>
                    <cflocation url="product_crud.cfm" addtoken="false">
                </cfif>

                <!-- ===== CANCEL LOGIC ===== -->
                <cfif structKeyExists(form,"cancel")>
                    <cflocation url="product_crud.cfm" addtoken="false">
                </cfif>

            </div>
        </cfoutput>
    </body>
</html>
