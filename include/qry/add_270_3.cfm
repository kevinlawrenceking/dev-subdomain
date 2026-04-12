<cfinclude template="/include/perfcount.cfm" />
<cfset objGenderPronounUserService = createObject("component", "services.GenderPronounUserService")>
<cfset objGenderPronounUserService.INSgenderpronouns_users(userid=userid, custom=custom)>