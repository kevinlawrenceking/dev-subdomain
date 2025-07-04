<cfset componentPath = "/services/AuditionAnswerService">
<cfset auditionAnswerService = createObject("component", componentPath)>
<cfset auditionAnswerService.UPDaudanswers_24507(
    new_qID = new_qID,
    new_eventid = new_eventid,
    new_aText = new_aText,
    new_aRating = new_aRating,
    new_aMemo = new_aMemo,
    new_isDeleted = new_isDeleted,
    new_answerID = new_answerID
)>