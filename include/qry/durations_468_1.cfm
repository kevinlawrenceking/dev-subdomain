<cfinclude template="/include/perfcount.cfm" />
<cfset meetingDurationService = createObject("component", "services.MeetingDurationService")>
<cfset durations = meetingDurationService.SELmtgdurations_24656()>