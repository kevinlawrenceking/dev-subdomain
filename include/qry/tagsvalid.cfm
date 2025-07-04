<!--- This ColdFusion page retrieves user tags and formats them into a list for display. --->

<cfinclude template="/include/qry/tagsvalid_542_1.cfm" />		

<cfsavecontent variable="taglist">
    <!--- Save the output of the tags into a variable for later use. --->
    <cfoutput query="tagsvalid">
        {value: "#tagsvalid.tagname#", text: "#tagsvalid.tagname#"}
        <cfif #tagsvalid.currentrow# is not "#tagsvalid.recordcount#">,</cfif>
    </cfoutput>
</cfsavecontent>

