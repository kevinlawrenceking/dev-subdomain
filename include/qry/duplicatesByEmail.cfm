<!---
    PURPOSE: Find duplicate contacts by email for current user
    AUTHOR: Kevin King
    DATE: 2025-08-07
    PARAMETERS: userid
--->

<cfquery name="qDuplicatesByEmail" datasource="#application.dsn#">
    SELECT 
        ci.valuetext as email,
        cd.userid,
        COUNT(DISTINCT cd.contactid) as duplicate_count,
        GROUP_CONCAT(DISTINCT cd.contactid ORDER BY cd.contactid) as contact_ids,
        GROUP_CONCAT(DISTINCT CONCAT(cd.contactfirst, ' ', cd.contactlast) ORDER BY cd.contactid SEPARATOR '|') as contact_names
    FROM contactitems ci
    INNER JOIN contactdetails cd ON ci.contactid = cd.contactid
    INNER JOIN itemcategories ic ON ci.catid = ic.catid
    WHERE cd.isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
      AND cd.userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND ic.valueCategory = 'Email'
      AND ci.valuetext IS NOT NULL
      AND TRIM(ci.valuetext) != ''
      AND ci.valuetext LIKE '%@%'
    GROUP BY ci.valuetext, cd.userid 
    HAVING COUNT(DISTINCT cd.contactid) > 1 
    ORDER BY duplicate_count DESC, ci.valuetext
</cfquery>
