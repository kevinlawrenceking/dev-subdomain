<cfinclude template="/include/perfcount.cfm" />
<!--- Retrieves union information filtered by country and audition category.
      Defaults are non-NULL by contract: countryid='US', audcatid=1.
      Empty/non-numeric inputs from upstream are coerced so the inner SQL
      always sees valid filter values. --->
<cfparam name="dbug" default="N" />
<cfparam name="new_countryid" default="US" />
<cfparam name="new_audcatid"  default="1" />

<cfif not len(trim(new_countryid))>
    <cfset new_countryid = "US" />
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

