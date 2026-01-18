<cfset componentPath = "/services/AuditionMediaXRefService" />
<cfset componentInstance = createObject("component", componentPath) />
<cfset componentInstance.INSaudmedia_auditions_xref(new_mediaid=new_mediaid, audprojectid=audprojectid) />