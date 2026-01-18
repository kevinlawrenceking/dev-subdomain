<cfset dbug="n" />

<!--- Set default value for idlist --->
<cfparam name="idlist" default="0" />

<!--- Check if session idlist is not defined, then set it to idlist --->
<Cfif not #isdefined('idlist')#>
    <cfset idlist = idlist />
</cfif>

<!--- If idlist is "0" and session idlist is not "0", set idlist to session idlist --->
<cfif #idlist# is "0" and #idlist# is not "0">
    <cfset idlist = idlist />
</cfif>

<!--- Include BatchDetails template --->
<cfinclude template="/include/qry/BatchDetails_304_1.cfm" />

<!--- Set current start date --->
<Cfset currentStartDate = dateFormat(Now(), 'yyyy-mm-dd') />

<!--- Set default values for parameters --->
<cfparam name="contact_expand" default="true" />
<cfparam name="contactcheckvisible" default="false" />
<cfparam name="maintenance_expand" default="false" />
<cfparam name="bytag" default="" />
<cfparam name="target_expand" default="false" />
<cfparam name="followup_expand" default="false" />
<cfparam name="all_expand" default="false" />
<cfparam name="pgaction" default="view" />
<cfparam name="systemID" default="0" />

<!--- Include last updates template --->
<cfinclude template="/include/qry/lastupdates.cfm" />

<!--- Set session idlist to idlist --->
<cfset idlist = idlist />

<!--- Initialize counters --->
<cfset no_deleted = 0 />
<cfset no_skipped = 0 />
<cfset no_added = 0 />

