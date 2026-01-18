<cfset componentPath = "/services/AuditionAnswerService">
<cfset auditionAnswerService = createObject("component", componentPath)>
<cfset auditionAnswerService.UPDaudanswers(
    new_qtype = new_qtype,
    new_value = new_value,
    new_answerID = new_answerID
)>