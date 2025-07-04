<!--- This ColdFusion page retrieves the title and company name for a specific page based on the page ID. --->
<cfquery name="FindModalTitle">
    <!--- Query to select page title and company name based on page ID --->
    SELECT 
        p.pgTitle,
        c.compname
    FROM 
        pgpages p
    INNER JOIN 
        pgcomps c ON c.compID = p.compID
    INNER JOIN 
        pgapps a ON a.appID = c.appid
    WHERE 
        p.pgid = #rpgid#
</cfquery>
