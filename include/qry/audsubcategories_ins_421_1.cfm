<cfset componentPath = "/services/AuditionSubcategorieService">
<cfset componentInstance = createObject("component", componentPath)>
<cfset new_audSubCatId = componentInstance.INSaudsubcategories(
    new_audSubCatName = new_audSubCatName,
    new_audCatId = new_audCatId,
    new_isDeleted = new_isDeleted
)>