<cfset audRoleTypeService = createObject("component", "services.AuditionRoleTypeService")>
<cfset audroletypes_sel = audRoleTypeService.SELaudroletypes(audcatid=cat.audcatid)>