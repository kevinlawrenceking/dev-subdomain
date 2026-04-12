<cfinclude template="/include/perfcount.cfm" />
<cfset incomeTypeService = createObject("component", "services.IncomeTypeService")>
<cfset incometypes_sel = incomeTypeService.SELincometypes()>