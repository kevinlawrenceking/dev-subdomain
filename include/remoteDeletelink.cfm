<!--- This ColdFusion page prompts the user for confirmation before deleting a specified link. --->

<cfinclude template="/include/qry/audlink_details_237_1.cfm" />

<cfoutput>
    <center>Are you sure you want<BR>to delete <strong>#audlink_details.linkname#</strong>?</center>
</cfoutput>
<p></p>

<!--- Form for deleting the link --->
<form action="/include/remoteDeletelink2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="eventid" value="#eventid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="linkid" value="#linkid#" />
        <input type="hidden" name="secid" value="177" />
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Delete</button>
    </div>
</form>
