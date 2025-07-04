<!--- This ColdFusion page confirms the deletion of an audition and submits the deletion request. --->

<cfinclude template="/include/qry/details_229_1.cfm" />

<cfoutput>
    <center>Are you sure you want to delete this #this.formatDate(details.eventStart)# audition?</center>
</cfoutput>
<p></p>

<!--- Form for submitting the delete request --->
<form action="/include/remoteDeleteFormAudDelete.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="rpgid" value="175" />
        <input type="hidden" name="eventid" value="#eventid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="audroleid" value="#audroleid#" />
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Delete</button>
    </div>
</form>
