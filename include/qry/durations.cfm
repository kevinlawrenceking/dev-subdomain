<!--- Create an instance of the MeetingDurationService component --->
<cfset meetingDurationService = createObject("component", "services.MeetingDurationService")>

<!--- Call the SELdurations function to fetch all durations --->
<cfset durations = meetingDurationService.SELdurations()>
