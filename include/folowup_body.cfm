
<cfinclude template="/include/qry/fetch_folowup.cfm" >
<cfoutput>

<p>&nbsp;</p>
            <p>This audition is in the past.  Do you want to add <strong>#details.contactfullname#</strong> to a Follow Up System?<p>
<p>&nbsp;</p>
<i><p>Clicking Add will add #details.contactfullname# to a follow-up system and take you to their relationship details page.</i><p>
</cfoutput>
<form action="/include/systemchange.cfm">
<cfoutput>
<input type="hidden" name="contactid" value="#followup_contactid#" />

<input type="hidden" name="suid" value="0" />
<input type="hidden" name="new_systemtype" value="Follow Up"  />

</cfoutput>
         <div>
         <center> 
         <input name="submit" type="submit" value="Add" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" />
         </center>
         </div>

</form>