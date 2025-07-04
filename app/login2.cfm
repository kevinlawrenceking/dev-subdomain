<cfparam name="j_password" default="" />
<cfparam name="j_username" default="" />

<cfquery result="result" name="insert">
    INSERT INTO loggins (u, p, REMOTE_ADDR, HTTP_USER_AGENT) 
    VALUES (
        <cfqueryparam value="#j_username#" cfsqltype="cf_sql_varchar" />, 
        <cfqueryparam value="#j_password#" cfsqltype="cf_sql_varchar" />,
        <cfqueryparam value="#cgi.REMOTE_ADDR#" cfsqltype="cf_sql_varchar" />, 
        <cfqueryparam value="#cgi.HTTP_USER_AGENT#" cfsqltype="cf_sql_varchar" />
    );
</cfquery>

<!--- Query to authenticate the user --->
<cfquery result="result" name="loginQuery" maxrows="1">
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
        u.userEmail = <cfqueryparam value="#j_username#" cfsqltype="cf_sql_varchar" />
</cfquery>

<!--- Check if the user exists --->
<cfif loginQuery.recordcount eq 1>
    <!--- Hash the provided password with the stored salt --->
    <cfset userpassword2 = Hash(j_password & loginQuery.passwordSalt, "SHA-512") />

    <!--- Validate the password  --->
    <cfif loginQuery.passwordHash eq userpassword2> --->
        <!--- Set the session variable --->
        <cfset userid = loginQuery.userid />
        <cfset session.userid = userid />
here<cfabort>
        <cflocation url="#loginQuery.status_url#" addtoken="false" />
 <cfelse> 
        <!--- Invalid password, redirect to login with error message --->
        <cflocation url="/loginform.cfm?pwrong=Y" addtoken="false" />
    </cfif> 
<cfelse>
 No matching user found, redirect to login with error message --->
    <cflocation url="/loginform.cfm?pwrong=Y" addtoken="false" />
</cfif>
