<!--- This ColdFusion page confirms the deletion of an audition and submits the deletion request. --->

<cfinclude template="/include/qry/details_229_1.cfm" />

<form action="/include/remoteDeleteFormAudDelete.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <p class="mb-3">Are you sure you want to delete this #this.formatDate(details.eventStart)# audition?</p>

        <input type="hidden" name="rpgid" value="175" />
        <input type="hidden" name="eventid" value="#eventid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="audroleid" value="#audroleid#" />
    </cfoutput>

    <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Delete</button>
    </div>
</form>
