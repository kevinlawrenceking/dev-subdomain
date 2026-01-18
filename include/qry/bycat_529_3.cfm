<!--- This ColdFusion page retrieves audio records by category from the database, filtering based on provided criteria. --->

<cfquery name="bycat">
    SELECT 
        a.#fid# as ID, 
        a.#fname# as NAME, 
        ac.audCatName, 
        ac.audCatID
    FROM 
        #tname# a
    INNER JOIN 
        audcategories ac ON ac.audcatid = a.audcatid
    WHERE 
        a.isDeleted IS FALSE

    <!--- Check if a new audio category ID is provided and filter accordingly. --->
    <cfif #new_audcatid# is not "0">
        AND a.audcatid = <cfqueryparam value="#new_audcatid#" cfsqltype="cf_sql_integer" />
    </cfif>

    ORDER BY 
        a.#orderby#
</cfquery>
