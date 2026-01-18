<!--- This page retrieves the gender pronoun for the logged-in user from the database. --->
<cfquery name="pronouns">
    <!--- Query to select the gender pronoun for the current user --->
    SELECT 
        genderPronoun 
    FROM 
        genderpronouns_users 
    WHERE 
        userid = #userid#
</cfquery>
