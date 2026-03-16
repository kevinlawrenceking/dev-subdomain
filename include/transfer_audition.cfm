<!---
    PURPOSE: Transfer imported audition data from auditionsimport to permanent tables with validation
    AUTHOR: Kevin King
    DATE: 2025-07-26
    PARAMETERS: new_uploadid, userid
    DEPENDENCIES: services.AuditionImportErrorService
--->

<cfparam name="new_isDeleted" default="0"/>

<cfparam name="new_projName" default=""/>

<cfparam name="new_projDescription" default=""/>

<cfparam name="new_audSubCatID" default=""/>

<cfparam name="new_unionID" default=""/>

<cfparam name="new_networkID" default=""/>

<cfparam name="new_toneID" default=""/>

<cfparam name="new_contractTypeID" default=""/>

<cfparam name="new_contactid" default=""/>

<cfparam name="isdirect" default="0"/>

<cfparam name="isredirect" default="0"/>

<cfparam name="isbooked" default="0"/>

<cfparam name="ispin" default="0"/>

<!--- Initialize service layer --->
<cfset auditionImportErrorService = createObject("component", "services.AuditionImportErrorService")>

<cfinclude template="/include/remote_load.cfm"/>

<!--- WO-4.1: Pre-load all reference data in batch (replaces per-row lookups) --->

<!--- Pre-load: existing project names for duplicate check --->
<cfquery name="existingProjects">
    SELECT projname FROM audprojects
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer" />
    AND isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
</cfquery>
<cfset projectNameSet = structNew() />
<cfloop query="existingProjects">
    <cfset projectNameSet[lcase(trim(existingProjects.projname))] = true />
</cfloop>

<!--- Pre-load: all categories by name --->
<cfquery name="allCategories">
    SELECT audcatid, audcatname FROM audcategories
</cfquery>
<cfset categoryMap = structNew() />
<cfloop query="allCategories">
    <cfset categoryMap[lcase(trim(allCategories.audcatname))] = allCategories.audcatid />
</cfloop>

<!--- Pre-load: all active sources by name --->
<cfquery name="allSources">
    SELECT audsourceid, audsource FROM audsources
    WHERE isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
</cfquery>
<cfset sourceMap = structNew() />
<cfloop query="allSources">
    <cfset sourceMap[lcase(trim(allSources.audsource))] = allSources.audsourceid />
</cfloop>

<!--- Pre-load: all category+subcategory combos for processing loop --->
<cfquery name="allSubcats">
    SELECT s.audsubcatid, s.audsubcatname, c.audcatid, c.audcatname,
           CONCAT(c.audcatname, '-', s.audSubCatName) AS fullname
    FROM audcategories c
    INNER JOIN audsubcategories s ON s.audcatid = c.audcatid
    WHERE c.isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
    AND s.isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
</cfquery>
<cfset subcatMap = structNew() />
<cfset catDetailMap = structNew() />
<cfloop query="allSubcats">
    <cfset subcatMap[lcase(trim(allSubcats.fullname))] = allSubcats.audsubcatid />
    <!--- Also map category name to audcatid for the secondary lookup --->
    <cfset catDetailMap[lcase(trim(allSubcats.audcatname))] = structNew() />
    <cfset catDetailMap[lcase(trim(allSubcats.audcatname))].audcatid = allSubcats.audcatid />
</cfloop>
<!--- Also build subcatByCat map for the fallback cat+subcat lookup --->
<cfset subcatByCatMap = structNew() />
<cfloop query="allSubcats">
    <cfset subKey = allSubcats.audcatid & "|" & lcase(trim(allSubcats.audsubcatname)) />
    <cfset subcatByCatMap[subKey] = allSubcats.audsubcatid />
</cfloop>

<cfquery name="y">
    SELECT *
    FROM auditionsimport
    WHERE uploadid = <cfqueryparam value="#new_uploadid#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- VALIDATION LOOP: uses pre-loaded maps instead of per-row queries --->
<cfloop query="y">

