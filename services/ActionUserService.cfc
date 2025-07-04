<cfcomponent displayname="ActionUserService" hint="Handles operations for ActionUser table">

  <cffunction name="restoreActionUsers" access="public" returntype="numeric" output="false">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="target_id_system" type="numeric" required="true">

    <!--- Step 1: Delete existing action users for the user and target system --->
    <cfquery name="deleteActionUsers">
      delete from  actionusers_tbl
      WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
      AND actionid IN (
      SELECT actionid
      FROM fuactions
      WHERE systemid = <cfqueryparam value="#arguments.target_id_system#" cfsqltype="CF_SQL_INTEGER">
      )
    </cfquery>

<cffunction output="false" name="INSactionusers_24455" access="public" returntype="numeric">
  <cfargument name="actionid" type="numeric" required="true">
  <cfargument name="userid" type="numeric" required="true">
  <cfargument name="actiondaysno" type="numeric" required="true">
  <cfargument name="actiondaysrecurring" type="string" required="false" default="">

  <cfquery result="result" >
    INSERT INTO actionusers_tbl (actionid, userid, actiondaysno
    <cfif len(arguments.actiondaysrecurring) gt 0>
      , actiondaysrecurring</cfif>
    , IsDeleted)
    VALUES ( <cfqueryparam value="#arguments.actionid#" cfsqltype="CF_SQL_INTEGER">
    , <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    , <cfqueryparam value="#arguments.actiondaysno#" cfsqltype="CF_SQL_INTEGER">
    <cfif len(arguments.actiondaysrecurring) gt 0>
      , <cfqueryparam value="#arguments.actiondaysrecurring#" cfsqltype="CF_SQL_VARCHAR">
    </cfif>
    ,
    0
    )
  </cfquery>
  <cfreturn result.generatedKey>
</cffunction>

    <cfquery name="insertMissingActions" result="insertResult">
      INSERT INTO actionusers_tbl (
      actionid,
      userid,
      actiondaysno,
      actiondaysrecurring,
      isdeleted
      )
      SELECT
      a.actionid,
      <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
      AS userid,
      a.actiondaysno,
      a.actiondaysrecurring,
      0 AS isdeleted
      FROM fuactions a
      LEFT JOIN actionusers_tbl au
      ON a.actionid = au.actionid
      AND au.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
      WHERE a.systemid = <cfqueryparam value="#arguments.target_id_system#" cfsqltype="CF_SQL_INTEGER">
      AND au.actionid IS NULL
    </cfquery>

    <!--- Capture the number of inserted rows --->
    <cfset insertCount=insertResult.recordCount>

    <!--- Return the count --->
    <cfreturn insertCount>

  </cffunction>

  <cffunction output="false" name="addActionUsers" access="public" returntype="numeric">
    <cfargument name="actionid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="actiondaysno" type="numeric" required="true">
    <cfargument name="actiondaysrecurring" type="string" required="false" default="">

    <cfquery result="result" >
      INSERT INTO actionusers_tbl (
      actionid,
      userid,
      actiondaysno
      <cfif arguments.actiondaysrecurring neq "">
        , actiondaysrecurring</cfif>
      ,
      IsDeleted
      ) VALUES ( <cfqueryparam value="#arguments.actionid#" cfsqltype="CF_SQL_INTEGER">
      , <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
      , <cfqueryparam value="#arguments.actiondaysno#" cfsqltype="CF_SQL_INTEGER">
      <cfif arguments.actiondaysrecurring neq "">
        , <cfqueryparam value="#arguments.actiondaysrecurring#" cfsqltype="CF_SQL_VARCHAR">
      </cfif>
      ,
      0
      )
    </cfquery>
    <cfreturn result.generatedKey>
  </cffunction>

  <cffunction name="updateActionUsers" access="public" returntype="void" output="false" hint="Unified function to update actionusers_tbl with various update scenarios">
    <cfargument name="id" type="numeric" required="false" default="0" hint="ID of the specific record to update">
    <cfargument name="userid" type="numeric" required="false" default="0" hint="User ID for system-wide updates">
    <cfargument name="systemid" type="numeric" required="false" default="0" hint="System ID for system-wide updates">
    <cfargument name="actionDaysNo" type="numeric" required="false" default="0" hint="Number of action days">
    <cfargument name="actionDaysRecurring" type="string" required="false" default="" hint="Recurring days pattern">
    <cfargument name="updateIsDeleted" type="boolean" required="false" default="false" hint="Whether to update isDeleted field">
    <cfargument name="isDeleted" type="string" required="0" default="false" hint="Value to set for isDeleted">

    <cfset var result="">

    <cfquery name="result">
      UPDATE actionusers_tbl
      SET

        actionDaysNo = <cfqueryparam value="#arguments.actionDaysNo#" cfsqltype="CF_SQL_INTEGER">
 

        <cfif arguments.actionDaysRecurring neq "">
            ,actionDaysRecurring = <cfif arguments.actionDaysRecurring neq "0" AND len(trim(arguments.actionDaysRecurring))>
          <cfqueryparam value="#arguments.actionDaysRecurring#" cfsqltype="CF_SQL_INTEGER">
        <Cfelse>
            NULL
        </cfif></cfif>
      
      ,isDeleted = <cfqueryparam value="#arguments.isDeleted#" cfsqltype="CF_SQL_BIT">
      
      WHERE 1=1 
      
        <cfif arguments.id gt 0>
            AND id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
        </cfif>

        <cfif arguments.userid gt 0>
            AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfif>

        <cfif arguments.systemid gt 0 and arguments.systemid neq "">
            AND actionid IN (
            SELECT actionid
            FROM fuactions
            WHERE systemid = <cfqueryparam value="#arguments.systemid#" cfsqltype="CF_SQL_INTEGER">
        )
        </cfif>


  </cfquery>
</cffunction>

<cffunction name="GetActionUsers" access="public" returntype="query" output="false" hint="Retrieve user actions with optional filtering">
  <cfargument name="userid" type="numeric" required="true" hint="ID of the user">
  <cfargument name="actionid" type="numeric" required="false" default="0" hint="Optional action ID for specific queries">

  <cfset var result="">

  <cfquery name="result">
    SELECT
    au.id,
    au.actionid,
    au.userid,
    au.actionDaysNo,
    au.actionDaysRecurring,
    au.IsDeleted,
    s.systemID,
    s.systemName,
    s.SystemType,
    s.SystemScope,
    s.SystemDescript,
    s.SystemTriggerNote,
    a.actionNo,
    a.actionDetails,
    a.actionTitle,
    a.navToURL,
    a.actionNotes,
    a.actionInfo
    FROM
    actionusers au
    INNER JOIN fuactions a ON au.actionid = a.actionid
    INNER JOIN fusystems s ON s.systemid = a.systemid
    WHERE
    au.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    <cfif arguments.actionid gt 0>
      AND au.actionid = <cfqueryparam value="#arguments.actionid#" cfsqltype="CF_SQL_INTEGER">
    </cfif>
    ORDER BY
    a.actionNo
  </cfquery>

  <cfreturn result>
</cffunction>



</cfcomponent>
