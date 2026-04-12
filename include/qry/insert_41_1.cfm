<cfinclude template="/include/perfcount.cfm" />
<cfset componentPath = "/services/AuditionAnswerService">
<cfset auditionAnswerService = createObject("component", componentPath)>
<cfset auditionAnswerService.DELaudanswers(eventid=eventid)>