
<cfset AuditionVocalTypeXrefService = createObject("component", "services.AuditionVocalTypeXrefService")>
<cfset audvocaltypes_audition_xref = AuditionVocalTypeXrefService.audvocaltypes_audition_xref(audroleid=audroleid, userid=userid)>