<!--- This ColdFusion page retrieves the minimum user ID and user names from the taousers table, grouped by user name. --->

<cfquery name="users">
    <!--- Query to select minimum user ID and user names from taousers table --->
    SELECT 
        MIN(u.userid) AS id,
        u.recordname AS name
    FROM 
        taousers u 
    GROUP BY 
        u.recordname
    ORDER BY 
        u.recordname
</cfquery>
