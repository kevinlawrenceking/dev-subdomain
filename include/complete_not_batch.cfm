<!--- complete_not_batch.cfm - Batch process multiple notifications --->
<cfsetting showdebugoutput="false">
<cfcontent type="application/json">

<cfparam name="hide_completed" default="Y" />
<cfparam name="src" default="c" />
<cfparam name="form.notids" default="" />
<cfparam name="url.notids" default="" />
<cfparam name="form.notstatus" default="" />
<cfparam name="url.notstatus" default="" />

<!--- Handle both form and URL parameters --->
<cfif len(trim(form.notids))>
  <cfset notids = form.notids />
<cfelseif len(trim(url.notids))>
  <cfset notids = url.notids />
<cfelse>
  <cfoutput>{"error": "notids parameter is required but was not provided"}</cfoutput>
  <cfabort>
</cfif>

<cfif len(trim(form.notstatus))>
  <cfset notstatus = form.notstatus />
<cfelseif len(trim(url.notstatus))>
  <cfset notstatus = url.notstatus />
<cfelse>
  <cfset notstatus = "Pending" />
</cfif>

<!--- Convert comma-separated IDs to array --->
<cfset notidList = listToArray(notids, ",") />

<!--- Track results --->
<cfset results = {
  success = true,
  processed = 0,
  failed = 0,
  errors = []
} />

<!--- Get current date --->
<cfif isDefined('session.mocktoday')>
  <cfset currentStartDate = dateFormat(session.mocktoday, 'yyyy-mm-dd') />
<cfelse>
  <cfset currentStartDate = dateFormat(now(), 'yyyy-mm-dd') />
</cfif>

<cfset notEndDate = dateFormat(now(), 'yyyy-mm-dd') />

<!--- PERF: Batch-fetch all notification details in one query instead of N queries --->
<cfif len(trim(notids))>
  <cfset notificationService = request.svc("NotificationService")>
  <cfset allNotificationDetails = notificationService.GetNotificationsByIDList(notids=notids)>
<cfelse>
  <cfset allNotificationDetails = queryNew("contactid,userid,notid,systemid,newsystemscope,actionid,newsuid,actionDaysRecurring,uniquename,IsUnique,new_contactname")>
</cfif>

<!--- Process each notification --->
<cfloop array="#notidList#" index="notid">
  <cftry>
    <cfset notid = trim(notid) />

    <!--- Skip empty values --->
    <cfif not len(notid) or not isNumeric(notid)>
      <cfcontinue />
    </cfif>

    <!--- Get Notification Details --->
    <!--- Filter batch-fetched results for this notification --->
    <cfquery name="NotificationDetails" dbtype="query">
        SELECT * FROM allNotificationDetails WHERE notid = <cfqueryparam value="#notid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif NotificationDetails.recordcount EQ 0>
      <cfset arrayAppend(results.errors, "Notification #notid# not found") />
      <cfset results.failed++ />
      <cfcontinue />
    </cfif>

    <!--- Set values from query --->
    <cfset safeRecurringDays = val(NotificationDetails.actionDaysRecurring) />
    <cfset notstartdate = dateAdd('d', safeRecurringDays, currentStartDate) />

    <cfset contactid = NotificationDetails.contactid />
    <cfset new_contactname = NotificationDetails.new_contactname />
    <cfset systemid = NotificationDetails.systemid />
    <cfset userid = NotificationDetails.userid />
    <cfset actionid = NotificationDetails.actionid />
    <cfset newsuid = NotificationDetails.newsuid />
    <cfset newsystemscope = NotificationDetails.newsystemscope />
    <cfset actionDaysRecurring = safeRecurringDays />
    <cfset uniquename = NotificationDetails.uniquename />
    <cfset IsUnique = NotificationDetails.IsUnique />

    <!--- Transaction per notification — partial failure for one does not corrupt others --->
    <cftransaction>

    <!--- Update Notification --->
    <cfinclude template="/include/qry/updateNotificationCompleted.cfm" />

    <!--- Update Contact Unique if needed --->
    <cfif notstatus NEQ "Pending" AND len(trim(uniquename))>
      <cfinclude template="/include/qry/updateContactUnique.cfm" />
    </cfif>

    <!--- Add recurring notification if applicable --->
    <cfif actionDaysRecurring NEQ 0>
      <cfset newest_notstartdate = dateAdd('d', actionDaysRecurring, currentStartDate) />
      <cfinclude template="/include/qry/addNotification.cfm" />
    </cfif>

    <!--- Check for next notification --->
    <cfinclude template="/include/qry/getNotificationsBySystem.cfm" />

    <cfif notsafter EQ 1>
      <cfloop query="notsnext">
        <cfset new_notstartdate = dateAdd('d', notsnext.actiondaysno, currentStartDate) />
        <cfinclude template="/include/qry/updateNotificationNext.cfm" />
      </cfloop>
    <cfelse>
      <!--- Complete System --->
      <cfinclude template="/include/qry/updateSystemUserCompleted.cfm" />

      <!--- Check for Maintenance --->
      <cfinclude template="/include/qry/checkformaint_71_6.cfm" />

      <cfif checkformaint.recordcount EQ 0>
        <!--- Set required variables for addNotifications.cfm --->
        <cfset subtitle = "Maintenance system created for contact: #new_contactname#" />

        <cfinclude template="/include/qry/addNotifications.cfm" />
        <cfinclude template="/include/qry/findSystemByScope.cfm" />
        <cfset session.ftom = "Y" />
        <cfinclude template="/include/add_system.cfm" />
      </cfif>
    </cfif>

    </cftransaction>

    <cfset results.processed++ />

    <cfcatch type="any">
      <cfset arrayAppend(results.errors, "Error processing #notid#: #cfcatch.message#") />
      <cfset results.failed++ />
    </cfcatch>
  </cftry>
</cfloop>

<!--- Set overall success based on results --->
<cfif results.failed GT 0 AND results.processed EQ 0>
  <cfset results.success = false />
</cfif>

<!--- Return JSON response --->
<cfoutput>#serializeJSON(results)#</cfoutput>
