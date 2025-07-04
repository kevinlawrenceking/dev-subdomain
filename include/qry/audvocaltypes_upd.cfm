<!--- This ColdFusion page updates vocal type information in the audvocaltypes table based on provided parameters. --->

<cfparam name="new_vocaltype" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Execute the update query to modify the vocal type details --->
<cfinclude template="/include/qry/audvocaltypes_ins_439_1.cfm" />

