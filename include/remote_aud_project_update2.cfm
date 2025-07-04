<!--- This ColdFusion page handles the insertion and updating of audition-related data based on custom tone and network IDs. --->

<cfif #new_toneid# is "Custom">
    <!--- Check if the tone ID is custom and not empty --->
    <cfif #Custom# is not ""> 
        <cfinclude template="/include/qry/insert_277_1.cfm" />
    <cfelse>
        <cfset new_tone_id = old_toneid />
    </cfif>
</cfif>  

<cfif #new_networkid# is "CustomNetwork">
    <!--- Check if the network ID is custom and not empty --->
    <cfif #CustomNetwork# is not "">  
        <cfinclude template="/include/qry/insert_277_2.cfm" />
    <cfelse>
        <cfset new_networkid = old_networkid />
    </cfif>
</cfif>  

<cfset new_audprojectid = audprojectid />
<cfinclude template="/include/qry/find_new_277_3.cfm" />

<cfif #find_new.recordcount# is "0">
    <!--- If no records found, insert audition contacts --->
    <cfinclude template="/include/qry/audcontacts_auditions_xref_ins.cfm" />
</cfif>

<cfif old_contactid neq new_contactid>
    <!--- If the old contact ID is different from the new one, delete the old contact --->
    <cfinclude template="/include/qry/del_277_4.cfm" />
</cfif>

<cfinclude template="/include/qry/audprojects_upd.cfm" />

<cfoutput>
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=#secid#" />
</cfoutput>

<cflocation url="#returnurl#" />
