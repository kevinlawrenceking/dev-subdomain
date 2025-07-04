<cfset essenceService = createObject("component", "services.EssenceService")>

<cfif StructKeyExists(form, "isdeleted")>
    <cfset isdeletedValue = 1>
<cfelse>
    <cfset isdeletedValue = 0>
</cfif>

<cfset essenceService.UPDessences_24181(
    new_essenceName = form.new_essenceName,
    isdeleted = isdeletedValue,
    essenceid = form.essenceid
)>
