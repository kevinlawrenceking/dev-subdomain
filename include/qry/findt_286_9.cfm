<cfset auditionVocalTypeXRefService = createObject("component", "services.AuditionVocalTypeXRefService")>
<cfset findt = auditionVocalTypeXRefService.SELaudvocaltypes_audition_xref(audroleid=audroleid, new_vocaltypeid=new_vocaltypeid)>
<cfset audvocaltypes_audition_xref = auditionVocalTypeXRefService.SELaudvocaltypes_audition_xref(audroleid=audroleid, new_vocaltypeid=new_vocaltypeid)>




