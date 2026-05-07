<!--- Saves the user's audition-union country preferences as a CSV on
      taousers_tbl.prefCountryIDList. Only countryids that actually have
      at least one active audunion are accepted -- prevents arbitrary
      values from being written through the form. --->

<cfparam name="form.pref_countries" default="" />

<!--- Whitelist of valid countryids (those that have active audunions) --->
<cfquery name="qValidCountries">
    SELECT DISTINCT countryid
    FROM audunions
    WHERE isDeleted IS FALSE
</cfquery>
<cfset validList = valueList(qValidCountries.countryid) />

<!--- Build the CSV from submitted checkboxes, keeping only whitelisted codes --->
<cfset selected = "" />
<cfloop list="#form.pref_countries#" index="cid">
    <cfset cid = trim(cid) />
    <cfif len(cid) AND listFindNoCase(validList, cid) AND NOT listFindNoCase(selected, cid)>
        <cfset selected = listAppend(selected, cid) />
    </cfif>
</cfloop>

<!--- Never persist an empty pref -- always fall back to 'US' --->
<cfif NOT len(selected)>
    <cfset selected = "US" />
</cfif>

<cfquery name="updPref">
    UPDATE taousers_tbl
    SET prefCountryIDList = <cfqueryparam value="#selected#" cfsqltype="cf_sql_varchar" maxlength="50" />
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer" />
</cfquery>

<!--- Bust the fetchUsers session cache so the next page render reflects the change --->
<cfset session.bustUserCache = true />

<cflocation url="/app/myaccount/?new_pgid=124&t4=1" addtoken="false" />
