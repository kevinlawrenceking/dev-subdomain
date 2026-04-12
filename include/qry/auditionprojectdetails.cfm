<cfinclude template="/include/perfcount.cfm" />

<cfparam name="audprojectid" default="0" />
<cfinclude template="/include/qry/auditionprojectDetails_370_1.cfm" />

<cfset new_audcatid = len(trim(auditionprojectdetails.audcatid)) ? val(auditionprojectdetails.audcatid) : 0 />
