<cfinclude template="/include/perfcount.cfm" />
<!--- Returns the set of countries that have at least one active audunion.
      Used by the Preferences pane to render the "Union Countries"
      multi-select picker so users can only check countries that would
      add unions to their dropdown. --->
<cfquery name="audunion_countries_sel" cachedwithin="#createTimeSpan(0,1,0,0)#">
    SELECT DISTINCT c.countryid, c.countryname
    FROM audunions u
    INNER JOIN countries c ON c.countryid = u.countryid
    WHERE u.isDeleted IS FALSE
    ORDER BY c.countryname
</cfquery>
