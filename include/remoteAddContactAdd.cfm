<!--- This ColdFusion page handles the insertion of contact information and redirects based on the source parameter. --->

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

<!--- Include the query to add a new contact --->
<cfinclude template="/include/qry/add_201_1.cfm" />
<cfset currentid = contactid />

<!--- Check if new tags are provided and insert them --->
<cfif #new_tag# is not "">
    <cfloop list="#new_tag#" index="tag">
        <cfinclude template="/include/qry/insert_201_2.cfm" />
    </cfloop>
</cfif>

<!--- Check if work email is provided and insert it --->
<cfif #workemail# is not "">
    <cfinclude template="/include/qry/insert_201_3.cfm" /> 
</cfif>

<!--- Check if work phone is provided and insert it --->
<cfif #workphone# is not "">
    <cfinclude template="/include/qry/insert_201_4.cfm" /> 
</cfif>

<!--- Check if company name is provided and insert it --->
<cfif #company# is not "">
    <cfinclude template="/include/qry/insert_201_5.cfm" /> 
</cfif>

<cfset select_contactid = contactid />
<cfset select_userid = userid />
<cfinclude template="/include/contactfolder_setup.cfm" />

<!--- Redirect based on the source parameter --->
<cfif #src# is "setup">
   <cflocation url="/setup/?setupstep=2" />
<cfelse>
    <cflocation url="/app/myaccount/?t2=1" />    
</cfif>
