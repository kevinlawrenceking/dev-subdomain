<cfset componentPath = "/services/AuditionVocalTypeXRefService">
<cfset auditionService = createObject("component", componentPath)>
<cfset auditionService.DELaudvocaltypes_audition_xref(new_audroleid)>