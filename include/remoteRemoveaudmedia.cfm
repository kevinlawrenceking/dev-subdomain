<!--- This ColdFusion page confirms the removal of a media item and processes the deletion request. --->

<!--- WO-5.1: Validate numeric inputs --->
<cfset mediaid = val(mediaid) />
<cfset audprojectid = val(audprojectid) />
<cfset secid = val(secid) />

<cfinclude template="/include/qry/audmedia_details_226_1.cfm" />

<!--- Prepare the SQL delete query for the media item. --->
<cfsavecontent variable="dqry">
    <cfoutput>
        DELETE FROM audmedia_auditions_xref
        WHERE mediaid = #val(mediaid)#
        AND audprojectid = #val(audprojectid)#
    </cfoutput>
</cfsavecontent>

<form action="/include/remoteRemoveaudMedia2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <p class="mb-3">Are you sure you want to remove <strong>#htmlEditFormat(audmedia_details.mediaType)#: #htmlEditFormat(audmedia_details.medianame)#</strong>?</p>

        <input type="hidden" name="mediaid" value="#val(mediaid)#" />
        <input type="hidden" name="audprojectid" value="#val(audprojectid)#" />
        <input type="hidden" name="secid" value="#val(secid)#" />
        <input type="hidden" name="dqry" value="#htmlEditFormat(dqry)#" />
    </cfoutput>

    <div class="d-flex justify-content-end gap-2 pt-3 border-top">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Remove</button>
    </div>
</form>

