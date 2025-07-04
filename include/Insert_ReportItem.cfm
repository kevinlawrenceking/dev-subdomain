<!--- This ColdFusion page processes user IDs and labels, ensuring they are set to default values if not provided. It includes necessary query files for data retrieval and insertion. --->

<cfinclude template="/include/qry/findid_146_1.cfm" />

<cfoutput>
    <!--- Set new_ID from the query result --->
    <cfset new_ID = #findid.new_id# />
</cfoutput>

<cfoutput>
    <!--- Check if new_id is empty and set to 0 if true --->
    <cfif #new_id# is "">
        <cfset new_id = 0 />
    </cfif>

    <!--- Check if userid is empty and set to 0 if true --->
    <cfif #userid# is "">
        <cfset userid = 0 />
    </cfif>

    <!--- Replace single quotes in new_label and store in new_label_new --->
    <cfset new_label_new = "#Replace('#new_label#','''','','All')#" />
</cfoutput>

<cfinclude template="/include/qry/Insert_ReportItems_146_2.cfm" />
