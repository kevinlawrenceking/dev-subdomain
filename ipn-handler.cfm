<cftry>
    <cfset httpData = getHttpRequestData()>
    <cfset rawPostData = httpData.content>

    <!--- Parse rawPostData into a struct --->
    <cfset paramStruct = {}>

    <cfloop list="#rawPostData#" delimiters="&" index="pair">
        <cfset key = listFirst(pair, "=")>
        <cfset value = urlDecode(listRest(pair, "="))>
        <cfset paramStruct[key] = value>
    </cfloop>

    <!--- Insert into thrivecart_tbl --->
    <cfquery datasource="#application.dsn#">
        INSERT INTO thrivecart_tbl (
            CustomerFirst,
            CustomerLast,
            CustomerEmail,
            BaseProductLabel,
            BaseProductID,
            BasePaymentPlanID
        )
        VALUES (
            <cfqueryparam value="#paramStruct['buyer_first_name']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#paramStruct['buyer_last_name']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#paramStruct['buyer_email']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#paramStruct['campaign_name']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#paramStruct['campaign_id']#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#paramStruct['product_id']#" cfsqltype="cf_sql_varchar">
        )
    </cfquery>

<cfcatch>
    <!--- Optionally log the error --->
    <cflog file="ipn_errors" text="IPN Error: #cfcatch.message#">
</cfcatch>
</cftry>

<cfoutput>OK</cfoutput>
