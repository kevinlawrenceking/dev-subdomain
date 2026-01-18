<cfoutput>
  <cfset new_userid=#cookie.userid#/>
</cfoutput>
<cfparam name="cdfullname" default=""/>

<cfif #new_contactid# is "0" and #cdfullname# is not "">

  <cfinclude template="/include/qry/INScontactdetails.cfm"/>

  <cfset new_contactid=contact_id/>

  <cfinclude template="/include/qry/insert_367_2.cfm"/>

  <cfif #cdco# is not "">
  
    <cfinclude template="/include/qry/insert_367_3.cfm"/>

  </cfif>

</cfif>

<cfif #new_contactid# is "0" and #cdco# is not "">

  <cfinclude template="/include/qry/add_367_4.cfm"/>

  <cfinclude template="/include/qry/insert_367_5.cfm"/>

  <cfinclude template="/include/qry/insert_367_6.cfm"/>

</cfif>

<cfinclude template="/include/qry/audprojects_ins.cfm"/>
<cfinclude template="/include/qry/audroles_ins.cfm"/>
<cfabort>
<cfif #isdirect# is "0">
  <cfinclude template="/include/qry/auditions_ins.cfm"/>

  <cfinclude template="/include/qry/update_367_7.cfm"/>

</cfif>

<cfinclude template="/include/qry/add_cd_28_12.cfm"/>

<cflocation url="/app/audition/?audprojectid=#new_audprojectid#"/>
