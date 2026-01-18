<!--- This ColdFusion page handles ticket updates and logs changes in ticket priority and version. --->

<cfinclude template="/include/qry/update_312_1.cfm" />
<cfinclude template="/include/qry/details_312_2.cfm" />

<cfoutput>
    <cfset new_ticketstatus = "#details.new_ticketstatus#" />
</cfoutput>

<!--- Check if the ticket priority has changed --->
<cfif "#old_ticketpriority#" is not "#new_ticketpriority#">
    <cfoutput>
        <cfset new_tlogDetails = "changed PRIORITY from <strong>#chr(34)##old_ticketpriority##chr(34)#</strong> to <strong>#chr(34)##new_ticketpriority##chr(34)#</strong>." />
        <cfset new_ticketid = "#ticketid#" />
        <cfset new_ticketstatus = "#new_ticketStatus#" />
    </cfoutput>
    
    <cfinclude template="/include/qry/inserttlog.cfm" />
</cfif>

<!--- Check if the version ID has changed --->
<cfif "#numberformat(old_verid)#" is not "#numberformat(new_verid)#">
    <cfinclude template="/include/qry/old_312_3.cfm" />
    <cfinclude template="/include/qry/new_312_4.cfm" />

    <cfoutput>
        <!--- Determine old find name --->
        <cfif #old.recordcount# is "1">
            <cfset old_findname = "#old.old_findname#" />
        <cfelse>
            <cfset old_findname = "NULL" />
        </cfif>

        <!--- Determine new find name --->
        <cfif #new.recordcount# is "1">
            <cfset new_findname = "#new.new_findname#" />
        <cfelse>
            <cfset new_findname = "NULL" />
        </cfif>

        <cfset new_tlogDetails = "changed VERSION from <strong>#chr(34)##old_findname##chr(34)#</strong> to <strong>#chr(34)##new_findname##chr(34)#</strong>." />
        <cfset new_ticketid = "#ticketid#" />
        <cfset new_ticketstatus = "#new_ticketStatus#" />
    </cfoutput>
    
    <cfinclude template="/include/qry/inserttlog.cfm" />
</cfif>

<!--- Redirect based on the existence of oldverid --->
<Cfif #isdefined('oldverid')#>
    <cflocation url="/app/version/?recid=#oldverid#" />  
<cfelse>
    <cflocation url="/app/admin-support/" />  
</Cfif>
