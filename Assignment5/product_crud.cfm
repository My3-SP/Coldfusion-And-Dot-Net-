<cfparam name="SearchErrorMsg" default="">
<cfparam name="productErrorMsg" default="">

<!-- ================= DELETE ================= -->
<cfif structKeyExists(form,"deleteID") AND isNumeric(form.deleteID)>
    <cfstoredproc procedure="sp_DeleteProduct" datasource="ordersdsn">
        <cfprocparam value="#form.deleteID#" cfsqltype="cf_sql_integer">
    </cfstoredproc>
    <cflocation url="product_crud.cfm?msg=deleted" addtoken="false">
</cfif>

<!-- ================= SAVE ================= -->
<cfif structKeyExists(form,"ProductName")>
    <cfset cleanName = trim(form.ProductName)>
    <cfset priceValue = form.Price>

    <!-- Validation -->
    <cfif len(cleanName) LT 2>
        <cfset productErrorMsg = "Product name must be at least 2 characters long.">
    <cfelseif NOT reFind("^(?=.*[A-Za-z])[A-Za-z0-9 \-_()./]+$", cleanName)>
        <cfset productErrorMsg = "Product name must contain at least one letter.">
    <cfelseif NOT isNumeric(priceValue) OR priceValue LTE 0>
        <cfset productErrorMsg = "Price must be a positive number.">
    </cfif>

    <!-- Duplicate check -->
    <cfif NOT len(productErrorMsg)>
        <cfstoredproc procedure="sp_CheckProductExists" datasource="ordersdsn">
            <cfprocparam value="#cleanName#" cfsqltype="cf_sql_varchar">
            <cfprocparam value="#priceValue#" cfsqltype="cf_sql_decimal">
            <cfprocparam value="#structKeyExists(form,'ProductID') ? form.ProductID : ''#"
                        cfsqltype="cf_sql_integer"
                        null="#NOT structKeyExists(form,'ProductID')#">
            <cfprocresult name="qExists">
        </cfstoredproc>
        <cfif qExists.recordcount GT 0>
            <cfset productErrorMsg = "Product already exists with same name and price.">
        </cfif>
    </cfif>

    <!-- Insert / Update -->
    <cfif NOT len(productErrorMsg)>
        <cfif structKeyExists(form,"ProductID") AND form.ProductID NEQ 0>
            <cfstoredproc procedure="sp_UpdateProduct" datasource="ordersdsn">
                <cfprocparam value="#form.ProductID#" cfsqltype="cf_sql_integer">
                <cfprocparam value="#cleanName#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#priceValue#" cfsqltype="cf_sql_decimal">
            </cfstoredproc>
            <cflocation url="product_crud.cfm?msg=updated" addtoken="false">
        <cfelse>
            <cfstoredproc procedure="sp_InsertProduct" datasource="ordersdsn">
                <cfprocparam value="#cleanName#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#priceValue#" cfsqltype="cf_sql_decimal">
            </cfstoredproc>
            <cflocation url="product_crud.cfm?msg=added" addtoken="false">
        </cfif>
    </cfif>
</cfif>

<!-- ================= SEARCH ================= -->
<cfif structKeyExists(form,"search")>
    <cfset searchValue = trim(form.searchText)>

    <cfif NOT len(searchValue)>
        <cfset SearchErrorMsg = "Search cannot be empty.">
    <cfelseif NOT reFind("^(?=.*[A-Za-z0-9])[A-Za-z0-9 \-_()./]+$", searchValue)>
        <cfset SearchErrorMsg = "Invalid search text.">
    </cfif>

    <cfif NOT len(SearchErrorMsg)>
        <cfstoredproc procedure="sp_SearchProduct" datasource="ordersdsn">
            <cfprocparam value="#searchValue#" cfsqltype="cf_sql_varchar">
            <cfprocresult name="qProduct">
        </cfstoredproc>
    <cfelse>
        <cfstoredproc procedure="sp_SelectProduct" datasource="ordersdsn">
            <cfprocresult name="qProduct">
        </cfstoredproc>
    </cfif>
<cfelse>
    <cfstoredproc procedure="sp_SelectProduct" datasource="ordersdsn">
        <cfprocresult name="qProduct">
    </cfstoredproc>
</cfif>

