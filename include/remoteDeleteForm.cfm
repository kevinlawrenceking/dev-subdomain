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

<!--- WO-5.1: Whitelist validation for dynamic identifiers --->
<cfif NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(rpg_comptable))>
    <cflog file="remoteDeleteForm" text="BLOCKED: invalid table name rpg_comptable='#htmlEditFormat(rpg_comptable)#'" />
    <cfabort>
</cfif>
<cfif NOT reFindNoCase("^[a-z_][a-z0-9_]{0,63}$", trim(findkey.fname))>
    <cflog file="remoteDeleteForm" text="BLOCKED: invalid column name fname='#htmlEditFormat(findkey.fname)#'" />
    <cfabort>
</cfif>
<cfset recid = val(recid) />

<!--- Display confirmation message for deletion --->
<cfoutput>
    <center>Are you sure you want to delete?</center>
</cfoutput>
<p></p>

<!--- Prepare the SQL update query for deletion --->
<cfsavecontent variable="dqry">
    <cfoutput>
        update #trim(rpg_comptable)#_tbl set IsDeleted = 1 WHERE #trim(findkey.fname)# = #val(recid)#
    </cfoutput>
</cfsavecontent>

<!--- Form for submitting the deletion request --->
<form action="/include/remoteDeleteFormDelete.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="rpgid" value="#val(rpgid)#" />
        <input type="hidden" name="t1" value="#val(t1)#" />
        <input type="hidden" name="t2" value="#val(t2)#" />
        <input type="hidden" name="t3" value="#val(t3)#" />
        <input type="hidden" name="t4" value="#val(t4)#" />
        <input type="hidden" name="dqry" value="#htmlEditFormat(dqry)#" />
        <input type="hidden" name="pgdir" value="#htmlEditFormat(pgdir)#" />
        <input type="hidden" name="recid" value="#val(recid)#" />

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
