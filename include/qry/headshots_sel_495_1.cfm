<cfparam name="userid" default="">
<cfparam name="audprojectid" default="">

<cfset auditionMediaService = createObject("component", "services.AuditionMediaService")>
<cfset headshots_sel = auditionMediaService.SELaudmedia_24677(userid=userid, audprojectid=audprojectid)>