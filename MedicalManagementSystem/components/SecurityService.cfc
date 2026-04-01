<cfcomponent output="false">
    <cfset variables.secretKey = "MySecretKey123456789012345678iuh">
    <!---  ENCRYPT  --->
    <cffunction name="encryptID" access="public" returntype="string" output="false">
        <cfargument name="id" type="any" required="true">
        <cfset var encrypted = "">
        <!--- Normal AES Base64 encryption --->
        <cfset encrypted = encrypt(trim(arguments.id),variables.secretKey,"AES","Base64")>
        <!--- Convert to URL-safe Base64 --->
        <cfset encrypted = replace(encrypted, "+", "-", "all")>
        <cfset encrypted = replace(encrypted, "/", "_", "all")>
        <cfset encrypted = replace(encrypted, "=", "", "all")>
        <cfreturn trim(encrypted)>
    </cffunction>


    <!---  DECRYPT  --->
    <cffunction name="decryptID" access="public" returntype="numeric" output="false">
        <cfargument name="encryptedID" type="string" required="true">
        <cfset var encrypted = trim(arguments.encryptedID)>
        <cfset var modVal = 0>
        <cfset var decrypted = "">
        <!--- Restore Base64 format --->
        <cfset encrypted = replace(encrypted, "-", "+", "all")>
        <cfset encrypted = replace(encrypted, "_", "/", "all")>
        <!--- Restore padding if removed --->
        <cfset modVal = len(encrypted) MOD 4>
        <cfif modVal>
            <cfset encrypted &= repeatString("=", 4 - modVal)>
        </cfif>
        <cfset decrypted = decrypt(encrypted, variables.secretKey, "AES","Base64")>
        <cfreturn val(decrypted)>
    </cffunction>
</cfcomponent>