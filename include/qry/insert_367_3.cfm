<!--- This ColdFusion page inserts a new contact item into the CONTACTITEMS table. --->

<cfquery name="insert">
    <!--- Insert a new contact item into the CONTACTITEMS table with specified values. --->
    INSERT INTO CONTACTITEMS (
        CONTACTID,
        VALUETYPE,
        VALUECATEGORY,
        ValueCompany,
        ITEMSTATUS
    )
    VALUES (
        #new_contactid#,
        'Company',
        'Company',
        '#cdco#',
        'Active'
    )
</cfquery>
