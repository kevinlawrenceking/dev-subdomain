

 <cfset pgtable = "pgapplinks" />
<cfset pgid = "linkid" />

<cfinclude template="release_fix_qry.cfm" /> 

<cfset pgtable = "pgplugins_tbl" />
<cfset pgid = "pluginid" />

<cfinclude template="release_fix_qry.cfm" />

<cfset pgtable = "pgpages_tbl" />
<cfset pgid = "pgid" />

<cfinclude template="release_fix_qry.cfm" />

<cfset pgtable = "pgpagespluginsxref_tbl" />
<cfset pgid = "pgplugid" />

<cfinclude template="release_fix_qry.cfm" />

<cfset pgtable = "pgcomps" />
<cfset pgid = "compid" />

<cfinclude template="release_fix_qry.cfm" />

