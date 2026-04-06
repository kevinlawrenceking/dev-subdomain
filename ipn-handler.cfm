<!--- MIGRATE: IPN handler -> Go webhook endpoint with signature middleware --->
<cftry>
    <!--- Determine datasource from hostname --->
    <cfset dsn = ListFirst(cgi.server_name, ".") EQ "app" ? "abo" : "abod" />
    <cfset httpData = getHttpRequestData()>
    <cfset rawPostData = httpData.content>
    <cfset httpHeaders = httpData.headers>

    <!--- Log raw payload for field discovery and debugging --->
    <cflog file="ipn_raw_payload" text="#rawPostData#">

    <!--- ============================================================
          HMAC Signature Verification
          PayKickstart signs webhooks with HMAC-SHA256.
          Secret is read from server environment variable.
          ============================================================ --->
    <cfscript>
        webhookSecret = "";
        env = {};
        if (structKeyExists(server, "system") && structKeyExists(server.system, "environment")) {
            env = server.system.environment;
        }
        if (structKeyExists(env, "TAO_PAYKICKSTART_WEBHOOK_SECRET") && len(env["TAO_PAYKICKSTART_WEBHOOK_SECRET"])) {
            webhookSecret = env["TAO_PAYKICKSTART_WEBHOOK_SECRET"];
        }

        // Extract signature from header (check common PayKickstart header names)
        receivedSig = "";
        for (hName in ["X-PK-Signature", "x-pk-signature", "X-Webhook-Signature", "x-webhook-signature"]) {
            if (structKeyExists(httpHeaders, hName) && len(httpHeaders[hName])) {
                receivedSig = httpHeaders[hName];
                break;
            }
        }
    </cfscript>

    <cfif len(webhookSecret)>
        <!--- Secret is configured: enforce signature check --->
        <cfif NOT len(receivedSig)>
            <cflog file="ipn_security" text="REJECTED: No signature header present. IP=#cgi.remote_addr#">
            <cfheader statuscode="403" />
            <cfcontent type="text/plain" reset="true" /><cfoutput>Forbidden</cfoutput><cfabort />
        </cfif>

        <cfset computedSig = hmac(rawPostData, webhookSecret, "HmacSHA256", "utf-8") />

        <cfif compareNoCase(computedSig, receivedSig) NEQ 0>
            <cflog file="ipn_security" text="REJECTED: Signature mismatch. IP=#cgi.remote_addr# Expected=#computedSig# Got=#receivedSig#">
            <cfheader statuscode="403" />
            <cfcontent type="text/plain" reset="true" /><cfoutput>Forbidden</cfoutput><cfabort />
        </cfif>
    <cfelse>
        <!--- No secret configured yet: log warning, allow request (deployment grace period) --->
        <cflog file="ipn_security" text="WARNING: TAO_PAYKICKSTART_WEBHOOK_SECRET not configured. Skipping signature check. IP=#cgi.remote_addr#">
    </cfif>

    <!--- Parse rawPostData into a struct --->
    <cfset paramStruct = {}>

    <cfloop list="#rawPostData#" delimiters="&" index="pair">
        <cfset key = listFirst(pair, "=")>
        <cfset value = urlDecode(listRest(pair, "="))>
        <cfset paramStruct[key] = value>
    </cfloop>

    <!--- Ensure all expected keys exist with empty string defaults --->
    <cfloop list="buyer_first_name,buyer_last_name,buyer_email,campaign_name,campaign_id,product_id,buyer_address,buyer_city,buyer_state,buyer_zip,buyer_country,invoice_id,customer_id,base_product_name,purchase_name,order_date,purchase_amount_cents" index="k">
        <cfif NOT structKeyExists(paramStruct, k)>
            <cfset paramStruct[k] = "">
        </cfif>
    </cfloop>

    <!--- ============================================================
          Duplicate InvoiceID Detection
          Prevent re-inserting the same webhook delivery.
          ============================================================ --->
    <cfif len(trim(paramStruct['invoice_id']))>
        <cfquery name="qDupe" datasource="#dsn#">
            SELECT id FROM thrivecart_tbl
            WHERE InvoiceID = <cfqueryparam value="#paramStruct['invoice_id']#" cfsqltype="cf_sql_varchar">
            LIMIT 1
        </cfquery>

        <cfif qDupe.recordCount GT 0>
            <cflog file="ipn_duplicates" text="Duplicate InvoiceID=#paramStruct['invoice_id']# already exists as thrivecart_tbl.id=#qDupe.id#. IP=#cgi.remote_addr#">
            <cfoutput>OK</cfoutput>
            <cfabort />
        </cfif>
    </cfif>

    <!--- Derive full name --->
    <cfset fullName = trim(paramStruct['buyer_first_name'] & " " & paramStruct['buyer_last_name'])>

    <!--- Safe date/numeric pre-checks --->
    <cfset orderDateNull = NOT isDate(paramStruct['order_date'])>
    <cfset purchaseAmountNull = NOT isNumeric(paramStruct['purchase_amount_cents'])>

    <!--- Insert into thrivecart_tbl --->
    <cfquery datasource="#dsn#">
        INSERT INTO thrivecart_tbl (
            CustomerFirst,
            CustomerLast,
            CustomerFullName,
            CustomerEmail,
            BaseProductLabel,
            baseProductName,
            BaseProductID,
            BasePaymentPlanID,
            PurchaseName,
            BillingAddress,
            BillingCity,
            BillingState,
            BillingZip,
            BillingCountry,
            InvoiceID,
            CustomerID,
            OrderDate,
            PurchaseAmountCents,
            status
        )
        VALUES (
            <cfqueryparam value="#paramStruct['buyer_first_name']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#paramStruct['buyer_last_name']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#fullName#" cfsqltype="cf_sql_varchar" null="#NOT len(fullName)#">,
            <cfqueryparam value="#paramStruct['buyer_email']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#paramStruct['campaign_name']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#paramStruct['base_product_name']#" cfsqltype="cf_sql_varchar" null="#NOT len(paramStruct['base_product_name'])#">,
            <cfqueryparam value="#paramStruct['campaign_id']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#paramStruct['product_id']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#paramStruct['purchase_name']#" cfsqltype="cf_sql_varchar" null="#NOT len(paramStruct['purchase_name'])#">,
            <cfqueryparam value="#paramStruct['buyer_address']#" cfsqltype="cf_sql_varchar" null="#NOT len(paramStruct['buyer_address'])#">,
            <cfqueryparam value="#paramStruct['buyer_city']#" cfsqltype="cf_sql_varchar" null="#NOT len(paramStruct['buyer_city'])#">,
            <cfqueryparam value="#paramStruct['buyer_state']#" cfsqltype="cf_sql_varchar" null="#NOT len(paramStruct['buyer_state'])#">,
            <cfqueryparam value="#paramStruct['buyer_zip']#" cfsqltype="cf_sql_varchar" null="#NOT len(paramStruct['buyer_zip'])#">,
            <cfqueryparam value="#paramStruct['buyer_country']#" cfsqltype="cf_sql_varchar" null="#NOT len(paramStruct['buyer_country'])#">,
            <cfqueryparam value="#paramStruct['invoice_id']#" cfsqltype="cf_sql_varchar" null="#NOT len(paramStruct['invoice_id'])#">,
            <cfqueryparam value="#paramStruct['customer_id']#" cfsqltype="cf_sql_varchar" null="#NOT len(paramStruct['customer_id'])#">,
            <cfqueryparam value="#paramStruct['order_date']#" cfsqltype="cf_sql_timestamp" null="#orderDateNull#">,
            <cfqueryparam value="#paramStruct['purchase_amount_cents']#" cfsqltype="cf_sql_integer" null="#purchaseAmountNull#">,
            <cfqueryparam value="Pending" cfsqltype="cf_sql_varchar">
        )
    </cfquery>

<cfcatch>
    <!--- Log the error with detail --->
    <cflog file="ipn_errors" text="IPN Error: #cfcatch.message# | Detail: #cfcatch.detail#">
</cfcatch>
</cftry>

<cfoutput>OK</cfoutput>
