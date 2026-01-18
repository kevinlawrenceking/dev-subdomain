<!--- This ColdFusion page retrieves notifications for the user, including read and trashed ones, ordered by timestamp --->

<cfquery name="toastmenu">
    <!--- Retrieve all notifications for the user, including read and trashed ones, ordered by timestamp --->
    SELECT n.ID,
           n.notiftitle,
           n.notiftimestamp,
           c.recordname,
           n.subtitle,
           n.notifurl,
           n.contactid,
           n.`read`,
           n.trash
    FROM notifications n
    LEFT JOIN contactdetails c 
        ON c.contactid = n.contactid
    WHERE n.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#"> 
      AND n.trash = 0
    ORDER BY n.notiftimestamp DESC
</cfquery>
