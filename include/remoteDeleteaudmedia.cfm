<!--- This ColdFusion page confirms the deletion of a media item and processes the deletion request. --->

<!--- WO-5.1: Validate numeric inputs --->
<cfset mediaid = val(mediaid) />
<cfset new_secid = val(new_secid) />

<cfinclude template="/include/qry/audmedia_details_226_1.cfm" />

<!--- Save the delete query in a variable for later use. --->
<cfsavecontent variable="dqry">
    <cfoutput>
        update audmedia set IsDeleted = 1 WHERE mediaid = #val(mediaid)#
    </cfoutput>
</cfsavecontent>

<form action="/include/remoteDeleteaudMedia2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <p class="mb-3">Are you sure you want to delete <strong>#htmlEditFormat(audmedia_details.mediaType)#: #htmlEditFormat(audmedia_details.medianame)#</strong>?</p>

        <input type="hidden" name="mediaid" value="#val(mediaid)#" />
        <input type="hidden" name="secid" value="#val(new_secid)#" />
        <input type="hidden" name="dqry" value="#htmlEditFormat(dqry)#" />
    </cfoutput>

    <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Delete</button>
    </div>
</form>
