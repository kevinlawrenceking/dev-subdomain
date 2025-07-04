<!--- This ColdFusion page handles the insertion of a new contact item into the CONTACTITEMS table. --->

<cfquery name="insert">
    <!--- Insert a new contact item into the CONTACTITEMS table --->
    INSERT INTO CONTACTITEMS (
        CONTACTID,
        VALUETYPE,
        VALUECATEGORY,
        VALUETEXT,
        ITEMSTATUS
    )
    VALUES (
        #CONTACTID#,
        'Business',
        'Email',
        '#workemail#',
        'Active'
    )
</cfquery>
