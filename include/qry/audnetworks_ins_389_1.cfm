<cfset auditionNetworkService = createObject("component", "services.AuditionNetworkService")>
<cfset auditionNetworkService.UPDaudnetworks(
    new_network = new_network,
    new_audCatid = new_audCatid,
    new_isDeleted = new_isDeleted,
    new_networkid = new_networkid
)>