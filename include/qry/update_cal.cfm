<cfset userService = createObject("component", "services.userService")>

<!--- Example of variables for the function call --->


<!--- Call the function --->
<cfset rowsAffected = userService.update_cal(
    userid = userid,
    calstarttime = form.calstarttime,
    calendtime = form.calendtime,
    defRows = form.defRows,
    viewtypeid = form.viewtypeid,
    dateformatid = form.dateformatid,
    tzid = form.tzid
)>
<cfoutput>
    <p>Rows Updated: #rowsAffected#</p>
</cfoutput>
