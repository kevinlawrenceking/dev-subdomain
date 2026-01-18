<cfset var auditionUnionService = createObject("component", "services.AuditionUnionService")>
<cfset var audunions_sel = auditionUnionService.SELaudunions(
    new_countryid = new_countryid,
    new_audcatid = new_audcatid
)>