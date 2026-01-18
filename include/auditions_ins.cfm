<!--- This ColdFusion page initializes parameters for a new user event and cleans the event description. --->

<cfparam name="new_userid" default="" />
<cfparam name="new_audRoleID" default="" />
<cfparam name="new_audTypeID" default="" />
<cfparam name="new_audLocation" default="" />
<cfparam name="new_audlocid" default="" />
<cfparam name="new_eventStart" default="" />
<cfparam name="new_eventStartTime" default="" />
<cfparam name="new_eventStopTime" default="" />
<cfparam name="new_audplatformid" default="4" />
<cfparam name="new_audStepID" default="1" />
<cfparam name="new_parkingDetails" default="" />
<cfparam name="new_workwithcoach" default="0" />
<cfparam name="new_isDeleted" default="0" />
<cfparam name="new_trackmileage" default="0" />

<!--- Clean the event description by removing unwanted characters and limit its length.
<cfset cleanData = REReplace(new_eventdescription, "[^a-zA-Z0-9,.!? ]", "", "ALL")>
<cfset new_eventdescription = Left(cleanData, 5000) /> --->

<!--- Include the audition insertion template. --->
<cfinclude template="/include/qry/auditions_ins_32_1.cfm" />
