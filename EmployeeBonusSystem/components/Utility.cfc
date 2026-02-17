<cfcomponent output="false" hint="Utility functions for encryption/decryption">

    <!--- Encryption key --->
    <cfset variables.encryptionKey = "MySecretKey123456789012345678iuh">

    <!--- ================= PUBLIC FUNCTIONS ================= --->

    <!--- Encrypt a value safely for URLs --->
    <cffunction name="encryptValue" access="public" returntype="string" output="false" hint="Encrypt a string and return URL safe format">
        <cfargument name="value" required="true" type="string">
        <cfset var enc = encrypt(arguments.value, variables.encryptionKey, "AES/CBC/PKCS5Padding", "Base64")>
        <cfreturn urlEncodedFormat(enc)>
    </cffunction>

    <!--- Decrypt a value safely from URLs --->
    <cffunction name="decryptValue" access="public" returntype="string" output="false" hint="Decrypt a URL encoded encrypted string">
        <cfargument name="value" required="true" type="string">
        <cftry>
            <cfset var decoded = urlDecode(arguments.value)>
            <cfset var result = decrypt(decoded, variables.encryptionKey, "AES/CBC/PKCS5Padding", "Base64")>
            <cfreturn result>
            <cfcatch>
                <!--- Return empty string on failure --->
                <cfreturn "">
            </cfcatch>
        </cftry>
    </cffunction>

</cfcomponent>
