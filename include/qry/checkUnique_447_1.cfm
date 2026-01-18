<!--- This ColdFusion page checks for the uniqueness of a contact ID in the contact details. --->
<cfquery name="checkUnique">
    <!--- Query to select contact ID from contact details where the unique name is 'Y' and matches the given contact ID. --->
    SELECT d.contactid
    FROM contactdetails d
    WHERE d.#addDaysNo.uniquename# = 'Y'
    AND d.contactid = #contactid#
    LIMIT 1
</cfquery>
