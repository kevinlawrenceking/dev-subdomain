<cfset contactItemService = createObject("component", "services.ContactItemService")>

<!--- Initialize an empty structure to hold parameters --->
<cfset args = {
    valuetext: trim(valuetext),
    catid: catid,
    itemid: itemid
}>
<!--- Conditionally add defined variables to the structure --->
<cfif structKeyExists(form, "valuecompany")><cfset args.valuecompany = trim(valuecompany)></cfif>
<cfif structKeyExists(form, "valueDepartment")><cfset args.valueDepartment = trim(valueDepartment)></cfif>
<cfif structKeyExists(form, "valueTitle")><cfset args.valueTitle = trim(valueTitle)></cfif>
<cfif structKeyExists(form, "valueStreetAddress")><cfset args.valueStreetAddress = trim(valueStreetAddress)></cfif>
<cfif structKeyExists(form, "valueExtendedAddress")><cfset args.valueExtendedAddress = trim(valueExtendedAddress)></cfif>
<cfif structKeyExists(form, "valueCity")><cfset args.valueCity = trim(valueCity)></cfif>
<cfif structKeyExists(form, "new_regionname")><cfset args.new_regionname = trim(new_regionname)></cfif>
<cfif structKeyExists(form, "new_countryname")><cfset args.new_countryname = trim(new_countryname)></cfif>
<cfif structKeyExists(form, "valuePostalCode")><cfset args.valuePostalCode = trim(valuePostalCode)></cfif>
<cfif structKeyExists(form, "itemdate") AND IsDate(itemdate)><cfset args.itemdate = itemdate></cfif>

<cfset contactItemService.UPDcontactitems_24046(argumentCollection=args)>
