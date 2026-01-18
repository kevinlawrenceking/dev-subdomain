<!--- This ColdFusion page retrieves ticket priorities from the database and orders them by order number. --->
<cfquery name="priorities">
    <!--- Query to get ticket priorities ordered by orderNo --->
    SELECT 
        ticketpriority AS id, 
        ticketpriority AS name 
    FROM 
        ticketpriority 
    ORDER BY 
        orderNo
</cfquery>
