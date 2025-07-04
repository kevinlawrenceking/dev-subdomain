<cfset genderPronounService = createObject("component", "services.GenderPronounUserService")>
<cfset genderPronounService.INSgenderpronouns_users_24445(
    genderpronoun = x.genderpronoun,
    genderpronounplural = x.genderpronounplural,
    userid = users.userid
)>