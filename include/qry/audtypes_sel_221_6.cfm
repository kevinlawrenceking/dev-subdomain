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
        <cfif isDefined("cat") and cat.recordCount gt 0 and val(cat.audcatid) gt 0>
            AND audcategories LIKE <cfqueryparam value="%#val(cat.audcatid)#%" cfsqltype="cf_sql_varchar" />
        </cfif>
    ORDER BY 
        audtype
</cfquery>
