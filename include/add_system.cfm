<!--- This ColdFusion page manages system notifications and user actions based on specific criteria. --->
<cfparam name="add_count" default="0"/>
<cfparam name="systemID" default="0"/>
<cfparam name="mode" default="0"/>
<cfset suStartDate=dateFormat(Now(),'yyyy-mm-dd')/>
<cfset currentStartDate=dateFormat(Now(),'yyyy-mm-dd')/>

<!--- Delete any orphaned notifications of user that don't belong to a system --->
<cfinclude template="/include/qry/delSystemNotifications.cfm"/>

<!--- Add a system user record (returns existing suid if already enrolled) --->
<cfinclude template="/include/qry/addfuSystemUsers.cfm"/>

<!--- FIX #1630: Check if notifications already exist for this enrollment.
      If they do, skip the notification creation loop to prevent duplicates.
      This guards against double-enrollment from overlapping code paths
      (e.g., modalansweryes.cfm + add_system.cfm in the same audition flow). --->
<cfset var _existingNots = queryExecute(
    "SELECT notid FROM funotifications
     WHERE suid = ? AND notstatus = 'Pending'
     LIMIT 1",
    [ { value=NewSUID, cfsqltype="cf_sql_integer" } ]
)>
<cfif _existingNots.recordCount EQ 0>

<!--- Grab the list of action items for that particular system --->
<cfinclude template="/include/qry/getFuSystemUsersBySystemID.cfm"/>

<!--- Loop through all of the actions of a system. --->
<cfloop query="addDaysNo">
  <cfset add_action="Y"/>

  <!--- Check if the day is unique --->
  <cfif addDaysNo.isunique is "1">

    <!--- Include the query to check for unique contacts --->
    <cfinclude template="/include/qry/checkUnique_157_8.cfm"/>

    <!--- If a unique contact is found, set add_action to "N" --->
    <cfif checkUnique.recordcount is "1">

      <cfset add_action="N"/>

    </cfif>

  </cfif>

  <!--- If adding action is permitted --->
  <cfif add_action is "Y">

    <!--- Calculate the start date based on actionDaysNo and the current date --->
    <cfset newest_notstartdate=dateAdd('d', actionDaysNo, currentStartDate)/>
 
      <!--- Include the query to add a notification --->
      <cfinclude template="/include/qry/addNotification_326_1.cfm"/>
 
  </cfif>
</cfloop>

</cfif><!--- /FIX #1630: _existingNots guard --->

<!--- Redirect based on the mode parameter --->
<cfif mode is "0">
  <cflocation url="/app/contact/?contactid=#contactid#&t4=1"/>
</cfif>
