<cfset service = createObject("component", "services.AuditionQuestionUserService")>
<cfset new_qID = service.INSaudquestions_user(
    new_qTypeID = new_qTypeID,
    new_qtext = new_qtext,
    new_qorder = new_qorder,
    new_userid = new_userid,
    new_isDeleted = new_isDeleted
)>