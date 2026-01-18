<!--- This ColdFusion page processes audition locations and project details based on the provided parameters. --->

<cfif #new_audlocid# is "custom">
    <!--- Check if the new audition location ID is custom and include the relevant query. --->
    <cfinclude template="/include/qry/audlocations_ins_218_1.cfm" />
</cfif>

<!--- Include the project query to retrieve project details. --->
<cfinclude template="/include/qry/findproject_218_2.cfm" />

<cfset new_projname = findproject.projname />
<cfset new_projdescription = findproject.projdescription />
<cfset new_contactid = findproject.contactid />

<!--- Include the auditions insert query. --->
<cfinclude template="/include/qry/auditions_ins.cfm" />

<!--- Prepare the return URL for redirection after processing. --->
<cfoutput>
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&eventid=#new_eventid#&secid=#secid#&focusid=#focusid#" />
</cfoutput>

<!--- Redirect to the prepared return URL. --->
<cflocation url="#returnurl#" />
