<!--- This ColdFusion page retrieves active audio types based on the specified category. --->

<cfquery name="audtypes_sel">
    <!--- Query to select audio types that are not deleted and match the specified category. --->
    SELECT 
        audtypeid AS id, 
        audtype AS name, 
        audcategories 
    FROM 
        audtypes 
    WHERE 
        isdeleted = 0 
        AND audcategories LIKE '%#cat.audcatid#%' 
    ORDER BY 
        audtype
</cfquery>
