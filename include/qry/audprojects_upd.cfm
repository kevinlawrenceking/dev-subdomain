<!--- This ColdFusion page initializes parameters for a new project and includes a template for project insertion. --->

<cfparam name="new_projName" default="" />
<!--- Initialize project name parameter --->

<cfparam name="new_projDescription" default="" />
<!--- Initialize project description parameter --->

<cfparam name="new_userid" default="" />
<!--- Initialize user ID parameter --->

<cfparam name="new_audSubCatID" default="" />
<!--- Initialize audience subcategory ID parameter --->

<cfparam name="new_unionID" default="" />
<!--- Initialize union ID parameter --->

<cfparam name="new_networkID" default="" />
<!--- Initialize network ID parameter --->

<cfparam name="new_toneID" default="" />
<!--- Initialize tone ID parameter --->

<cfparam name="new_contractTypeID" default="" />
<!--- Initialize contract type ID parameter --->

<cfparam name="new_contactid" default="" />
<!--- Initialize contact ID parameter --->

<cfinclude template="/include/qry/audprojects_ins_401_1.cfm" />
<!--- Include the template for inserting a new project --->
