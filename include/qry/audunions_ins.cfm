<cfinclude template="/include/perfcount.cfm" />
<!--- Wrapper page that handles inserting a new union. --->
<cfparam name="new_unionName"    default="" />
<cfparam name="new_countryid"    default="" />
<cfparam name="new_audCatIDList" default="" />
<cfparam name="new_isDeleted"    default="0" />

<cfinclude template="/include/qry/audunions_ins_432_1.cfm" />
