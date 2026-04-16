<cfsilent>
<!--- Setup user: Mia Nguyen (mianguyen1357@gmail.com) as Admin with status "Setup"
     Runs against BOTH dev and prod datasources.
     Safe to run multiple times - checks for existing records first. --->

<cfset tempPassword = "Welcome2TAO!">
<cfset passwordSalt = hash(generateSecretKey("AES"), "SHA-512")>
<cfset passwordHash = hash(tempPassword & passwordSalt, "SHA-512")>

<cfset datasources = [
    { label: "DEV", dsn: "abod" },
    { label: "PROD", dsn: "abo" }
]>
</cfsilent>
<cfoutput>
<h2>Setup User: Mia Nguyen (mianguyen1357@gmail.com)</h2>

<cfloop array="#datasources#" index="ds">
    <h3>#ds.label# (#ds.dsn#)</h3>

    <!--- Check if user already exists --->
    <cfquery name="qExisting" datasource="#ds.dsn#">
        SELECT userid, userFirstName, userLastName, userEmail, userRole, userstatus, IsDeleted, isSetup, setup_step
        FROM taousers_tbl
        WHERE userEmail = <cfqueryparam value="mianguyen1357@gmail.com" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif qExisting.recordCount gt 0>
        <p>User FOUND (userid=#qExisting.userid#). Current state: role=#qExisting.userRole#, status=#qExisting.userstatus#, isDeleted=#qExisting.IsDeleted#, isSetup=#qExisting.isSetup#</p>

        <!--- Fix existing record: set Admin role, Setup status, undelete, reset setup wizard --->
        <cfquery datasource="#ds.dsn#">
            UPDATE taousers_tbl
            SET userRole = <cfqueryparam value="Admin" cfsqltype="cf_sql_varchar">,
                userstatus = <cfqueryparam value="Setup" cfsqltype="cf_sql_varchar">,
                IsDeleted = 0,
                isSetup = 0,
                setup_step = 0,
                setup_completed_at = NULL,
                passwordHash = <cfqueryparam value="#passwordHash#" cfsqltype="cf_sql_char">,
                passwordSalt = <cfqueryparam value="#passwordSalt#" cfsqltype="cf_sql_char">
            WHERE userid = <cfqueryparam value="#qExisting.userid#" cfsqltype="cf_sql_integer">
        </cfquery>
        <p>UPDATED: Set to Admin / Setup status, reset password and setup wizard.</p>
    <cfelse>
        <p>User NOT found. Creating new record...</p>

        <cfquery datasource="#ds.dsn#" result="qInsert">
            INSERT INTO taousers_tbl
                (userFirstName, userLastName, userEmail, userRole, userstatus,
                 passwordHash, passwordSalt, avatarname, IsDeleted, isSetup, setup_step)
            VALUES
                (<cfqueryparam value="Mia" cfsqltype="cf_sql_varchar">,
                 <cfqueryparam value="Nguyen" cfsqltype="cf_sql_varchar">,
                 <cfqueryparam value="mianguyen1357@gmail.com" cfsqltype="cf_sql_varchar">,
                 <cfqueryparam value="Admin" cfsqltype="cf_sql_varchar">,
                 <cfqueryparam value="Setup" cfsqltype="cf_sql_varchar">,
                 <cfqueryparam value="#passwordHash#" cfsqltype="cf_sql_char">,
                 <cfqueryparam value="#passwordSalt#" cfsqltype="cf_sql_char">,
                 <cfqueryparam value="Mia" cfsqltype="cf_sql_varchar">,
                 0, 0, 0)
        </cfquery>
        <p>CREATED: userid=#qInsert.generatedKey#, Admin role, Setup status.</p>
    </cfif>

    <!--- Verify --->
    <cfquery name="qVerify" datasource="#ds.dsn#">
        SELECT userid, userFirstName, userLastName, userEmail, userRole, userstatus, IsDeleted, isSetup, setup_step
        FROM taousers_tbl
        WHERE userEmail = <cfqueryparam value="mianguyen1357@gmail.com" cfsqltype="cf_sql_varchar">
    </cfquery>
    <p><strong>Verified:</strong> userid=#qVerify.userid#, name=#qVerify.userFirstName# #qVerify.userLastName#, role=#qVerify.userRole#, status=#qVerify.userstatus#, isDeleted=#qVerify.IsDeleted#, setup_step=#qVerify.setup_step#</p>
    <hr>
</cfloop>

<p><strong>Temp password:</strong> #tempPassword#</p>
<p>User will be redirected to setup wizard on first login.</p>
</cfoutput>
