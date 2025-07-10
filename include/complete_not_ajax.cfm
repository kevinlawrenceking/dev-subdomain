<!--- complete_not_ajax.cfm [UPDATED WITH DEBUG COUNTERS] --->
<cfparam name="hide_completed" default="Y" />
<cfparam name="src" default="c" />
<cfset dbug = "y" />

<cfset debugCounters = {
  selectedNotifications = 0,
  updatedNotifications = 0,
  insertedNotifications = 0,
  updatedContacts = 0,
  completedSystems = 0,
  createdMaintenanceSystems = 0
} />

<cfif isDefined('session.mocktoday')>
  <cfset currentStartDate = dateFormat(session.mocktoday, 'yyyy-mm-dd') />
<cfelse>
  <cfset currentStartDate = dateFormat(now(), 'yyyy-mm-dd') />
</cfif>

<cfif dbug EQ "Y">
  <cfoutput><h4>CurrentStartDate: #currentStartDate#</h4></cfoutput>
</cfif>

<!--- Get Notification Details --->
<cfinclude template="/include/qry/getNotificationByID.cfm" />
<cfset debugCounters.selectedNotifications = NotificationDetails.recordcount />

<!--- Set values from query --->
<cfset notstartdate = dateAdd('d', NotificationDetails.actionDaysRecurring, currentStartDate) />
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

<cfif NOT isDefined('notstatus')>
  <cfset notstatus = "Pending" />
</cfif>

<cfset notEndDate = dateFormat(now(), 'yyyy-mm-dd') />

<!--- Update Notification --->
<cfinclude template="/include/qry/updateNotificationCompleted.cfm" />
<cfset debugCounters.updatedNotifications++ />

<!--- Update Contact Unique if needed --->
<cfif notstatus NEQ "Pending" AND len(trim(uniquename))>
  <cfinclude template="/include/qry/updateContactUnique.cfm" />
  <cfset debugCounters.updatedContacts++ />
</cfif>

<!--- Add recurring notification if applicable --->
<cfif actionDaysRecurring NEQ 0>
  <cfset newest_notstartdate = dateAdd('d', actionDaysRecurring, currentStartDate) />
  <cfinclude template="/include/qry/addNotification.cfm" />
  <cfset debugCounters.insertedNotifications++ />
</cfif>

<!--- Check for next notification --->
<cfinclude template="/include/qry/getNotificationsBySystem.cfm" />
<cfif notsafter EQ 1>
  <cfloop query="notsnext">
    <cfset new_notstartdate = dateAdd('d', notsnext.actiondaysno, currentStartDate) />
    <cfinclude template="/include/qry/updateNotificationNext.cfm" />
    <cfset debugCounters.updatedNotifications++ />
  </cfloop>
<cfelse>
  <!--- Complete System --->
  <cfinclude template="/include/qry/updateSystemUserCompleted.cfm" />
  <cfset debugCounters.completedSystems++ />

  <!--- Check for Maintenance --->
  <cfinclude template="/include/qry/checkformaint_71_6.cfm" />
  <cfif checkformaint.recordcount EQ 0>
    <cfinclude template="/include/qry/addNotifications.cfm" />
    <cfinclude template="/include/qry/findSystemByScope.cfm" />
    <cfset session.ftom = "Y" />
    <cfinclude template="/include/add_system.cfm" />
    <cfset debugCounters.createdMaintenanceSystems++ />
    <cfset debugCounters.insertedNotifications++ />
  </cfif>
</cfif>

<!--- Final Debug Output --->
<cfif dbug EQ "Y">
  <cfoutput>
    <h3>Debug Summary</h3>
    <ul>
      <li>Selected Notifications: #debugCounters.selectedNotifications#</li>
      <li>Updated Notifications: #debugCounters.updatedNotifications#</li>
      <li>Inserted Notifications: #debugCounters.insertedNotifications#</li>
      <li>Updated Contacts: #debugCounters.updatedContacts#</li>
      <li>Completed Systems: #debugCounters.completedSystems#</li>
      <li>Maintenance Systems Created: #debugCounters.createdMaintenanceSystems#</li>
    </ul>
  </cfoutput>
  <cfabort>
</cfif>
