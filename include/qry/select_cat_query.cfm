<!--- This ColdFusion page retrieves and displays records from a specified table, with optional filtering by category. --->
<cfset dbug = "y" />
<cfparam name="new_audcatid" default="0" />

<!--- Query to select records from the specified table with optional category filtering --->
<cfinclude template="/include/qry/tname_sel_529_1.cfm" />

<cfif #dbug# is "n">
    <!--- Display the records if debugging is not enabled --->
    <h3>
        <cfoutput>#tname#_sel all records </cfoutput>
    </h3>

    <cftable query="#tname#_sel" colheaders="true" border="true" htmltable>
        <cfcol header="ID" text="#ID#" />
        <cfcol header="NAME" text="#NAME#" />
        <cfcol header="CATEGORY" text="#audCatName#" />
    </cftable>

    <!--- Query to get all categories --->
    <cfinclude template="/include/qry/cats_529_2.cfm" />

    <!--- Loop through each category to display records by category --->
    <cfloop query="cats">
        <cfset new_audcatid = cats.audcatid />

        <!--- Query to select records for the current category --->
        <cfinclude template="/include/qry/bycat_529_3.cfm" />

        <h3>
            <cfoutput>#tname# - [#cats.audcatid#] #cats.audcatname#</cfoutput>
        </h3>

        <cfif #bycat.recordcount# is not "0">
            <cftable query="bycat" colheaders="true" border="true" htmltable="true">
                <cfcol header="ID" text="#ID#" />
                <cfcol header="NAME" text="#NAME#" /> 
            </cftable>
        <cfelse>
            <p>No Records.</p>
        </cfif>
    </cfloop>
</cfif>

