<!--- Password Reset Handler
     Verifies recovery token from session, validates expiration, and updates password.
     Redirects to login on success. --->

<cfparam name="form.pass1" default="" />

<!--- dsn is set by Application.cfm --->
<cfif NOT isDefined("dsn") OR NOT len(dsn)>
    <cfset dsn = listFirst(cgi.server_name, ".") EQ "app" ? "abo" : "abod" />
</cfif>

<!--- Get token from session (set by index.cfm during token validation) --->
<cfif NOT structKeyExists(session, "recoverToken") OR NOT len(session.recoverToken)>
    <cflocation url="/loginform.cfm" addtoken="false" />
</cfif>

<!--- Re-verify token is valid and not expired --->
<cfquery name="u" datasource="#dsn#">
    SELECT userid, recover_requested_at
    FROM taousers
    WHERE recover = <cfqueryparam value="#session.recoverToken#" cfsqltype="cf_sql_varchar">
    LIMIT 1
</cfquery>

<cfif u.recordcount NEQ 1
      OR NOT isDate(u.recover_requested_at)
      OR dateDiff("n", u.recover_requested_at, now()) GTE 60>
    <cfset structDelete(session, "recoverToken")>
    <cflocation url="/auth-recoverpw.cfm" addtoken="false" />
</cfif>

<!--- Validate password is not empty --->
<cfif NOT len(trim(form.pass1))>
    <cflocation url="/auth-recoverpw.cfm" addtoken="false" />
</cfif>

<!--- Hash and save the new password --->
<cfset new_passwordSalt = hash(generateSecretKey("AES"), "SHA-512") />

<cfquery datasource="#dsn#">
    UPDATE taousers_tbl
    SET passwordHash = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(form.pass1 & new_passwordSalt, 'SHA-512')#">,
        passwordSalt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#new_passwordSalt#">,
        userPassword = '',
        recover = '',
        recover_requested_at = NULL
    WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#u.userid#">
</cfquery>

<!--- Clean up session --->
<cfset structDelete(session, "recoverToken")>

<!--- Redirect to login with success message --->
<cflocation url="/loginform.cfm?pgrecover=Y" addtoken="false" />
