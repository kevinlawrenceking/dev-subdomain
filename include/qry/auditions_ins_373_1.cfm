<cfset eventService = createObject("component", "services.EventService")>

<!--- Default handling for integers --->
<cfif NOT len(trim(new_audRoleID))><cfset new_audRoleID = 0></cfif>
<cfif NOT len(trim(new_audTypeID))><cfset new_audTypeID = 0></cfif>
<cfif NOT len(trim(new_audplatformid))><cfset new_audplatformid = 0></cfif>
<cfif NOT len(trim(new_audStepID))><cfset new_audStepID = 0></cfif>

<!--- Default handling for dates --->
<cfif NOT len(trim(new_eventStart))><cfset new_eventStart = "1970-01-01"></cfif>

<!--- Default handling for times --->
<cfif NOT len(trim(new_eventStartTime))><cfset new_eventStartTime = "00:00:00"></cfif>
<cfif NOT len(trim(new_durseconds))><cfset new_durseconds = "0"></cfif>

<cfset new_eventid = eventService.INSevents_24555(
    new_userid = new_userid,
    new_audRoleID = new_audRoleID,
    new_audTypeID = new_audTypeID,
    new_audLocation = new_audLocation,
    new_eventStart = new_eventStart,
    new_eventStartTime = new_eventStartTime,
    new_eventStopTime = new_eventStopTime,
    new_durseconds = new_durseconds,
    new_audplatformid = new_audplatformid,
    new_audStepID = new_audStepID,
    new_parkingDetails = new_parkingDetails,
    new_workwithcoach = new_workwithcoach,
    new_trackmileage = new_trackmileage,
    new_eventtitle = variables.new_eventtitle
)>
