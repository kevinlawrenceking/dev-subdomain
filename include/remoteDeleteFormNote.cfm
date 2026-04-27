<!--- This ColdFusion page confirms the deletion of a note and processes the deletion action. --->

<form action="/include/deletenote.cfm" method="post" class="needs-validation" novalidate>
    <p class="mb-3">Are you sure you want to delete this note?</p>

    <cfoutput>
        <input type="hidden" name="recid" value="#recid#" />
        <input type="hidden" name="contactid" value="#contactid#" />
        <input type="hidden" name="returnurl" value="contact" />
    </cfoutput>

    <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Delete</button>
    </div>
</form>