<cfset new_status = "Valid" />

    <!--- WO-4.1: Project duplicate check via pre-loaded set (was per-row SELECT) --->
    <cfif structKeyExists(projectNameSet, lcase(trim(y.projname)))>

        <cfset new_status="Invalid" />

        <cftry>
            <cfset auditionImportErrorService.INSauditionsimport_error(id=y.id, errorMsg="Duplicate project")>
            <cfcatch type="any">
                <cflog text="Error logging duplicate project for ID #y.id#: #cfcatch.message#" file="audition_import">
            </cfcatch>
        </cftry>

    </cfif>


<cfif y.projname is "">
    <cfset new_status="Invalid" />
    <cftry>
        <cfset auditionImportErrorService.INSauditionsimport_error_24355(id=y.id, errorMsg="Missing project name")>
        <cfcatch type="any">
            <cflog text="Error logging missing project name for ID #y.id#: #cfcatch.message#" file="audition_import">
        </cfcatch>
    </cftry>
</cfif>


<cfif y.audrolename is "">
    <cfset new_status="Invalid" />
    <cftry>
        <cfset auditionImportErrorService.INSauditionsimport_error_24356(id=y.id, errorMsg="Missing Role name")>
        <cfcatch type="any">
            <cflog text="Error logging missing role name for ID #y.id#: #cfcatch.message#" file="audition_import">
        </cfcatch>
    </cftry>
</cfif>

    <!--- WO-4.1: Category check via pre-loaded map (was per-row SELECT) --->
    <cfset catFound = structKeyExists(categoryMap, lcase(trim(y.audcatname))) />

<cfif NOT catFound>
    <cfset new_status="Invalid" />
    <cftry>
        <cfset auditionImportErrorService.INSauditionsimport_error_24358(id=y.id, errorMsg="Invalid Category")>
        <cfcatch type="any">
            <cflog text="Error logging invalid category for ID #y.id#: #cfcatch.message#" file="audition_import">
        </cfcatch>
    </cftry>
</cfif>

    <!--- WO-4.1: Source check via pre-loaded map (was per-row SELECT) --->
    <cfset sourceFound = structKeyExists(sourceMap, lcase(trim(y.audsource))) />

<cfif NOT sourceFound>
    <cfset new_status="Invalid" />
    <cftry>
        <cfset auditionImportErrorService.INSauditionsimport_error_24360(id=y.id, errorMsg="Invalid Source")>
        <cfcatch type="any">
            <cflog text="Error logging invalid source for ID #y.id#: #cfcatch.message#" file="audition_import">
        </cfcatch>
    </cftry>
</cfif>

        <cfquery name="update">
            UPDATE auditionsimport
            SET status = <cfqueryparam value="#new_status#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#y.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        </cfloop>

<!--- WO-4.1: Pre-load contacts for the processing loop --->
<cfquery name="x">
    SELECT *
    FROM auditionsimport
    WHERE uploadid = <cfqueryparam value="#new_uploadid#" cfsqltype="cf_sql_integer">
    AND status = <cfqueryparam value="Valid" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif x.recordcount GT 0>
    <!--- Build list of CD names to pre-load --->
    <cfset cdNameList = "" />
    <cfloop query="x">
        <cfset cdfn = trim(x.cdfirstname) & " " & trim(x.cdlastname) />
        <cfif len(trim(cdfn)) GT 1>
            <cfset cdNameList = listAppend(cdNameList, cdfn) />
        </cfif>
    </cfloop>

    <cfset contactMap = structNew() />
    <cfif len(cdNameList)>
        <cfquery name="existingContacts">
            SELECT contactid, contactfullname FROM contactdetails
            WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
            AND contactfullname IN (<cfqueryparam value="#cdNameList#" cfsqltype="cf_sql_varchar" list="true" />)
        </cfquery>
        <cfloop query="existingContacts">
            <cfset contactMap[lcase(trim(existingContacts.contactfullname))] = existingContacts.contactid />
        </cfloop>
    </cfif>
