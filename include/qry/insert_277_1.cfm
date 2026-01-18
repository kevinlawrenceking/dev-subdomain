<cfset objService = createObject("component", "services.AuditionToneUserService")>
<cfset new_toneid = objService.INSaudtones_user(tone="#Custom#", audcatid=#audcatid#, userid=#userid#)>