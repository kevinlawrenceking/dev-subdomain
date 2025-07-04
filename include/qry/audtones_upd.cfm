<!--- This ColdFusion page updates the audtones table with new tone information based on provided parameters. --->

<cfparam name="new_tone" default="" />
<cfparam name="new_audCatid" default="2" />
<cfparam name="new_isDeleted" default="0" />

<!--- Execute the update query to modify the audtones record. --->
<cfinclude template="/include/qry/audtones_ins_427_1.cfm" />

