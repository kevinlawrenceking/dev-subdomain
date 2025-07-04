<!--- Get system user details ---> 
<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset oldSystemDetails = systemUserService.getOldSystemDetails(suid=suid)>

<cfset old_systemscope = oldSystemDetails.systemscope>
<cfset old_systemtype = oldSystemDetails.systemtype>

<!--- Get contact tag status --->
<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset new_systemscope = contactItemService.getContactTagStatus(contactid=contactid, userid=userid)>
<Cfoutput>
old_systemscope: #old_systemscope#<BR>
old_systemtype: #old_systemtype#<BR>



<cfdump var="#new_systemscope#">

</cfoutput>

<!--- Part c--->
<cfif old_systemtype neq new_systemtype>

    <!--- Close existing system if old system type is not "None" --->
    <cfif old_systemtype neq "None">
    <cfset systemUserService.closeSystem(suid=suid)>
    <cfset notificationService = createObject("component", "services.notificationService")>
       <cfset notificationService.deleteNotificationBySystem(suid=suid)>
    </cfif>

<!--- part d --->
    <cfif new_systemtype neq "None">
        <cfinclude template="/include/qry/FindSystem_294_6.cfm" />
        <cfinclude template="/include/qry/FindSystemOld_294_7.cfm" />

        <!--- Check if there is exactly one record in findsystem --->
        <cfif findsystem.recordcount is 1>
          <cfif len(trim(findsystem.systemid))>
    <cfset systemid = findsystem.systemid>
<cfelse>
    <cfset systemid = 0>
</cfif>

<cfif len(trim(findsystemold.systemid))>
    <cfset systemid_old = findsystemold.systemid>
<cfelse>
    <cfset systemid_old = 0>
</cfif>

<!--- part K--->

<cfif systemid_old eq 0>

<cfset verb = "Added">

<cfelse>
<cfset verb = "Moved">
</cfif>
            <cfif systemid is 1 and systemid_old neq 1>
            <cfset new_NoteDetails = "#verb# to Follow Up track." />
                <cfinclude template="/include/qry/InsertNote_294_8.cfm" />
            </cfif>

                     <cfif systemid is 2 and systemid_old neq 2>
            <cfset new_NoteDetails = "#verb# to Follow Up track." />
                <cfinclude template="/include/qry/InsertNote_294_8.cfm" />
            </cfif>

                     <cfif systemid is 3 and systemid_old neq 3>
            <cfset new_NoteDetails = "#verb# to Maintenance Track." />
                <cfinclude template="/include/qry/InsertNote_294_8.cfm" />
            </cfif>

                     <cfif systemid is 4 and systemid_old neq 4>
            <cfset new_NoteDetails = "#verb# to Maintenance Track." />
                <cfinclude template="/include/qry/InsertNote_294_8.cfm" />
            </cfif>

                     <cfif systemid is 5 and systemid_old neq 5>
            <cfset new_NoteDetails = "#verb# to Targeted Track." />
                <cfinclude template="/include/qry/InsertNote_294_8.cfm" />
            </cfif>

                     <cfif systemid is 6 and systemid_old neq 6>
            <cfset new_NoteDetails = "#verb# to Targeted Track." />
                <cfinclude template="/include/qry/InsertNote_294_8.cfm" />
            </cfif>

            <cfinclude template="/include/add_system.cfm" />
        </cfif>
    </cfif>
</cfif>

<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), '\')#" />
<cflocation url="/app/contact/?contactid=#contactid#" />
