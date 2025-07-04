<cfcomponent displayname="TicketPriorityService" hint="Handles operations for TicketPriority table" > 
<cffunction output="false" name="SELticketpriority" access="public" returntype="query">
    <!--- Execute the query --->
    <cfquery name="result">
        SELECT ticketpriority AS id, ticketpriority AS name 
        FROM ticketpriority 
        ORDER BY orderNo
    </cfquery>

<!--- Return the query result --->
    <cfreturn result>
</cffunction>

</cfcomponent>