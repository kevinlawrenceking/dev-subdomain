<cfset auditionNetworkService = createObject("component", "services.AuditionNetworkService")>
<cfset new_networkid = auditionNetworkService.INSaudnetworks(
    new_network = new_network,
    new_audCatid = new_audCatid,
    new_isDeleted = new_isDeleted
)>