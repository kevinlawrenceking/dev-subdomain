<cftransaction>
  <cftry>
    <!--- 1) Pull the source row from ABOD, formatting all date/timestamp fields as strings --->
    <cfquery name="src" datasource="abod">
      SELECT
        CustomerFirst,
        CustomerLast,
        DATE_FORMAT(purchasedate, '%Y-%m-%d %H:%i:%s')   AS purchasedate_str,
        CustomerFullName,
        baseProductName,
        DATE_FORMAT(`timestamp`, '%Y-%m-%d %H:%i:%s')    AS ts_str,
        CustomerEmail,
        PurchaseName,
        BillingAddress,
        BillingCity,
        BillingZip,
        BillingCountry,
        BillingState,
        InvoiceID,
        CustomerID,
        BaseProductLabel,
        BaseProductID,
        DATE_FORMAT(OrderDate, '%Y-%m-%d %H:%i:%s')      AS orderdate_str,
        TrialDays,
        DATE_FORMAT(TrialEndDate, '%Y-%m-%d %H:%i:%s')   AS trialenddate_str,
        PurchaseAmountCents,
        BasePaymentPlanID,
        UUID,
        IsDemo,
        IsDeleted,
        DATE_FORMAT(canceldate, '%Y-%m-%d %H:%i:%s')     AS canceldate_str,
        userid
      FROM new_development.thrivecart_tbl
      WHERE id = 1361
      LIMIT 1
    </cfquery>

    <cfif src.recordCount EQ 0>
      <cfthrow message="No source row found in ABOD for id 1361." />
    </cfif>

    <!--- 2) Insert into ABO, omit id, force status = 'Pending' --->
    <cfquery name="ins" datasource="abo" result="r">
      INSERT INTO actorsbusinessoffice.thrivecart_tbl (
        CustomerFirst, CustomerLast, purchasedate, CustomerFullName,
        baseProductName, `timestamp`, CustomerEmail, PurchaseName,
        BillingAddress, BillingCity, BillingZip, BillingCountry, BillingState,
        InvoiceID, CustomerID, BaseProductLabel, BaseProductID, OrderDate,
        TrialDays, TrialEndDate, PurchaseAmountCents, BasePaymentPlanID,
        status, UUID, IsDemo, IsDeleted, canceldate, userid
      ) VALUES (
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.CustomerFirst#"          null="#NOT Len(src.CustomerFirst)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.CustomerLast#"           null="#NOT Len(src.CustomerLast)#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp"  value="#src.purchasedate_str#"       null="#NOT Len(src.purchasedate_str)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.CustomerFullName#"       null="#NOT Len(src.CustomerFullName)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.baseProductName#"        null="#NOT Len(src.baseProductName)#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp"  value="#src.ts_str#"                 null="#NOT Len(src.ts_str)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.CustomerEmail#"          null="#NOT Len(src.CustomerEmail)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.PurchaseName#"           null="#NOT Len(src.PurchaseName)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.BillingAddress#"         null="#NOT Len(src.BillingAddress)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.BillingCity#"            null="#NOT Len(src.BillingCity)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.BillingZip#"             null="#NOT Len(src.BillingZip)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.BillingCountry#"         null="#NOT Len(src.BillingCountry)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.BillingState#"           null="#NOT Len(src.BillingState)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.InvoiceID#"              null="#NOT Len(src.InvoiceID)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.CustomerID#"             null="#NOT Len(src.CustomerID)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.BaseProductLabel#"       null="#NOT Len(src.BaseProductLabel)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.BaseProductID#"          null="#NOT Len(src.BaseProductID)#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp"  value="#src.orderdate_str#"          null="#NOT Len(src.orderdate_str)#">,
        <cfqueryparam cfsqltype="cf_sql_integer"    value="#src.TrialDays#"              null="#NOT Len(src.TrialDays)#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp"  value="#src.trialenddate_str#"       null="#NOT Len(src.trialenddate_str)#">,
        <cfqueryparam cfsqltype="cf_sql_integer"    value="#src.PurchaseAmountCents#"    null="#NOT Len(src.PurchaseAmountCents)#">,
        <cfqueryparam cfsqltype="cf_sql_integer"    value="#src.BasePaymentPlanID#"      null="#NOT Len(src.BasePaymentPlanID)#">,
        'Pending',
        <cfqueryparam cfsqltype="cf_sql_varchar"    value="#src.UUID#"                   null="#NOT Len(src.UUID)#">,
        <cfqueryparam cfsqltype="cf_sql_tinyint"    value="#src.IsDemo#"                 null="#NOT Len(src.IsDemo)#">,
        <cfqueryparam cfsqltype="cf_sql_tinyint"    value="#src.IsDeleted#"              null="#NOT Len(src.IsDeleted)#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp"  value="#src.canceldate_str#"         null="#NOT Len(src.canceldate_str)#">,
        <cfqueryparam cfsqltype="cf_sql_integer"    value="#src.userid#"                 null="#NOT Len(src.userid)#">
      )
    </cfquery>

    <cfoutput>Inserted 1 row into ABO for source id 1361.</cfoutput>

    <cfcatch type="any">
      <cftransaction action="rollback" />
      <cfoutput>Insert failed: #cfcatch.message#</cfoutput>
      <cfabort />
    </cfcatch>
  </cftry>
</cftransaction>
