<!--- This ColdFusion page retrieves project details along with associated roles, categories, tones, networks, and contact information based on a specific project ID. --->

<cfquery name="projectDetails" >
    SELECT 
        proj.audprojectID, 
        r.audroleid,
        proj.projName, 
        proj.projDescription,
        proj.payrate,
        cat.audCatName, 
        cat.audcatid,
        subcat.audSubCatName, 
        subcat.audsubcatid,
        proj.contactid,
        ct.contracttype,
        ton.tone, 
        net.network,
        un.unionName,    
        c.recordname AS castingFullName
    FROM 
        audprojects proj 
        INNER JOIN audroles r ON r.audprojectid = proj.audprojectid
        LEFT OUTER JOIN audcontracttypes ct ON (proj.contractTypeID = ct.contracttypeid)  
        LEFT OUTER JOIN audsubcategories subcat ON (proj.audSubCatID = subcat.audSubCatId)  
        LEFT OUTER JOIN audcategories cat ON (subcat.audCatId = cat.audCatId)  
        LEFT OUTER JOIN audtones ton ON (proj.toneID = ton.toneid)  
        LEFT OUTER JOIN audnetworks net ON (proj.networkID = net.networkid)  
        LEFT OUTER JOIN contactdetails c ON c.contactid = proj.contactid
        LEFT OUTER JOIN audunions un ON (proj.unionID = un.unionID)   
    WHERE 
        proj.audprojectID = <cfqueryparam value="#audprojectID#" cfsqltype="cf_sql_integer">
</cfquery>
