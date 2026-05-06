<cfinclude template="/include/perfcount.cfm" />
<!--- Wrapper page that handles updating an existing union. --->
<cfparam name="new_unionName"    default="" />
<cfparam name="new_countryid"    default="" />
<cfparam name="new_audCatIDList" default="" />
<cfparam name="new_isDeleted"    default="0" />

<cfinclude template="/include/qry/audunions_ins_434_1.cfm" />
