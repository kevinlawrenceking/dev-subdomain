<cfset AuditionProjectService = createObject("component", "services.AuditionProjectService")>

<!--- Default handling for fetch variables --->
<cfif NOT len(trim(new_projName))><cfset new_projName = ""></cfif>
<cfif NOT len(trim(new_projDescription))><cfset new_projDescription = ""></cfif>
<cfif NOT len(trim(new_unionID))><cfset new_unionID = 0></cfif>
<cfif NOT len(trim(new_networkID))><cfset new_networkID = 0></cfif>
<cfif NOT len(trim(new_toneID))><cfset new_toneID = 0></cfif>
<cfif NOT len(trim(new_contractTypeID))><cfset new_contractTypeID = 0></cfif>
<cfif NOT len(trim(new_contactid))><cfset new_contactid = 0></cfif>

<!--- Call the function --->
<cfset AuditionProjectService.UPDaudprojects_24586(
    new_projName = new_projName,
    new_projDescription = new_projDescription,
    new_unionID = new_unionID,
    new_networkID = new_networkID,
    new_toneID = new_toneID,
    new_contractTypeID = new_contractTypeID,
    new_contactid = new_contactid,
    new_audprojectID = new_audprojectID
)>
