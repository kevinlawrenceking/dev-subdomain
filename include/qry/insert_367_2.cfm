<!--- This ColdFusion page inserts a new contact item into the CONTACTITEMS table --->
<cfquery name="insert">
    <!--- Insert a new contact item with specified details --->
    INSERT INTO CONTACTITEMS (
        CONTACTID,
        VALUETYPE,
        VALUECATEGORY,
        VALUETEXT,
        ITEMSTATUS
    )
    VALUES (
        #new_contactid#,
        'Tags',
        'Tag',
        '#cdtype#',
        'Active'
    )
</cfquery>
