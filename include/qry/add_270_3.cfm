<cfset objGenderPronounUserService = createObject("component", "services.GenderPronounUserService")>
<cfset objGenderPronounUserService.INSgenderpronouns_users(userid=userid, custom=custom)>