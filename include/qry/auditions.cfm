<!--- ignore for now <CFINCLUDE template="/include/projdate_fix_user.cfm" /> --->
<cfinclude template="/include/qry/updateEventData.cfm" />

<cfparam name="sel_audcatid" default="%" />
<cfparam name="SEL_AUDSTEPID" default="0" />

<cfparam name="audsearch" default="" />
<cfparam name="byimport" default="" />
<cfparam name="sel_audstepid" default="%" />

<cfparam name="sel_audtype" default="%" />
<cfparam name="materials" default="%" />
<cfparam name="auddate" default="%" />

<cfparam name="sel_contactid" default="%" />
<cfparam name="sel_coname" default="%" />
<cfoutput>
<cfset cur_date = "#dateformat('#now()#','YYYY-MM-dd')#" />

</cfoutput>

<cfinclude template="/include/qry/coss_371_1.cfm" />

<cfset colist = valuelist(coss.contactid) />

<cfinclude template="/include/qry/getAuditions.cfm" />  <!--- results_371_2.cfm --->

<cfset projectlist = valuelist(results.audprojectid) />    

