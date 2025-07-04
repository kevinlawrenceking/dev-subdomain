<cfcomponent displayname="" hint="Handles operations for SystemUser table" >

<cffunction name="closeSystem" access="public" returntype="void">
    <cfargument name="suid" type="numeric" required="true">
    <cfquery>
        UPDATE fusystemusers
        SET isdeleted = 1
        WHERE suid = <cfqueryparam value="#arguments.suid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>



    <cffunction name="findSystemByScope" access="public" returntype="string" output="false" hint="Finds system ID based on type and scope">
    <cfargument name="systemscope" type="string" required="true" hint="The scope to filter the systems">

    <cfset var systemID = "">

    <cfquery name="findSystem" >
        SELECT s.systemid
        FROM fusystems s
        WHERE s.systemtype = 'Maintenance List'
          AND s.systemscope = <cfqueryparam value="#arguments.systemscope#" cfsqltype="CF_SQL_VARCHAR">
        LIMIT 1
    </cfquery>

    <!--- If a record is found, assign the system ID --->
    <cfif findSystem.recordCount>
        <cfset systemID = findSystem.systemid>
    </cfif>

    <cfreturn systemID>
</cffunction>


<cffunction name="getOldSystemDetails" access="public" returntype="query" output="false" hint="Gets the old system details including system scope and type">
    <!--- Arguments --->
    <cfargument name="suid" type="numeric" required="true" hint="The system user ID (suid) to look up">
    
    <!--- Query to fetch old system details --->
    <cfquery name="reldetails">
        SELECT 
            fc.suID, 
            fc.contactid, 
            fc.userid, 
            fc.suStartDate, 
            fc.suenddate, 
            fc.suStatus, 
            s.systemName, 
            s.systemdescript, 
            s.systemtype, 
            s.systemscope, 
            s.systemid, 
            s.recordname
        FROM fusystemusers fc
        INNER JOIN fusystems s ON s.systemID = fc.systemID
        WHERE fc.suid = <cfqueryparam value="#arguments.suid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    
    <!--- Return the query result --->
    <cfreturn reldetails>
</cffunction>




   <cffunction name="updateSystemUser" access="public" returntype="void" output="false">
        <cfargument name="suid" type="numeric" required="true">
        <cfargument name="sustatus" type="string" required="false" default="Completed">

        <cfquery name="updateQuery">
            UPDATE fusystemusers
            SET suStatus = <cfqueryparam value="#arguments.sustatus#" cfsqltype="CF_SQL_VARCHAR">
            WHERE suid = <cfqueryparam value="#arguments.suid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cffunction>



<cffunction output="false" name="addfuSystemUsers" access="public" returntype="numeric">
    <cfargument name="systemID" type="numeric" required="true">
    <cfargument name="contactID" type="numeric" required="true">
    <cfargument name="userID" type="string" required="true">
    <cfargument name="suStartDate" type="date" required="true">

<cfquery result="result" >
            INSERT INTO fuSystemUsers (systemID, contactID, userID, suStartDate)
            VALUES (
                <cfqueryparam value="#arguments.systemID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.suStartDate#" cfsqltype="CF_SQL_DATE">
            )
        </cfquery>

<cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="INSfusystemusers_batch" access="public" returntype="numeric">
    <cfargument name="new_systemid" type="numeric" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="new_suStartDate" type="date" required="true">

