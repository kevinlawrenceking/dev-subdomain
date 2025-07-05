

<cfapplication name="TAO" sessionmanagement="true">

<!--- Ensure required application variables exist --->
<cfif NOT structKeyExists(application, "dsn")>
    <cfset host = ListFirst(cgi.server_name, ".") />
    <cfif host EQ "app">
        <cfset application.dsn = "abo" />
    <cfelse>
        <cfset application.dsn = "abod" />
    </cfif>
</cfif>

<cfif NOT structKeyExists(application, "information_schema")>
    <cfset application.information_schema = "actorsbusinessoffice" />
</cfif>

<cfif NOT structKeyExists(application, "suffix")>
    <cfset application.suffix = "_1.5" />
</cfif>

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

    <!--- Validate the provided password --->
    <cfif loginQuery.passwordHash eq userpassword2>
        <cfset session.userid = loginQuery.userid>
        <cfset session.userLoggedIn = true>

        <cflocation url="#loginQuery.status_url#?u=#loginQuery.userid#" addtoken="true">
    <cfelse>
        <!--- Invalid password --->
        <cflocation url="/loginform.cfm?pwrong=Y" addtoken="false">
    </cfif>

<cfelse>
    <!--- User not found --->
    <cflocation url="/loginform.cfm?pwrong=Y" addtoken="false">
</cfif>
