<cfparam name="errorMsg" default="">

<!-- ===== RESET ===== -->
<cfif structKeyExists(form,"reset")>
    <cflocation url="product_crud.cfm" addtoken="false">
</cfif>

<!-- ===== DELETE ===== -->
<cfif structKeyExists(form,"deleteID") AND isNumeric(form.deleteID)>
    <cfstoredproc procedure="sp_DeleteProduct" datasource="ordersdsn">
        <cfprocparam value="#form.deleteID#" cfsqltype="cf_sql_integer">
    </cfstoredproc>
    <cflocation url="product_crud.cfm" addtoken="false">
</cfif>

<!-- ===== SAVE (INSERT / UPDATE) ===== -->
<cfif structKeyExists(form,"save")>

    <!-- Product Name validation -->
    <cfif NOT reFind("^(?=.*[A-Za-z0-9])[A-Za-z0-9 \-\_\.\(\)/]+$", trim(form.ProductName))>
        <cfset errorMsg = "Invalid product name. Only letters, numbers, spaces, and - _ . ( ) / are allowed.">
    </cfif>

    <!-- Price validation -->
    <cfif NOT len(errorMsg) AND (NOT isNumeric(form.Price) OR form.Price LTE 0)>
        <cfset errorMsg = "Price must be a positive number.">
    </cfif>

    <!-- Duplicate check -->
    <cfif NOT len(errorMsg)>
        <cfstoredproc procedure="sp_CheckProductExists" datasource="ordersdsn">
            <cfprocparam dbvarname="@ProductName"
                         value="#trim(form.ProductName)#"
                         cfsqltype="cf_sql_varchar">
            <cfprocparam dbvarname="@Price"
                         value="#form.Price#"
                         cfsqltype="cf_sql_decimal">
            <cfprocresult name="qExists">
        </cfstoredproc>

        <cfif qExists.recordcount AND
              (NOT structKeyExists(form,"ProductID") OR qExists.ProductID NEQ form.ProductID)>
            <cfset errorMsg = "Product with the same Name and Price already exists!">
        </cfif>
    </cfif>

    <!-- Insert or Update -->
    <cfif NOT len(errorMsg)>
        <cfif structKeyExists(form,"ProductID") AND isNumeric(form.ProductID)>
            <!-- UPDATE -->
            <cfstoredproc procedure="sp_UpdateProduct" datasource="ordersdsn">
                <cfprocparam value="#form.ProductID#" cfsqltype="cf_sql_integer">
                <cfprocparam value="#trim(form.ProductName)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#form.Price#" cfsqltype="cf_sql_decimal">
            </cfstoredproc>
        <cfelse>
            <!-- INSERT -->
            <cfstoredproc procedure="sp_InsertProduct" datasource="ordersdsn">
                <cfprocparam value="#trim(form.ProductName)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#form.Price#" cfsqltype="cf_sql_decimal">
            </cfstoredproc>
        </cfif>

        <cflocation url="product_crud.cfm" addtoken="false">
    </cfif>

</cfif>

<!-- ========================= DATA FETCHING ========================= -->

<!-- Search / Select -->
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

<!-- Load Edit Data -->
<cfif structKeyExists(form,"editID") AND isNumeric(form.editID)>
    <cfstoredproc procedure="sp_GetProductById" datasource="ordersdsn">
        <cfprocparam value="#form.editID#" cfsqltype="cf_sql_integer">
        <cfprocresult name="qEdit">
    </cfstoredproc>
</cfif>

<!-- ========================= HTML ========================= -->

<html>
    <head>
        <title>Product Records</title>
        <link rel="stylesheet" href="style.css">
    </head>

    <body>
        <cfoutput>
            <div class="container">

                <h2 class="page-title">Product Records - CRUD OPERATIONS</h2>

                <!-- ===== SEARCH BAR ===== -->
                <form method="post" class="search-add">
                    <input type="text" name="searchText" class="input-box search-input" placeholder="Search by product name"
                        value="#form.searchText ?: ''#">

                    <button type="submit" name="search" class="btn search-btn">Search</button>
                    <button type="submit" name="reset" class="btn reset-btn">Reset</button>
                </form>

                <!-- ===== ERROR MESSAGE (BELOW SEARCH BAR) ===== -->
                <cfif len(errorMsg)>
                    <div class="error">
                        #errorMsg#
                    </div>
                </cfif>

                <!-- ===== ADD BUTTON ===== -->
                <cfif NOT structKeyExists(form,"editID") AND NOT structKeyExists(form,"addNew")>
                    <form method="post">
                        <button type="submit" name="addNew" class="btn add-btn">Add New Product</button>
                    </form>
                </cfif>
                <br>
                <p class="nav">
                    <a href="customer_crud.cfm" class="button">Go to Customer Records</a>
                </p>

                <!-- ===== ADD / EDIT FORM ===== -->
                <cfif structKeyExists(form,"addNew") OR structKeyExists(form,"editID")>

                    <h3 class="form-title">
                        #structKeyExists(form,"editID") ? "Edit Product" : "Add New Product"#
                    </h3>

                    <form method="post" class="product-form">

                        <cfif structKeyExists(form,"editID")>
                            <input type="hidden" name="ProductID" value="#qEdit.ProductID#">
                        </cfif>

                        <label class="form-label">Product Name:</label>
                        <input type="text" name="ProductName" class="input-box" required
                            value="#structKeyExists(form,'editID') ? qEdit.ProductName : ''#">
                        <br><br>

                        <label class="form-label">Price:</label>
                        <input type="text" name="Price" class="input-box" required
                            value="#structKeyExists(form,'editID') ? qEdit.Price : ''#">
                        <br><br>

                        <button type="submit" name="save" class="btn save-btn">
                            #structKeyExists(form,"editID") ? "Update" : "Insert"#
                        </button>

                        <cfif structKeyExists(form,"editID")>
                            <button type="submit" name="cancel" class="btn cancel-btn">Cancel</button>
                        </cfif>

                    </form>
                </cfif>

                <!-- ===== PRODUCT TABLE ===== -->
                <table class="product-table">

                    <tr>
                        <th>SL NO</th>
                        <th>PRODUCT NAME</th>
                        <th>PRICE</th>
                        <th>ACTIONS</th>
                    </tr>

                    <cfset sl = 1>
                    <cfloop query="qProduct">
                        <tr>
                            <td>#sl#</td>
                            <td>#ProductName#</td>
                            <td>#Price#</td>
                            <td class="actions-cell">

                                <form method="post" class="inline-form">
                                    <input type="hidden" name="editID" value="#ProductID#">
                                    <button type="submit" class="btn edit-btn">Edit</button>
                                </form>

                                <form method="post" class="inline-form">
                                    <input type="hidden" name="deleteID" value="#ProductID#">
                                    <button type="submit" class="btn delete-btn"
                                            onclick="return confirm('Delete this product?')">
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
