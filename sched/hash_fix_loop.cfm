 

<cfquery result="result" name="getUsers"  >
  SELECT * FROM taousers where passwordHash is null
</cfquery>

<cfloop query="getUsers">
  <cfset new_passwordSalt = hash(generateSecretKey("AES"),"SHA-512")>

<cfquery result="result" name="setHashedPassword"  >
    UPDATE taousers
    SET
      passwordHash = <cfqueryparam cfsqltype="char" value="#hash(userPassword & new_passwordSalt,'SHA-512')#">,
      passwordSalt = <cfqueryparam cfsqltype="char" value="#new_passwordSalt#">
    WHERE userID = <cfqueryparam cfsqltype="integer" value="#userID#">
  </cfquery>
      <cfoutput>#getusers.userfirstname# #getusers.userlastname# added<BR></cfoutput>
</cfloop>

