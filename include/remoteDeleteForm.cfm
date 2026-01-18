<!--- This ColdFusion page handles the deletion confirmation for a record in the RPG database. --->
<cfsilent>

    <cfinclude template="rpg_load.cfm" />

    <cfparam name="t1" default="0" />
    <cfparam name="t2" default="0" />
    <cfparam name="t3" default="0" />
    <cfparam name="t4" default="0" />
    <cfparam name="contactid" default="0" />

</cfsilent>

<cfinclude template="/include/qry/FindKey_228_1.cfm" />
<cfinclude template="/include/qry/Findrec_228_2.cfm" />

<!--- Display confirmation message for deletion --->
<cfoutput>
    <center>Are you sure you want to delete?</center>
</cfoutput>
<p></p>

<!--- Prepare the SQL update query for deletion --->
<cfsavecontent variable="dqry">
    <cfoutput>
        update #rpg_comptable#_tbl set IsDeleted = 1 WHERE #findkey.fname# = #recid#
    </cfoutput>
</cfsavecontent>

<!--- Form for submitting the deletion request --->
<form action="/include/remoteDeleteFormDelete.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="rpgid" value="#rpgid#" />
        <input type="hidden" name="t1" value="#t1#" />
        <input type="hidden" name="t2" value="#t2#" />
        <input type="hidden" name="t3" value="#t3#" />
        <input type="hidden" name="t4" value="#t4#" />
        <input type="hidden" name="dqry" value="#dqry#" />
        <input type="hidden" name="pgdir" value="#pgdir#" />
        <input type="hidden" name="recid" value="#recid#" />

        <!--- Include contact ID if defined --->
        <cfif isdefined('contactid')>
            <input type="hidden" name="contactid" value="#contactid#" />
        </cfif>

        <!--- Include user ID if defined --->
        <cfif isdefined('userid')>
            <input type="hidden" name="userid" value="#userid#" />
        </cfif>
    </cfoutput>

    <p>&nbsp;</p>
    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: red; border: red" type="submit">Delete</button>
    </div>
</form>
