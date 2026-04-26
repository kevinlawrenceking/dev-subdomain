<!--- Prompts the user for confirmation before soft-deleting a contact (relationship). --->
<cfparam name="url.contactid" default="0" />

<form action="/include/remoteDeleteFormContactDelete.cfm" method="post" class="needs-validation" novalidate>
    <p class="mb-3">Are you sure you want to delete this relationship?</p>

    <cfoutput>
        <input type="hidden" name="contactid" value="#url.contactid#" />
    </cfoutput>

    <div class="d-flex justify-content-end gap-2 pt-3 border-top">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Delete</button>
    </div>
</form>
