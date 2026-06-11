<cfsilent>
<!---
    TAO-SETUP-TEST-HARNESS-01 (D2) - Provision a setup-test user (Option A)
    POST /app/admin-users/ajax/create-test-setup.cfm

    Creates a taousers_tbl row directly in pre-setup state (NO setup2.cfm,
    NO thrivecart row), then runs standard provisioning (self-contact +
    *_user lookups + media dirs) via setup/user_setup_core.cfm.

    SCOPE CONTRACT (verified by read):
      setup2.cfm sets select_userid (:110), includes user_setup_core (:148),
      THEN sets session.userid (:151) -- include runs before session.userid exists.
      user_setup_core.cfm reads select_userid (:15-17,35,41), and a grep proves it
      reads NO session.userid/uid/uuid and includes no sub-files. So we set
      variables.select_userid and never touch session.userid (no admin-session hijack).

    TRANSACTION STRUCTURE (Architect ruling):
      1. INSERT taousers_tbl in its OWN short transaction; commit; capture newUserId.
      2. Run user_setup_core.cfm OUTSIDE any transaction (mirrors prod setup2: txn
         closes :118, include runs :148 outside it). user_setup_core issues no DDL
         (grep-confirmed) and swallows its own per-table errors, so a wrapping txn
         never delivered atomicity anyway, and wrapping would hold write locks across
         cfdirectory I/O on shared hosting.
      3. Post-condition guard: re-query base tables for taousers_tbl.contactid set AND
         a user_yn='Y' row in contactdetails_tbl.
      4. On post-condition failure: soft-delete the user (IsDeleted=1) and mangle the
         email to free the unique slot. Orphaned lookup rows/dirs are D5/reset's job.

    Ruling 2: snapshot the 12 session.user* keys user_setup_core.cfm overwrites
      (:77-88) and restore them in cffinally so the admin's session is not corrupted.

    DEV/UAT ONLY (allow-list: application.dsn EQ 'abod'). Prod (abo) hard-aborts.
    Auth + role enforced by admin-guard.cfm; CSRF by app/Application.cfc.

    Form params: contactName (required), email (blank -> auto-generate),
                 testAdminUserid (default session.userid), password (blank -> default dev pw)
    Returns JSON: { success, message, data:{ userid, email } }
--->
<cfset variables.isAjax = true>
<cfinclude template="../admin-guard.cfm">

<cfset variables.response = { "success": false, "message": "", "data": {} }>

<!--- Allow-list env gate: permit ONLY the dev/UAT datasource; prod 'abo' denied. --->
<cfset variables.allowedDsns = "abod">
<cfif NOT structKeyExists(application, "dsn") OR NOT listFindNoCase(variables.allowedDsns, application.dsn)>
    <cfset variables.response.message = "Test setup provisioning is available on the dev environment only.">
    <cflog file="TAO_setup_test_harness" type="warning"
           text="provision BLOCKED on non-allowed dsn=#structKeyExists(application,'dsn') ? application.dsn : '(unset)'# by admin=#session.userid#">
    <cfheader statuscode="403">
    <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
</cfif>

