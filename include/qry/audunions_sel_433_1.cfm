<!--- This ColdFusion page retrieves union information from the database, with optional filtering by country ID and audit category ID. --->
<cfquery name="audunions_sel">
    SELECT 
        u.unionid AS ID,
        u.unionName AS NAME,
        c.countryid,
        u.audcatid
    FROM 
        audunions u
        INNER JOIN countries c ON c.countryid = u.countryid
    WHERE 
        u.isDeleted IS FALSE

    <!--- Filter by country ID if provided --->
    <cfif #new_countryid# IS NOT "">
        AND c.countryid = <cfqueryparam value="#new_countryid#" cfsqltype="cf_sql_varchar" />
    </cfif>

    <!--- Filter by audit category ID if provided --->
    <cfif #new_audcatid# IS NOT "0">
        AND u.audcatid = <cfqueryparam value="#new_audcatid#" cfsqltype="cf_sql_integer" />
    </cfif>

    ORDER BY 
        u.unionname
</cfquery>
