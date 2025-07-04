

<cfparam name="audprojectid" default="" />

<cfparam name="new_mediaTypeID" default="" />

<cfparam name="new_mediaURL" default="" />

<cfparam name="new_mediaName" default="" />
 
<cfparam name="new_mediaFilename" default="" />

<cfparam name="new_mediaExt" default="" />

<cfparam name="new_userid" default="" />

<cfparam name="new_mediaCreated" default="CURRENT_TIMESTAMP" />

<cfparam name="new_isDeleted" default="0" />

 <cfif #left(new_mediaURL,4)# is not "http">
<cfset new_mediaURL = "https://#new_mediaURL#" />
</cfif>

<cfinclude template="/include/qry/audmedia_ins_383_1.cfm" />

<cfif #audprojectid# is not "">

    <cfinclude template="/include/qry/find_383_2.cfm" />

    <cfif #find.recordcount# is "0">

        <cfinclude template="/include/qry/add_383_3.cfm" />

    </cfif>

</cfif>

