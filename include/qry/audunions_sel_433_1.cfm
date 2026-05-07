<cfinclude template="/include/perfcount.cfm" />
<!--- Retrieves union information, optionally filtered by country and
      audition category.
      Post-2026-05-05: audCatIDList is a CSV string (e.g. "1,2,6");
        category match uses FIND_IN_SET.
      Post-2026-05-06: new_countryid is a CSV (e.g. "US,CA") sourced from
        taousers_tbl.prefCountryIDList; country match uses FIND_IN_SET so
        a user can see unions from multiple countries in one dropdown. --->
<cfquery name="audunions_sel">
    SELECT
        u.unionid       AS ID,
        u.unionName     AS NAME,
        c.countryid,
        c.countryname,
        u.audCatIDList
    FROM
        audunions u
        INNER JOIN countries c ON c.countryid = u.countryid
    WHERE
        u.isDeleted IS FALSE

    <!--- Filter by country preference (CSV) if provided --->
    <cfif #new_countryid# IS NOT "">
        AND FIND_IN_SET(c.countryid, <cfqueryparam value="#new_countryid#" cfsqltype="cf_sql_varchar" />) > 0
    </cfif>

    <!--- Filter by audition category ID if provided --->
    <cfif #new_audcatid# IS NOT "0">
        AND FIND_IN_SET(<cfqueryparam value="#new_audcatid#" cfsqltype="cf_sql_integer" />, u.audCatIDList) > 0
    </cfif>

    ORDER BY
        c.countryid,
        u.unionname
</cfquery>
