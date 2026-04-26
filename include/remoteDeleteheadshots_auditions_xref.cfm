

<cfinclude template="/include/qry/audmedia_details_226_1.cfm" />

<form action="/include/remoteDeleteheadshots_auditions_xref2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <p class="mb-3">Are you sure you want to remove <strong>#audmedia_details.mediaType#: #audmedia_details.medianame#</strong> from this audition?</p>

        <input type="hidden" name="mediaid" value="#mediaid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="secid" value="#secid#" />
    </cfoutput>

    <div class="d-flex justify-content-end gap-2 pt-3 border-top">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Remove</button>
    </div>
</form>