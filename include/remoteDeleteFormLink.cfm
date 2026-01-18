<!--- This ColdFusion page confirms the deletion of a site link and provides a form to submit the deletion request. --->
<cfset siteLinksService = createObject("component", "services.SiteLinksService")>
<cfset linkDetails = siteLinksService.getLinkDetailsById(new_id)>

<cfoutput>
    <center>Are you sure you want to delete your #linkDetails.sitename# link?</center>
</cfoutput>
<p></p>

<!--- Form for deleting the site link --->
<form action="/include/excludelink.cfm" method="post" class="needs-validation" novalidate="novalidate">
    <cfoutput>
        <input type="hidden" name="dd" value="1"/>
        <input type="hidden" name="new_id" value="#linkDetails.id#"/>
        <input type="hidden" name="target_id" value="#linkDetails.sitetypeid#"/>
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Delete</button>
    </div>
</form>
