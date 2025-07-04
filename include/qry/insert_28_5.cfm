<!--- This ColdFusion code inserts a new contact item into the CONTACTITEMS table --->
<cfquery name="insert">
    <!--- Insert a new record into the CONTACTITEMS table --->
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
