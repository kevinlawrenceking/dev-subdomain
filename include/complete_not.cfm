<!--- This ColdFusion page processes notifications and updates system information based on user input and session data. --->

<cfparam name="src" default="c"/>
<cfset dbug="N"/>

<!--- Check if session variable 'mocktoday' is defined and set currentStartDate accordingly --->
<cfif #isdefined('session.mocktoday')#>
  <Cfset currentStartDate="#DateFormat(session.mocktoday,'yyyy-mm-dd')#"/>
<cfelse>
  <Cfset currentStartDate="#DateFormat(Now(),'yyyy-mm-dd')#"/>
</cfif>

<cfif #dbug# is "Y">
  <cfoutput>
    <h4>Check if session variable 'mocktoday' is defined and set currentStartDate accordingly
    </h4>
    <p>CurrentStartDate: #currentStartDate#</p>
  </cfoutput>
</cfif>

<!--- Get the notification details --->
<cfinclude template="/include/qry/getNotificationByID.cfm"/>

<cfif #dbug# is "Y">
  <h3>Get Notification Details</h3>
  <Cfoutput>
    <p>
      SELECT su.contactid, su.userid, n.notid, s.systemid, s.systemscope AS newsystemscope, n.actionid, su.suID AS newsuid, au.actionDaysRecurring, a.uniquename, a.IsUnique, u.recordname AS new_contactname FROM funotifications n INNER JOIN fusystemusers su ON su.suid = n.suid INNER JOIN contactdetails c ON c.contactID = su.contactid INNER JOIN fusystems s ON s.systemID = su.systemID INNER JOIN actionusers au ON au.actionid = n.actionid INNER JOIN fuactions a ON a.actionid = au.actionid INNER JOIN taousers u ON u.userid = n.userid WHERE n.notID = #notid# AND au.userid = n.userid</p>
    <h4>Notification ID: #notid#</h4>
  </cfoutput>
</cfif>
<!--- Calculate the start date for notifications based on actionDaysRecurring --->
<cfset notstartdate=dateAdd('d', numberformat(NotificationDetails.actionDaysRecurring), currentStartDate)/>

<!--- Set various contact and notification details from the query results --->
<cfset contactid="#NotificationDetails.contactid#"/>
<cfset new_contactname="#NotificationDetails.new_contactname#"/>
<cfset systemid="#NotificationDetails.systemid#"/>
<cfset userid="#NotificationDetails.userid#"/>
<cfset actionid="#NotificationDetails.actionid#"/>
<cfset newsuid=#NotificationDetails.newsuid#/>
<cfset newsystemscope="#NotificationDetails.newsystemscope#"/>
<cfset actionDaysRecurring="#NotificationDetails.actionDaysRecurring#"/>
<cfset uniquename="#NotificationDetails.uniquename#"/>
<cfset IsUnique="#NotificationDetails.IsUnique#"/>

<cfif dbug eq "Y">
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

<!--- Set default notification status if not defined --->
<cfif NOT #isdefined('notstatus')#>
  <Cfset notstatus="Pending"/>
  <p>notstatus isn't defined</p>
  notstatus: Pending<br/>
</cfif>

<cfset notEndDate="#DateFormat(Now(),'yyyy-mm-dd')#"/>
<Cfoutput>
  notEndDate: #notEndDate#<br/>

</cfoutput>

<!--- Include the add notification query --->
<cfinclude template="/include/qry/updateNotificationCompleted.cfm"/>
<cfif #dbug# is "Y">

  <cfoutput>
    <p>
      UPDATE funotifications<br/>
      SET notStatus = '#notstatus#'<br/>
      <cfif len(trim(notstartdate))>
        , notstartdate = '#notstartdate#<br/>
      </cfif>
      <cfif notstatus EQ "Completed" OR notstatus EQ "Skipped">
        , notenddate = #notendDate#<br/>
      </cfif>
      WHERE notid = #notid#<br/></p>

  </cfoutput>
</cfif>

<!--- If notstatus is not "Pending" and uniquename is not empty, update contact --->
<cfif #notstatus# is not "Pending" and #uniquename#is not "">

  <cfif #dbug# is "Y">
    <Cfoutput>
      Update the Contact's #uniquename# to Yes.<br/>
    </cfoutput>
  </cfif>

  <cfinclude template="/include/qry/updateContactUnique.cfm"/>

  <cfif #dbug# is "Y">
    <Cfoutput>
    <h4>Notification completed!</h4>
      <p>
        UPDATE contactdetails SET #uniquename# = 'Y' WHERE contactid = #contactid#</p>
    </cfoutput>
  </cfif>

</cfif>

<CFIF #DBUG# IS "y">
  <h4>Check to see if action item is recurring....</h4>
</cfif>
<!--- If actionDaysRecurring is not zero, calculate the newest start date and add notification --->
<Cfif #numberformat(actionDaysRecurring)# is not "0">
  <CFIF #DBUG# IS "y">
    <p>Its recurring every
      <cfoutput>#actiondaysrecurring#</cfoutput>
      days</p>
  </cfif>

  <cfset newest_notstartdate=dateAdd('d', numberformat(actionDaysRecurring), currentStartDate)/>

  <CFIF #DBUG# IS "y">
    <p>Next start date for this recurring item is
      <cfoutput>#newest_notstartdate#</cfoutput>
    </p>
  </cfif>
  <CFIF #DBUG# IS "y">
    <p>Add a recurring notification</p>
  </cfif>
  <cfinclude template="/include/qry/addNotification.cfm"/>
  <CFIF #DBUG# IS "y">
    <Cfoutput>
      actionID; #NotificationDetails.actionID#<BR/>
      userid: #userid#<BR/>
      suid: #NewSuid#<BR/>
      notstartdate: #newest_notstartdate#<BR/>
      notstatus : "Pending"<BR/>

    </cfoutput>
  </cfif>
