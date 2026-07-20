<cfcomponent displayname="MasterAuditService" hint="DIR-LNK-WO-7 master-link audit writer. Append-only inserts into master_audit_tbl (V3_12) using the governed action_type vocabulary. First runtime audit writer for link events (links wrote zero audit rows before WO-7). No triggers - all audit is explicit and testable (V3_12 policy).">

<!--- Instantiated via request.svc() (no init call); methods are self-contained and use the
      framework default datasource (bare cfquery -> application.datasource -> abod on dev). --->
<cffunction name="init" access="public" returntype="MasterAuditService" output="false">
    <cfreturn this>
</cffunction>

<!--- Governed action_type vocabulary of record (V3_12 header). VARCHAR, not ENUM: the DB does
      not enforce it, so the service does. Extend here (not the schema) if a new action is added. --->
<cffunction name="governedActions" access="private" returntype="string" output="false">
    <cfreturn "BACKFILL_FROM_CONTACTITEM,LINK_CREATED,PRELINK_VALUE_PRESERVED,MASTER_SNAPSHOT_POPULATED,MASTER_AUTO_UPDATE,CORRECTION_SUBMITTED,CORRECTION_APPROVED,CORRECTION_REJECTED,BAD_MATCH_REMOVED,MASTER_RELINKED,PRELINK_VALUE_RESTORED,PRIMARY_FIELD_CLEARED_AFTER_UNLINK,ADMIN_REPAIR">
</cffunction>

<!--- ============================================================
      record(...) -> new auditID (0 when an idempotency_key collision made the insert a no-op).
      Append-only. Value columns are VARCHAR(500) (co_locations-sized); over-long values are
      trimmed by cfqueryparam maxlength rather than silently overflowing.
      Retry-guarded writes pass a deterministic idempotency_key -> INSERT IGNORE dedups on
      UQ_master_audit_idem. Inherently-unique events leave the key blank (MySQL NULL is distinct).
      ============================================================ --->
<cffunction name="record" access="public" returntype="numeric" output="false">
    <cfargument name="contactID"            type="numeric" required="true">
    <cfargument name="action_type"          type="string"  required="true">
    <cfargument name="actor_userid"         type="numeric" required="false" default="0">
    <cfargument name="actor_type"           type="string"  required="false" default="user">
    <cfargument name="master_co_contact_id" type="numeric" required="false" default="0">
    <cfargument name="master_coid"          type="numeric" required="false" default="0">
    <cfargument name="company_location_id"  type="numeric" required="false" default="0">
    <cfargument name="field_name"           type="string"  required="false" default="">
    <cfargument name="old_value"            type="string"  required="false" default="">
    <cfargument name="new_value"            type="string"  required="false" default="">
    <cfargument name="previous_source"      type="string"  required="false" default="">
    <cfargument name="new_source"           type="string"  required="false" default="">
    <cfargument name="reason"               type="string"  required="false" default="">
    <cfargument name="idempotency_key"      type="string"  required="false" default="">

    <cfif NOT listFindNoCase(governedActions(), trim(arguments.action_type))>
        <cfthrow message="MasterAuditService.record: ungoverned action_type '#arguments.action_type#' (V3_12 vocabulary)">
    </cfif>

    <cfset var r = "">
    <cfquery result="r">
        INSERT <cfif len(trim(arguments.idempotency_key))>IGNORE </cfif>INTO master_audit_tbl
            (contactID, actor_userid, actor_type, action_type,
             master_co_contact_id, master_coid, company_location_id,
             field_name, old_value, new_value, previous_source, new_source, reason, idempotency_key)
        VALUES (
            <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.actor_userid#" cfsqltype="CF_SQL_INTEGER" null="#(val(arguments.actor_userid) LE 0)#">,
            <cfqueryparam value="#lCase(trim(arguments.actor_type))#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#trim(arguments.action_type)#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.master_co_contact_id#" cfsqltype="CF_SQL_INTEGER" null="#(val(arguments.master_co_contact_id) LE 0)#">,
            <cfqueryparam value="#arguments.master_coid#" cfsqltype="CF_SQL_INTEGER" null="#(val(arguments.master_coid) LE 0)#">,
            <cfqueryparam value="#arguments.company_location_id#" cfsqltype="CF_SQL_INTEGER" null="#(val(arguments.company_location_id) LE 0)#">,
            <cfqueryparam value="#trim(arguments.field_name)#" cfsqltype="CF_SQL_VARCHAR" null="#(NOT len(trim(arguments.field_name)))#">,
            <cfqueryparam value="#arguments.old_value#" cfsqltype="CF_SQL_VARCHAR" maxlength="500" null="#(NOT len(arguments.old_value))#">,
            <cfqueryparam value="#arguments.new_value#" cfsqltype="CF_SQL_VARCHAR" maxlength="500" null="#(NOT len(arguments.new_value))#">,
            <cfqueryparam value="#lCase(trim(arguments.previous_source))#" cfsqltype="CF_SQL_VARCHAR" null="#(NOT len(trim(arguments.previous_source)))#">,
            <cfqueryparam value="#lCase(trim(arguments.new_source))#" cfsqltype="CF_SQL_VARCHAR" null="#(NOT len(trim(arguments.new_source)))#">,
            <cfqueryparam value="#trim(arguments.reason)#" cfsqltype="CF_SQL_VARCHAR" maxlength="255" null="#(NOT len(trim(arguments.reason)))#">,
            <cfqueryparam value="#trim(arguments.idempotency_key)#" cfsqltype="CF_SQL_VARCHAR" maxlength="191" null="#(NOT len(trim(arguments.idempotency_key)))#">
        )
    </cfquery>
    <cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfreturn val(r.generatedKey)>
</cffunction>

</cfcomponent>
