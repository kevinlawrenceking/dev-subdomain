<!--- complete_not_ajax.cfm [UPDATED WITH DEBUG COUNTERS] --->
<cfparam name="hide_completed" default="Y" />
<cfparam name="src" default="c" />
<cfset dbug = "N" />

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
  <cfoutput>
    <h4>Check if session variable 'mocktoday' is defined and set currentStartDate accordingly</h4>
    <p>CurrentStartDate: #currentStartDate#</p>
  </cfoutput>
</cfif>

<!--- Get Notification Details --->
<cfinclude template="/include/qry/getNotificationByID.cfm" />
<cfset debugCounters.selectedNotifications = NotificationDetails.recordcount />

<cfif dbug EQ "Y"> 
  <h3>Get Notification Details</h3>
  <cfoutput>
    <p>
      SELECT su.contactid, su.userid, n.notid, s.systemid, s.systemscope AS newsystemscope, n.actionid, su.suID AS newsuid, au.actionDaysRecurring, a.uniquename, a.IsUnique, u.recordname AS new_contactname FROM funotifications n INNER JOIN fusystemusers su ON su.suid = n.suid INNER JOIN contactdetails c ON c.contactID = su.contactid INNER JOIN fusystems s ON s.systemID = su.systemID INNER JOIN actionusers au ON au.actionid = n.actionid INNER JOIN fuactions a ON a.actionid = au.actionid INNER JOIN taousers u ON u.userid = n.userid WHERE n.notID = #notid# AND au.userid = n.userid</p>
    <h4>Notification ID: #notid#</h4>
  </cfoutput>
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

<cfif dbug EQ "Y">
  <cfoutput>
    <p>
      <strong>Debug Output:</strong>
    </p>
    notstartdate: #notstartdate#<br/>
    Contact ID: #contactid#<br/>
    New Contact Name: #new_contactname#<br/>
    System ID: #systemid#<br/>
    User ID: #userid#<br/>
    Action ID: #actionid#<br/>
    New suID: #newsuid#<br/>
    New System Scope: #newsystemscope#<br/>
    Action Days Recurring: #actionDaysRecurring#<br/>
    Unique Name: #uniquename#<br/>
    Is Unique: #IsUnique#<br/>
  </cfoutput>
</cfif>

<cfif NOT isDefined('notstatus')>
  <cfset notstatus = "Pending" />
  <cfoutput>
    <p>notstatus isn't defined</p>
    notstatus: Pending<br/>
  </cfoutput>
</cfif>

<cfset notEndDate = dateFormat(now(), 'yyyy-mm-dd') />
<cfif dbug EQ "Y">
  <cfoutput>
    <p>notEndDate: #notEndDate#</p>
  </cfoutput>
</cfif>

<!--- Update Notification --->
<cfinclude template="/include/qry/updateNotificationCompleted.cfm" />
<cfset debugCounters.updatedNotifications++ />

<cfif dbug EQ "Y">
  <cfoutput>
    <p>
      UPDATE funotifications<br/>
      SET notStatus = '#notstatus#'<br/>
      <cfif len(trim(notstartdate))>
        , notstartdate = '#notstartdate#'<br/>
      </cfif>
      <cfif notstatus EQ "Completed" OR notstatus EQ "Skipped">
        , notenddate = #notEndDate#<br/>
      </cfif>
      WHERE notid = #notid#<br/>
    </p>
  </cfoutput>
</cfif>

<!--- Update Contact Unique if needed --->
<cfif notstatus NEQ "Pending" AND len(trim(uniquename))>
  <cfif dbug EQ "Y">
    <cfoutput>
      Update the Contact's #uniquename# to Yes.<br/>
    </cfoutput>
  </cfif>
  <cfinclude template="/include/qry/updateContactUnique.cfm" />
  <cfset debugCounters.updatedContacts++ />
  <cfif dbug EQ "Y">
    <cfoutput>
      <h4>Notification completed!</h4>
      <p>UPDATE contactdetails SET #uniquename# = 'Y' WHERE contactid = #contactid#</p>
    </cfoutput>
  </cfif>
</cfif>

<!--- Add recurring notification if applicable --->
<cfif actionDaysRecurring NEQ 0>
  <cfif dbug EQ "Y">
    <cfoutput>
      <p>Its recurring every #actiondaysrecurring# days</p>
    </cfoutput>
  </cfif>
  <cfset newest_notstartdate = dateAdd('d', actionDaysRecurring, currentStartDate) />
  <cfif dbug EQ "Y">
    <cfoutput><p>Next start date for this recurring item is #newest_notstartdate#</p></cfoutput>
    <cfoutput><p>Add a recurring notification</p></cfoutput>
  </cfif>
  <cfinclude template="/include/qry/addNotification.cfm" />
  <cfset debugCounters.insertedNotifications++ />
  <cfif dbug EQ "Y">
    <cfoutput>
      actionID: #NotificationDetails.actionID#<br/>
      userid: #userid#<br/>
      suid: #newsuid#<br/>
      notstartdate: #newest_notstartdate#<br/>
      notstatus: "Pending"<br/>
    </cfoutput>
  </cfif>
<cfelse>
  <cfif dbug EQ "Y">
    <p>Its not recurring....</p>
  </cfif>
