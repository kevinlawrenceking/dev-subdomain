<!--- This ColdFusion page initializes parameters for a question form and includes a template for default questions insertion. --->

<cfparam name="new_qTypeID" default="2" /> <!--- Set default question type ID --->

<cfparam name="new_qtext" default="" /> <!--- Set default question text --->

<cfparam name="new_qorder" default="0" /> <!--- Set default question order --->

<cfparam name="new_isDeleted" default="0" /> <!--- Set default deletion status --->

<cfinclude template="/include/qry/audquestions_default_ins_406_1.cfm" /> <!--- Include the template for inserting default questions --->
