<cfparam name="userid" default="">

<cfset auditionMediaService = createObject("component", "services.AuditionMediaService")>

<cfset headshots_sel = auditionMediaService.SELaudmedia_24678(userid=userid)>