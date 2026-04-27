<!--- This ColdFusion page handles booking status updates and redirects based on user actions. --->

<cfif #statusfield# is "isBooking">
    <!--- Check if the status field indicates a booking action --->
    <cfset statusfield = "isBooked" />
</cfif>

<cfif #pgaction# is "cancel">
    <!--- If the action is to cancel, include the appropriate update query --->
    <cfinclude template="/include/qry/update_68_1.cfm" />
<cfelse>
    <!--- Otherwise, include the alternative update query --->
    <cfinclude template="/include/qry/update_68_2.cfm" />
</cfif>

<cfparam name="focusid" default="" />

<!--- booked=1 signals audition.cfm to fire the one-shot confetti animation.
      Only append it when transitioning TO booked, not on cancel. --->
<cfset bookedFlag = (statusfield eq "isBooked" and pgaction neq "cancel") ? "&booked=1" : "" />

<cfoutput>
    <cflocation url="/app/audition/?audprojectid=#audprojectid##bookedFlag#" />
</cfoutput>
