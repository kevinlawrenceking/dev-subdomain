<!--- This ColdFusion page initializes project parameters and includes a query for inserting new projects. --->
<cfparam name="new_projName" default="" />
<!--- Parameter for project name --->
<cfparam name="new_projDescription" default="" />
<!--- Parameter for project description --->
<cfparam name="new_userid" default="" />
<!--- Parameter for user ID --->
<cfparam name="new_audSubCatID" default="" />
<!--- Parameter for audience subcategory ID --->
<cfparam name="new_unionID" default="" />
<!--- Parameter for union ID --->
<cfparam name="new_networkID" default="" />
<!--- Parameter for network ID --->
<cfparam name="new_toneID" default="" />
<!--- Parameter for tone ID --->
<cfparam name="new_contractTypeID" default="" />
<!--- Parameter for contract type ID --->
<cfparam name="new_isDeleted" default="0" />
<!--- Parameter to indicate if the project is deleted --->
<cfparam name="new_contactid" default="" />
<!--- Parameter for contact ID --->
<cfparam name="isdirect" default="0" />
<!--- Parameter to indicate if the project is direct --->
<cfinclude template="/include/qry/audprojects_ins_399_1.cfm" />
<!--- Set the new audience project ID from the result --->
<cfset audprojectid = new_audprojectid />
<!--- Assign the new audience project ID to a variable --->
<cfset new_eventtitle = new_projName />
<!--- Set the new event title to the project name --->
<cfset new_eventdescription = new_projDescription />
<!--- Set the new event description to the project description --->
