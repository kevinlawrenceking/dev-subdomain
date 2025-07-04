<cfset genderPronounUserService = createObject("component", "services.GenderPronounUserService")>
<cfset pronouns = genderPronounUserService.SELgenderpronouns_users(userid=userid)>