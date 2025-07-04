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

<cfoutput>
    <cfif #focusid# is "">
        <!--- If no focus ID is provided, redirect to the audition page --->
        <cflocation url="/app/audition/?audprojectid=#audprojectid#" />
    <cfelse>
        <!--- If a focus ID is provided, redirect to the audition page as well --->
        <cflocation url="/app/audition/?audprojectid=#audprojectid#" />
    </cfif>
</cfoutput>
