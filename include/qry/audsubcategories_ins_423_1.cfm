<cfset service = createObject("component", "services.AuditionSubcategorieService")>
<cfset service.UPDaudsubcategories(
    new_audSubCatName = trim(new_audSubCatName),
    new_audCatId = new_audCatId,
    new_isDeleted = new_isDeleted,
    new_audSubCatId = new_audSubCatId
)>
