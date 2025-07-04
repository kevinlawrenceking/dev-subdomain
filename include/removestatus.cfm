<!--- This ColdFusion page handles the booking status and redirects based on focus ID --->
<cfif #statusfield# is "isBooking">
    <!--- Check if the status field indicates a booking and update it to 'isBooked' --->
    <cfset statusfield = "isBooked" />
</cfif>

<!--- Include the update query template --->
<cfinclude template="/include/qry/update_68_1.cfm" />

<!--- Set default value for focusid if not provided --->
<cfparam name="focusid" default="" />

<cfoutput>
    <!--- Check if focusid is empty and redirect accordingly --->
    <cfif #focusid# is "">
        <cflocation url="/app/audition/?audprojectid=#audprojectid#" />
    <cfelse>
        <cflocation url="/app/audition/?audprojectid=#audprojectid#&focusid=#focusid#" />
    </cfif>
</cfoutput>

