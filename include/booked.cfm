<!--- This ColdFusion page handles redirection after updating audition details --->
<cfinclude template="/include/qry/update_56_1.cfm" />

<cfoutput>
    <!--- Set the return URL for redirection based on parameters --->
    <!--- booked=1 signals audition.cfm to fire the one-shot confetti animation. --->
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&eventid=#eventid#&secid=#secid#&booked=1" />
</cfoutput>

<!--- Redirect to the specified return URL --->
<cflocation url="#returnurl#">