<cftry>
    <cfparam name="form.contactName" default="">
    <cfparam name="form.email" default="">
    <cfparam name="form.testAdminUserid" default="#session.userid#">
    <cfparam name="form.password" default="">

    <cfset variables.contactName = trim(form.contactName)>
    <cfif NOT len(variables.contactName)>
        <cfset variables.response.message = "Contact name is required.">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- Best-effort first/last split; last falls back to 'Test'. --->
    <cfset variables.firstName = trim(listFirst(variables.contactName, " "))>
    <cfset variables.lastName = trim(listRest(variables.contactName, " "))>
    <cfif NOT len(variables.lastName)><cfset variables.lastName = "Test"></cfif>

    <!--- C4: auto-unique email with sub-second entropy (ms tick + short uuid) so two
          provisions in the same second cannot collide. --->
    <cfset variables.email = trim(form.email)>
    <cfif NOT len(variables.email)>
        <cfset variables.email = "setup-test+" & getTickCount() & "-" & left(lCase(replace(createUUID(), "-", "", "all")), 6) & "@theactorsoffice.com">
    </cfif>

    <!--- Default dev test password (reachable ONLY behind the env gate above). --->
    <cfset variables.password = len(trim(form.password)) ? trim(form.password) : "TestSetup123!">

    <cfset variables.testAdminUserid = val(form.testAdminUserid)>
    <cfif variables.testAdminUserid LTE 0><cfset variables.testAdminUserid = val(session.userid)></cfif>

    <!--- C3: hashing mirrors setup2.cfm:50,104 so login2.cfm:389 reproduces the hash.
          login compares Hash(password & salt, "SHA-512") to stored passwordHash. --->
    <cfset variables.passwordSalt = hash(generateSecretKey("AES"), "SHA-512")>
    <cfset variables.passwordHash = hash(variables.password & variables.passwordSalt, "SHA-512")>

    <!--- (1) INSERT the user row in its OWN short transaction (mirrors setup2.cfm:96-108
          column set; avatarname=firstName per setup2:103) into the BASE table. --->
    <cftransaction>
        <cfquery name="variables.qIns" result="variables.insResult" datasource="#application.dsn#">
            INSERT INTO taousers_tbl (
                customerid, userfirstName, userLastName, userEmail, avatarname,
                passwordHash, passwordSalt, userstatus, setup_step, setup_completed_at,
                is_setup_test, test_email_redirect_userid
            ) VALUES (
                NULL,
                <cfqueryparam value="#variables.firstName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#variables.lastName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#variables.email#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#variables.firstName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#variables.passwordHash#" cfsqltype="cf_sql_char">,
                <cfqueryparam value="#variables.passwordSalt#" cfsqltype="cf_sql_char">,
                <cfqueryparam value="Setup" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="0" cfsqltype="cf_sql_tinyint">,
                NULL,
                <cfqueryparam value="1" cfsqltype="cf_sql_tinyint">,
                <cfqueryparam value="#variables.testAdminUserid#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
    </cftransaction>
    <cfset variables.newUserId = variables.insResult.generatedKey>
    <cflog file="TAO_setup_test_harness"
           text="provision: inserted test userid=#variables.newUserId# email=#variables.email# redirect_userid=#variables.testAdminUserid# by admin=#session.userid#">

    <!--- Ruling 2: snapshot the 12 session.user* keys user_setup_core overwrites (:77-88). --->
    <cfset variables.sessionKeys = ["userMediaPath","userMediaUrl","userContactsPath","userContactsUrl",
        "userImportsPath","userImportsUrl","userExportsPath","userExportsUrl",
        "userSharePath","userShareUrl","userAvatarPath","userAvatarUrl"]>
    <cfset variables.sessionSnapshot = {}>
    <cfloop array="#variables.sessionKeys#" index="variables.sk">
        <cfif structKeyExists(session, variables.sk)>
            <cfset variables.sessionSnapshot[variables.sk] = session[variables.sk]>
        </cfif>
    </cfloop>

    <!--- (2) Provision OUTSIDE any transaction. Contract: user_setup_core.cfm reads
          select_userid from the variables scope (C6). --->
    <cfset variables.provisionError = "">
    <cftry>
        <cfset variables.select_userid = variables.newUserId>
        <cfinclude template="/setup/user_setup_core.cfm">
        <cfcatch type="any">
            <cfset variables.provisionError = cfcatch.message>
            <cflog file="TAO_setup_test_harness" type="error"
                   text="provision: user_setup_core threw for userid=#variables.newUserId#: #cfcatch.message# | #cfcatch.detail#">
        </cfcatch>
        <cffinally>
            <!--- Restore admin session keys (set->restore, absent->remove). --->
            <cfloop array="#variables.sessionKeys#" index="variables.sk">
                <cfif structKeyExists(variables.sessionSnapshot, variables.sk)>
                    <cfset session[variables.sk] = variables.sessionSnapshot[variables.sk]>
                <cfelseif structKeyExists(session, variables.sk)>
                    <cfset structDelete(session, variables.sk)>
                </cfif>
            </cfloop>
            <cflog file="TAO_setup_test_harness"
                   text="provision: restored #structCount(variables.sessionSnapshot)# admin session key(s) for admin=#session.userid#">
        </cffinally>
    </cftry>

    <!--- (3) Post-condition guard (the real silent-failure catch). --->
    <cfquery name="variables.qChk" datasource="#application.dsn#">
        SELECT
            (SELECT contactid FROM taousers_tbl
              WHERE userid = <cfqueryparam value="#variables.newUserId#" cfsqltype="cf_sql_integer">) AS user_contactid,
            (SELECT COUNT(*) FROM contactdetails_tbl
              WHERE userid = <cfqueryparam value="#variables.newUserId#" cfsqltype="cf_sql_integer">
                AND user_yn = 'Y') AS self_contacts
    </cfquery>

    <cfif val(variables.qChk.user_contactid) LTE 0 OR val(variables.qChk.self_contacts) EQ 0>
        <!--- (4) Soft-delete + mangle email to free the unique slot. Do NOT chase orphans here. --->
        <cfquery datasource="#application.dsn#">
            UPDATE taousers_tbl
            SET IsDeleted = 1,
                userEmail = CONCAT('deleted_', userid, '_', UNIX_TIMESTAMP())
            WHERE userid = <cfqueryparam value="#variables.newUserId#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset variables.response.success = false>
        <cfset variables.response.message =
            "Provisioning failed post-condition (contactid=#variables.qChk.user_contactid#, self_contacts=#variables.qChk.self_contacts#"
            & (len(variables.provisionError) ? "; error=" & variables.provisionError : "")
            & "); user soft-deleted. No usable user created.">
        <cflog file="TAO_setup_test_harness" type="error"
               text="provision SOFT-DELETED userid=#variables.newUserId#: post-condition failed contactid=#variables.qChk.user_contactid# self_contacts=#variables.qChk.self_contacts# provisionError=#variables.provisionError#">
    <cfelse>
        <cfset variables.response.success = true>
        <cfset variables.response.message = "Test setup user " & variables.newUserId & " created (" & variables.email & ").">
        <!--- Return the actual password used so the operator always has working creds,
              even if the field was autofilled/non-empty (dev-only endpoint, throwaway user). --->
        <cfset variables.response.data = { "userid": variables.newUserId, "email": variables.email, "password": variables.password }>
        <cflog file="TAO_setup_test_harness"
               text="provision: COMMITTED test userid=#variables.newUserId# contactid=#variables.qChk.user_contactid# by admin=#session.userid#">
    </cfif>

    <cfcatch type="any">
        <cfset variables.response.success = false>
        <cfset variables.response.message = "Provision error: " & cfcatch.message>
        <cflog file="TAO_setup_test_harness" type="error"
               text="provision OUTER error admin=#session.userid#: #cfcatch.message#">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
