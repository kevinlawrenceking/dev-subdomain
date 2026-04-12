<cfinclude template="/include/perfcount.cfm" />
<!--- This ColdFusion page handles the insertion of a new contact item into the CONTACTITEMS table. --->

<cfquery name="insert">
    <!--- Insert a new contact item into the CONTACTITEMS table --->
    INSERT INTO contactitems_tbl (
        CONTACTID,
        VALUETYPE,
        VALUECATEGORY,
        VALUETEXT,
        ITEMSTATUS
    )
    VALUES (
        <cfqueryparam value="#CONTACTID#" cfsqltype="cf_sql_integer">,
        'Business',
        'Email',
        <cfqueryparam value="#workemail#" cfsqltype="cf_sql_varchar">,
        'Active'
    )
</cfquery>
