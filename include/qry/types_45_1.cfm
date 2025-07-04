<cfset mediaTypeService = createObject("component", "services.AuditionMediaTypeService")>
<cfset types = mediaTypeService.getMediaTypes(mediaTypeIds=[1, 2, 3, 5, 6, 7, 8, 14])>