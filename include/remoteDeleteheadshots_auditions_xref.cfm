

<cfinclude template="/include/qry/audmedia_details_226_1.cfm" />

<cfoutput>
    <center>Are you sure you want<BR>to remove <strong>#audmedia_details.mediaType#: #audmedia_details.medianame#</strong> from this audition?</center>
</cfoutput>
<p></p>
<form action="/include/remoteDeleteheadshots_auditions_xref2.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="mediaid" value="#mediaid#" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="secid" value="#secid#" />
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Remove</button>
    </div>
</form>