<cfinclude template="/include/perfcount.cfm" />
<!--- This ColdFusion page inserts a new contact item into the CONTACTITEMS table --->
<cfquery name="insert">
    <!--- Insert a new contact item with specified details --->
    INSERT INTO contactitems_tbl (
        CONTACTID,
        VALUETYPE,
        VALUECATEGORY,
        ValueCompany,
        ITEMSTATUS
    )
    VALUES (
        <cfqueryparam value="#new_contactid#" cfsqltype="cf_sql_integer">,
        'Company',
        'Company',
        <cfqueryparam value="#cdco#" cfsqltype="cf_sql_varchar">,
        'Active'
    )
</cfquery>
