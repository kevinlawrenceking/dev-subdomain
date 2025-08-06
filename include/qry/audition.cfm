<cfabort><cfinclude template="/include/qry/submitsitefix_368_1.cfm" />
<!---<CFINCLUDE template="/include/projdate_fix_user.cfm" /> --->

    <cfquery >
        CALL UpdateAudProjects();
    </cfquery>
<!--- Set default variables --->
<cfparam name="focusid" default="" />
<cfparam name="ctaction" default="" />
<cfparam name="new_contactid" default="" />
<cfparam name="eventid" default="0" />
<cfparam name="secid" default="176" />

<!--- Consolidate submitsitefix into the main update DONE 
<cfinclude template="/include/qry/submitsitefix_368_1.cfm" />--->

<!--- Fetch project details --->
<cfinclude template="/include/qry/projectDetails_368_2.cfm" />

<cfset audroleid = projectDetails.audroleid />

<!--- Fetch role details --->
<cfinclude template="/include/qry/roleDetails_368_3.cfm" />

<!--- Delete referral contacts --->
<cfinclude template="/include/qry/delete_ref_368_4.cfm" />

<!--- Fetch and consolidate event queries DONE --->
<cfinclude template="/include/qry/events_368_5.cfm" />

<!--- Fetch no-booking events --->
<cfinclude template="/include/qry/events_nobooking_368_6.cfm" />

<!--- Handle delete contact action --->
<cfif ctaction is "deleteContact">
    <cfinclude template="/include/qry/delete_368_7.cfm" />

    <cfinclude template="/include/qry/delete2_368_8.cfm" />
</cfif>

<cfparam name="events_list" default="">

<cfif #ctaction# is "addmember">

<cfinclude template="/include/qry/add_aud_contact.cfm" />
<cfinclude template="/include/qry/set_missing.cfm" />

        <cfif DateCompare(projectDetails.audprojectdate, Now()) lt 0>
      
             <cfinclude template="/include/qry/getSystemIdBasedOnTag.cfm" />

<cfset new_contactid=new_contactid />
           <cfset new_userid=userid />
         
            <cfset new_suStartDate = projectDetails.audprojectdate />

<cfinclude template="/include/modalansweryes.cfm" />

</cfif>

    </cfif>

<!--- Check for projects and contact id --->
<cfinclude template="/include/qry/cdcheck_368_9.cfm" />

<cfif cdcheck.contactid is "99999999">
    <cfloop query="cdcheck">
        <cfinclude template="/include/qry/add_cd_368_10.cfm" />
    </cfloop>
</cfif>

<cfset EventContactsXRefService = createObject("component", "services.EventContactsXRefService")>
<cfset EventContactsXRefService.eventaudsync(audprojectid)>


<cfinclude template="/include/qry/audageranges_audtion_xref_368_11.cfm" />
