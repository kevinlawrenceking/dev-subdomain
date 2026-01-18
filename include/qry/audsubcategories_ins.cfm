<!--- This ColdFusion page initializes parameters, includes a query, and sets a new subcategory ID based on the result. --->

<cfparam name="new_audSubCatName" default="" />
<cfparam name="new_audCatId" default="0" />
<cfparam name="new_isDeleted" default="0" />

<!--- Include the query for inserting subcategories. --->
<cfinclude template="/include/qry/audsubcategories_ins_421_1.cfm" />