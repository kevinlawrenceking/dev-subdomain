<cfsilent>
<!---
    TAO-SETUP-TEST-HARNESS-01 (D3) - Provision a TEST setup purchase (thrivecart-driven)
    POST /app/admin-users/ajax/create-test-setup.cfm

    Inserts a TEST row into thrivecart_tbl: cloned product codes, status='Pending',
    IsDemo=1, linked to an admin via thrivecart_tbl.userid. The standard scheduled
    task (sched/thrivecart_process.cfm) then generates the uuid and sends the setup
    email -- redirected to that admin (resolver lives in thrivecart_process.cfm).
    The admin clicks GET STARTED -> /setup/ -> setup2.cfm creates the real test user.

    NOTE: no taousers row is created here -- setup2 creates it when the link is clicked.
    CustomerID is set to a unique numeric value because setup2.cfm:38 requires
    customerid numeric > 0.

    Product codes cloned from a real row (BaseProductLabel/ID + BasePaymentPlanID that
    the thrivecart_process paymentplans JOIN requires).

    DEV/UAT ONLY (allow-list: application.dsn EQ 'abod'). Auth+role via admin-guard.
    Form params: contactName (required), email (blank -> auto-generate),
                 testAdminUserid (admin to receive the redirected setup email; default session.userid)
    Returns JSON: { success, message, data:{ thrivecartId, customerEmail, adminUserid, adminEmail } }
--->
<cfset variables.isAjax = true>
<cfinclude template="../admin-guard.cfm">

<cfset variables.response = { "success": false, "message": "", "data": {} }>

<!--- Allow-list env gate: dev + prod. --->
<cfset variables.allowedDsns = "abo,abod">
<cfif NOT structKeyExists(application, "dsn") OR NOT listFindNoCase(variables.allowedDsns, application.dsn)>
    <cfset variables.response.message = "Test setup provisioning is not available in this environment.">
    <cflog file="TAO_setup_test_harness" type="warning"
           text="provision BLOCKED on dsn=#structKeyExists(application,'dsn') ? application.dsn : '(unset)'# by admin=#session.userid#">
    <cfheader statuscode="403">
    <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
</cfif>

<cftry>
    <cfparam name="form.contactName" default="">
    <cfparam name="form.email" default="">
    <cfparam name="form.testAdminUserid" default="#session.userid#">

    <cfset variables.contactName = trim(form.contactName)>
    <cfif NOT len(variables.contactName)>
        <cfset variables.response.message = "Contact name is required.">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.firstName = trim(listFirst(variables.contactName, " "))>
    <cfset variables.lastName = trim(listRest(variables.contactName, " "))>
    <cfif NOT len(variables.lastName)><cfset variables.lastName = "Test"></cfif>

    <!--- Auto-unique customer email (the would-be user's email). --->
    <cfset variables.email = trim(form.email)>
    <cfif NOT len(variables.email)>
        <cfset variables.email = "setup-test+" & getTickCount() & "-" & left(lCase(replace(createUUID(), "-", "", "all")), 6) & "@theactorsoffice.com">
    </cfif>

    <cfset variables.adminUserid = val(form.testAdminUserid)>
    <cfif variables.adminUserid LTE 0><cfset variables.adminUserid = val(session.userid)></cfif>

    <!--- Unique numeric customerid (setup2.cfm:38 requires numeric > 0) + unique test invoice id. --->
    <cfset variables.testCustomerId = getTickCount()>
    <cfset variables.testInvoiceId = "TEST-" & getTickCount() & "-" & left(lCase(replace(createUUID(), "-", "", "all")), 6)>

    <!--- Insert the test thrivecart row (Pending so the scheduled task picks it up). --->
    <cftransaction>
        <cfquery result="variables.insResult" datasource="#application.dsn#">
            INSERT INTO thrivecart_tbl (
                CustomerFirst, CustomerLast, CustomerFullName, CustomerEmail,
                BaseProductLabel, BaseProductID, BasePaymentPlanID,
                CustomerID, InvoiceID, OrderDate, status, IsDemo, IsDeleted, userid
            ) VALUES (
                <cfqueryparam value="#variables.firstName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#variables.lastName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#variables.firstName# #variables.lastName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#variables.email#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="The Actor's Office" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="24201" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="95048" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#variables.testCustomerId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#variables.testInvoiceId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="Pending" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="1" cfsqltype="cf_sql_tinyint">,
                <cfqueryparam value="0" cfsqltype="cf_sql_tinyint">,
                <cfqueryparam value="#variables.adminUserid#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
    </cftransaction>
    <cfset variables.tcId = variables.insResult.generatedKey>

    <!--- Resolve the admin's email for the operator message. --->
    <cfquery name="variables.qAdmin" datasource="#application.dsn#">
        SELECT userEmail FROM taousers
        WHERE userid = <cfqueryparam value="#variables.adminUserid#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfset variables.adminEmail = (variables.qAdmin.recordCount AND len(trim(variables.qAdmin.userEmail))) ? trim(variables.qAdmin.userEmail) : "(no email on file)">

    <cflog file="TAO_setup_test_harness"
           text="provision: created TEST thrivecart id=#variables.tcId# customerEmail=#variables.email# customerid=#variables.testCustomerId# admin=#variables.adminUserid# by admin=#session.userid#">

    <cfset variables.response.success = true>
    <cfset variables.response.message = "Test purchase created (thrivecart id " & variables.tcId & "). The setup email will go to " & variables.adminEmail & " (admin " & variables.adminUserid & ") next time the thrivecart scheduled task runs. Click GET STARTED in that email to run setup.">
    <cfset variables.response.data = {
        "thrivecartId": variables.tcId,
        "customerEmail": variables.email,
        "adminUserid": variables.adminUserid,
        "adminEmail": variables.adminEmail
    }>

    <cfcatch type="any">
        <cfset variables.response.success = false>
        <cfset variables.response.message = "Provision failed: " & cfcatch.message & (structKeyExists(cfcatch,"detail") AND len(cfcatch.detail) ? " | " & cfcatch.detail : "")>
        <cflog file="TAO_setup_test_harness" type="error"
               text="provision FAILED admin=#session.userid#: #cfcatch.message# | #(structKeyExists(cfcatch,'detail') ? cfcatch.detail : '')#">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