<cfquery result="result">
        INSERT INTO fuSystemUsers (systemID, contactID, userID, suStartDate, suNotes)
        VALUES (
            <cfqueryparam value="#arguments.new_systemid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.new_suStartDate#" cfsqltype="CF_SQL_DATE">,
            <cfqueryparam value="Added via user batch update" cfsqltype="CF_SQL_VARCHAR">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>



<cffunction output="false" name="SELfusystemusers" access="public" returntype="query">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT fc.suID 
        FROM fusystemusers fc 
        INNER JOIN fusystems s ON s.systemID = fc.systemID 
        WHERE fc.contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER"> 
        AND s.systemtype = <cfqueryparam value="Maintenance List" cfsqltype="CF_SQL_VARCHAR"> 
        AND fc.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELfusystemusers_23864" access="public" returntype="query">
    <cfargument name="idlist" type="string" required="true">
    <cfargument name="new_systemid" type="numeric" required="true">

<cfquery name="result">
        SELECT COUNT(*) AS totals
        FROM fusystemusers_tbl
        WHERE isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
        AND contactid IN (#arguments.idlist#)
        AND systemid = <cfqueryparam value="#arguments.new_systemid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="UPDfusystemusers_23865" access="public" returntype="void">
    <cfargument name="idList" type="string" required="true">
    <cfargument name="newSystemId" type="numeric" required="true">

<cfquery>
        UPDATE fusystemusers_tbl
        SET isdeleted = 1
        WHERE contactid IN (#arguments.idList#)
        AND systemid = <cfqueryparam value="#arguments.newSystemId#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="INSfusystemusers_23934" access="public" returntype="numeric">
    <cfargument name="new_systemid" type="numeric" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="new_userid" type="numeric" required="true">
    <cfargument name="suStartDate" type="date" required="true">
    <cfargument name="sunotes" type="string" required="true">

<cfquery result="result">
        INSERT INTO fuSystemUsers (systemID, contactID, userID, suStartDate, sunotes)
        VALUES (
            <cfqueryparam value="#arguments.new_systemid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.new_userid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.suStartDate#" cfsqltype="CF_SQL_DATE">,
            <cfqueryparam value="#arguments.sunotes#" cfsqltype="CF_SQL_VARCHAR">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDfusystemusers_23935" access="public" returntype="void">
    <cfargument name="new_userid" type="numeric" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery result="result">
        UPDATE fusystemusers 
        SET sustatus = 'Completed' 
        WHERE userid = <cfqueryparam value="#arguments.new_userid#" cfsqltype="CF_SQL_INTEGER"> 
        AND systemid IN (5, 6) 
        AND contactid = <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="SELfusystemusers_24031" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                n.notid, 
                a.id, 
                fu.systemid, 
                n.actionid, 
                n.suid, 
                fu.sustartdate, 
                a.actionDaysNo, 
                a.actiondaysrecurring, 
                n.notstartdate, 
                DATE_ADD(fu.sustartdate, INTERVAL a.actionDaysNo DAY) AS new_notstartdate
            FROM 
                fusystemusers fu
            INNER JOIN 
                funotifications n ON n.suid = fu.suid
            INNER JOIN 
                actionusers a ON a.actionid = n.actionid
            WHERE 
                fu.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> AND
                a.userid = fu.userid AND
                n.userID = fu.userid AND
                n.notstatus <> 'Completed' AND
                n.isdeleted = 0 AND
                n.notstartdate <> DATE_ADD(fu.sustartdate, INTERVAL a.actionDaysNo DAY)
            ORDER BY 
                n.notid
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="getSystemUserByID" access="public" returntype="query">
    <cfargument name="suid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                fc.suID, 
                fc.contactid, 
                fc.userid, 
                fc.suStartDate, 
                fc.suenddate, 
                fc.suStatus, 
                s.systemName, 
                s.systemdescript, 
                s.systemtype, 
                s.systemscope, 
                s.systemid, 
                s.recordname
            FROM fusystemusers fc
            INNER JOIN fusystems s ON s.systemID = fc.systemID
            WHERE fc.suid = <cfqueryparam value="#arguments.suid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="UPDfusystemusers_24315" access="public" returntype="void">
    <cfargument name="suid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE fusystemusers 
            SET isdeleted = 1 
            WHERE suid = <cfqueryparam value="#arguments.suid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>

<cffunction output="false" name="SELfusystemusers_24343" access="public" returntype="query">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery name="result" >
            SELECT fc.suID 
            FROM fusystemusers fc 
            WHERE fc.contactID = <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER"> 
            AND fc.suStatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELfusystemusers_24344" access="public" returntype="query">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="new_systemid" type="numeric" required="true">

<cfquery name="result" >
            SELECT *
            FROM fusystemusers_tbl
            WHERE contactid = <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">
              AND sustatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
              AND isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
              AND systemid = <cfqueryparam value="#arguments.new_systemid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="UPDfusystemusers_24345" access="public" returntype="numeric">
    <cfargument name="new_contactid" type="numeric" required="true">

<!--- Run the update query --->
    <cfquery result="result" name="updateQuery">
        UPDATE fusystemusers_tbl
        SET isdeleted = 1, sunotes = 'Deleted via batch update'
        WHERE contactID = <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">
        AND suStatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
        AND isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
    </cfquery>

<!--- Return the RecordCount to indicate the number of rows affected --->

<cfreturn result.RecordCount>
</cffunction>

<cffunction output="false" name="SELfusystemusers_24426" access="public" returntype="query">
    <cfargument name="maint_contactid" type="numeric" required="true">
    <cfargument name="maint_systemid" type="numeric" required="true">

<cfquery name="result" >
            SELECT *
            FROM fusystemusers
            WHERE contactid = <cfqueryparam value="#arguments.maint_contactid#" cfsqltype="CF_SQL_INTEGER">
            AND systemid = <cfqueryparam value="#arguments.maint_systemid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INSfusystemusers_24427" access="public" returntype="numeric">
    <cfargument name="maint_systemID" type="numeric" required="true">
    <cfargument name="maint_contactID" type="numeric" required="true">
    <cfargument name="userid" type="string" required="true">
    <cfargument name="suStartDate" type="date" required="true">

<cfquery result="result" >
            INSERT INTO fuSystemUsers (systemID, contactID, userID, suStartDate)
            VALUES (
                <cfqueryparam value="#arguments.maint_systemID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.maint_contactID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.suStartDate#" cfsqltype="CF_SQL_DATE">
            )
        </cfquery>
<cfreturn result.generatedKey>

</cffunction>

<cffunction output="false" name="getRemindersByRelationship" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">
    <cfargument name="sessionUserId" type="numeric" required="true">

<cfquery name="result" >
   SELECT fc.suid,
                s.systemtype,
                s.systemscope
            FROM fusystemusers fc
            INNER JOIN fusystems s ON s.systemID = fc.systemID
            WHERE fc.contactID = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER">
            AND fc.userID = <cfqueryparam value="#arguments.sessionUserId#" cfsqltype="CF_SQL_INTEGER">
            AND fc.sustatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELfusystemusers_24758" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">
    <cfargument name="sessionUserId" type="numeric" required="true">
    <cfargument name="hideCompleted" type="string" required="false" default="N">

<cfquery name="result" >
            SELECT 
                fc.suID, 
                fc.contactid, 
                fc.userid, 
                fc.suStartDate, 
                fc.suenddate, 
                fc.suStatus, 
                s.systemName, 
                s.systemdescript, 
                s.systemtype, 
                s.systemscope, 
                s.systemid, 
                s.recordname
            FROM 
                fusystemusers fc
            INNER JOIN 
                fusystems s ON s.systemID = fc.systemID
            WHERE 
                fc.contactID = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER"> 
                AND fc.userID = <cfqueryparam value="#arguments.sessionUserId#" cfsqltype="CF_SQL_INTEGER">
            <cfif arguments.hideCompleted is "Y">
                AND fc.suStatus <> 'Completed'
            </cfif>
            ORDER BY 
                fc.suStatus
        </cfquery>

<cfreturn result>

</cffunction>
</cfcomponent>
