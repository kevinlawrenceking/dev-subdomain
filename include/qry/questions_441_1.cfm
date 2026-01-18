<cfset auditionQuestionUserService = createObject("component", "services.AuditionQuestionUserService")>
<cfset questions = auditionQuestionUserService.SELaudquestions_user_24501(eventid=eventid)>