</cfif>

<!--- PROCESSING LOOP --->
<cfloop query="x">
<cfset new_projdate = this.formatDate(x.projdate) />

<cfif IsDate(new_projdate)>
    <cfset new_projdate = x.projdate>
<cfelse>
    <cfset new_projdate = Now()>
</cfif>

<cfset cdfullname = x.cdfirstname & " " & x.cdlastname />

            <!--- WO-4.1: Contact lookup via pre-loaded map (was per-row SELECT) --->
            <cfset cdKey = lcase(trim(cdfullname)) />
            <cfset cdExists = structKeyExists(contactMap, cdKey) />

            <cfif NOT cdExists and x.cdfirstname is not "">
                <cfoutput>contact not found, adding...<BR></cfoutput>
                <cfquery name="add" result="result">
                    INSERT INTO contactdetails (userid,contactFullName)
                    VALUES (
                        <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#cdfullname#" cfsqltype="cf_sql_varchar">
                    );
                </cfquery>

                <cfset new_contactid=result.generatedkey />

                <cfset select_userid=userid />

                <cfset select_contactid=new_contactid />

                <cfset cdtype="Casting Director" />
<cfoutput>new contactid: #new_contactid#<BR></cfoutput>
<cfset current_id = new_contactid />
<cfset currentid = new_contactid />
                <cfinclude template="/include/folder_setup.cfm" />

                <cfquery name="insert">
                    INSERT INTO CONTACTITEMS (CONTACTID,VALUETYPE,VALUECATEGORY,VALUETEXT,ITEMSTATUS)
                    VALUES (
                        <cfqueryparam value="#new_contactid#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="Tags" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="Tag" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#cdtype#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="Active" cfsqltype="cf_sql_varchar">
                    )
                </cfquery>

                <!--- Add newly created contact to the map so subsequent rows find it --->
                <cfset contactMap[cdKey] = new_contactid />

                <cfelse>

                    <cfif cdExists>
                        <cfset new_contactid = contactMap[cdKey] />
                    <cfelse>
                        <cfset new_contactid=0 />
                    </cfif>
            </cfif>

            <cfset new_status="Added" />

            <cfoutput>
                result: added - #new_contactid#
                <br>
            </cfoutput>

            <cfset select_userid=session.userid />
            <cfset select_contactid=new_contactid />
            <cfinclude template="/include/folder_setup.cfm" />


    <cfset new_projName=trim(x.projname) />

    <cfset new_audrolename=trim(x.audrolename) />

    <cfif x.audcatname is not "">

            <!--- WO-4.1: Subcategory lookup via pre-loaded map (was per-row SELECT with JOIN) --->
            <cfset subcatKey = lcase(trim(x.audcatname)) />
            <cfif structKeyExists(subcatMap, subcatKey)>
                <cfset new_audsubcatid = subcatMap[subcatKey] />
            </cfif>
        </cfif>


       <cfset iscallback=0 />
              <cfset isredirect=0 />
                     <cfset ispin=0 />
                            <cfset isbooked=0 />


    <cfif x.callback_yn is "Y">
        <cfset iscallback=1 />
    </cfif>

    <cfif x.redirect_yn is "Y">
        <cfset isredirect=1 />
    </cfif>

    <cfif x.pin_yn is "Y">
        <cfset ispin=1 />
    </cfif>

    <cfif x.booked_yn is "Y">
        <cfset isbooked=1 />
    </cfif>

    <cfset new_projDescription=x.projDescription />

    <cfset new_charDescription=x.charDescription />

    <cfset new_audRoleName=x.audRoleName />


    <cfif x.audcatname is not "">

        <!--- WO-4.1: Category lookup via pre-loaded map (was per-row SELECT) --->
        <cfset catKey = lcase(trim(x.audcatname)) />
        <cfif structKeyExists(catDetailMap, catKey)>

            <cfset new_audcatid = catDetailMap[catKey].audcatid />

            <!--- WO-4.1: Subcategory lookup via pre-loaded map (was per-row SELECT) --->
            <cfset subKey = new_audcatid & "|" & lcase(trim(x.audsubcatname)) />
            <cfif structKeyExists(subcatByCatMap, subKey)>

                <cfset new_audsubcatid = subcatByCatMap[subKey] />

            </cfif>
        </cfif>
    </cfif>


    <cfquery name="audprojects_ins" result="result">

        INSERT INTO audprojects (
        projName,
        projDescription,
        userid,
        audSubCatID,
        isDeleted,
        IsDirect,
        contactid,
        projdate
        )
        VALUES

        (
        <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_projName#" maxlength="500" null="#NOT len(trim(new_projName))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_LONGVARCHAR" value="#new_projDescription#" null="#NOT len(trim(new_projDescription))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#cookie.userid#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_audSubCatID#" null="#NOT len(trim(new_audSubCatID))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_BIT" value="#new_isDeleted#" null="#NOT len(trim(new_isDeleted))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_BIT" value="#isdirect#" null="#NOT len(trim(isdirect))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_contactid#" null="#NOT len(trim(new_contactid))#" />

                ,
        <cfqueryparam cfsqltype="CF_SQL_DATE" value="#new_projdate#"/>
        )
    </cfquery>

    <cfset new_audprojectID=result.GENERATEDKEY />
    <cfset audprojectid=new_audprojectid />
