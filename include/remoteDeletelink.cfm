<!--- This ColdFusion page prompts the user for confirmation before deleting a specified link. --->

<cfinclude template="/include/qry/audlink_details_237_1.cfm" />

<form action="/include/remoteDeletelink2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <p class="mb-3">Are you sure you want to delete <strong>#audlink_details.linkname#</strong>?</p>

        <input type="hidden" name="eventid" value="#eventid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="linkid" value="#linkid#" />
        <input type="hidden" name="secid" value="177" />
    </cfoutput>

    <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Delete</button>
    </div>
</form>
