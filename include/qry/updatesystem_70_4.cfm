<!--- This ColdFusion page updates the notification status in the funotifications table based on certain conditions. --->

<cfquery name="updatesystem">
    <!--- Update funotifications set notstatus to 'Pending' --->
    Update funotifications
    set notstatus = 'Pending'
    
    <!--- Check if new_notstartdate is empty --->
    <cfif #notsnext.notstartdate# is "">
        , notstartdate = '#DateFormat(new_notstartdate, 'yyyy-mm-dd')#'
    </cfif>
    
    <!--- Specify the notification ID to update --->
    where notid = #notsnext.notid#
</cfquery>
