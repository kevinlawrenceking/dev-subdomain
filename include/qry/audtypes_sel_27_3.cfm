<cfset auditionTypeService = createObject("component", "services.AuditionTypeService")>
<cfset audtypes_sel = auditionTypeService.SELaudtypes(audcatid=cat.audcatid)>