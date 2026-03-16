<!--- This ColdFusion page inserts a new contact item into the CONTACTITEMS table. --->

<cfquery name="insert">
    <!--- Insert a new contact item with specified values into the CONTACTITEMS table. --->
    INSERT INTO contactitems_tbl (
        CONTACTID,
        VALUETYPE,
        VALUECATEGORY,
        VALUETEXT,
        ITEMSTATUS
    )
    VALUES (
        <cfqueryparam value="#new_contactid#" cfsqltype="cf_sql_integer">,
        'Tags',
        'Tag',
        <cfqueryparam value="#cdtype#" cfsqltype="cf_sql_varchar">,
        'Active'
    )
</cfquery>