<cfoutput>new audprojectid: #new_audprojectid#<BR/></cfoutput>


    <cfif x.audsource is not "">

        <!--- WO-4.1: Source lookup via pre-loaded map (was per-row SELECT) --->
        <cfset srcKey = lcase(trim(x.audsource)) />
        <cfif structKeyExists(sourceMap, srcKey)>
            <cfset new_audsourceid = sourceMap[srcKey] />
        </cfif>

    </cfif>


<cfif new_audRoleName is "">

<cfset new_audRoleName = "Unknown" />

</cfif>


    <cfquery name="audroles_ins" result="result">

        INSERT INTO audroles (
        audRoleName,
        audprojectID,
        charDescription,
        audSourceID,
        userid,
        isDeleted,
        isBooked,
        isCallback,
        ispin,
        isredirect
        )

        VALUES (

        <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#new_audRoleName#" maxlength="500" null="#NOT len(trim(new_audRoleName))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_audprojectID#" null="#NOT len(trim(new_audprojectID))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_LONGVARCHAR" value="#new_charDescription#" null="#NOT len(trim(new_charDescription))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_audSourceID#" null="#NOT len(trim(new_audSourceID))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#userid#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_BIT" value="#new_isDeleted#" null="#NOT len(trim(new_isDeleted))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_BIT" value="#isbooked#" null="#NOT len(trim(isbooked))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_BIT" value="#isCallback#" null="#NOT len(trim(isCallback))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_BIT" value="#ispin#" null="#NOT len(trim(ispin))#" />
        ,
        <cfqueryparam cfsqltype="CF_SQL_BIT" value="#isredirect#" null="#NOT len(trim(isredirect))#" />

        );
    </cfquery>

    <cfset new_audRoleID=result.GENERATEDKEY />

    <cfif x.note is not "">

        <cfquery name="InsertNote">
            INSERT INTO noteslog (userid,noteDetails,isPublic,audprojectid,contactid)
            VALUES (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#" />
            ,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#LEFT(trim(x.note),2000)#" />
            ,
            <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
            ,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#new_audprojectid#" />

            ,0

            )
        </cfquery>

</cfif>

    <cfquery name="update_contact">
        UPDATE auditionsimport
        SET status = <cfqueryparam value="#new_status#" cfsqltype="cf_sql_varchar">,
            audprojectid = <cfqueryparam value="#new_audprojectid#" cfsqltype="cf_sql_integer">
        WHERE id = <cfqueryparam value="#x.id#" cfsqltype="cf_sql_integer">
    </cfquery>

</cfloop>
