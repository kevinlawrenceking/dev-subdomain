<cfset componentPath = "/services/AuditionContractTypeService">
<cfset componentInstance = createObject("component", componentPath)>
<cfset componentInstance.UPDaudcontracttypes(
    new_contracttype = new_contracttype, 
    new_audCatid = new_audCatid, 
    new_isDeleted = new_isDeleted, 
    new_contracttypeid = new_contracttypeid
)>