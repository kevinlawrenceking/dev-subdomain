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









<cfquery name="y">
    SELECT *
    FROM auditionsimport
    WHERE uploadid = <cfqueryparam value="#new_uploadid#" cfsqltype="cf_sql_integer">
</cfquery>

<cfloop query="y">

<cfset new_status = "Valid" />



    <cfquery name="find" maxrows="1">
        SELECT * FROM audprojects 
        WHERE projname = <cfqueryparam value="#y.projname#" cfsqltype="cf_sql_varchar"> 
        AND userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer"> 
        AND isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
    </cfquery>

    <cfif #find.recordcount# is not "0">

        <cfset new_status="Invalid" />

        <cfset auditionImportErrorService.INSauditionsimport_error(id=y.id, errorMsg="Duplicate project")>

    </cfif>


<cfif #y.projname# is "">
    <cfset new_status="Invalid" />
    <cfset auditionImportErrorService.INSauditionsimport_error_24355(id=y.id, errorMsg="Missing project name")>
</cfif>


<cfif #y.audrolename# is "">
    <cfset new_status="Invalid" />
    <cfset auditionImportErrorService.INSauditionsimport_error_24356(id=y.id, errorMsg="Missing Role name")>
</cfif>






    <cfquery name="findcat">
        SELECT audcatid FROM audcategories 
        WHERE audcatname = <cfqueryparam value="#y.audcatname#" cfsqltype="cf_sql_varchar">
    </cfquery>


<cfif #findcat.recordcount# is not "1">
    <cfset new_status="Invalid" />
    <cfset auditionImportErrorService.INSauditionsimport_error_24358(id=y.id, errorMsg="Invalid Category")>
</cfif>




    <cfquery name="findsource">
        SELECT * FROM audsources 
        WHERE isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit"> 
        AND audsource = <cfqueryparam value="#y.audsource#" cfsqltype="cf_sql_varchar">
    </cfquery>


<cfif #findsource.recordcount# is not "1">
    <cfset new_status="Invalid" />
    <cfset auditionImportErrorService.INSauditionsimport_error_24360(id=y.id, errorMsg="Invalid Source")>
</cfif>






        <cfquery name="update">
            UPDATE auditionsimport
            SET status = <cfqueryparam value="#new_status#" cfsqltype="cf_sql_varchar"> 
            WHERE id = <cfqueryparam value="#y.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        </cfloop>


















<cfquery name="x">
    SELECT *
    FROM auditionsimport
    WHERE uploadid = <cfqueryparam value="#new_uploadid#" cfsqltype="cf_sql_integer"> 
    AND status = <cfqueryparam value="Valid" cfsqltype="cf_sql_varchar">
</cfquery>


<cfloop query="x">
<cfset new_projdate = this.formatDate(x.projdate) />

<cfif IsDate(new_projdate)>
    <cfset new_projdate = x.projdate>
<cfelse>
    <cfset new_projdate = Now()>
</cfif>



<cfset cdfullname = x.cdfirstname & " " & x.cdlastname />

            <cfquery name="findcd">
                SELECT * FROM contactdetails 
                WHERE contactfullname = <cfqueryparam value="#cdfullname#" cfsqltype="cf_sql_varchar">
                AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">
            </cfquery>
            
       

            <cfif #findcd.recordcount# is "0" and #x.cdfirstname# is not "">
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

                <cfquery  name="insert">
                    INSERT INTO CONTACTITEMS (CONTACTID,VALUETYPE,VALUECATEGORY,VALUETEXT,ITEMSTATUS)
                    VALUES (#new_contactid#,'Tags','Tag','#cdtype#','Active')
                </cfquery>

                <cfelse>

                    <cfset new_contactid=0 />
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

    <cfif #x.audcatname# is not "">


            <cfquery  name="find_subcat" maxrows="1">
SELECT s.audsubcatid
FROM audcategories c INNER JOIN audsubcategories s ON s.audcatid = c.audcatid 

WHERE c.isdeleted = 0 AND s.isdeleted = 0 
AND CONCAT(c.audcatname,"-",s.audSubCatName) = '#x.audcatname#'
            </cfquery>
        
        

            <cfif #find_subcat.recordcount# is "1">
subcat found<BR>
                <cfset new_audsubcatid=find_subcat.audsubcatid />
            </cfif>
        </cfif>
 

       <cfset iscallback=0 />
              <cfset isredirect=0 />
                     <cfset ispin=0 />
                            <cfset isbooked=0 />


            
    <cfif #x.callback_yn# is "Y">
        <cfset iscallback=1 />
    </cfif>

    <cfif #x.redirect_yn# is "Y">
        <cfset isredirect=1 />
    </cfif>

    <cfif #x.pin_yn# is "Y">
        <cfset ispin=1 />
    </cfif>

    <cfif #x.booked_yn# is "Y">
        <cfset isbooked=1 />
    </cfif>

    <cfset new_projDescription=x.projDescription />

    <cfset new_charDescription=x.charDescription />

    <cfset new_audRoleName=x.audRoleName />


    <cfif #x.audcatname# is not "">

        <cfquery name="find_cat">
            SELECT * FROM audcategories 
            WHERE audcatname = <cfqueryparam value="#x.audcatname#" cfsqltype="cf_sql_varchar"> 
            AND isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
        </cfquery>
        <cfoutput>   SELECT * FROM audcategories WHERE audcatname = '#x.audcatname#' and isdeleted is false<BR></cfoutput>
        <cfif find_cat.recordcount eq 1>

            <cfset new_audcatid=find_cat.audcatid />

            <cfquery name="find_subcat" maxrows="1">
                SELECT * FROM audsubcategories 
                WHERE audcatid = <cfqueryparam value="#new_audcatid#" cfsqltype="cf_sql_integer"> 
                AND audsubcatname = <cfqueryparam value="#x.audsubcatname#" cfsqltype="cf_sql_varchar">
            </cfquery>
            <cfoutput>           SELECT * FROM audsubcategories WHERE audcatid = #new_audcatid# and audsubcatname = '#x.audsubcatname#'<BR /></cfoutput>
            <cfif #find_subcat.recordcount# is "1">

                <cfset new_audsubcatid=find_subcat.audsubcatid />
                
                <Cfoutput>new_audsubcatid: #find_subcat.audsubcatid#<BR></Cfoutput>
            </cfif>
        </cfif>
    </cfif>





    <cfquery name="audprojects_ins"  result="result">

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


    <cfif #x.audsource# is not "">

        <cfquery name="find_source">
            SELECT * FROM audsources 
            WHERE audsource = <cfqueryparam value="#x.audsource#" cfsqltype="cf_sql_varchar"> 
            AND isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
        </cfquery>

        <cfif find_source.recordcount eq 1>

            <cfset new_audsourceid=find_source.audsourceid />


        </cfif>
    </cfif>


<cfif #new_audRoleName# is "">

<cfset new_audRoleName = "Unknown" />

</cfif>


    <cfquery name="audroles_ins"  result="result">

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

    <cfif #x.note# is not "">



        <cfquery  name="InsertNote">
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
