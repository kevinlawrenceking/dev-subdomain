<!--- This ColdFusion page processes notifications based on session data and includes various query templates for handling notifications and system updates. --->

<cfif isdefined('session.mocktoday')>
    <!--- Check if session.mocktoday is defined and set currentStartDate accordingly --->
    <Cfset currentStartDate = DateFormat(session.mocktoday, 'yyyy-mm-dd') />
</cfif>

<cfif NOT isdefined('session.mocktoday')>
    <!--- If session.mocktoday is not defined, set currentStartDate to the current date --->
    <Cfset currentStartDate = DateFormat(Now(), 'yyyy-mm-dd') />
</cfif>

<cfinclude template="/include/qry/getNotificationById.cfm" />

<!--- Calculate the notification start date based on actionDaysRecurring --->
<cfset notstartdate = dateAdd('d', numberformat(NotificationDetails.actionDaysRecurring), currentStartDate) />

<cfoutput>
    <!--- Set various notification-related variables from the NotificationDetails query --->
    <cfset contactid = NotificationDetails.contactid />
    <cfset new_contactname = NotificationDetails.new_contactname />
    <cfset systemid = NotificationDetails.systemid />
    <cfset userid = NotificationDetails.userid />
    <cfset actionid = NotificationDetails.actionid />
    <cfset newsuid = NotificationDetails.newsuid />
    <cfset newsystemscope = NotificationDetails.newsystemscope />
    <cfset actionDaysRecurring = NotificationDetails.actionDaysRecurring />
    <cfset uniquename = NotificationDetails.uniquename />
    <cfset IsUnique = NotificationDetails.IsUnique />
    
    <!--- Initialize notification status as "Skipped" --->
    <Cfset notstatus = "Skipped" />
    
    <!--- Set the notification end date to the current date --->
    <cfset notEndDate = DateFormat(Now(), 'yyyy-mm-dd') />
</cfoutput>

<cfinclude template="/include/qry/addNotification_72_1.cfm" />

<cfif notstatus is not "Pending" and uniquename is not "">
    <!--- If the notification status is not "Pending" and the unique name is not empty, include updateContact template --->
    <cfinclude template="/include/qry/updateContact_72_2.cfm" />
</cfif>

<Cfif numberformat(actionDaysRecurring) is not "0">
    <!--- If actionDaysRecurring is not zero, calculate the newest notification start date and include addNotification template --->
    <cfset newest_notstartdate = dateAdd('d', numberformat(actionDaysRecurring), currentStartDate) />
    <cfinclude template="/include/qry/addNotification_71_3.cfm" />
</Cfif>

<cfinclude template="/include/qry/notsnext.cfm" />

<!--- Get the record count of notifications after the current one --->
<cfset notsafter = numberformat(notsnext.recordcount) />
<cfoutput>notsafter: #notsafter#</cfoutput>

<cfif notsafter is "1">
    <!--- If there is one notification after, loop through the results --->
    <cfloop query="notsnext">
        <cfset new_notstartdate = dateAdd('d', numberformat(notsnext.actiondaysno), currentStartDate) />
        <cfinclude template="/include/qry/updatesystem_72_4.cfm" />
    </cfloop>
</cfif>

<cfif notsafter is "0">
    <!--- If there are no notifications after, include various templates for system updates and checks --->
    <cfinclude template="/include/qry/updatesystem_72_5.cfm" />
    <cfinclude template="/include/qry/checkformaint_72_6.cfm" />
    
    <cfif checkformaint.recordcount is "0">
        <!--- If there are no maintenance records, find the system and potentially insert it --->
        <cfinclude template="/include/qry/findSystem_71_7.cfm" />
        
        <cfif findsystem.recordcount is "1">
            <cfset systemid = findsystem.systemid />
            <cfinclude template="/include/qry/Insert_72_8.cfm" />
            <cfset session.ftom = "Y" />
            <cfset mode = "1" />
            <cfinclude template="/include/add_system.cfm" />
        </cfif>
    </cfif>
</cfif>
