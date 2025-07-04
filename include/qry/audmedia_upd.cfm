

<cfparam name="new_isshare" default="1" />

<cfparam name="new_mediaTypeID" default="" />

<cfparam name="new_mediaURL" default="" />

<cfparam name="new_mediaName" default="" />

<cfparam name="new_userid" default="" />

<cfparam name="new_isDeleted" default="0" />

 <cfif #left(new_mediaURL,4)# is not "http">
<cfset new_mediaURL = "https://#new_mediaURL#" />
</cfif>

<cfinclude template="/include/qry/audmedia_upd_386_1.cfm" />

