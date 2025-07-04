<!--- This ColdFusion page handles the insertion of new audio tones into the database. --->

<cfparam name="new_tone" default="" />
<cfparam name="new_audCatid" default="2" />
<cfparam name="new_isDeleted" default="0" />

<!--- Execute the SQL query to insert a new audio tone into the audtones table. --->
<cfinclude template="/include/qry/audtones_ins_425_1.cfm" />
