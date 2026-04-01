<!--- ================= SESSION INIT ================= --->
<cfif NOT structKeyExists(session,"uploadState")>
    <cfset session.uploadState = {
        successMsg = "",
        errorMsg = "",
        formData = {},
        lastFile = "",
        uploaded = false
    }>
</cfif>

<!--- ================= RESET STATE ================= --->
<cfif structKeyExists(form,"resetBtn")>
    <cfset session.uploadState = {
        successMsg = "",
        errorMsg = "",
        formData = {},
        lastFile = "",
        uploaded = false
    }>
    <cflocation url="upload.cfm" addToken="false">
</cfif>

<!--- ================= PROCESS UPLOAD ================= --->
<cfif structKeyExists(form,"submitBtn")>
    <cftry>
        <cfset userName = trim(form.userName)>
        <cfset userEmail = trim(form.userEmail)>
        <!-- Save form data -->
        <cfset session.uploadState.formData = {
            userName = userName,
            userEmail = userEmail
        }>
        <!-- VALIDATION -->
        <cfif len(userName) LT 3 OR NOT reFind("^[A-Za-z ]+$", userName)>
            <cfset session.uploadState.errorMsg = "Name must contain only letters and be at least 3 characters.">
            <cflocation url="upload.cfm" addToken="false">
        </cfif>
        <cfif NOT isValid("email", userEmail)>
            <cfset session.uploadState.errorMsg = "Please enter a valid email address.">
            <cflocation url="upload.cfm" addToken="false">
        </cfif>
        <cfif NOT len(form.imageFile)>
            <cfset session.uploadState.errorMsg = "Please select an image file.">
            <cflocation url="upload.cfm" addToken="false">
        </cfif>
        <!-- UPLOAD FILE -->
        <cffile action="upload"
            fileField="imageFile"
            destination="#application.uploadPath#"
            nameConflict="makeunique"
            accept="image/jpeg,image/png,image/gif"
            result="uploadResult">    
        <!-- LOG SUCCESS -->
        <cffile action="append"
            file="#application.logPath#"
            output="UPLOAD SUCCESS | #userEmail# | #uploadResult.serverFile# | #now()#">
        <!-- MOVE FILE -->
        <cffile action="move"
            source="#uploadResult.serverDirectory#/#uploadResult.serverFile#"
            destination="#application.archivePath#/#uploadResult.serverFile#">
        <!-- SAVE STATE -->
        <cfset session.uploadState.lastFile = uploadResult.serverFile>
        <cfset session.uploadState.uploaded = true>
        <cfset session.uploadState.successMsg = "Image uploaded successfully and email sent!">
        <cfset session.uploadState.errorMsg = "">
        <cfset session.uploadState.formData = {}>
        <!-- SEND EMAIL -->
        <cfset mailObj = createObject("component","mailService")>
        <cfset mailObj.sendUploadMail(userName,userEmail,uploadResult.serverFile)>
        <cflocation url="upload.cfm" addToken="false">
    <cfcatch>
        <cffile action="append"
            file="#expandPath('./logs/errorLog.txt')#"
            output="ERROR | #cfcatch.message# | #now()#">
        <cfset session.uploadState.errorMsg = cfcatch.message>
        <cflocation url="upload.cfm" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<html>
    <head>
        <title>Image Upload System</title>
        <link rel="stylesheet" href="style.css">
        <script>
            setTimeout(()=>{
                document.querySelectorAll(".alert").forEach(e=>e.style.display="none");
            },3000);

            function openModal(){
                document.getElementById("imgModal").style.display="block";
            }

            function closeModal(){
                document.getElementById("imgModal").style.display="none";
            }

            window.onclick = function(e){
                let m=document.getElementById("imgModal");
                if(e.target==m) m.style.display="none";
            }
        </script>
    </head>
    
    <body>
        <div class="container">
            <cfoutput>
                <h2>Upload Image</h2>
                <!-- SUCCESS -->
                <cfif len(session.uploadState.successMsg)>
                    <div class="success alert">#session.uploadState.successMsg#</div>
                    <cfset session.uploadState.successMsg = "">
                </cfif>
                <!-- ERROR -->
                <cfif len(session.uploadState.errorMsg)>
                    <div class="error alert">#session.uploadState.errorMsg#</div>
                    <cfset session.uploadState.errorMsg = "">
                </cfif>
                <!-- ================= FORM BEFORE UPLOAD ================= -->
                <cfif NOT session.uploadState.uploaded>
                    <form method="post" enctype="multipart/form-data">
                        <div class="input-group">
                            <input type="text" name="userName"
                                placeholder="Enter Name"
                                value="#session.uploadState.formData.userName ?: ''#">
                        </div>
                        <div class="input-group">
                            <input type="email" name="userEmail"
                                placeholder="Enter Email"
                                value="#session.uploadState.formData.userEmail ?: ''#">
                        </div>
                        <div class="input-group">
                            <input type="file" name="imageFile">
                        </div>
                        <button type="submit" name="submitBtn">
                            Upload & Send Email
                        </button>
                    </form>
                </cfif>
                <!-- ================= AFTER UPLOAD SCREEN ================= -->
                <cfif session.uploadState.uploaded>
                    <button type="button" class="view-btn" onclick="openModal()">
                        View Uploaded Image
                    </button>
                    <br><br>
                    <form method="post">
                        <button type="submit" name="resetBtn" class="reset-btn">
                            Upload New Image
                        </button>
                    </form>
                    <div id="imgModal" class="modal">
                        <span class="close-btn" onclick="closeModal()">&times;</span>
                        <img class="modal-content" src="archive/#session.uploadState.lastFile#">
                    </div>
                </cfif>
            </cfoutput>
        </div>
    </body>
</html>