<!-- ================= FETCH EDIT ================= -->
<cfif structKeyExists(url,"id") AND isNumeric(url.id) AND url.id GT 0>
    <cfstoredproc procedure="sp_GetProductByID" datasource="ordersdsn">
        <cfprocparam value="#url.id#" cfsqltype="cf_sql_integer">
        <cfprocresult name="qSingle">
    </cfstoredproc>
</cfif>

<html>
    <head>
        <title>Product Records</title>
        <link rel="stylesheet" href="style.css">
        <script>
            function confirmDelete(id){
                if(confirm("Are you sure you want to delete this product?")){
                    document.getElementById("deleteID").value = id;
                    document.getElementById("deleteForm").submit();
                }
            }

            function closeMessage(el){
                el.parentElement.style.display = "none";
            }

            window.onload = function(){
                let msg = document.querySelector(".success");
                if(msg){
                    setTimeout(function(){
                        msg.style.display="none";
                    },3000);
                }
            }
        </script>
    </head>
    <body>
        <cfoutput>
            <div class="container">
                <h2 class="page-title">Product Records - CRUD Operations</h2>

                <!-- Hidden Delete Form -->
                <form method="post" id="deleteForm">
                    <input type="hidden" name="deleteID" id="deleteID">
                </form>

                <!-- SUCCESS MESSAGE -->
                <cfif structKeyExists(url,"msg")>
                    <div class="success message-box">
                        <cfif url.msg EQ "added">Product added successfully.</cfif>
                        <cfif url.msg EQ "updated">Product updated successfully.</cfif>
                        <cfif url.msg EQ "deleted">Product deleted successfully.</cfif>
                    </div>
                </cfif>

                <!-- FORM MODE -->
                <cfif structKeyExists(url,"id")>
                    <h3 class="form-title">
                        <cfif url.id EQ 0>
                            Add New Product 
                        <cfelse> Edit Product 
                        </cfif>
                    </h3>

                    <form method="post">
                        <input type="hidden" name="ProductID" value="#url.id#">

                        <label class="form-label">Product Name:</label>
                        <input type="text" name="ProductName" class="input-box" required
                            value="#url.id GT 0 ? qSingle.ProductName : ''#">

                        <br><br>

                        <label class="form-label">Price:</label>
                        <input type="text" name="Price" class="input-box" required
                            value="#url.id GT 0 ? qSingle.Price: ''#">

                        <br><br>

                        <button type="submit" class="btn">Save</button>
                        <a href="product_crud.cfm" class="btn">Cancel</a>
                    </form>

                    <cfif len(productErrorMsg)>
                        <div class="error message-box">
                            <span class="close-btn" onclick="closeMessage(this)">&times;</span>
                            #productErrorMsg#
                        </div>
                    </cfif>

                <!-- TABLE MODE -->
                <cfelse>
                    <div class="search-add">
                        <form method="post" class="inline-form">
                            <input type="text" name="searchText" class="input-box search-input"
                                placeholder="Search by product name"
                                value="#structKeyExists(form,'searchText') ? form.searchText : ''#">
                            <button type="submit" name="search" class="btn">Search</button>
                            <a href="product_crud.cfm" class="btn">Reset</a>
                        </form>

                        <a href="product_crud.cfm?id=0" class="btn">Add New Product</a>

                        <p class="nav">
                            <a href="customer_crud.cfm" class="button"> Go to Customer Records</a>
                        </p>
                    </div>

                    <cfif len(SearchErrorMsg)>
                        <div class="error message-box">
                            <span class="close-btn" onclick="closeMessage(this)">&times;</span>
                            #SearchErrorMsg#
                        </div>
                    </cfif>

                    <table class="product-table">
                        <tr>
                            <th>SL NO</th>
                            <th>PRODUCT NAME</th>
                            <th>PRICE</th>
                            <th>ACTIONS</th>
                        </tr>

                        <cfif qProduct.recordcount EQ 0>
                            <tr>
                                <td colspan="4" align="center">No products found.</td>
                            </tr>
                        </cfif>

                        <cfset sl=1>
                        <cfloop query="qProduct">
                            <tr>
                                <td>#sl#</td>
                                <td>#qProduct.ProductName#</td>
                                <td>#qProduct.Price#</td>
                                <td class="actions-cell">
                                    <a href="product_crud.cfm?id=#qProduct.ProductID#" class="btn">Edit</a>
                                    <button type="button" class="btn" onclick="confirmDelete(#qProduct.ProductID#)">Delete</button>
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
