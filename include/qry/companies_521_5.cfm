<!--- This ColdFusion page retrieves distinct company values associated with a specific user from the database. --->

<cfquery name="companies">
    SELECT DISTINCT 
        i.valueCompany AS new_valuecompany
    FROM 
        contactitems i
    INNER JOIN 
        contactdetails d ON d.contactid = i.contactid
    WHERE 
        i.VALUEcategory = 'company' 
        AND d.userid = #userid#
        AND i.valuecompany <> '' 
        AND i.valueCompany IS NOT NULL
        AND i.valuecompany <> 'Custom'
    ORDER BY 
        i.valuecompany
</cfquery>
