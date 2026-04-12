<cfinclude template="/include/perfcount.cfm" />
<!--- This ColdFusion page retrieves the total count of pending notifications for a specific user. --->

<cfquery name="notsActives">
    <!--- Query to count pending notifications for the user --->
    SELECT count(*) as nots_total
    FROM funotifications n
    INNER JOIN fusystemusers f ON f.suID = n.suID
    INNER JOIN fusystems s ON s.systemID = f.systemID
    INNER JOIN fuactions a ON a.actionID = n.actionID
    INNER JOIN actionusers au ON a.actionID = au.actionID
    INNER JOIN fuActionLinks l ON l.actionlinkid = a.actionlinkid
    INNER JOIN notstatuses ns ON ns.notstatus = n.notStatus
    INNER JOIN contactdetails c ON c.contactid = f.contactid
    WHERE au.userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">
    AND c.userid = au.userid
    AND n.notstartdate IS NOT NULL
    AND DATE(n.notstartdate) <= <cfqueryparam value="#Now()#" cfsqltype="cf_sql_date">
    AND n.notstatus = 'Pending'
    AND n.isdeleted = 0
</cfquery>
