<cfinclude template="/include/perfcount.cfm" />
<cfset genderPronounService = createObject("component", "services.GenderPronounService")>
<cfset x = genderPronounService.SELgenderpronouns()>