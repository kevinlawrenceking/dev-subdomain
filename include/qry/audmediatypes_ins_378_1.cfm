<cfset service = createObject("component", "services.AuditionMediaTypeService")>
<cfset new_mediaTypeID = service.INSaudmediatypes(new_mediaType=new_mediaType, new_isDeleted=new_isDeleted)>