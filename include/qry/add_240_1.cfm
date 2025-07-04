<cfset siteTypeUserService = createObject("component", "services.SiteTypeUserService")>
<Cfif not isdefined('new_isvisible')><Cfset new_isvisible = 0 /></cfif>
<cfset result = siteTypeUserService.UPDsitetypes_user_24134(new_sitetypename=new_sitetypename, new_sitetypeid=new_sitetypeid,new_isvisible=new_isvisible) />