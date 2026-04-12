<cfinclude template="/include/perfcount.cfm" />
<cfset service = createObject("component", "services.AuditionVocalTypeXRefService")>
<cfset service.INSaudvocaltypes_audition_xref(new_vocaltypeid=new_vocaltypeid, new_audroleid=new_audroleid)>