<Cfelse>
  <!--- It's not --->
  <CFIF #DBUG# IS "y">
    <p>Its not recurring....</p>
  </cfif>
</Cfif>

<!--- Include the next notifications query --->
<cfinclude template="/include/qry/getNotificationsBySystem.cfm"/>

<Cfif #dbug# is "Y">
  <Cfoutput>
    <h4>Find Next notification</h4>
    SELECT n.notID, n.actionID, n.userID, n.suID, n.notTimeStamp, n.notStartDate, n.notEndDate, n.notStatus, n.notNotes, f.systemID, f.contactID, f.suTimeStamp, f.suStartDate, f.suEndDate, f.suStatus, f.suNotes, a.actionID, a.actionNo, a.actionDetails, a.actionTitle, a.navToURL, au.actionDaysNo, au.actionDaysRecurring, a.actionNotes, a.actionInfo, n.ispastdue, ns.checktype, ns.delstart, ns.delend, ns.status_color FROM funotifications n
    <BR/>
    INNER JOIN fusystemusers f ON f.suID = n.suID
    <BR/>
    INNER JOIN fuactions a ON a.actionID = n.actionID
    <BR/>
    INNER JOIN actionusers au ON a.actionID = au.actionID
    <BR/>
    INNER JOIN notstatuses ns ON ns.notstatus = n.notStatus
    <BR/>
    WHERE n.suID = #newsuid#
    <BR/>
    AND au.userID = f.userID
    <BR/>
    AND n.notStatus = 'Pending'
    <BR/>
    AND n.notStartDate IS NULL
    <BR/>
    ORDER BY au.actionDaysNo, a.actionID
    <BR/>
    LIMIT 1<BR/>
  </cfoutput>
</cfif>

<!--- If there is one notification after, loop through and update system --->
<cfif #notsafter# is "1">
  <Cfif #dbug# is "Y">
    <cfoutput>
      <h4>Next record found!</h4>
    </cfoutput>
  </cfif>
  <cfloop query="notsnext">
    <cfset new_notstartdate=dateAdd('d', numberformat(notsnext.actiondaysno), currentStartDate)/>
    <Cfif #dbug# is "Y">
      <cfoutput>
        <br/>New start date will be #this.formatDate(new_notstartdate)#</br>
    </cfoutput>
  </cfif>

  <cfinclude template="/include/qry/updateNotificationNext.cfm"/>

  <Cfif #dbug# is "Y">
    <Cfoutput>
      <p>
        UPDATE funotifications<BR/>
        SET notStatus = 'Pending'<BR/>
        <cfif len(trim(notstartdate))>
          , notstartdate = '#notstartdate#'<BR/>
        </cfif>

        WHERE notid = #notsnext.notid#<BR/></p>
    </cfoutput>
  </cfif>

</cfloop>
</cfif>

<!--- If there are no notifications after, perform maintenance checks and updates --->

<cfif #notsafter# is "0">

<Cfif #dbug# is "Y">
  <cfoutput>
    <h4>All items for this system completed!</h4>
  </cfoutput>
</cfif>

<!--- No more notifications for this system, so change to "Completed" --->

<cfinclude template="/include/qry/updateSystemUserCompleted.cfm"/>

<Cfif #dbug# is "Y">
  <cfoutput>
    UPDATE fusystemusers SET suStatus = 'Completed'<br/>
    WHERE suid = #newsuid#<br/>
  </cfoutput>
</cfif>

<Cfinclude template="/include/qry/checkformaint_71_6.cfm"/>

<Cfif #dbug# is "Y">
  <Cfoutput>
    <p>
      Check if a maintenance record exists<BR/></p>
  </cfoutput>
</cfif>

<cfif #checkformaint.recordcount# is "0">

  <Cfif #dbug# is "Y">
    <Cfoutput>
      <p>
        No maintenance record!<BR/></p>
    </cfoutput>
  </cfif>
<Cfoutput>
 <cfset subtitle = "Maintenance system created for #new_contactname#" />

<Cfset notifUrl = "/app/contact/?contactid=#contactid#&t4=1" />
</cfoutput>

  <cfinclude template="/include/qry/addNotifications.cfm">

  <Cfif #dbug# is "Y">
    <Cfoutput>
      <p>
        Added notification<BR/></p>
    </cfoutput>
  </cfif>

  <cfinclude template="/include/qry/findSystemByScope.cfm">

  <Cfif #dbug# is "Y">
    <Cfoutput>
      <p>
        Found the proper system id.<BR/></p>
    </cfoutput>
  </cfif>

  <cfset session.ftom="Y"/>

  <cfinclude template="/include/add_system.cfm"/>
  <Cfif #dbug# is "Y">
    <Cfoutput>
      <p>
        Added new maintence system!<BR/></p>
    </cfoutput>
  </cfif>
</cfif>
</cfif>

<Cfif #dbug# is "Y">
<Cfabort />
</cfif>
<cfif #src# is "c">

<cflocation url="/app/contact?contactid=#contactid#&t4=1&hide_completed=#hide_completed#"/>

</cfif>

<cfif #src# is "d">

<cflocation url="/app/dashboard_new/"/>

</cfif>
