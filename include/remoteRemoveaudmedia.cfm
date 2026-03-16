<!--- This ColdFusion page confirms the removal of a media item and processes the deletion request. --->

<!--- WO-5.1: Validate numeric inputs --->
<cfset mediaid = val(mediaid) />
<cfset audprojectid = val(audprojectid) />
<cfset secid = val(secid) />

<cfinclude template="/include/qry/audmedia_details_226_1.cfm" />

<cfoutput>
    <center>Are you sure you want<BR>to remove <strong>#htmlEditFormat(audmedia_details.mediaType)#: #htmlEditFormat(audmedia_details.medianame)#</strong>?</center>
</cfoutput>
<p></p>

<!--- Prepare the SQL delete query for the media item. --->
<cfsavecontent variable="dqry">
    <cfoutput>
        DELETE FROM audmedia_auditions_xref
        WHERE mediaid = #val(mediaid)#
        AND audprojectid = #val(audprojectid)#
    </cfoutput>
</cfsavecontent>

<!--- Form to confirm and submit the deletion of the media item. --->
<form action="/include/remoteRemoveaudMedia2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="mediaid" value="#val(mediaid)#" />
        <input type="hidden" name="audprojectid" value="#val(audprojectid)#" />
        <input type="hidden" name="secid" value="#val(secid)#" />
        <input type="hidden" name="dqry" value="#htmlEditFormat(dqry)#" />
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Remove</button>
    </div>
</form>

