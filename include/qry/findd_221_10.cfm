<cfinclude template="/include/perfcount.cfm" />

<cfset meetingDurationService = createObject("component", "services.MeetingDurationService")>
<cfset findd = meetingDurationService.SELmtgdurations(new_durhours=new_durhours)>