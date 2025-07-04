<!--- This ColdFusion page confirms the removal of a media item and processes the deletion request. --->

<cfinclude template="/include/qry/audmedia_details_226_1.cfm" />

<cfoutput>
    <center>Are you sure you want<BR>to remove <strong>#audmedia_details.mediaType#: #audmedia_details.medianame#</strong>?</center>
</cfoutput>
<p></p>

<!--- Prepare the SQL delete query for the media item. --->
<cfsavecontent variable="dqry">
    <cfoutput>
        DELETE FROM audmedia_auditions_xref 
        WHERE mediaid = #mediaid# 
        AND audprojectid = #audprojectid#
    </cfoutput>
</cfsavecontent>

<!--- Form to confirm and submit the deletion of the media item. --->
<form action="/include/remoteRemoveaudMedia2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="mediaid" value="#mediaid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="secid" value="#secid#" />
        <input type="hidden" name="dqry" value="#dqry#" />
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Remove</button>
    </div>
</form>

