<!--- This ColdFusion page handles the insertion of new audio types into the database. --->
<cfparam name="new_audtype" default="" />
<cfparam name="new_audCatid" default="2" />
<cfparam name="new_isDeleted" default="0" />

<!--- Execute the SQL query to insert a new audio type into the audtypes table --->
<cfinclude template="/include/qry/audtypes_ins_429_1.cfm" />