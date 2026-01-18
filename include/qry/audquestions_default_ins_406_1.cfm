<cfset service = createObject("component", "services.AuditionQuestionsDefaultService")>
<cfset service.UPDaudquestions_default(
    new_qTypeID = new_qTypeID,
    new_qtext = new_qtext,
    new_qorder = new_qorder,
    new_isDeleted = new_isDeleted,
    new_qID = new_qID
)>