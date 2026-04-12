<cfinclude template="/include/perfcount.cfm" />
<cfset auditionMediaService = createObject("component", "services.AuditionMediaService") />
<cfset find_#types.mediatypeid# = auditionMediaService.SELaudmedia(audprojectid=audprojectid, mediatypeid=types.mediatypeid) />