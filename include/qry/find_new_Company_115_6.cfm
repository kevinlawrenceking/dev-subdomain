<cfinclude template="/include/perfcount.cfm" />
<!--- DIR-LNK-WO-7 (S-2): read the company from the contactCompany COLUMN, not the Company
      contactitem. The bridge is disabled (no new Company items on link) and WO-6 unlinked-panel
      edits write the column with no item (Q1e), so the item-based read (SELcontactitems_23892) had
      been returning blank for column-sourced contacts since WO-6 shipped - a discovered live defect
      fixed here, not a WO-7 regression. contactdetails is the active-only view; the non-blank filter
      keeps recordcount at 1 only when a company exists, preserving exportContacts.cfm's
      "recordcount eq 1" gate. SELcontactitems_23892 loses its only caller and retires with WO-11. --->
<cfquery name="find_new_Company">
    SELECT contactCompany AS new_Company
    FROM contactdetails
    WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
      AND contactCompany IS NOT NULL
      AND TRIM(contactCompany) <> ''
</cfquery>
