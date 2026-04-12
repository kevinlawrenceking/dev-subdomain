<cfinclude template="/include/perfcount.cfm" />
<cfset countryService = createObject("component", "services.CountryService")>
<cfset findcountry = countryService.SELcountries(countryid=countryid)>