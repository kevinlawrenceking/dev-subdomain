<!--- This ColdFusion page retrieves and displays data from the audunions_sel query based on parameters provided. --->
<cfparam name="dbug" default="N" />
<cfparam name="new_audcatid" default="0" />
<cfparam name="new_countryid" default="US" />

<cfinclude template="/include/qry/audunions_sel_40_1.cfm" />

<!--- Check if debugging is enabled --->
<cfif #dbug# is "Y">
    
    <!--- Display the country ID and a header for the data table --->
    <h3>
        <cfoutput>#new_countryid# - Audunions_sel</cfoutput>
    </h3>

    <!--- Create a table to display the query results --->
    <cftable query="audunions_sel" colheaders=true border="true" htmltable>
        <cfcol header="ID" text="#ID#" />
        <cfcol header="NAME" text="#NAME#" />
    </cftable>

</cfif>
