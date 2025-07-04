<cfset dbug="N" />

<!--- Set default parameters for the contact expansion and ID list --->
<cfparam name="contact_expand" default="true" />
<cfparam name="idlist" default="0" />

<!--- Check if idlist is 0 and idlist is not 0, then set idlist from session --->
<cfif #idlist# is "0" and #idlist# is not "0">
    <cfset idlist = idlist />
</cfif>

<!--- If debugging is off, check if idlist is 0 and redirect if true --->
<CFIF #dbug# is "N">
    <cfif #idlist# is "0">
        <cflocation url="/app/contacts/?bulk_no=0" />
    </cfif>
</CFIF>

<!--- Set additional default parameters --->
<cfparam name="contactcheckvisible" default="false" />
<cfparam name="maintenance_expand" default="false" />
<cfparam name="bytag" default="" />
<cfparam name="target_expand" default="false" />
<cfparam name="followup_expand" default="false" />
<cfparam name="all_expand" default="false" />
<cfparam name="pgaction" default="view" />
<cfparam name="systemID" default="0" />

<!--- Include last updates query --->
<cfinclude template="/include/qry/lastupdates.cfm" />

<!--- Set session idlist to the current idlist --->
<cfset idlist=idlist />

<!--- Initialize counters for added, skipped, and deleted records --->
<cfset no_deleted=0 />
<cfset no_skipped=0 />
<cfset no_added=0 />
<cfset new_addremove = addremove />

<!--- Include batch details query --->
<cfinclude template="/include/qry/BatchDetails_304_1.cfm" />

<!--- Loop through each record in BatchDetails query --->
<cfloop query="BatchDetails">
    
    <!--- If debugging is on, output contact details --->
    <cfif #dbug# is "Y">
        <cfoutput>
            <h2>Contact: #batchdetails.recordname# (#batchdetails.contactid#) </h2>
        </cfoutput>
    </cfif>

    <!--- Set new contact ID and current start date --->
    <cfset new_contactid=BatchDetails.contactid />
    <cfset new_tagname=new_tagname />
    <Cfset new_currentStartDate=dateFormat(Now(),'yyyy-mm-dd') />

    <!--- Include query to find same records --->
    <cfinclude template="/include/qry/findsame_305_2.cfm" />

    <!--- Check if the action is to add --->
    <cfif #addremove# is "add">
        
        <!--- If no matching records found, insert new record --->
        <cfif #findsame.recordcount# is "0">
            <cfinclude template="/include/qry/insert_305_3.cfm" />
            <cfoutput>
                <cfset no_added=#no_added# + 1 />
            </cfoutput>
        </cfif>
        
        <!--- If one matching record found, increment skipped counter --->
        <cfif #findsame.recordcount# is "1">
            <cfoutput>
                <cfset no_skipped=#no_skipped# + 1 />
            </cfoutput>
        </cfif>

    </cfif>

    <!--- Check if the action is to remove --->
    <cfif #addremove# is "remove">
        
        <!--- If no matching records found, increment skipped counter --->
        <cfif #findsame.recordcount# is "0">
            <cfoutput>
                <cfset no_skipped=#no_skipped# + 1 />
            </cfoutput>
        </cfif>
        
        <!--- If one matching record found, delete record and increment deleted counter --->
        <cfif #findsame.recordcount# is "1">
            <cfinclude template="/include/qry/insert_305_4.cfm" />
            <cfoutput>
                <cfset no_deleted=#no_deleted# + 1 />
            </cfoutput>
        </cfif>
        
    </cfif>

</cfloop>

<!--- Output the results of the processing --->
<cfoutput>
    <P>ID LIST: #idlist#<BR>Tag: #new_tagname#<BR>action: #addremove#</P>
    <p>no_skipped: #no_skipped#<BR>no_deleted: #no_deleted#<BR>no_added: #no_added#</p>
</cfoutput>

<!--- Set the script name for inclusion --->
<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />

<!--- Set the session page action to bulk --->
<cfset session.pgaction="bulk" />

<!--- If debugging is off, redirect to contacts page with results --->
<cfif #dbug# is "N">
    <cflocation url="/app/contacts/?bt=tag&d=#no_deleted#&s=#no_skipped#&a=#no_added#&t=#new_tagname#" />
</cfif>

