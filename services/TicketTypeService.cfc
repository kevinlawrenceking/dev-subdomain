<cfcomponent displayname="TicketTypeService" hint="Handles operations for TicketType table" >

<cffunction output="false" name="SELtickettypes" access="public" returntype="query">
    <!--- Execute the query --->
    <cfquery name="result">
        SELECT tickettype AS id, tickettype AS name 
        FROM tickettypes 
        ORDER BY tickettype
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

<!--- Return the query result --->
    <cfreturn result>
</cffunction>

</cfcomponent>