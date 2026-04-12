<cfinclude template="/include/perfcount.cfm" />
<cfset durationService = createObject("component", "services.MeetingDurationService")>
<cfset duration = durationService.SELmtgdurations_24655(new_durid=new_durid)>