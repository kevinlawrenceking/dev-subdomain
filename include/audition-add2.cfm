<!--- This ColdFusion page processes user input and manages audition-related data based on various conditions. --->
<cfparam name="modalAnswer" default="No" />
<cfparam name="CustomPlatform" default="" />
<cfparam name="cdco" default="" />

<!--- Check if modalAnswer is defined in the form --->
<cfif isdefined('form.modalAnswer')>
    <cfset modalAnswer = form.modalAnswer>
</cfif>

<cfoutput>
    #cdco#<BR>
    <cfset new_userid = #cookie.userid# />
</cfoutput>

<cfparam name="isdirect" default="0" />
<cfparam name="isbooked" default="0" />

<!--- Initialize new_contactid if not set --->
<cfif #new_contactid# is "">
    <cfset new_contactid = 0 />
</cfif>

<!--- Process new contact if new_contactid is 0 and cdfullname is not empty --->
<cfif #new_contactid# is "0" and #cdfullname# is not "">
    <cfinclude template="/include/qry/inscontactdetails.cfm" />
    <cfset select_contactid = contactid />
    <cfset new_contactid = contactid />
    <cfinclude template="/include/folder_setup.cfm" />
    <cfinclude template="/include/qry/insert_28_2.cfm" />

    <!--- Insert additional data if cdco is not empty --->
    <cfif #cdco# is not "">
        <cfinclude template="/include/qry/insert_28_3.cfm" />
    </cfif>
</cfif>

<!--- Handle modal answer if it is "Yes" --->
<cfif #modalAnswer# is "Yes">
    <cfset new_contactid = new_contactid />
    <cfset new_userid = userid />
    <cfset new_systemid = 1 />
    <cfset new_suStartDate = new_eventStart />
    <cfinclude template="modalansweryes.cfm" />
</cfif>

<!--- Process new contact if new_contactid is 0 and cdfullname is not empty again --->
<cfif #new_contactid# is "0" and #cdfullname# is not "">
    <cfinclude template="/include/qry/insContactDetails.cfm" />

    <cfinclude template="/include/qry/insert_28_5.cfm" />

    <!--- Insert additional data if cdco is not empty --->
    <cfif #cdco# is not "">
        <cfinclude template="/include/qry/insert_28_6.cfm" />
    </cfif>
</cfif>

<!--- Process new contact if new_contactid is 0 and cdco is not empty --->
<cfif #new_contactid# is "0" and #cdco# is not "">
    <cfinclude template="/include/qry/insContactDetails.cfm" />
    <cfset new_contactid = contactid />
    <cfinclude template="/include/qry/insert_28_8.cfm" />
    <cfinclude template="/include/qry/insert_28_3.cfm" />
</cfif>

<cfinclude template="/include/qry/FIND_28_10.cfm" />

<!--- Handle custom platform logic --->
<cfif #new_audPlatformid# is "CustomPlatform" and #CustomPlatform# is not "" and #find.recordcount# is "0">
    <cfinclude template="/include/qry/insert_28_11.cfm" />
    <cfset new_audPlatformid = resultx />
<cfelseif #new_audplatformid# is "CustomPlatform" and #CustomPlatform# is not "" and #find.recordcount# is "1">
    <cfset new_audPlatformid = find.audplatformid />
<cfelseif #new_audplatformid# is "CustomPlatform" and #CustomPlatform# is "">
    <cfset new_audPlatformid = old_audplatformid />
</cfif>

<cfinclude template="/include/qry/audprojects_ins.cfm" />
<cfinclude template="/include/qry/audroles_ins.cfm" />

<!--- Include auditions if not direct --->
<cfif #isdirect# is not "1">
    <cfinclude template="/include/qry/auditions_ins.cfm" />
</cfif>

<!--- Add contact data if new_contactid is not 0 --->
<cfif #new_contactid# is not "0">
    <cfinclude template="/include/qry/add_cd_28_12.cfm" />
</cfif>

<cflocation url="/app/audition/?audprojectid=#new_audprojectid#&isnew=1" />

