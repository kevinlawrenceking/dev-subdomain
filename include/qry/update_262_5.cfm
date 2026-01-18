<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset params = {}>

<!--- Conditionally add variables to the params struct --->
<cfif len(trim(valuetext))>
    <cfset params.valuetext = trim(valuetext)>
</cfif>

<cfif len(trim(valuetype))>
    <cfset params.valuetype = trim(valuetype)>
</cfif>

<cfif isDefined("catid")>
    <cfset params.catid = catid>
</cfif>

<cfif isDefined("valuecompany")>
    <cfset params.valuecompany = valuecompany>
</cfif>

<cfif isDefined("custom")>
    <cfset params.custom = custom>
</cfif>

<cfif isDefined("valueDepartment")>
    <cfset params.valueDepartment = valueDepartment>
</cfif>

<cfif isDefined("valueTitle")>
    <cfset params.valueTitle = valueTitle>
</cfif>

<cfif isDefined("valueStreetAddress")>
    <cfset params.valueStreetAddress = valueStreetAddress>
</cfif>

<cfif isDefined("valueExtendedAddress")>
    <cfset params.valueExtendedAddress = valueExtendedAddress>
</cfif>

<cfif isDefined("valueCity")>
    <cfset params.valueCity = valueCity>
</cfif>

<cfif isDefined("new_region_id")>
    <cfset params.new_region_id = new_region_id>
</cfif>

<cfif isDefined("new_countryid")>
    <cfset params.new_countryid = new_countryid>
</cfif>

<cfif isDefined("valuePostalCode")>
    <cfset params.valuePostalCode = valuePostalCode>
</cfif>

<cfif isDefined("itemdate") and isDate(itemdate)>
    <cfset params.itemdate = itemdate>
</cfif>

<cfif isDefined("deleteitem")>
    <cfset params.deleteitem = deleteitem>
</cfif>

<cfif isDefined("itemid")>
    <cfset params.itemid = itemid>
</cfif>

<!--- Call the service method with the params struct --->
<cfset contactItemService.UPDcontactitems_24178(argumentCollection=params)>
