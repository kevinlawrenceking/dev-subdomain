<!--- This ColdFusion page updates the audsubcategories table with new values for subcategory name, category ID, and deletion status. --->

<cfparam name="new_audSubCatName" default="" />
<cfparam name="new_audCatId" default="0" />
<cfparam name="new_isDeleted" default="0" />

<!--- Execute the update query for audsubcategories --->
<cfinclude template="/include/qry/audsubcategories_ins_423_1.cfm" />