<!--- Loop through BatchDetails query --->
<cfloop query="BatchDetails">

    <!--- Debug output for contact information --->
    <cfif #dbug# is "Y">
        <cfoutput>
            <h2>Contact: #batchdetails.recordname# (#batchdetails.contactid#) </h2>
        </cfoutput>
    </cfif>

    <!--- Set new contact id --->
    <cfset new_contactid = BatchDetails.contactid />
    <cfset new_systemtype = form.new_systemtype />
    <Cfset new_suStartDate = dateFormat(Now(), 'yyyy-mm-dd') />
    <Cfset new_currentStartDate = dateFormat(Now(), 'yyyy-mm-dd') />

    <!--- Include FindScope template --->
    <cfinclude template="/include/qry/FindScope_304_2.cfm" />

    <!--- Determine system scope based on record count --->
    <cfif #findscope.recordcount# is "1">
        <cfset new_systemscope = "Casting Director" />
        
        <!--- Debug output for system type --->
        <cfif #dbug# is "Y">
            <cfoutput>
                <h4>#new_systemtype# -  Casting Director</h4>
            </cfoutput>
        </cfif>
    <cfelse>
        <cfset new_systemscope = "Industry" />
        
        <!--- Debug output for system type --->
        <cfif #dbug# is "Y">
            <cfoutput>
                <h4>#new_systemtype# -  Industry</h4>
            </cfoutput>
        </cfif>
    </cfif>

    <!--- Include FindSystem template --->
    <cfinclude template="/include/qry/FindSystem_304_3.cfm" />

    <!--- Check if system is found --->
    <cfif #findsystem.recordcount# is "1">
        <cfset new_systemid = findsystem.systemid />
         <cfset systemid = findsystem.systemid />
        <!--- Debug output for new system id --->
        <cfif #dbug# is "Y">
            <cfoutput>
                <p>new_systemid: #findsystem.systemid#</p>
            </cfoutput>
        </cfif>

        <!--- Include FindActive template --->
        <cfinclude template="/include/qry/FindActive_304_4.cfm" />

        <!--- Check if keeplist is "skip" --->
        <cfif #keeplist# is "skip">
            <!--- Debug output for skipping logic --->
            <cfif #dbug# is "Y">
                <cfoutput>
                    <p>keeplist: skip</p>
                    <p>Number of active systems for #batchdetails.recordname#: #findactive.recordcount#</p>
                </cfoutput>
            </cfif>

            <!--- Check if there are no active systems --->
            <cfif #findactive.recordcount# is "0">
                <!--- Debug output for adding a new system --->
                <cfif #dbug# is "Y">
                    <p>Since the number of active systems is zero, add a new system.</p>
                </cfif>

                <!--- Include AddSystemToContact template --->
                <cfinclude template="/include/AddSystemToContact.cfm" />
            <cfelse>
                <cfoutput>
                    <cfset no_skipped = #no_skipped# + 1 />
                </cfoutput>

                <!--- Debug output for skipping a system --->
                <cfif #dbug# is "Y">
                    <cfoutput>
                        <p>Skipping because it already has #findactive.recordcount# active system(s)</p>
                        <p>Total skipped: #no_skipped#</p>
                    </cfoutput>
                </cfif>
            </cfif>
        </cfif>

        <!--- Check if keeplist is "replace" --->
        <cfif #keeplist# is "replace">
            <!--- Check if the contact already has this system type active --->
            <cfinclude template="/include/qry/findsame_304_5.cfm" />

            <!--- Debug output for identical systems --->
            <cfif #dbug# is "Y">
                <cfoutput>
                    <p>keeplist: replace
                    <br>Number of active identical systems of this same type: #findsame.recordcount#</p>
                </cfoutput>
            </cfif>

            <!--- If it doesn't already have this identical type --->
            <cfif #findsame.recordcount# is "0">
                <!--- Debug output for deleting active systems --->
                <cfif #dbug# is "Y">
                    <p>Since the number of identical systems is zero, just delete any active systems.</p>
                </cfif>

                <!--- Delete all of the contact's systems that are currently active --->
                <cfinclude template="/include/qry/delete_304_6.cfm" />

                <!--- resultsqryUpdateCell is the total systems deleted --->
                <!--- add resultsqryUpdateCell to the current delete count --->
                <cfoutput>
                    <cfset no_deleted = #no_deleted# + #updatedRecordCount# />
                </cfoutput>

                <!--- Debug output for total deleted systems --->
                <cfif #dbug# is "Y">
                    <cfoutput>
                        <p>Total contact system's deleted: #updatedRecordCount#</p>
                        <p>no_deleted: #no_deleted#</p>
                    </cfoutput>
                </cfif>

                <!--- Debug output for adding a new system --->
                <cfif #dbug# is "Y">
                    <p>Add a new system.</p>
                </cfif>

                <!--- Include AddSystemToContact template --->
                <cfinclude template="/include/AddSystemToContact.cfm" />
            <cfelse>
                <!--- no_skipped is the total systems skipped --->
                <!--- add 1 to the current skipped count --->
                <cfoutput>
                    <cfset no_skipped = #no_skipped# + 1 />
                </cfoutput>

                <!--- Debug output for skipping a system --->
                <cfif #dbug# is "Y">
                    <cfoutput>
                        <p>System skipped</p>
                        <p>no_skipped: #no_skipped#</p>
                    </cfoutput>
                </cfif>
            </cfif>
        </cfif>
    <cfelse>
        <p>Aborted</p>
        
        <!--- Debug output for aborted process --->
        <cfif #dbug# is "Y">
            <cfoutput>
                <p>Aborted - No System Found!!!</p>
            </cfoutput>
        </cfif>
    </cfif>
</cfloop>

<!--- Output summary of operations --->
<cfoutput>
    <p>ID LIST: #idlist#<br>System: #new_systemtype#<br>KEEPLIST: #keeplist#</p>
    <p>no_skipped: #no_skipped#<br>no_deleted: #no_deleted#<br>no_added: #no_added#</p>
</cfoutput>

<!--- Set script name include --->
<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), " \")#" />

<!--- Set session page action --->
<cfset session.pgaction = "bulk" />

<!--- Redirect if debug is off --->
<cfif #dbug# is "N">
    <cflocation url="/app/contacts/?bt=system&d=#no_deleted#&s=#no_skipped#&a=#no_added#&t=#new_systemtype#" />
</cfif>
