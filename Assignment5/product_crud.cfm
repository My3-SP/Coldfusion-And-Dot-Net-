<cfparam name="productErrorMsg" default="">
<cfparam name="SearchErrorMsg" default="">

<!-- ================= DELETE ================= -->
<cfif structKeyExists(form,"deleteID") AND isNumeric(form.deleteID)>
    <cfstoredproc procedure="sp_DeleteProduct" datasource="ordersdsn">
        <cfprocparam value="#form.deleteID#" cfsqltype="cf_sql_integer">
    </cfstoredproc>
    <cflocation url="product_crud.cfm" addtoken="false">
</cfif>

<!-- ================= SAVE ================= -->
<cfif structKeyExists(form,"save")>

    <!-- Validation -->
    <cfif NOT reFind("^(?=.*[A-Za-z])[A-Za-z0-9 \-_()./]+$", trim(form.ProductName))>
        <cfset productErrorMsg = "Product name must contain at least one letter and can include numbers.">
    </cfif>

    <cfif NOT len(productErrorMsg) AND (NOT isNumeric(form.Price) OR form.Price LTE 0)>
        <cfset productErrorMsg = "Price must be positive number.">
    </cfif>

    <!-- Duplicate Check -->
    <cfif NOT len(productErrorMsg)>
        <cfstoredproc procedure="sp_CheckProductExists" datasource="ordersdsn">
            <cfprocparam value="#trim(form.ProductName)#" cfsqltype="cf_sql_varchar">
            <cfprocparam value="#form.Price#" cfsqltype="cf_sql_decimal">
            <cfprocparam value="#structKeyExists(form,'ProductID') ? form.ProductID : ''#"
                         cfsqltype="cf_sql_integer"
                         null="#NOT structKeyExists(form,'ProductID')#">
            <cfprocresult name="qExists">
        </cfstoredproc>

        <cfif qExists.recordcount>
            <cfset productErrorMsg = "Product already exists with same price.">
        </cfif>
    </cfif>

    <!-- Insert / Update -->
    <cfif NOT len(productErrorMsg)>
        <cfif structKeyExists(form,"ProductID") AND isNumeric(form.ProductID)>
            <cfstoredproc procedure="sp_UpdateProduct" datasource="ordersdsn">
                <cfprocparam value="#form.ProductID#" cfsqltype="cf_sql_integer">
                <cfprocparam value="#trim(form.ProductName)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#form.Price#" cfsqltype="cf_sql_decimal">
            </cfstoredproc>
        <cfelse>
            <cfstoredproc procedure="sp_InsertProduct" datasource="ordersdsn">
                <cfprocparam value="#trim(form.ProductName)#" cfsqltype="cf_sql_varchar">
                <cfprocparam value="#form.Price#" cfsqltype="cf_sql_decimal">
            </cfstoredproc>
        </cfif>

        <cflocation url="product_crud.cfm" addtoken="false">
    </cfif>

</cfif>

<!-- ================= SEARCH ================= -->
<cfif structKeyExists(form,"search")>
    <cfset searchValue = trim(form.searchText)>
    <!-- Validation -->
    <cfif NOT len(searchValue)>
        <cfset SearchErrorMsg = "Search text cannot be empty or spaces only.">
    <cfelseif NOT reFind("^(?=.*[A-Za-z0-9])[A-Za-z0-9 \-_()./]+$", searchValue)>
        <cfset SearchErrorMsg = "Search must contain at least one letter or number.">
    </cfif>

    <!-- If valid, perform search -->
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


<html>
    <head>
        <title>Product Records</title>
        <link rel="stylesheet" href="style.css">

        <script>
            function showAddForm(){
                document.getElementById("formTitle").innerText = "Add New Product";
                document.getElementById("ProductID").value = "";
                document.getElementById("ProductName").value = "";
                document.getElementById("Price").value = "";
                document.getElementById("productFormContainer").style.display = "block";
            }

            function editProduct(id,name,price){
                document.getElementById("formTitle").innerText = "Edit Product";
                document.getElementById("ProductID").value = id;
                document.getElementById("ProductName").value = name;
                document.getElementById("Price").value = price;
                document.getElementById("productFormContainer").style.display = "block";
            }

            function deleteProduct(id){
                if(confirm("Delete this product?")){
                    document.getElementById("deleteID").value = id;
                    document.getElementById("deleteForm").submit();
                }
            }

            function hideForm(){
                document.getElementById("productFormContainer").style.display = "none";
            }
        </script>
    </head>
    <body>
        <cfoutput>
            <div class="container">
                <h2 class="page-title">Product Records - CRUD Operations</h2>

                <!-- SEARCH + ADD SECTION -->
                <div class="search-add">

                    <form method="post" id="searchForm">

                        <input type="text" name="searchText" class="input-box search-input"
                            placeholder="Search by product name"
                            value="#structKeyExists(form,'searchText') ? form.searchText : ''#">

                        <button type="submit" name="search" class="btn">Search</button>
                        <button type="button" class="btn"
                                onclick="window.location='product_crud.cfm'">Reset</button>
                    </form>
                    <button type="button" class="btn"
                                onclick="showAddForm()">Add New Product</button>
                </div>
                <form method="post" id="deleteForm">
                    <input type="hidden" name="deleteID" id="deleteID">
                </form>

                <!-- ERROR MESSAGE -->
                <cfif len(SearchErrorMsg)>
                    <div class="error">#SearchErrorMsg#</div>
                </cfif>
                <cfif len(productErrorMsg)>
                    <div class="error">#productErrorMsg#</div>
                    <script>
                        document.addEventListener("DOMContentLoaded", function(){
                            document.getElementById("productFormContainer").style.display = "block";
                        });
                    </script>
                </cfif>
                <p class="nav">
                    <a href="customer_crud.cfm" class="button">Go to Customer Records</a>
                </p>

                <!-- TOGGLE ADD / EDIT FORM -->
                <div id="productFormContainer" class="product-form" style="display:none;">

                    <h3 class="form-title" id="formTitle">Add New Product</h3>
                    <form method="post">
                        <input type="hidden" name="ProductID" id="ProductID"
                            value="#structKeyExists(form,'ProductID') ? form.ProductID : ''#">

                        <div>
                            <label class="form-label">Product Name:</label>
                            <input type="text" name="ProductName" id="ProductName" class="input-box" required
                                value="#structKeyExists(form,'ProductName') ? form.ProductName : ''#">
                        </div>
                        <br>
                        <div>
                            <label class="form-label">Price:</label>
                            <input type="text"
                                name="Price" id="Price" class="input-box" required
                                value="#structKeyExists(form,'Price') ? form.Price : ''#">
                        </div>
                        <br>
                        <button type="submit" name="save" class="btn">Save</button>
                        <button type="button" onclick="hideForm()" class="btn">Cancel</button>
                    </form>
                </div>

                <!-- PRODUCT TABLE -->
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

                                <button type="button" class="btn"
                                        onclick="editProduct('#ProductID#',
                                                            '#ProductName#',
                                                            '#Price#')">
                                    Edit
                                </button>

                                <button type="button" class="btn"
                                        onclick="deleteProduct(#ProductID#)">
                                    Delete
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
