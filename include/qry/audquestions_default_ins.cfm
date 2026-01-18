<!--- This ColdFusion page initializes parameters for a new question and includes a template for database insertion. --->
<cfparam name="new_qTypeID" default="2" />
<cfparam name="new_qtext" default="" />
<cfparam name="new_qorder" default="0" />
<cfparam name="new_isDeleted" default="0" />

<!--- Include the template for inserting a new question into the database --->
<cfinclude template="/include/qry/audquestions_default_ins_405_1.cfm" />

