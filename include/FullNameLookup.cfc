<!--- This ColdFusion component provides a function to retrieve full names based on a search term. --->
<cfcomponent>

<!--- Function to get full names based on a search term --->
    <cffunction name="getFullNames" access="remote" returntype="query" output="false" returnformat="json">

<!--- Define the search term argument --->
        <cfargument name="searchTerm" type="string" required="true">

<!--- Include the query logic for retrieving full names --->
        <cfinclude template="/include/qry/queryFullNames_129_1.cfm" />

<!--- Return the query result containing full names --->
        <cfreturn queryFullNames>
    </cffunction>

</cfcomponent>
