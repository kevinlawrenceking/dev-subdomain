<!--- This ColdFusion page initializes parameters for a project and includes a template for casting information. --->

<cfparam name="new_projName" default="" />
<!--- Initialize project name parameter --->

<cfparam name="new_projtye" default="" />
<!--- Initialize project type parameter --->

<cfparam name="new_Status1" default="" />
<!--- Initialize first status parameter --->

<cfparam name="new_Status2" default="" />
<!--- Initialize second status parameter --->

<cfparam name="new_CastingAgency" default="" />
<!--- Initialize casting agency parameter --->

<cfparam name="new_CastingDir" default="" />
<!--- Initialize casting director parameter --->

<cfparam name="new_CastingAssociate" default="" />
<!--- Initialize casting associate parameter --->

<cfparam name="new_CastingAssistant" default="" />
<!--- Initialize casting assistant parameter --->

<cfparam name="new_Notes1" default="" />
<!--- Initialize first notes parameter --->

<cfparam name="new_Notes2" default="" />
<!--- Initialize second notes parameter --->

<cfparam name="new_Notes3" default="" />
<!--- Initialize third notes parameter --->

<cfparam name="new_CastingDir2" default="" />
<!--- Initialize second casting director parameter --->

<cfparam name="new_audnetwork" default="" />
<!--- Initialize audition network parameter --->

<cfinclude template="/include/qry/audprojects_castingabout_ins_397_1.cfm" />
<!--- Include the template for casting information --->

