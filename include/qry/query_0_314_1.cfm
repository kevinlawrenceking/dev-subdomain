<!--- This ColdFusion page updates the order number for a specific user in the pgpanels_user table based on the provided new order details. --->

<cfquery>
    <!--- Update the order number for the user based on the new order ID --->
    UPDATE pgpanels_user
    SET pnorderno = #i#
    WHERE pnid = #newOrder[i]#
</cfquery>
