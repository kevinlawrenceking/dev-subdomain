 

<cfquery result="result" name="x" datasource="#application.dsn#" >
  SELECT * FROM taousers_tbl
</cfquery>

<cfloop query="x">

<cfquery result="result" name="setHashedPassword" datasource="#application.dsn#" >
    UPDATE taousers_tbl
    SET
      useremail  = <cfqueryparam cfsqltype="varchar" value="#x.useremail#">
      ,userpassword  = <cfqueryparam cfsqltype="varchar" value="#x.userpassword#">
      ,passwordHash = <cfqueryparam cfsqltype="char" value="#x.passwordHash#">
      ,passwordSalt = <cfqueryparam cfsqltype="char" value="#x.passwordSalt#">
    WHERE userID = <cfqueryparam cfsqltype="integer" value="#x.userID#">
  </cfquery>
</cfloop>

