<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>

<Cfif #new_audsubcatid# is "">
<Cfset new_audsubcatid = "0" />
 </cfif>

<Cfif #new_unionID# is "">
<Cfset new_unionID = "0" />
  </cfif>

<Cfif #new_audsubcatid# is "">
<Cfset new_audsubcatid = "0" />
  </cfif>

<Cfif #new_unionID# is "">
<Cfset new_unionID = "0" />
  </cfif>

<Cfif #new_networkID# is "">
<Cfset new_networkID = "0" />
  </cfif>

<Cfif #new_toneID# is "">
<Cfset new_toneID = "0" />
  </cfif>

<Cfif #new_contactid# is "">
<Cfset new_contactid = "0" />
</cfif>

<Cfif #new_contractTypeID# is "">
<Cfset new_contractTypeID = "0" />
</cfif>

<cfset new_audprojectID = auditionProjectService.INSaudprojects_24585(
    new_projName = new_projName,
    new_projDescription = new_projDescription,
    new_userid = new_userid,
    new_audSubCatID = new_audSubCatID,
    new_unionID = new_unionID,
    new_networkID = new_networkID,
    new_toneID = new_toneID,
    new_contractTypeID = new_contractTypeID,
    new_isDeleted = new_isDeleted,
    isdirect = isdirect
    ,new_contactid = new_contactid
    ,new_eventStart = new_eventStart

) />