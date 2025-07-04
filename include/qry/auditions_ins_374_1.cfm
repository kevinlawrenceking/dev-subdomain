<cfset eventService = createObject("component", "services.EventService")>

<!--- Prepare required arguments --->
<cfset eventArguments = {
    new_userid = new_userid,
    new_audRoleID = new_audRoleID,
    new_audTypeID = new_audTypeID,
    new_audBookTypeID = new_audBookTypeID,
    new_audLocation = new_audLocation,
    new_eventLocation = new_eventLocation,
    new_audlocadd1 = new_audlocadd1,
    new_audlocadd2 = new_audlocadd2,
    new_audcity = new_audcity,
    new_region_id = new_region_id,
    new_audzip = new_audzip,
    new_audStepID = new_audStepID,
    new_parkingDetails = trim(new_parkingDetails),
    new_workwithcoach = new_workwithcoach,
    new_trackmileage = new_trackmileage,
    new_isDeleted = new_isDeleted,
    new_eventid = new_eventid,
    new_durseconds = new_durseconds
}>

<!--- Include optional numeric arguments if numeric --->
<cfif isNumeric(new_audplatformid)>
    <cfset eventArguments["new_audplatformid"] = new_audplatformid>
</cfif>
<cfif isNumeric(new_callbacktypeid)>
    <cfset eventArguments["new_callbacktypeid"] = new_callbacktypeid>
</cfif>

<!--- Include optional date arguments if valid date --->
 
    <cfset eventArguments["new_eventStart"] = new_eventStart>
 
 
    <cfset eventArguments["new_eventStartTime"] = new_eventStartTime>
 
    <cfset eventArguments["new_durseconds"] = new_durseconds>
 
<cfoutput>were now here: #new_durseconds#</cfoutput>
<!--- Call the function with filtered arguments --->
<cfset eventService.UPDevents_24557(argumentCollection=eventArguments)>

