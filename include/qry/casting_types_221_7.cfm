<!--- This ColdFusion page retrieves casting types for a specific user from the database. --->

<cfquery name="casting_types">
    <!--- Query to select casting tags for the user that are not deleted. --->
    SELECT 
        tagid AS id,
        tagname AS name 
    FROM 
        tags_user 
    WHERE 
        iscasting IS TRUE 
        AND userid = #userid# 
        AND isdeleted = 0 
    ORDER BY 
        tagname
</cfquery>
