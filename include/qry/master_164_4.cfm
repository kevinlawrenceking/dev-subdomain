<cfset masterService = createObject("component", "services.SiteTypeMasterService")>
<cfset master = masterService.SELsitetypes_master(sitetypename=current_sitetypename)>