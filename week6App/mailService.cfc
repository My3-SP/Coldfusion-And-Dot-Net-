<cfcomponent output="false">

<cffunction name="sendUploadMail" access="public" returntype="void">

<cfargument name="userName" required="true">
<cfargument name="userEmail" required="true">
<cfargument name="fileName" required="true">

<cfmail to="#arguments.userEmail#"
        from="cfmltestmail@gmail.com"
        subject="Image Upload Confirmation"
        type="html">

<h2>Hello #arguments.userName#,</h2>

<p>Your image has been uploaded successfully.</p>
<p><b>File Name:</b> #arguments.fileName#</p>
<p><b>Upload Time:</b> #now()#</p>

</cfmail>

</cffunction>

</cfcomponent>