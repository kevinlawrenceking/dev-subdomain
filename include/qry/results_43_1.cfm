<cfset eventService = createObject("component", "services.EventService")>

<!--- Ensure required variables are defined --->
<cfif NOT structKeyExists(variables, "audroleid") OR NOT isNumeric(audroleid)>
    <cfset audroleid = 0>
</cfif>

<cfif NOT structKeyExists(variables, "eventid") OR NOT isNumeric(eventid)>
    <cfset eventid = 0>
</cfif>

<cfif NOT structKeyExists(variables, "userid") OR NOT isNumeric(userid)>
    <cfset userid = 0>
</cfif>

<!--- Optional currentid --->
<cfif NOT structKeyExists(variables, "currentid") OR NOT isNumeric(currentid)>
    <cfset currentid = "0">
</cfif>

<!--- Call the RESevents function --->
<cfset results = eventService.RESevents(
    audroleid = audroleid,
    eventid = eventid,
    userid = userid,
    currentid = currentid
)>
