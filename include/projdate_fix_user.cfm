<!--- This ColdFusion page processes various queries and updates based on the debug mode. --->

<cfset dbug = "y">



<!--- Loop through query y and include the update template. --->
<cfloop query="y">
    <cfinclude template="/include/qry/pupdate_191_5.cfm" />
</cfloop>

<!--- Include the fourth query template. --->
<cfinclude template="/include/qry/z_191_6.cfm" />

<!--- Check if debugging is enabled and output the record count of query z. --->
<cfif #dbug# is "Y">
    <cfoutput>
        #z.recordcount#
        <br>
    </cfoutput>
</cfif>

<!--- Loop through query z and include the update template. --->
<cfloop query="z">
    <cfinclude template="/include/qry/update_191_7.cfm" />
</cfloop>

<!--- Include the delete query template. --->
<cfinclude template="/include/qry/delete_191_8.cfm" />

<!--- Check if debugging is enabled and output the current time again. --->
<cfif #dbug# is "Y">
    <cfoutput>
        #now()#
        <br>
    </cfoutput>
</cfif>

<!--- Include the fix query template. --->
<cfinclude template="/include/qry/fix_191_9.cfm" />

<!--- Include the correct query template. --->
<cfinclude template="/include/qry/correct_191_10.cfm" />

<!--- Include the remove query template. --->
<cfinclude template="/include/qry/remove_191_11.cfm" />

<!--- Include the second remove query template. --->
<cfinclude template="/include/qry/remove2_191_12.cfm" />
