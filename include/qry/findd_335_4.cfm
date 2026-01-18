<cfset meetingDurationService=createObject("component", "services.MeetingDurationService") />

<Cfif eventdetails.new_durhours eq "">

  <cfset new_durhours=1 />

<Cfelse>

  <cfset new_durhours=eventdetails.new_durhours />

</cfif>

<cfset findd=meetingDurationService.SELmtgdurations_24493(new_durhours=new_durhours) />
