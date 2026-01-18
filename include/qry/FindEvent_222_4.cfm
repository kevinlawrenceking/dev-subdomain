

<Cfset eventService = createObject("component", "services.EventService")>
 
<cfif NOT len(trim(new_eventStart))>
    <cfset new_eventStart = "1970-01-01">  
</cfif>

<cfif NOT len(trim(new_eventStartTime))>
    <cfset new_eventStartTime = "00:00:00">  
</cfif>

<cfif NOT len(trim(new_eventStopTime))>
    <cfset new_eventStopTime = "00:00:00">  
</cfif>
<cfset eventService.SELevents_24105(
    new_eventid=new_eventid,
    new_eventStart=new_eventstart,
    new_eventStartTime=new_eventStartTime,
    new_durseconds=new_durseconds
)>
<cfoutput>#new_eventStopTime#</cfoutput> 