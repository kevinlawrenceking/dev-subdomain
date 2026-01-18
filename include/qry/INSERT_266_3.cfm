<cfset updateLogService = createObject("component", "services.UpdateLogService")>
<cfset updateLogService.INSupdatelog(
    oldvalue = "#oldvalue#",
    newvalue = "#newvalue#",
    recordname = "#recordname#",
    updatename = "#updatename#",
    recid = "#recid#",
    compid = "#compid#",
    userid = "#userid#",
    updatedetails = "#updatedetails#"
)>