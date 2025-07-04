<!--- This ColdFusion page handles ticket status updates and sends email notifications when the status changes to "Implemented." --->
<!--- Ensure pgid has a default value if not provided --->
<cfif NOT isNumeric(pgid)>
    <cfset pgid = 0 />
</cfif>

<!--- Execute the update query --->
<cfinclude template="/include/qry/update_9_1.cfm" />

<!--- Set default email details --->
<cfset to_email = "cansoff@gmail.com" />
<cfset ismail = "Y" />

<!--- Check if the ticket status has changed --->
<cfif old_ticketstatus NEQ new_ticketstatus>
    <!--- Send email if status changes to "Implemented" --->
    <cfif old_ticketstatus NEQ "Implemented" AND new_ticketstatus EQ "Implemented">
        <cfset emailto = "cansoff@gmail.com" />
        <cfset emailcc = "jodie@jodiebentley.com, support@theactorsoffice.com" />
        <cfset emailsubject = "Ready for Testing Approval" />
        <cfset emailmessage = "Please review the Testing Script and approve for Testing." />
        <cfset emaillink = "https://#host#.theactorsoffice.com/app/testing/?recid=#ticketid#" />
        <cfset emaillinkname = "REVIEW" />

        <!--- Include the email template if email should be sent --->
        <cfif ismail EQ "Y">
            <cfinclude template="ticketemail.cfm" />
        </cfif>
    </cfif>
</cfif>

<!--- Redirect to the updated version record --->
<cflocation url="/app/version/?recid=#new_verid#" />
