<!--- This ColdFusion page retrieves user information based on the provided user ID and displays it in a table if debugging is enabled. --->

<cfparam name="new_userid" default="0" />

<!--- Query to select user information based on user ID --->
<cfinclude template="/include/qry/tname_sel_533_1.cfm" />

<!--- Debugging output if dbug is set to "Y" --->
<cfif #dbug# is "Y">
    <cfoutput>
        SELECT a.#fid# as ID, 
               a.#fname# as NAME
        FROM #tname# a
        WHERE 0=0
        
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

