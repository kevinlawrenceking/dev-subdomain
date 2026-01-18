<cfset auditionSourceService = createObject("component", "services.AuditionSourceService")>
<cfset auditionSourceService.UPDaudsources(
    new_audsource = trim(new_audsource),
    new_isDeleted = new_isDeleted,
    new_audsourceid = new_audsourceid
)>