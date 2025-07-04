<!--- This ColdFusion page processes contact information and related data, including tags, emails, phones, and events. --->

<cfparam name="deleteitem" default="0" /> 
<cfparam name="valuetext" default="" /> 
<cfparam name="src" default="" /> 
<cfparam name="birthday_DD" default="" /> 
<cfparam name="birthday_MM" default="" /> 
<cfparam name="contactPronoun" default="" /> 
<cfparam name="contactmeetingdate" default="" />
<cfparam name="contactmeetingloc" default="" />
<cfparam name="new_systemtype" default="None" /> 
<cfparam name="company" default="" />
<cfparam name="company_new" default="" />

<!--- Include the initial query for adding contact information --->
<cfinclude template="/include/qry/add_202_1.cfm" />
<cfset currentid = newContactId />
<cfset contactid = newContactId />

<!--- Check if new tags are provided and insert them --->
<cfif #new_tag# is not "">
    <cfloop list="#new_tag#" index="tag">
        <cfinclude template="/include/qry/insert_202_2.cfm" />
    </cfloop>
</cfif>

<!--- Check if work email is provided and insert it --->
<cfif #workemail# is not "">
    <cfinclude template="/include/qry/insert_202_3.cfm" /> 
</cfif>

<!--- Check if work phone is provided and insert it --->
<cfif #workphone# is not "">
    <cfinclude template="/include/qry/insert_201_4.cfm" /> 
</cfif>

<!--- Check if a company is provided and is not "Custom", then insert it --->
<cfif #company# is not "" and #company# is not "Custom">
    <cfinclude template="/include/qry/insert_202_5.cfm" /> 
</cfif>

<!--- Check if a new company name is provided and insert it --->
<cfif #company_new# is not "">
    <cfinclude template="/include/qry/insert_202_6.cfm" /> 
</cfif>

<cfset select_contactid = contactid />
<cfset select_userid = userid />
<cfinclude template="/include/contactfolder_setup.cfm" />

<!--- Include the query for adding additional contact information --->
<cfinclude template="/include/qry/add_cd_202_7.cfm" />

<cfparam name="events_list" default="">

<!--- Check if events list is provided --->
<cfif #events_list# is not "">
    <cfset EventNumbers = listToArray(events_list, ",")>
    
    <!--- Loop through each event number and process it --->
    <cfloop array="#EventNumbers#" index="eventNumber">
        <cfinclude template="/include/qry/findnumber_202_8.cfm" />
        
        <!--- Check if the event number is not found, then insert it --->
        <cfif #findnumber.recordcount# is "0">
            <cfinclude template="/include/qry/inserts_202_9.cfm" />
        </cfif>
    </cfloop>
</cfif>

<!--- Redirect to the audition page with project ID and section ID --->
<cflocation url="/app/audition/?audprojectid=#audprojectid#&secid=175" />

