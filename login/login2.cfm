

<cfscript>
    // Use datasource configured by Application.cfc
    dsn = application.dsn;
    datasourceName = application.dsn;
</cfscript>

 
 
<!--- Process Login --->
<cfquery name="loginQuery" datasource="#dsn#" maxrows="1">
    SELECT 
        u.userid,
        u.passwordHash,
        u.passwordSalt,
        us.status_url
    FROM 
        taousers u
    INNER JOIN 
        userstatuses us ON us.userstatus = u.userstatus
    WHERE 
        u.userEmail = <cfqueryparam value="#form.j_username#" cfsqltype="cf_sql_varchar">
</cfquery>
 
 
<cfif loginQuery.recordcount eq 1>
    <cfset userpassword2 = Hash(form.j_password & loginQuery.passwordSalt, "SHA-512")> 

 
        <cfset session.userid = loginQuery.userid>
        <cfset session.userLoggedIn = true>

        <!--- Debug session after setting user ID --->
        <cfdump var="#session#" label="Session After Login">
    
        <cflocation url="#loginQuery.status_url#?u=#loginquery.userid#" addtoken="true">
   
</cfif>

 
<cflocation url="/loginform.cfm?pwrong=Y" addtoken="false">
