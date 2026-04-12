<cfinclude template="/include/perfcount.cfm" />
<cfset auditionLocationService = createObject("component", "services.AuditionLocationService")>
<cfset audlocations_sel = auditionLocationService.SELaudlocations(userid=userid)>