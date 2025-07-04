<cfset mediaTypeIds = [1, 2, 3, 5, 6, 7, 8]>
<cfset auditionMediaTypeService = createObject("component", "services.AuditionMediaTypeService")>
<cfset types = auditionMediaTypeService.SELaudmediatypes_23753(mediaTypeIds=mediaTypeIds)>