</cfif>

<!--- Check for next notification --->
<cfinclude template="/include/qry/getNotificationsBySystem.cfm" />

<cfif dbug EQ "Y">
  <cfoutput>
    <h4>Find Next notification</h4>
    <pre>SELECT 
            n.notID, 
            n.actionID, 
            n.userID, 
            n.suID, 
            n.notTimeStamp, 
            n.notStartDate, 
            n.notEndDate, 
            n.notStatus, 
            n.notNotes, 
            f.systemID, 
            f.contactID, 
            f.suTimeStamp, 
            f.suStartDate, 
            f.suEndDate, 
            f.suStatus, 
            f.suNotes, 
            a.actionID, 
            a.actionNo, 
            a.actionDetails, 
            a.actionTitle, 
            a.navToURL, 
            au.actionDaysNo, 
            au.actionDaysRecurring, 
            a.actionNotes, 
            a.actionInfo, 
            n.ispastdue, 
            ns.checktype, 
            ns.delstart, 
            ns.delend, 
            ns.status_color 
        FROM 
            funotifications n 
        INNER JOIN 
            fusystemusers f ON f.suID = n.suID 
        INNER JOIN 
            fuactions a ON a.actionID = n.actionID 
        INNER JOIN 
            actionusers au ON a.actionID = au.actionID 
        INNER JOIN 
            notstatuses ns ON ns.notstatus = n.notStatus 
        WHERE 
            n.suID = #newsuid#
            AND au.userID = f.userID 
            AND n.notStatus = 'Pending' 
            AND n.notStartDate IS NULL 
 
            ORDER BY a.actionno, a.actionID
        LIMIT 1</pre>
  </cfoutput>
</cfif>

<cfif notsafter EQ 1>
  <cfif dbug EQ "Y">
    <cfoutput><h4>Next record found!</h4>
notsnext.recordcount: #notsnext.recordcount#
<br/>
</cfoutput>
  </cfif>
  <cfloop query="notsnext">
    <cfset new_notstartdate = dateAdd('d', notsnext.actiondaysno, currentStartDate) />
      <cfif dbug EQ "Y">
      <cfoutput>
        new_notstartdate: #new_notstartdate#<br/>
      </cfoutput>
    </cfif>
    <cfinclude template="/include/qry/updateNotificationNext.cfm" />
    <cfset debugCounters.updatedNotifications++ />
    <cfif dbug EQ "Y">
      <cfoutput>
        UPDATE funotifications<br>
        SET <br>
            notStatus = 'Pending'<br>
            <cfif #new_notstartdate# IS NOT ""> 
                , notstartdate = '#new_notstartdate#'<br>
            </cfif><br>
            <cfif notstatus EQ "Completed" OR notstatus EQ "Skipped"><br>
                , notenddate = '#notEndDate#'<br>
            </cfif>
        WHERE notid = #notid#<br>

        <br/>New start date will be #dateFormat(new_notstartdate, 'yyyy-mm-dd')#<br/>
        UPDATE funotifications SET notStatus = 'Pending', notstartdate = '#new_notstartdate#' WHERE notid = #notsnext.notid#<br/>
      </cfoutput>
    </cfif>
  </cfloop>
<cfelse>
  <!--- Complete System --->
  <cfinclude template="/include/qry/updateSystemUserCompleted.cfm" />
  <cfset debugCounters.completedSystems++ />
  <cfif dbug EQ "Y">
    <cfoutput>
      UPDATE fusystemusers SET suStatus = 'Completed' WHERE suid = #newsuid#<br/>
    </cfoutput>
  </cfif>

  <!--- Check for Maintenance --->
  <cfinclude template="/include/qry/checkformaint_71_6.cfm" />
  <cfif dbug EQ "Y">
    <cfoutput>
    <PRE>        SELECT fc.suID 
        FROM fusystemusers fc 
        INNER JOIN fusystems s ON s.systemID = fc.systemID 
        WHERE fc.contactid = #contactid#
        AND s.systemtype = 'Maintenance List'
        AND fc.userid = #userid#</PRE><br>
    
    
    
    <p>Check if a maintenance record exists</p></cfoutput>
  </cfif>

  <cfif checkformaint.recordcount EQ 0>
    <cfif dbug EQ "Y">
      <cfoutput>
        checkformaint.recordcount: #checkformaint.recordcount#<br> 
      </cfoutput>
    </cfif>

    <!--- Set required variables for addNotifications.cfm --->
    <cfset subtitle = "Maintenance system created for contact: #new_contactname#" />
    
    <cfinclude template="/include/qry/addNotifications.cfm" />
    <cfinclude template="/include/qry/findSystemByScope.cfm" />
    <cfset session.ftom = "Y" />
    <cfinclude template="/include/add_system.cfm" />
    <cfset debugCounters.createdMaintenanceSystems++ />
    <cfset debugCounters.insertedNotifications++ />
    <cfif dbug EQ "Y">
      <cfoutput>
        <p>No maintenance record!</p>
        <p>Added notification</p>
        <p>Found the proper system id.</p>
        <p>Added new maintenance system!</p>
      </cfoutput>
    </cfif>
  </cfif>
</cfif>

<!--- Final Debug Summary --->
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
