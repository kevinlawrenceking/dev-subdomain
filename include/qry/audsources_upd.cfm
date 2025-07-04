<!--- This ColdFusion page initializes parameters for a new audio source and includes a query for audio sources. --->

<cfparam name="new_audsource" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Include the query for audio sources ---> 
<cfinclude template="/include/qry/audsources_ins_417_1.cfm" />
