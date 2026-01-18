<cfcomponent displayname="EventTypesUserService" hint="Handles operations for EventTypesUser table" > 
<cffunction output="false" name="DETeventtypes_user" access="public" returntype="query">
    <cfargument name="id" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM eventtypes_user
        WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDeventtypes_user" access="public" returntype="void">
    <cfargument name="eventtypeid" type="numeric" required="true">
    <cfargument name="new_eventtypecolor" type="string" required="true">
    <cfargument name="deletelink" type="numeric" required="false" default="false">
    <cfargument name="new_iscustom" type="numeric" required="false" default="false">
    <cfargument name="new_eventtypename" type="string" required="false" default="">

    <!--- Execute the query --->
    <cfquery name="update">
        UPDATE eventtypes_user
        SET 
            eventtypecolor = <cfqueryparam value="#arguments.new_eventtypecolor#" cfsqltype="cf_sql_varchar">
            
            <!--- Conditionally set isdeleted --->
            <cfif arguments.deletelink eq 1>
                , isdeleted = 1
            </cfif>
            
            <!--- Conditionally set eventtypename --->
            <cfif arguments.new_iscustom eq 1>
                , eventtypename = <cfqueryparam value="#arguments.new_eventtypename#" cfsqltype="cf_sql_varchar">
            </cfif>
            
        WHERE id = <cfqueryparam value="#arguments.eventtypeid#" cfsqltype="cf_sql_integer">
    </cfquery>
</cffunction>



<cffunction output="false" name="SELeventtypes_user" access="public" returntype="query">
    <cfargument name="eventTypeName" type="string" required="true">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result">
        SELECT eventTypeName, eventtypedescription, eventtypecolor
        FROM eventtypes_user
        WHERE eventTypeName = <cfqueryparam value="#arguments.eventTypeName#" cfsqltype="CF_SQL_VARCHAR">
        AND userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSeventtypes_user" access="public" returntype="void">
    <cfargument name="eventTypeName" type="string" required="true">
    <cfargument name="eventtypedescription" type="string" required="true">
    <cfargument name="eventtypecolor" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO eventtypes_user 
            (eventTypeName, eventtypedescription, eventtypecolor, userid) 
        VALUES 
            (
                <cfqueryparam value="#arguments.eventTypeName#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.eventtypedescription#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.eventtypecolor#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            )
    </cfquery>
</cffunction>

<cffunction output="false" name="SELeventtypes_user_24484" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="isAuditionModule" type="boolean" required="true">

<cfquery name="result">
        SELECT eventtypename 
        FROM eventtypes_user 
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER" />
        <cfif arguments.isAuditionModule>
            AND eventtypename <> 'Audition'
        </cfif>
        ORDER BY eventtypename
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELeventtypes_user_24486" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT eventtypename 
        FROM eventtypes_user 
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        ORDER BY eventtypename
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELeventtypes_user_24619" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            id, 
            eventtypename, 
            eventtypedescription, 
            recordname, 
            iscustom, 
            eventtypecolor 
        FROM 
            eventtypes_user 
        WHERE 
            userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
        ORDER BY 
            eventtypename
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELeventtypes_user_24661" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            id, 
            eventtypename, 
            eventtypedescription, 
            recordname, 
            iscustom, 
            eventtypecolor 
        FROM 
            eventtypes_user 
        WHERE 
            userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        ORDER BY 
            eventtypename
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>