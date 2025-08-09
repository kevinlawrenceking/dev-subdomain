<cftransaction>
  <cftry>
    <cfquery name="qInsert" datasource="abo" result="r">
      INSERT INTO actorsbusinessoffice.thrivecart_tbl (
        CustomerFirst, CustomerLast, purchasedate, CustomerFullName,
        baseProductName, `timestamp`, CustomerEmail, PurchaseName,
        BillingAddress, BillingCity, BillingZip, BillingCountry, BillingState,
        InvoiceID, CustomerID, BaseProductLabel, BaseProductID, OrderDate,
        TrialDays, TrialEndDate, PurchaseAmountCents, BasePaymentPlanID,
        status, UUID, IsDemo, IsDeleted, canceldate, userid
      )
      SELECT
        s.CustomerFirst, s.CustomerLast, s.purchasedate, s.CustomerFullName,
        s.baseProductName, s.`timestamp`, s.CustomerEmail, s.PurchaseName,
        s.BillingAddress, s.BillingCity, s.BillingZip, s.BillingCountry, s.BillingState,
        s.InvoiceID, s.CustomerID, s.BaseProductLabel, s.BaseProductID, s.OrderDate,
        s.TrialDays, s.TrialEndDate, s.PurchaseAmountCents, s.BasePaymentPlanID,
        'Pending', s.UUID, s.IsDemo, s.IsDeleted, s.canceldate, s.userid
      FROM (
        SELECT *
        FROM new_development.thrivecart_tbl
        ORDER BY purchasedate DESC, id DESC
        LIMIT 1
      ) AS s
      WHERE NOT EXISTS (
        SELECT 1
        FROM actorsbusinessoffice.thrivecart_tbl d
        WHERE d.UUID = s.UUID
      );
    </cfquery>

    <cfset inserted = val(structFind(r, "rowcount"))>
    <cfoutput>#inserted# row(s) inserted.</cfoutput>

    <cfcatch type="any">
      <cftransaction action="rollback" />
      <cfoutput>Insert failed: #cfcatch.message#</cfoutput>
      <cfabort />
    </cfcatch>
  </cftry>
</cftransaction>
