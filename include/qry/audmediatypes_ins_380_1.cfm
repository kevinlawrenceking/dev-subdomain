<cfset objService = createObject("component", "services.AuditionMediaTypeService")>
<cfset objService.UPDaudmediatypes(
    new_mediaType = new_mediaType,
    new_isDeleted = new_isDeleted,
    new_mediaTypeID = new_mediaTypeID
)>