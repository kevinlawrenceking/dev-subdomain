<!--- This ColdFusion page retrieves contact details, referral details, active contacts, and user pronouns. It redirects if no contact details are found. --->



<cfinclude template="/include/qry/details_456_1.cfm" />

<cfif #details.refer_contact_id# IS NOT "">
    <!--- Retrieve referral details if a referral contact ID exists --->
    <cfinclude template="/include/qry/refer_details_456_2.cfm" />
</cfif>

<!--- Retrieve active contacts for the current user --->
<cfinclude template="/include/qry/results_456_3.cfm" />

<!--- Retrieve gender pronouns for the current user --->
<cfinclude template="/include/qry/pronouns_456_4.cfm" />
<cfquery>
UPDATE fusystemusers u
INNER JOIN (
    SELECT DISTINCT u.suid
    FROM fusystemusers u
    INNER JOIN funotifications n ON n.suid = u.suid
    WHERE u.suStatus = 'Completed' AND n.notstatus = 'Pending'
) AS sub ON sub.suid = u.suid
SET u.suStatus = 'Active'
</cfquery>
<!--- Redirect if no contact details are found --->
<Cfif #details.recordcount# IS "0">
    <cflocation url="/app/contacts/" />
</Cfif>

