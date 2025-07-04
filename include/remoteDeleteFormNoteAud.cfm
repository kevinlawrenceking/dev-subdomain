<!--- This ColdFusion page confirms the deletion of a note and provides a form to submit the deletion request. --->

<cfoutput>
    <center>Are you sure you want to delete this note?</center>
</cfoutput>
<p></p>

<!--- Form to handle note deletion --->
<form action="/include/deletenote.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="recid" value="#recid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="returnurl" value="audition" />
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <!--- Submit button for deletion confirmation --->
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Delete</button>
    </div>
</form>
