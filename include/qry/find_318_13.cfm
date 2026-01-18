<cfset genderPronounUserService = createObject("component", "services.GenderPronounUserService")>
<cfset find = genderPronounUserService.SELgenderpronouns_users_24444(
    genderpronoun = x.genderpronoun,
    userid = users.userid
)>