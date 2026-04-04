<cfcomponent displayname="NotificationStatusService" hint="Handles operations for NotificationStatus table" > 
<cffunction output="false" name="SELnotstatuses" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">
    <cfargument name="sysActiveSuid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            n.notID, n.actionID, n.userID, n.suID, n.notTimeStamp, 
            n.notStartDate, n.notEndDate, 'Future' AS notStatus, 
            n.notNotes, f.systemID, f.contactID, f.suTimeStamp, 
            f.suStartDate, f.suEndDate, f.suStatus, f.suNotes, 
            a.actionID, a.actionNo, a.actionDetails, a.actionTitle, 
            a.navToURL, au.actionDaysNo, au.actionDaysRecurring, 
            a.actionNotes, a.actionInfo, l.actionlinkid, l.BtnName, 
            l.ActionLinkURL, l.endlink, l.targetlink, n.ispastdue,
            ns.checktype, ns.delstart, ns.delend, ns.status_color
        FROM 
            notstatuses ns,
            funotifications n
        INNER JOIN 
            fusystemusers f ON f.suID = n.suID
        INNER JOIN 
            fusystems s ON s.systemID = f.systemID
        INNER JOIN 
            fuactions a ON a.actionID = n.actionID
        INNER JOIN 
            actionusers au ON a.actionID = au.actionID
        INNER JOIN 
            fuActionLinks l ON l.actionlinkid = a.actionlinkid
        WHERE 
            f.contactID = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER"> AND
            f.suid = <cfqueryparam value="#arguments.sysActiveSuid#" cfsqltype="CF_SQL_INTEGER"> AND
            au.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> AND
            (n.notstartdate IS NULL OR DATE(n.notstartdate) >= <cfqueryparam value="#DateFormat(Now(),'yyyy-mm-dd')#" cfsqltype="CF_SQL_DATE">) AND
            n.notstatus = <cfqueryparam value="Pending" cfsqltype="CF_SQL_VARCHAR"> AND
            ns.notstatus = <cfqueryparam value="Future" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

    

<cfreturn result>
</cffunction>

<!--- PERF: Batch version of SELnotstatuses to eliminate N+1 queries. --->
<!--- Accepts a comma-delimited list of suIDs and returns all matching rows in one round-trip. --->
<cffunction output="false" name="SELnotstatuses_batch" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">
    <cfargument name="suidList" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <cfif NOT len(trim(arguments.suidList))>
        <cfreturn queryNew("notID,actionID,userID,suID,notTimeStamp,notStartDate,notEndDate,notStatus,notNotes,systemID,contactID,suTimeStamp,suStartDate,suEndDate,suStatus,suNotes,actionNo,actionDetails,actionTitle,navToURL,actionDaysNo,actionDaysRecurring,actionNotes,actionInfo,actionlinkid,BtnName,ActionLinkURL,endlink,targetlink,ispastdue,checktype,delstart,delend,status_color")>
    </cfif>

<cfquery name="result">
        SELECT 
            n.notID, n.actionID, n.userID, n.suID, n.notTimeStamp, 
            n.notStartDate, n.notEndDate, 'Future' AS notStatus, 
            n.notNotes, f.systemID, f.contactID, f.suTimeStamp, 
            f.suStartDate, f.suEndDate, f.suStatus, f.suNotes, 
            a.actionID, a.actionNo, a.actionDetails, a.actionTitle, 
            a.navToURL, au.actionDaysNo, au.actionDaysRecurring, 
            a.actionNotes, a.actionInfo, l.actionlinkid, l.BtnName, 
            l.ActionLinkURL, l.endlink, l.targetlink, n.ispastdue,
            ns.checktype, ns.delstart, ns.delend, ns.status_color
        FROM 
            notstatuses ns,
            funotifications n
        INNER JOIN 
            fusystemusers f ON f.suID = n.suID
        INNER JOIN 
            fusystems s ON s.systemID = f.systemID
        INNER JOIN 
            fuactions a ON a.actionID = n.actionID
        INNER JOIN 
            actionusers au ON a.actionID = au.actionID
        INNER JOIN 
            fuActionLinks l ON l.actionlinkid = a.actionlinkid
        WHERE 
            f.contactID = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER"> AND
            f.suid IN (<cfqueryparam value="#arguments.suidList#" cfsqltype="CF_SQL_INTEGER" list="true">) AND
            au.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> AND
            (n.notstartdate IS NULL OR DATE(n.notstartdate) >= <cfqueryparam value="#DateFormat(Now(),'yyyy-mm-dd')#" cfsqltype="CF_SQL_DATE">) AND
            n.notstatus = <cfqueryparam value="Pending" cfsqltype="CF_SQL_VARCHAR"> AND
            ns.notstatus = <cfqueryparam value="Future" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>