<cfsilent>
<!---
    TAO-SETUP-TEST-HARNESS-01 (D2) - TEMPORARY login diagnostic. DEV-ONLY, READ-ONLY.
    Replicates login/login2.cfm exactly (INNER JOIN userstatuses + SHA-512 salt+hash
    compare) for a setup-test user, in ColdFusion's OWN Hash() engine -- so we isolate
    whether login would succeed, independent of MySQL's SHA2().
    DELETE this file after diagnosis.

    Usage (logged in as admin, on dev):
      /app/admin-users/ajax/diag-setup-test-login.cfm?userid=204&pw=TestSetup123!
--->
<cfset variables.isAjax = true>
<cfinclude template="../admin-guard.cfm">

<cfif NOT structKeyExists(application, "dsn") OR application.dsn NEQ "abod">
    <cfheader statuscode="403">
    <cfcontent type="text/plain; charset=utf-8" reset="true">dev only<cfabort>
</cfif>

<cfparam name="url.userid" default="204">
<cfparam name="url.pw" default="TestSetup123!">
<cfset variables.uid = val(url.userid)>

<cfquery name="variables.qU" datasource="#application.dsn#">
    SELECT userEmail FROM taousers_tbl
    WHERE userid = <cfqueryparam value="#variables.uid#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- EXACT login2.cfm query: INNER JOIN userstatuses, lookup by userEmail. --->
<cfquery name="variables.qLogin" datasource="#application.dsn#" maxrows="1">
    SELECT u.userid, u.passwordHash, u.passwordSalt, us.status_url
    FROM taousers u
    INNER JOIN userstatuses us ON us.userstatus = u.userstatus
    WHERE u.userEmail = <cfqueryparam value="#variables.qU.userEmail#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset variables.cfHash = "">
<cfset variables.matches = false>
<cfif variables.qLogin.recordCount EQ 1>
    <!--- Identical to login2.cfm:389 --->
    <cfset variables.cfHash = Hash(url.pw & variables.qLogin.passwordSalt, "SHA-512")>
    <cfset variables.matches = (variables.cfHash EQ variables.qLogin.passwordHash)>
</cfif>

<cfset variables.out = {
    "userid": variables.uid,
    "email": variables.qU.userEmail,
    "login_query_rows": variables.qLogin.recordCount,
    "status_url": variables.qLogin.recordCount ? variables.qLogin.status_url : "",
    "candidate_pw": url.pw,
    "cf_hash": variables.cfHash,
    "stored_hash": variables.qLogin.recordCount ? variables.qLogin.passwordHash : "",
    "WOULD_LOGIN_SUCCEED": variables.matches
}>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.out)#</cfoutput>
