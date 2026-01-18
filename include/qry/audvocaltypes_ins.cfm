<!--- This ColdFusion page inserts a new vocal type into the audvocaltypes table and retrieves the generated key for the new entry. --->

<cfparam name="new_vocaltype" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Insert a new vocal type into the database. --->
<cfinclude template="/include/qry/audvocaltypes_ins_437_1.cfm" />
