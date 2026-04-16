<cfsilent>
<!--- Setup user: userid 30 — Kevin King (kevinking7135@gmail.com)
     Updates email and password for userid 30 on BOTH dev and prod datasources.
     Safe to run multiple times — idempotent update. --->

<cfset newPassword = "Rimshot323!">
<cfset passwordSalt = hash(generateSecretKey("AES"), "SHA-512")>
<cfset passwordHash = hash(newPassword & passwordSalt, "SHA-512")>

<cfset datasources = [
    { label: "DEV", dsn: "abod" },
    { label: "PROD", dsn: "abo" }
]>
</cfsilent>
<cfoutput>
<h2>Setup User: userid 30 — Kevin King (kevinking7135@gmail.com)</h2>

<cfloop array="#datasources#" index="ds">
    <h3>#ds.label# (#ds.dsn#)</h3>

    <!--- Check current state --->
    <cfquery name="qBefore" datasource="#ds.dsn#">
        SELECT userid, userFirstName, userLastName, userEmail, userRole, userstatus
        FROM taousers_tbl
        WHERE userid = <cfqueryparam value="30" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif qBefore.recordCount gt 0>
        <p><strong>Before:</strong> userid=#qBefore.userid#, name=#qBefore.userFirstName# #qBefore.userLastName#, email=#qBefore.userEmail#, role=#qBefore.userRole#, status=#qBefore.userstatus#</p>

        <cfquery datasource="#ds.dsn#">
            UPDATE taousers_tbl
            SET userEmail = <cfqueryparam value="kevinking7135@gmail.com" cfsqltype="cf_sql_varchar">,
                passwordHash = <cfqueryparam value="#passwordHash#" cfsqltype="cf_sql_char">,
                passwordSalt = <cfqueryparam value="#passwordSalt#" cfsqltype="cf_sql_char">
            WHERE userid = <cfqueryparam value="30" cfsqltype="cf_sql_integer">
        </cfquery>
        <p>UPDATED: email set to kevinking7135@gmail.com, password reset.</p>
    <cfelse>
        <p style="color:red;">userid 30 NOT FOUND in #ds.label#.</p>
    </cfif>

    <!--- Verify --->
    <cfquery name="qAfter" datasource="#ds.dsn#">
        SELECT userid, userFirstName, userLastName, userEmail, userRole, userstatus
        FROM taousers_tbl
        WHERE userid = <cfqueryparam value="30" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfif qAfter.recordCount gt 0>
        <p><strong>After:</strong> userid=#qAfter.userid#, name=#qAfter.userFirstName# #qAfter.userLastName#, email=#qAfter.userEmail#, role=#qAfter.userRole#, status=#qAfter.userstatus#</p>
    </cfif>
    <hr>
</cfloop>

<p><strong>Password set to:</strong> Rimshot323!</p>
<p>Navigate to the login page to verify.</p>
</cfoutput>
