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
    WHERE au.userid = #userid#
    AND c.userid = au.userid
    AND n.notstartdate IS NOT NULL
    AND DATE(n.notstartdate) <= '#DateFormat(Now(),'yyyy-mm-dd')#'
    AND n.notstatus = 'Pending'
</cfquery>
