<!--- Prompts the user for confirmation before soft-deleting a contact (relationship). --->
<cfparam name="url.contactid" default="0" />

<center>Are you sure you want to delete this relationship?</center>
<p></p>

<form action="/include/remoteDeleteFormContactDelete.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="contactid" value="#url.contactid#" />
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Delete</button>
    </div>
</form>
