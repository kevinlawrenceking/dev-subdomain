<cfset componentPath = "/services/AuditionAnswerService">
<cfset auditionAnswerService = createObject("component", componentPath)>
<cfset auditionAnswerService.INSaudanswers(qid=x.qid, eventid=eventid)>