<cfparam name="pgtable" default="" />
<cfparam name="pgid" default="" />

<!--- Whitelist validation: only allow safe identifier characters for table/column names --->
<cfif NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(pgtable)) OR NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(pgid))>
    <cflog file="release_fix_qry" text="BLOCKED: invalid identifier pgtable='#htmlEditFormat(pgtable)#' pgid='#htmlEditFormat(pgid)#'" />
    <cfthrow message="Invalid table or column name" detail="pgtable and pgid must be valid SQL identifiers" />
</cfif>

<cfset pgtable = trim(pgtable) />
<cfset pgid = trim(pgid) />

<cfquery name="x" result="result">
INSERT INTO actorsbusinessoffice.#pgtable#
SELECT * FROM new_development.#pgtable# WHERE #pgid# NOT IN (SELECT #pgid# FROM actorsbusinessoffice.#pgtable#);
</cfquery>

<cfdump var="#result#" />
