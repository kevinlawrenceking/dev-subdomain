<cfset auditionQuestionUserService = createObject("component", "services.AuditionQuestionUserService")>
<cfset auditionQuestionUserService.UPDaudquestions_user(
    new_qTypeID=new_qTypeID,
    new_qtext=new_qtext,
    new_qorder=new_qorder,
    new_userid=new_userid,
    new_isDeleted=new_isDeleted,
    new_qID=new_qID
)>
