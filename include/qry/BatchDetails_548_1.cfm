<!--- This ColdFusion page retrieves batch details from the contactdetails table based on a list of contact IDs. --->

<cfquery name="BatchDetails">
    <!--- Query to select contact ID and record name from contactdetails where contact ID is in the provided list. --->
    SELECT 
        contactid,
        recordname 
    FROM 
        contactdetails d 
    WHERE 
        d.contactid IN (#idlist#)
</cfquery>
