<!---
    PURPOSE: Find duplicate contacts by name for current user
    AUTHOR: Kevin King
    DATE: 2025-08-07
    PARAMETERS: userid
--->

<cfquery name="qDuplicatesByName" datasource="#application.dsn#">
    SELECT 
        contactfirst,
        contactlast,
        userid,
        COUNT(*) as duplicate_count,
        GROUP_CONCAT(contactid ORDER BY contactid) as contact_ids
    FROM contactdetails 
    WHERE isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
      AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND contactfirst IS NOT NULL 
      AND contactlast IS NOT NULL
      AND TRIM(contactfirst) != ''
      AND TRIM(contactlast) != ''
    GROUP BY contactfirst, contactlast, userid 
    HAVING COUNT(*) > 1 
    ORDER BY duplicate_count DESC, contactlast, contactfirst
</cfquery>
