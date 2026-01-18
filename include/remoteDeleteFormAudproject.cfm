<!--- This ColdFusion page prompts the user for confirmation before deleting an audition project. --->
<center>Are you sure you want to delete this audition project?</center>
<p></p>

<form action="/include/remoteDeleteFormAudprojectDelete.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <!--- Hidden input for RPG ID --->
        <input type="hidden" name="rpgid" value="175" />
        
        <!--- Hidden input for Audition Project ID --->
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <!--- Submit button for deletion confirmation --->
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Delete</button>
    </div>
</form>
