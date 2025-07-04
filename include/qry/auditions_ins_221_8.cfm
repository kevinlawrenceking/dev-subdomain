<cfset eventService = createObject("component", "services.EventService")>

<cfset dynamicArgs = structNew()>

<!--- Always include required arguments --->
<cfset dynamicArgs.new_userid = new_userid>

<!--- Conditionally add optional arguments --->
<cfif isNumeric(new_audRoleID)>
    <cfset dynamicArgs.new_audRoleID = new_audRoleID>
</cfif>
<cfif isNumeric(new_audTypeID)>
    <cfset dynamicArgs.new_audTypeID = new_audTypeID>
</cfif>
<cfif len(trim(new_audLocation))>
    <cfset dynamicArgs.new_audLocation = new_audLocation>
</cfif>
<cfif isDate(new_eventStart)>
    <cfset dynamicArgs.new_eventStart = new_eventStart>
</cfif>
<cfif len(trim(new_eventStartTime))>
    <cfset dynamicArgs.new_eventStartTime = new_eventStartTime>
</cfif>
<cfif len(trim(new_durseconds))>
    <cfset dynamicArgs.new_durseconds = new_durseconds>
</cfif>
<cfif isNumeric(new_audplatformid)>
    <cfset dynamicArgs.new_audplatformid = new_audplatformid>
</cfif>
<cfif isNumeric(new_audStepID)>
    <cfset dynamicArgs.new_audStepID = new_audStepID>
</cfif>
<cfif len(trim(new_parkingDetails))>
    <cfset dynamicArgs.new_parkingDetails = new_parkingDetails>
</cfif>
<cfif isBoolean(new_workwithcoach)>
    <cfset dynamicArgs.new_workwithcoach = new_workwithcoach>
</cfif>
<cfif isBoolean(new_trackmileage)>
    <cfset dynamicArgs.new_trackmileage = new_trackmileage>
</cfif>
<cfif isNumeric(new_audlocid)>
    <cfset dynamicArgs.new_audlocid = new_audlocid>
</cfif>

<!--- Call the function with argumentCollection --->
<cfset result = eventService.INSevents_24096(argumentCollection=dynamicArgs)>
