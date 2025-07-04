<!--- This ColdFusion page handles the retrieval and insertion of version records, redirecting to a specific URL based on the outcome. --->

<cfinclude template="/include/qry/find_320_1.cfm" />

<!--- Check if a record was found --->
<cfif #find.recordcount# is "1">
    <cfset verid = find.verid />
<cfelse>
    <!--- Include the insert query template if no record was found --->
    <cfinclude template="/include/qry/insert_320_2.cfm" />
    
    <!--- Get the last inserted ID --->
    <cfset verid = insertResult.GENERATEDKEY>
</cfif>

<!--- Redirect to the new URL with the record ID --->
<cflocation url="/app/version/?recid=#verid#" addtoken="false" />
