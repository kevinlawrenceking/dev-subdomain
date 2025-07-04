<cfcomponent displayname="TicketTypeService" hint="Handles operations for TicketType table" >

<cffunction output="false" name="SELtickettypes" access="public" returntype="query">
    <!--- Execute the query --->
    <cfquery name="result">
        SELECT tickettype AS id, tickettype AS name 
        FROM tickettypes 
        ORDER BY tickettype
    </cfquery>

<!--- Return the query result --->
    <cfreturn result>
</cffunction>

</cfcomponent>