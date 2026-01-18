<!--- This ColdFusion page retrieves the latest unread notifications for the user --->
<cfquery name="toasts" maxrows="5">
    <!--- Retrieve the latest unread notifications for the user --->
    SELECT n.ID,
           n.notiftitle,
           n.notiftimestamp,
           c.recordname,
           n.subtitle,
           n.notifurl
    FROM notifications n
    INNER JOIN contactdetails c 
        ON c.contactid = n.contactid
    WHERE n.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#"> 
      AND n.read = 0
      AND n.trash = 0
</cfquery>
