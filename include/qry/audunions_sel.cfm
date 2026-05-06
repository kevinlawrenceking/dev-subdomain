<cfinclude template="/include/perfcount.cfm" />
<!--- Retrieves union information filtered by country (CSV) and audition
      category. Resolution order for new_countryid:
        1. Explicit caller value (any non-empty string -- single code or CSV)
        2. Logged-in user's prefCountryIDList from taousers_tbl
        3. Fallback 'US'
      audcatid defaults to 1; non-numeric or <1 is coerced. --->
<cfparam name="dbug" default="N" />
<cfparam name="new_countryid" default="" />
<cfparam name="new_audcatid"  default="1" />

<cfif not len(trim(new_countryid))>
    <cfif structKeyExists(session, "userid") and isNumeric(session.userid)>
        <cfquery name="qPrefCountry">
            SELECT prefCountryIDList
            FROM taousers_tbl
            WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfif qPrefCountry.recordcount and len(trim(qPrefCountry.prefCountryIDList))>
            <cfset new_countryid = qPrefCountry.prefCountryIDList />
        <cfelse>
            <cfset new_countryid = "US" />
        </cfif>
    <cfelse>
        <cfset new_countryid = "US" />
    </cfif>
</cfif>

<cfif not isNumeric(new_audcatid) or new_audcatid lt 1>
    <cfset new_audcatid = 1 />
</cfif>

<!--- Dev-only visibility: surface the resolved filter values in page source --->
<cfif findNoCase("dev.", cgi.server_name) gt 0>
    <cfoutput><!-- audunions_sel filter: countryid=#new_countryid# audcatid=#new_audcatid# --></cfoutput>
</cfif>

<!--- Query to select unions based on filters --->
<cfinclude template="/include/qry/audunions_sel_433_1.cfm" />

