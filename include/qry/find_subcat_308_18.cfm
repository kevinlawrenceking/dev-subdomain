<cfset auditionSubcategorieService = createObject("component", "services.AuditionSubcategorieService")>
<cfset find_subcat = auditionSubcategorieService.SELaudsubcategories(
    new_audcatid = new_audcatid,
    audsubcatname = x.audsubcatname
)>