<!--- This ColdFusion page retrieves audio categories and user-related data from the database based on specified filters. --->
<cfquery name="#tname#_sel">
    SELECT 
        a.#fid# as ID, 
        a.#fname# as NAME, 
        ac.audCatName, 
        ac.audCatId, 
        a.userid
    FROM 
        #tname# a
    INNER JOIN 
        audcategories ac 
    ON 
        ac.audcatid = a.audcatid

    <!--- Check if new_audcatid is not zero and filter results accordingly --->
    <cfif #new_audcatid# is not "0">
        AND a.audcatid = <cfqueryparam value="#new_audcatid#" cfsqltype="cf_sql_integer" />
    </cfif>

    <!--- Filter results by user ID --->
    AND a.userid = <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer" />

    <!--- Check if new_userid is not zero and filter results accordingly --->
    <cfif #new_userid# is not "0">
        AND a.userid = <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer" />
    </cfif>

    ORDER BY 
        ac.audcatname, 
        a.#orderby#
</cfquery>
