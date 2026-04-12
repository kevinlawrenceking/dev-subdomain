<cfinclude template="/include/perfcount.cfm" />
<cfset fTypeXRefService = createObject("component", "services.FTypeXRefService")>
<cfset find = fTypeXRefService.SELftypexref(type=x.type)>