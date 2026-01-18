<!--- This ColdFusion page retrieves user data from a specified table and displays it in a formatted table if debugging is enabled. --->
<cfparam name="new_userid" default="0" />

<!--- Query to select user data from the specified table --->
<cfinclude template="/include/qry/tname_sel_532_1.cfm" />

<!--- Debugging output to display the SQL query and results --->
<cfif #dbug# is "Y">
    <cfoutput>
        SELECT a.#fid# as ID, 
               a.#fname# as NAME
        FROM #tname# a
        WHERE a.isDeleted is false
        
        <!--- Check if a new user ID is provided for debugging output --->
        <cfif #new_userid# is not "0">
            AND a.userid =  #new_userid# 
        </cfif>
        
        ORDER BY a.#orderby#
    </cfoutput>
    
    <h3>
        <cfoutput>#new_userid# - #tname#_sel</cfoutput>
    </h3>

    <!--- Display the results in a table format --->
    <cftable query="#tname#_sel" colheaders=true border="true" htmltable>
        <cfcol header="ID" text="#ID#" />
        <cfcol header="NAME" text="#NAME#" />
    </cftable>
</cfif>

