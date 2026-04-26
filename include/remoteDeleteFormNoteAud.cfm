<!--- This ColdFusion page confirms the deletion of a note and provides a form to submit the deletion request. --->

<form action="/include/deletenote.cfm" method="post" class="needs-validation" novalidate>
    <p class="mb-3">Are you sure you want to delete this note?</p>

    <cfoutput>
        <input type="hidden" name="recid" value="#recid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="returnurl" value="audition" />
    </cfoutput>

    <div class="d-flex justify-content-end gap-2 pt-3 border-top">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Delete</button>
    </div>
</form>
