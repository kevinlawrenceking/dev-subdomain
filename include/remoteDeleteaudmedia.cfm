<!--- This ColdFusion page confirms the deletion of a media item and processes the deletion request. --->

<cfinclude template="/include/qry/audmedia_details_226_1.cfm" />

<cfoutput>
    <center>
        Are you sure you want<BR>to delete <strong>#audmedia_details.mediaType#: #audmedia_details.medianame#</strong>?
    </center>
</cfoutput>
<p></p>

<!--- Save the delete query in a variable for later use. --->
<cfsavecontent variable="dqry">
    <cfoutput>
        update audmedia set IsDeleted = 1 WHERE mediaid = #mediaid#
    </cfoutput>
</cfsavecontent>

<!--- Form to confirm deletion of the media item. --->
<form action="/include/remoteDeleteaudMedia2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="mediaid" value="#mediaid#" />
        <input type="hidden" name="secid" value="#new_secid#" />
        <input type="hidden" name="dqry" value="#dqry#" />
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Delete</button>
    </div>
</form>
