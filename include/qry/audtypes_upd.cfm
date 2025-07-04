<!--- This ColdFusion page updates the audtypes table with new values based on user input. --->
<cfparam name="new_audtype" default="" />
<cfparam name="new_audCatid" default="2" />
<cfparam name="new_isDeleted" default="0" />

<!--- Execute the update query for audtypes --->
<cfinclude template="/include/qry/audtypes_ins_431_1.cfm" />

