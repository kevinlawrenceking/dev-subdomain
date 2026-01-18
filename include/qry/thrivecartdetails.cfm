<!--- This ColdFusion page initializes the customer ID if it is not provided. --->

<cfif #customerid# is "">
    <!--- Check if customer ID is empty and set to 0 if true. --->
    <cfset customerid = 0 />
</cfif>
