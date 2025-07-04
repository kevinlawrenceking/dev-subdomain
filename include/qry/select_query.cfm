
<cfset dbug = "N" />

<!--- Query to select records from the database table ---> 
<cfinclude template="/include/qry/tname_sel_531_1.cfm" />

<!--- Check if debugging is enabled to display the results ---> 
<cfif #dbug# is "Y">
    
    <h3>
        <cfoutput>#tname#_sel</cfoutput>
    </h3>

    <!--- Display the query results in a table format ---> 
    <cftable query="#tname#_sel" colheaders=true border="true" htmltable>
        <cfcol header="ID" text="#ID#" />
        <cfcol header="NAME" text="#NAME#" />
    </cftable>
    
</cfif>
