<!--- This ColdFusion page retrieves audio categories and subcategories based on a given subcategory ID. --->

<cfquery name="cat">
    <!--- Query to select audio categories and subcategories based on the provided subcategory ID --->
    SELECT 
        c.audcatid,
        c.audcatname,
        s.audsubcatid,
        s.audsubcatname 
    FROM 
        audcategories c 
    INNER JOIN 
        audsubcategories s 
    ON 
        s.audcatid = c.audcatid
    WHERE 
        s.audsubcatid = #new_audsubcatid#
</cfquery>
