<cfset actionUserService = createObject("component", "services.ActionUserService")>
<cfset actionUserService.addActionUsers(
    actionid = xs.actionid,
    userid = u.userid,
    actiondaysno = xs.actiondaysno,
    actiondaysrecurring = xs.actiondaysrecurring
)>