<cfcomponent displayname="AdminEnumService" hint="Generic CRUD for admin enum/lookup tables. All table/column names come from the admin_enums registry (whitelist). User-supplied values always go through cfqueryparam.">

    <!--- ================================================================
         PRIVATE: Load the admin_enums registry row for a given enum_id.
         Every public method calls this first so table/column names are
         always server-controlled.
    ================================================================ --->
    <cffunction name="loadEnumDef" access="private" returntype="query" output="false"
                hint="Returns the admin_enums row for the given enum_id. Throws if not found or inactive.">
        <cfargument name="enum_id" type="numeric" required="true">

        <cfquery name="local.qDef" datasource="#application.dsn#">
            SELECT  enum_id, enum_group, display_name, table_name,
                    pk_column, pk_type, name_column,
                    parent_table, parent_pk, parent_name_col,
                    fk_column, fk_type, parent_label,
                    has_soft_delete, is_read_only, sort_order
            FROM    admin_enums
            WHERE   enum_id   = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.enum_id#">
              AND   is_active = 1
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfif local.qDef.recordCount EQ 0>
            <cfthrow type="AdminEnumService.NotFound"
                     message="Enum definition not found or inactive for enum_id #arguments.enum_id#.">
        </cfif>

        <cfreturn local.qDef>
    </cffunction>

    <!--- ================================================================
         PRIVATE: Map pk_type / fk_type string to CF_SQL constant
    ================================================================ --->
    <cffunction name="cfSqlType" access="private" returntype="string" output="false">
        <cfargument name="typeLabel" type="string" required="true">

        <cfif arguments.typeLabel EQ "varchar">
            <cfreturn "CF_SQL_VARCHAR">
        </cfif>
        <cfreturn "CF_SQL_INTEGER">
    </cffunction>

    <!--- ================================================================
         getEnumsByGroup  -  returns all active registry rows for a group
    ================================================================ --->
    <cffunction name="getEnumsByGroup" access="public" returntype="query" output="false">
        <cfargument name="group" type="string" required="true">

        <cfquery name="local.q" datasource="#application.dsn#">
            SELECT  enum_id, enum_group, display_name, table_name,
                    pk_column, pk_type, name_column,
                    parent_table, parent_pk, parent_name_col,
                    fk_column, fk_type, parent_label,
                    has_soft_delete, is_read_only, sort_order
            FROM    admin_enums
            WHERE   enum_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.group#">
              AND   is_active  = 1
            ORDER BY sort_order
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfreturn local.q>
    </cffunction>

    <!--- ================================================================
         getEnumRows  -  returns active rows from the target table
         Dynamic SQL uses only registry-sourced column/table names.
    ================================================================ --->
    <cffunction name="getEnumRows" access="public" returntype="query" output="false">
        <cfargument name="enum_id" type="numeric" required="true">

        <cfset var def = loadEnumDef(arguments.enum_id)>

        <!--- Build SELECT with optional parent join --->
        <cfset var hasParent = len(trim(def.parent_table))>

        <cfquery name="local.qRows" datasource="#application.dsn#">
            SELECT  t.#def.pk_column#   AS id,
                    t.#def.name_column#  AS name
                    <cfif hasParent>
                    , t.#def.fk_column#    AS parent_id
                    , p.#def.parent_name_col# AS parent_name
                    </cfif>
            FROM    #def.table_name# t
            <cfif hasParent>
            LEFT JOIN #def.parent_table# p
                   ON p.#def.parent_pk# = t.#def.fk_column#
            </cfif>
            WHERE   1 = 1
            <cfif def.has_soft_delete EQ 1>
                AND t.isDeleted = 0
            </cfif>
            ORDER BY t.#def.name_column#
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfreturn local.qRows>
    </cffunction>

    <!--- ================================================================
         getParentOptions  -  returns rows from the parent table for
         populating FK dropdown selects.
    ================================================================ --->
    <cffunction name="getParentOptions" access="public" returntype="query" output="false">
        <cfargument name="enum_id" type="numeric" required="true">

        <cfset var def = loadEnumDef(arguments.enum_id)>

        <cfif NOT len(trim(def.parent_table))>
            <!--- No parent relationship: return empty query --->
            <cfset var empty = queryNew("id,name", "varchar,varchar")>
            <cfreturn empty>
        </cfif>

        <!--- Check if parent table has soft delete by looking up its own registry entry --->
        <cfquery name="local.qParentDef" datasource="#application.dsn#">
            SELECT has_soft_delete
            FROM   admin_enums
            WHERE  table_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#def.parent_table#">
              AND  is_active  = 1
            LIMIT 1
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfset var parentSoftDelete = (local.qParentDef.recordCount GT 0 AND local.qParentDef.has_soft_delete EQ 1)>

        <cfquery name="local.qParent" datasource="#application.dsn#">
            SELECT  #def.parent_pk#       AS id,
                    #def.parent_name_col#  AS name
            FROM    #def.parent_table#
            WHERE   1 = 1
            <cfif parentSoftDelete>
                AND isDeleted = 0
            </cfif>
            ORDER BY #def.parent_name_col#
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfreturn local.qParent>
    </cffunction>

    <!--- ================================================================
         addEnumRow  -  INSERT a new row. Returns struct with success,
         message, and id (new PK).
    ================================================================ --->
    <cffunction name="addEnumRow" access="public" returntype="struct" output="false">
        <cfargument name="enum_id"   type="numeric" required="true">
        <cfargument name="name"      type="string"  required="true">
        <cfargument name="parent_id" type="string"  required="false" default="">

        <cfset var def = loadEnumDef(arguments.enum_id)>
        <cfset var result = { "success" = false, "message" = "", "id" = "" }>

        <!--- Read-only guard --->
        <cfif def.is_read_only EQ 1>
            <cfset result.message = "This table is read-only and cannot be modified.">
            <cfreturn result>
        </cfif>

        <!--- Validate name --->
        <cfset var trimmedName = trim(arguments.name)>
        <cfif NOT len(trimmedName)>
            <cfset result.message = "Name is required.">
            <cfreturn result>
        </cfif>

        <!--- Duplicate check (case-insensitive) --->
        <cfquery name="local.qDup" datasource="#application.dsn#">
            SELECT #def.pk_column# AS id
            FROM   #def.table_name#
            WHERE  LOWER(#def.name_column#) = LOWER(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trimmedName#">)
            <cfif def.has_soft_delete EQ 1>
                AND isDeleted = 0
            </cfif>
            LIMIT 1
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfif local.qDup.recordCount GT 0>
            <cfset result.message = "A row named '#trimmedName#' already exists.">
            <cfreturn result>
        </cfif>

        <!--- Determine if we have a parent FK to insert --->
        <cfset var hasParent = (len(trim(def.fk_column)) AND len(trim(arguments.parent_id)))>

        <cfquery result="local.ins" datasource="#application.dsn#">
            INSERT INTO #def.table_name# (
                #def.name_column#
                <cfif hasParent>, #def.fk_column#</cfif>
                <cfif def.has_soft_delete EQ 1>, isDeleted</cfif>
            ) VALUES (
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trimmedName#">
                <cfif hasParent>
                    , <cfqueryparam cfsqltype="#cfSqlType(def.fk_type)#" value="#arguments.parent_id#">
                </cfif>
                <cfif def.has_soft_delete EQ 1>, 0</cfif>
            )
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <!--- For varchar PK tables (e.g. fusystemtypes), generatedKey may not apply.
              For integer auto-increment tables it will. --->
        <cfif def.pk_type EQ "integer" AND structKeyExists(local.ins, "generatedKey")>
            <cfset result.id = local.ins.generatedKey>
        <cfelse>
            <cfset result.id = trimmedName>
        </cfif>

        <cfset result.success = true>
        <cfset result.message = "Row added successfully.">
        <cfreturn result>
    </cffunction>

    <!--- ================================================================
         updateEnumRow  -  UPDATE an existing row's name (and parent FK).
    ================================================================ --->
    <cffunction name="updateEnumRow" access="public" returntype="struct" output="false">
        <cfargument name="enum_id"   type="numeric" required="true">
        <cfargument name="pk_value"  type="string"  required="true">
        <cfargument name="name"      type="string"  required="true">
        <cfargument name="parent_id" type="string"  required="false" default="">

        <cfset var def = loadEnumDef(arguments.enum_id)>
        <cfset var result = { "success" = false, "message" = "" }>

        <!--- Read-only guard --->
        <cfif def.is_read_only EQ 1>
            <cfset result.message = "This table is read-only and cannot be modified.">
            <cfreturn result>
        </cfif>

        <!--- Validate name --->
        <cfset var trimmedName = trim(arguments.name)>
        <cfif NOT len(trimmedName)>
            <cfset result.message = "Name is required.">
            <cfreturn result>
        </cfif>

        <!--- Duplicate check (case-insensitive), exclude current row --->
        <cfquery name="local.qDup" datasource="#application.dsn#">
            SELECT #def.pk_column# AS id
            FROM   #def.table_name#
            WHERE  LOWER(#def.name_column#) = LOWER(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trimmedName#">)
              AND  #def.pk_column# != <cfqueryparam cfsqltype="#cfSqlType(def.pk_type)#" value="#arguments.pk_value#">
            <cfif def.has_soft_delete EQ 1>
                AND isDeleted = 0
            </cfif>
            LIMIT 1
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfif local.qDup.recordCount GT 0>
            <cfset result.message = "A row named '#trimmedName#' already exists.">
            <cfreturn result>
        </cfif>

        <!--- Determine if we have a parent FK to update --->
        <cfset var hasParent = (len(trim(def.fk_column)) AND len(trim(arguments.parent_id)))>

        <cfquery result="local.upd" datasource="#application.dsn#">
            UPDATE #def.table_name#
            SET    #def.name_column# = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trimmedName#">
                   <cfif hasParent>
                   , #def.fk_column# = <cfqueryparam cfsqltype="#cfSqlType(def.fk_type)#" value="#arguments.parent_id#">
                   </cfif>
            WHERE  #def.pk_column# = <cfqueryparam cfsqltype="#cfSqlType(def.pk_type)#" value="#arguments.pk_value#">
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfif local.upd.recordCount EQ 0>
            <cfset result.message = "Row not found. It may have been deleted.">
            <cfreturn result>
        </cfif>

        <cfset result.success = true>
        <cfset result.message = "Row updated successfully.">
        <cfreturn result>
    </cffunction>

    <!--- ================================================================
         deleteEnumRow  -  Soft delete (isDeleted=1) or hard DELETE
         depending on has_soft_delete flag.
    ================================================================ --->
    <cffunction name="deleteEnumRow" access="public" returntype="struct" output="false">
        <cfargument name="enum_id"  type="numeric" required="true">
        <cfargument name="pk_value" type="string"  required="true">

        <cfset var def = loadEnumDef(arguments.enum_id)>
        <cfset var result = { "success" = false, "message" = "" }>

        <!--- Read-only guard --->
        <cfif def.is_read_only EQ 1>
            <cfset result.message = "This table is read-only and cannot be modified.">
            <cfreturn result>
        </cfif>

        <cfif def.has_soft_delete EQ 1>
            <cfquery result="local.del" datasource="#application.dsn#">
                UPDATE #def.table_name#
                SET    isDeleted = 1
                WHERE  #def.pk_column# = <cfqueryparam cfsqltype="#cfSqlType(def.pk_type)#" value="#arguments.pk_value#">
            </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfelse>
            <cfquery result="local.del" datasource="#application.dsn#">
                DELETE FROM #def.table_name#
                WHERE  #def.pk_column# = <cfqueryparam cfsqltype="#cfSqlType(def.pk_type)#" value="#arguments.pk_value#">
            </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        </cfif>

        <cfif local.del.recordCount EQ 0>
            <cfset result.message = "Row not found. It may have already been deleted.">
            <cfreturn result>
        </cfif>

        <cfset result.success = true>
        <cfset result.message = "Row deleted successfully.">
        <cfreturn result>
    </cffunction>

</cfcomponent>
