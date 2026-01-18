<!--- This ColdFusion page handles the insertion of a new union into the audunions table. --->
<cfparam name="new_unionName" default="" />
<cfparam name="new_countryid" default="" />
<cfparam name="new_audCatID" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Insert a new record into the audunions table --->
<cfinclude template="/include/qry/audunions_ins_432_1.cfm" />

