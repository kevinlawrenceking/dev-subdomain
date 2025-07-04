<!--- This ColdFusion page updates site link details and redirects to the target page. --->
<cfparam name="deletelink" default="0" /> 
<cfparam name="ver" default="1" /> 

<!--- Initialize the SiteLinksService --->
<cfset siteLinksService = createObject("component", "services.SiteLinksService")>

<!--- Update site link details with provided parameters
<cfset siteLinksService.updateSiteLinkDetails(
    new_id = new_id, 
    userid = userid, 
    new_sitename = new_sitename, 
    new_siteurl = new_siteurl, 
    new_iscustom = new_iscustom, 
    deletelink = deletelink
)> --->

<!--- Prepare corrected URL --->
<cfif left(new_siteurl, 8) neq "https://" and left(new_siteurl, 7) neq "http://">
    <cfset corrected_new_siteurl = "https://" & new_siteurl />
<cfelse>
    <cfset corrected_new_siteurl = new_siteurl />
</cfif>
<cfoutput>
  new_id = #new_id#<BR> 
    userid = #userid#<BR>
    new_sitename = #new_sitename#<BR>
    corrected_new_site_url = #corrected_new_siteurl# <BR>
    new_iscustom = #new_iscustom#<BR>
    deletelink = #deletelink#<BR>
    </cfoutput> 
<!--- Call the update function from SiteLinksService --->
<cfset siteLinksService.updateSiteLink(
    new_id = new_id,
    new_siteurl = corrected_new_siteurl,
    new_sitename = new_sitename, 
    deletelink = deletelink,
    ver = ver
)>

<!--- Redirect to the target page --->
<cflocation url="/app/#target#/?t1=1&target_id=#target_id###item#new_id#" addToken="no" /> 
