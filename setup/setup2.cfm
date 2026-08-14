<!--- MIGRATE: Setup flow -> Go SetupService with proper request validation middleware --->
<cfparam name="pass1" default="" />
<cfparam name="form.customerfirst" default="" />
<cfparam name="form.customerlast" default="" />
<cfparam name="form.customeremail" default="" />

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

<!--- Server-side re-query: pull ALL identity data from DB, not form POST.
      NOTE: thrivecart_tbl.customerid is the ThriveCart customer id from the IPN payload.
      It is informational only and is NULL on most real purchases (ipn-handler.cfm writes
      it from the webhook's customer_id, which the current product does not send). The
      identity key for a purchase is thrivecart_tbl.id -- that is the value
      taousers_tbl.customerid stores (see sched/cancel.cfm join on u.customerid = t.id). --->
<cfquery name="qSetup" datasource="#application.dsn#">
    SELECT id, customerid, customerfirst, customerlast, customeremail
    FROM thrivecart_tbl
    WHERE uuid = <cfqueryparam value="#session.setupUUID#" cfsqltype="cf_sql_varchar">
    AND status = <cfqueryparam value="Emailed" cfsqltype="cf_sql_varchar">
    LIMIT 1
</cfquery>

<cfif qSetup.recordCount EQ 0>
    <cflocation url="/setup/?error=invalid" addtoken="false">
</cfif>

<!--- Validate critical fields before transaction --->
<cfif NOT val(qSetup.id) GT 0>
    <cflog file="TAO_setup" type="error" text="setup2: invalid thrivecart id (#qSetup.id#) for uuid #session.setupUUID#" />
    <cflocation url="/setup/?error=invalid" addtoken="false">
</cfif>
<!--- TAO-SETUP-KEY-01: no customerid gate here. A NULL/blank thrivecart_tbl.customerid
      is normal for a real purchase and must not block setup -- qSetup.id (validated
      above) is the key this flow writes and every other consumer reads. --->

<!--- Name/email: accept user edits from form, fall back to DB values.
      The thrivecart id always comes from the DB (security-critical). --->
<cfset setupFirst = len(trim(form.customerfirst)) ? trim(form.customerfirst) : qSetup.customerfirst>
<cfset setupLast = len(trim(form.customerlast)) ? trim(form.customerlast) : qSetup.customerlast>
<cfset setupEmail = len(trim(form.customeremail)) ? trim(form.customeremail) : qSetup.customeremail>

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

    <!--- TAO-SETUP-LINK-GUARD (POST side): the setup link is single-use. index.cfm makes
          the same check on GET, but a stale form can still be POSTed, so refuse here too.
          An active account already attached to this purchase is never overwritten. --->
    <cfquery name="qActiveUser" datasource="#application.dsn#">
        SELECT userid FROM taousers_tbl
        WHERE customerid = <cfqueryparam value="#val(qSetup.id)#" cfsqltype="cf_sql_bigint" />
        AND isdeleted = 0
        LIMIT 1
    </cfquery>
    <cfif qActiveUser.recordCount GT 0>
        <cftransaction action="rollback" />
        <cflog file="TAO_setup" type="warning" text="setup2: link already used -- active userid #qActiveUser.userid# for thrivecart id #qSetup.id#" />
        <cflocation url="/setup/?uuid=#session.setupUUID#" addtoken="false">
    </cfif>

    <!--- Soft-delete any prior (already-deleted) users for this purchase. Keyed on
          thrivecart_tbl.id -- the guard above means no active account can be hit. --->
    <cfquery result="result" name="Del" datasource="#application.dsn#">
        UPDATE taousers_tbl SET isdeleted = 1
        WHERE customerid = <cfqueryparam value="#val(qSetup.id)#" cfsqltype="cf_sql_bigint" />
    </cfquery>

    <!--- Clear email on soft-deleted users to free the unique index slot.
          Uses a unique placeholder instead of NULL (userEmail has NOT NULL constraint).
          Only touches already-deleted rows -- never touches active accounts. --->
    <cfquery datasource="#application.dsn#">
        UPDATE taousers_tbl SET userEmail = CONCAT('deleted_', userid, '_', UNIX_TIMESTAMP())
        WHERE userEmail = <cfqueryparam value="#setupEmail#" cfsqltype="cf_sql_varchar" />
        AND isdeleted = 1
    </cfquery>

    <!--- Check if email is still taken by an active user (different customer) --->
    <cfquery name="qEmailCheck" datasource="#application.dsn#">
        SELECT userid FROM taousers_tbl
        WHERE userEmail = <cfqueryparam value="#setupEmail#" cfsqltype="cf_sql_varchar" />
        AND isdeleted = 0
        LIMIT 1
    </cfquery>
    <cfif qEmailCheck.recordCount GT 0>
        <cftransaction action="rollback" />
        <cflocation url="/setup/?uuid=#session.setupUUID#&error=email_taken" addtoken="false">
    </cfif>

    <!--- INSERT new taousers_tbl record --->
    <!--- P11: Include userstatus='Setup' so login2.cfm INNER JOIN on userstatuses works --->
    <cfquery name="insert" result="result" datasource="#application.dsn#">
        INSERT INTO taousers_tbl (customerid, userfirstName, userLastName, userEmail, avatarname, passwordHash, passwordSalt, userstatus)
        VALUES (
            <cfqueryparam value="#val(qSetup.id)#" cfsqltype="cf_sql_bigint" />,
            <cfqueryparam value="#setupFirst#" cfsqltype="cf_sql_varchar" />,
            <cfqueryparam value="#setupLast#" cfsqltype="cf_sql_varchar" />,
            <cfqueryparam value="#setupEmail#" cfsqltype="cf_sql_varchar" />,
            <cfqueryparam value="#setupFirst#" cfsqltype="cf_sql_varchar" />,
            <cfqueryparam cfsqltype="char" value="#hash(pass1 & new_passwordSalt, 'SHA-512')#" />,
            <cfqueryparam cfsqltype="char" value="#new_passwordSalt#" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="Setup" />
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

<!--- P11: Set session.userid so the wizard guard works on first request --->
<cfset session.userid = select_userid>

<!--- TAO-SETUP-WIZARD-RESET: the new user starts the wizard at step 1. Reset any
      setup_step left in the session from a prior login (e.g. an admin testing a
      dummy record carries their own setup_step=7, which would otherwise drop the
      wizard onto the last step). The new taousers_tbl row has no progress yet. --->
<cfset session.setup_step = 0>

<!--- Session verification logging -- remove after setup flow is confirmed stable --->
<cflog file="TAO_setup_session" type="information"
       text="Setup complete | userid=#select_userid# | email=#setupEmail# | dsn=#application.dsn# | appName=#application.applicationName# | cfid=#cookie.cfid# | cftoken=#cookie.cftoken#" />

<!--- P11: Redirect to onboarding wizard instead of static completion page.
      Force step=1 so the new user always starts at the beginning, regardless of
      any setup_step left in the session (e.g. an admin testing a dummy record). --->
<cflocation url="/app/setup-wizard/?step=1" addtoken="false" />
