

<cfquery result="result"  name="x" >
     SELECT id,sitename,siteurl,siteicon FROM sitelinks_user WHERE iscustom = 1 AND siteicon = 'unknown.png' 
 </cfquery>

 <cfloop query="x">

<cfset id=x.id />

<p>id:<cfoutput>#id#</cfoutput></p>

<cfinclude template="/include/customicon_single.cfm" />

</cfloop>
