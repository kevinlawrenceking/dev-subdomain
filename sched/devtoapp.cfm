<cftransaction>
  <cftry>
    <!--- 1) Get the specific source row from ABOD --->
    <cfquery name="src" datasource="abod">
      SELECT
        CustomerFirst, CustomerLast, purchasedate, CustomerFullName,
        baseProductName, `timestamp`, CustomerEmail, PurchaseName,
        BillingAddress, BillingCity, BillingZip, BillingCountry, BillingState,
        InvoiceID, CustomerID, BaseProductLabel, BaseProductID, OrderDate,
        TrialDays, TrialEndDate, PurchaseAmountCents, BasePaymentPlanID,
        UUID, IsDemo, IsDeleted, canceldate, userid
      FROM new_development.thrivecart_tbl
      WHERE id = 1361
      LIMIT 1
    </cfquery>

    <cfif src.recordCount EQ 0>
      <cfthrow message="No source row found in ABOD for id 1361." />
    </cfif>

    <!--- 2) Insert into ABO. Omit id. Force status = 'Pending'. --->
    <cfquery name="ins" datasource="abo" result="r">
      INSERT INTO actorsbusinessoffice.thrivecart_tbl (
        CustomerFirst, CustomerLast, purchasedate, CustomerFullName,
        baseProductName, `timestamp`, CustomerEmail, PurchaseName,
        BillingAddress, BillingCity, BillingZip, BillingCountry, BillingState,
        InvoiceID, CustomerID, BaseProductLabel, BaseProductID, OrderDate,
        TrialDays, TrialEndDate, PurchaseAmountCents, BasePaymentPlanID,
        status, UUID, IsDemo, IsDeleted, canceldate, userid
      ) VALUES (
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.CustomerFirst#"  null="#NOT Len(src.CustomerFirst)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.CustomerLast#"   null="#NOT Len(src.CustomerLast)#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#src.purchasedate#"  null="#NOT Len(src.purchasedate)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.CustomerFullName#" null="#NOT Len(src.CustomerFullName)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.baseProductName#" null="#NOT Len(src.baseProductName)#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#src.timestamp#"      null="#NOT Len(src.timestamp)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.CustomerEmail#"   null="#NOT Len(src.CustomerEmail)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.PurchaseName#"    null="#NOT Len(src.PurchaseName)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.BillingAddress#"  null="#NOT Len(src.BillingAddress)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.BillingCity#"     null="#NOT Len(src.BillingCity)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.BillingZip#"      null="#NOT Len(src.BillingZip)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.BillingCountry#"  null="#NOT Len(src.BillingCountry)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.BillingState#"    null="#NOT Len(src.BillingState)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.InvoiceID#"       null="#NOT Len(src.InvoiceID)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.CustomerID#"      null="#NOT Len(src.CustomerID)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.BaseProductLabel#" null="#NOT Len(src.BaseProductLabel)#">,
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.BaseProductID#"   null="#NOT Len(src.BaseProductID)#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#src.OrderDate#"      null="#NOT Len(src.OrderDate)#">,
        <cfqueryparam cfsqltype="cf_sql_integer"  value="#src.TrialDays#"       null="#NOT Len(src.TrialDays)#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#src.TrialEndDate#"   null="#NOT Len(src.TrialEndDate)#">,
        <cfqueryparam cfsqltype="cf_sql_integer"  value="#src.PurchaseAmountCents#" null="#NOT Len(src.PurchaseAmountCents)#">,
        <cfqueryparam cfsqltype="cf_sql_integer"  value="#src.BasePaymentPlanID#"   null="#NOT Len(src.BasePaymentPlanID)#">,
        'Pending',
        <cfqueryparam cfsqltype="cf_sql_varchar"  value="#src.UUID#"            null="#NOT Len(src.UUID)#">,
        <cfqueryparam cfsqltype="cf_sql_bit"      value="#src.IsDemo#"          null="#NOT Len(src.IsDemo)#">,
        <cfqueryparam cfsqltype="cf_sql_bit"      value="#src.IsDeleted#"       null="#NOT Len(src.IsDeleted)#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#src.canceldate#"     null="#NOT Len(src.canceldate)#">,
        <cfqueryparam cfsqltype="cf_sql_integer"  value="#src.userid#"          null="#NOT Len(src.userid)#">
      )
    </cfquery>

    <!--- Optional: report new id --->
    <cfquery name="qLastID" datasource="abo">
      SELECT LAST_INSERT_ID() AS new_id
    </cfquery>

    <cfoutput>Inserted 1 row into ABO. New id: #qLastID.new_id#</cfoutput>

    <cfcatch type="any">
      <cftransaction action="rollback" />
      <cfoutput>Insert failed: #cfcatch.message#</cfoutput>
      <cfabort />
    </cfcatch>
  </cftry>
</cftransaction>
