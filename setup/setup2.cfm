<!--- MIGRATE: Setup flow -> Go SetupService with proper request validation middleware --->
<cfparam name="pass1" default="" />

<!--- Re-validate UUID server-side -- never trust form fields --->
<cfif NOT structKeyExists(session, "setupUUID") OR NOT len(trim(session.setupUUID))>
    <cflocation url="/setup/?error=expired" addtoken="false">
</cfif>

<!--- CSRF validation --->
<!--- TECH-DEBT: session-based CSRF in setup -- proper token framework needed app-wide --->
<cfif NOT structKeyExists(form, "csrfToken")
      OR NOT structKeyExists(session, "setupCSRF")
      OR form.csrfToken NEQ session.setupCSRF>
    <cflocation url="/setup/?error=invalid" addtoken="false">
</cfif>

<!--- Server-side re-query: pull ALL identity data from DB, not form POST --->
<cfquery name="qSetup" datasource="#application.dsn#">
    SELECT id, customerid, customerfirst, customerlast, customeremail, productname
    FROM thrivecart_tbl
    WHERE recoveryhash = <cfqueryparam value="#session.setupUUID#" cfsqltype="cf_sql_varchar">
    AND status = <cfqueryparam value="Emailed" cfsqltype="cf_sql_varchar">
    LIMIT 1
</cfquery>

<cfif qSetup.recordCount EQ 0>
    <cflocation url="/setup/?error=invalid" addtoken="false">
</cfif>

<!--- MIGRATE: Password hashing -> bcrypt in Go (SHA-512+salt is CF-era pattern) --->
<cfset new_passwordSalt = hash(generateSecretKey("AES"), "SHA-512") />

<cftransaction>
    <!--- Guard: re-check status inside transaction to prevent double-submit --->
    <cfquery name="qGuard" datasource="#application.dsn#">
        SELECT id FROM thrivecart_tbl
        WHERE id = <cfqueryparam value="#qSetup.id#" cfsqltype="cf_sql_integer">
        AND status = <cfqueryparam value="Emailed" cfsqltype="cf_sql_varchar">
        FOR UPDATE
    </cfquery>

    <cfif qGuard.recordCount EQ 0>
        <!--- Another request already processed this -- abort gracefully --->
        <cftransaction action="rollback" />
        <cflocation url="/setup/setup-complete.cfm" addtoken="false">
    </cfif>

    <!--- Soft-delete old users with same customerid --->
    <cfquery result="result" name="Del" datasource="#application.dsn#">
        UPDATE taousers_tbl SET isdeleted = 1
        WHERE customerid = <cfqueryparam value="#qSetup.customerid#" cfsqltype="cf_sql_integer" />
    </cfquery>

    <!--- INSERT new taousers_tbl record --->
    <cfquery name="insert" result="result" datasource="#application.dsn#">
        INSERT INTO taousers_tbl (customerid, userfirstName, userLastName, userEmail, avatarname, passwordHash, passwordSalt)
        VALUES (
            <cfqueryparam value="#qSetup.customerid#" cfsqltype="cf_sql_integer" />,
            <cfqueryparam value="#qSetup.customerfirst#" cfsqltype="cf_sql_varchar" />,
            <cfqueryparam value="#qSetup.customerlast#" cfsqltype="cf_sql_varchar" />,
            <cfqueryparam value="#qSetup.customeremail#" cfsqltype="cf_sql_varchar" />,
            <cfqueryparam value="#qSetup.customerfirst#" cfsqltype="cf_sql_varchar" />,
            <cfqueryparam cfsqltype="char" value="#hash(pass1 & new_passwordSalt, 'SHA-512')#" />,
            <cfqueryparam cfsqltype="char" value="#new_passwordSalt#" />
        )
    </cfquery>

    <cfset select_userid = result.generatedkey />

    <!--- UPDATE thrivecart_tbl status (not the view) --->
    <cfquery result="result" name="update" datasource="#application.dsn#">
        UPDATE thrivecart_tbl
        SET status = <cfqueryparam cfsqltype="cf_sql_varchar" value="Completed" />
        WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qSetup.id#" />
    </cfquery>
</cftransaction>

<!--- Map billing address from Thrivecart purchase to user profile --->
<cftry>
    <cfquery name="tcBilling" datasource="#application.dsn#">
        SELECT BillingAddress, BillingCity, BillingState, BillingZip, BillingCountry
        FROM thrivecart_tbl
        WHERE id = <cfqueryparam value="#qSetup.id#" cfsqltype="cf_sql_integer" />
    </cfquery>

    <cfif tcBilling.recordCount
          AND (len(trim(tcBilling.BillingAddress))
               OR len(trim(tcBilling.BillingCity))
               OR len(trim(tcBilling.BillingZip)))>
        <cfquery datasource="#application.dsn#">
            UPDATE taousers_tbl
            SET add1 = <cfqueryparam value="#tcBilling.BillingAddress#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(tcBilling.BillingAddress))#">,
                city = <cfqueryparam value="#tcBilling.BillingCity#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(tcBilling.BillingCity))#">,
                defState = <cfqueryparam value="#tcBilling.BillingState#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(tcBilling.BillingState))#">,
                zip = <cfqueryparam value="#tcBilling.BillingZip#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(tcBilling.BillingZip))#">,
                defCountry = <cfqueryparam value="#tcBilling.BillingCountry#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(tcBilling.BillingCountry))#">
            WHERE userid = <cfqueryparam value="#select_userid#" cfsqltype="cf_sql_integer" />
        </cfquery>
    </cfif>

    <cfcatch type="any">
        <cflog file="TAO_setup_errors" text="Address mapping error for userid #select_userid#: #cfcatch.message#" type="error" />
    </cfcatch>
</cftry>

<cfinclude template="user_setup_core.cfm" />

<cflocation url="setup-complete.cfm" addtoken="false" />
