<cfset objService = createObject("component", "services.AuditionCategoryService")>
<cfset objService.UPDaudcategories(
    new_audCatName = new_audCatName, 
    new_isDeleted = new_isDeleted, 
    new_audCatId = new_audCatId
)>