<cfinclude template="/include/perfcount.cfm" />
<!--- This ColdFusion page inserts a new contact item into the CONTACTITEMS table --->
<cfquery name="insert">
    <!--- Insert a new contact item with specified details --->
    INSERT INTO contactitems_tbl (
        CONTACTID,
        VALUETYPE,
        VALUECATEGORY,
        VALUETEXT,
        ITEMSTATUS
    )
    VALUES (
        <cfqueryparam value="#CONTACTID#" cfsqltype="cf_sql_integer">,
        'Tags',
        'Tag',
        <cfqueryparam value="#tag#" cfsqltype="cf_sql_varchar">,
        'Active'
    )
</cfquery>
