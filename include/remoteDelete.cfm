<!--- This ColdFusion page confirms the deletion of a media file and processes the deletion request. --->

<!--- WO-5.1: Validate numeric inputs --->
<cfset mediaid = val(mediaid) />
<cfset eventid = val(eventid) />
<cfset audprojectid = val(audprojectid) />
<cfset secid = val(secid) />

<cfinclude template="/include/qry/attachdetails_109_1.cfm" />

<!--- Save the delete query in a variable. --->
<cfsavecontent variable="dqry">
    <cfoutput>
        update audmedia set IsDeleted = 1 WHERE mediaid = #val(mediaid)#
    </cfoutput>
</cfsavecontent>

<form action="/include/remoteDelete2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <p class="mb-3">Are you sure you want to delete <strong>#htmlEditFormat(audmedia_details.mediafilename)#</strong>?</p>

        <input type="hidden" name="mediaid" value="#val(mediaid)#" />
        <input type="hidden" name="eventid" value="#val(eventid)#" />
        <input type="hidden" name="audprojectid" value="#val(audprojectid)#" />
        <input type="hidden" name="secid" value="#val(secid)#" />
        <input type="hidden" name="dqry" value="#htmlEditFormat(dqry)#" />
    </cfoutput>

    <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Delete</button>
    </div>
</form>

