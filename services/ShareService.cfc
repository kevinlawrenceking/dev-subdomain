<cfcomponent displayname="ShareService" hint="Handles operations for Share table" > 

    <cffunction name="GetShareDetailsByAudition" access="public" returntype="query" output="false">
        <!--- Arguments --->
        <cfargument name="userid" type="numeral" required="true">

        <!--- Query --->
        <cfquery name="result" >
 SELECT 
    d.recordname AS Name, 
    ci_company.valueCompany AS Company, 
    ci_tag.valueText AS Title, 
    mx.audstep AS AuditionStatus, 
    d.contactMeetingLoc AS WhereMet, 
    d.contactMeetingDate AS WhenMet, 
    p.projname AS Project, 
    c.audcatname AS Category, 
    sc.audsubcatname AS SubCategory, 
    rt.audroletype AS RoleType, 
    GROUP_CONCAT(DISTINCT n.noteDetails SEPARATOR ',') AS NotesLog
FROM 
    contactdetails_tbl d
LEFT JOIN audcontacts_auditions_xref x 
    ON d.contactID = x.contactID
LEFT JOIN audprojects p 
    ON p.audprojectID = x.audprojectID
INNER JOIN audroles r 
    ON r.audprojectID = p.audprojectID
LEFT JOIN audsubcategories sc 
    ON sc.audsubcatID = p.audsubcatID
LEFT JOIN audcategories c 
    ON c.audcatID = sc.audcatID
LEFT JOIN audroletypes rt 
    ON rt.audroleTypeID = r.audroleTypeID
LEFT JOIN maxaudition mx 
    ON mx.contactID = d.contactID
LEFT JOIN contactitems ci_company 
    ON ci_company.contactID = d.contactID AND ci_company.valueCategory = 'Company' AND ci_company.itemStatus = 'Active'
LEFT JOIN contactitems ci_tag 
    ON ci_tag.contactID = d.contactID AND ci_tag.valueCategory = 'Tag' AND ci_tag.itemStatus = 'Active'
LEFT JOIN noteslog_tbl n 
    ON n.contactID = d.contactID AND n.isPublic = 1
INNER JOIN fusystemusers_tbl su 
    ON su.contactID = d.contactID AND su.suStatus = 'Active' AND su.systemID IN (1, 2, 3, 4)
WHERE 
    d.userID = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_VARCHAR">
GROUP BY 
    d.contactID
LIMIT 100;


        </cfquery>

        <!--- Return Query Result --->
        <cfreturn result>
    </cffunction>

    <cffunction name="GetShareDetails" access="public" returntype="query" output="false">
        <!--- Arguments --->
        <cfargument name="contactid" type="numeric" required="true">

        <!--- Query --->
        <cfquery name="result">
            SELECT 
                `Name`,
                `Company`,
                `Title`,
                `WhereMet`,
                `WhenMet`,
                `NotesLog`
            FROM 
                sharez
            WHERE 
                contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

        <!--- Return Query Result --->
        <cfreturn result>
    </cffunction>

    <cffunction output="false" name="SELshares" access="public" returntype="query">
        <cfargument name="userId" type="numeric" required="true">

<cfquery name="result">
            SELECT *
            FROM shares
            WHERE userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
    </cffunction>

    <cffunction name="shares" access="public" returntype="query" output="false">
        <cfargument name="userid" type="numeric" required="true">

        <cfquery name="result" >
            SELECT 
                contactid,
                Name,
                Company,
                Title,
                Audition,
                WhereMet,
                WhenMet,
                NotesLog,
                userid,
                u
            FROM 
                sharez
            WHERE 
                userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        <cfreturn result>
    </cffunction>
</cfcomponent>