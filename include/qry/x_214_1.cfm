<cfinclude template="/include/perfcount.cfm" />
<cfset auditionQuestionUserService = createObject("component", "services.AuditionQuestionUserService")>
<cfset x = auditionQuestionUserService.SELaudquestions_user_24078(userid=userid)>