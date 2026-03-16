<!--- This ColdFusion page confirms the deletion of a media file and processes the deletion request. --->

<!--- WO-5.1: Validate numeric inputs --->
<cfset mediaid = val(mediaid) />
<cfset eventid = val(eventid) />
<cfset audprojectid = val(audprojectid) />
<cfset secid = val(secid) />

<cfinclude template="/include/qry/attachdetails_109_1.cfm" />

<cfoutput>
    <center>Are you sure you want<BR>to delete <strong>#htmlEditFormat(audmedia_details.mediafilename)#</strong>?</center>
</cfoutput>
<p></p>

<!--- Save the delete query in a variable. --->
<cfsavecontent variable="dqry">
    <cfoutput>
        update audmedia set IsDeleted = 1 WHERE mediaid = #val(mediaid)#
    </cfoutput>
</cfsavecontent>

<!--- Form for submitting the deletion request. --->
<form action="/include/remoteDelete2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="mediaid" value="#val(mediaid)#" />
        <input type="hidden" name="eventid" value="#val(eventid)#" />
        <input type="hidden" name="audprojectid" value="#val(audprojectid)#" />
        <input type="hidden" name="secid" value="#val(secid)#" />
        <input type="hidden" name="dqry" value="#htmlEditFormat(dqry)#" />
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Delete</button>
    </div>
</form>

