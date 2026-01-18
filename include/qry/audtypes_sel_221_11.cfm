<cfset auditionTypeService = createObject("component", "services.AuditionTypeService")>
<cfset audtypes_sel = auditionTypeService.getAudtypes(new_audcatid)>