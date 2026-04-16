 
<cfset newSalt = hash(generateSecretKey("AES"), "SHA-512")>
<cfset newHash = hash("Rimshot323!" & newSalt, "SHA-512")>
<cfquery datasource="abo">
    UPDATE taousers_tbl
    SET passwordHash = <cfqueryparam value="#newHash#" cfsqltype="cf_sql_char">,
        passwordSalt = <cfqueryparam value="#newSalt#" cfsqltype="cf_sql_char">,
        userPassword = ''
    WHERE userid = 30
</cfquery>
<cfoutput>Done. Salt=#newSalt# Hash=#newHash#</cfoutput>
 

<cflocation url="/app/" addtoken="no" />
