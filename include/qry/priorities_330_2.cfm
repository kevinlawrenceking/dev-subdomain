<!--- This ColdFusion page retrieves ticket priorities from the database for display purposes. --->

<cfquery name="priorities">
    <!--- Query to select ticket priorities from the ticketpriority table --->
    SELECT
        ticketpriority AS id,
        ticketpriority AS name
    FROM
        ticketpriority
    ORDER BY
        orderNo
</cfquery>
