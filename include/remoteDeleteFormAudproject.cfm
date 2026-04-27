<!--- Prompts for confirmation before deleting an audition project. --->
<form action="/include/remoteDeleteFormAudprojectDelete.cfm" method="post" class="needs-validation" novalidate>
    <p class="mb-3">Are you sure you want to delete this audition project?</p>

    <cfoutput>
        <input type="hidden" name="rpgid" value="175" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
    </cfoutput>

    <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Delete</button>
    </div>
</form>
