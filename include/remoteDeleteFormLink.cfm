<!--- This ColdFusion page confirms the deletion of a site link and provides a form to submit the deletion request. --->
<cfset siteLinksService = createObject("component", "services.SiteLinksService")>
<cfset linkDetails = siteLinksService.getLinkDetailsById(new_id)>

<form action="/include/excludelink.cfm" method="post" class="needs-validation" novalidate="novalidate">
    <cfoutput>
        <p class="mb-3">Are you sure you want to delete your #linkDetails.sitename# link?</p>

        <input type="hidden" name="dd" value="1"/>
        <input type="hidden" name="new_id" value="#linkDetails.id#"/>
        <input type="hidden" name="target_id" value="#linkDetails.sitetypeid#"/>
    </cfoutput>

    <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-danger">Delete</button>
    </div>
</form>
