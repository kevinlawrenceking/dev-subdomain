<!--- This ColdFusion page initializes parameters and includes a template for inserting user questions. --->

<cfparam name="new_qTypeID" default="2" />
<!--- Set default question type ID to 2 --->

<cfparam name="new_qtext" default="" />
<!--- Set default question text to an empty string --->

<cfparam name="new_qorder" default="0" />
<!--- Set default question order to 0 --->

<cfparam name="new_userid" default="0" />
<!--- Set default user ID to 0 --->

<cfparam name="new_isDeleted" default="0" />
<!--- Set default deletion status to 0 (not deleted) --->

<cfinclude template="/include/qry/audquestions_user_ins_407_1.cfm" />
<!--- Include the template for inserting user questions --->

