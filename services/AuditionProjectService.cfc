<cfcomponent displayname="AuditionProjectService" hint="Handles operations for AuditionProject table" >

    <cffunction name="getProjectsByContact" access="public" returntype="query" output="false">
        <!--- Arguments --->
        <cfargument name="contactid" type="numeric" required="true">

        <!--- Query --->
        <cfquery name="result" >
            SELECT DISTINCT 
                p.projdate AS col1,
                p.projname AS col2,
                s.audstep AS col3
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            INNER JOIN events a ON r.audroleid = a.audroleid
            INNER JOIN audsteps s ON s.audstepid = a.audstepid
            INNER JOIN audcontacts_auditions_xref x ON x.audprojectid = p.audprojectid
            INNER JOIN (
                SELECT 
                    p.audprojectID, 
                    MAX(s.audstepid) AS max_audstepid
                FROM audprojects p
                INNER JOIN audroles r ON p.audprojectID = r.audprojectID
                INNER JOIN events a ON r.audroleid = a.audroleid
                INNER JOIN audsteps s ON s.audstepid = a.audstepid
                INNER JOIN audcontacts_auditions_xref x ON x.audprojectid = p.audprojectid
                WHERE 
                    r.isdeleted IS FALSE 
                    AND p.isDeleted IS FALSE
                    AND x.contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                GROUP BY p.audprojectID
            ) AS max_values ON p.audprojectID = max_values.audprojectID AND s.audstepid = max_values.max_audstepid
            WHERE 
                r.isdeleted IS FALSE 
                AND p.isDeleted IS FALSE
                AND x.contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

        <!--- Return Query Result --->
        <cfreturn result>
    </cffunction>

<cffunction name="UPDaudprojects_24586" access="public" returntype="void" output="false">
    <!--- Arguments with default handling --->
    <cfargument name="new_projName" type="string" required="false" default="">
    <cfargument name="new_projDescription" type="string" required="false" default="">
    <cfargument name="new_unionID" type="numeric" required="false" default="0">
    <cfargument name="new_networkID" type="numeric" required="false" default="0">
    <cfargument name="new_toneID" type="numeric" required="false" default="0">
    <cfargument name="new_contractTypeID" type="numeric" required="false" default="0">
    <cfargument name="new_contactid" type="numeric" required="false" default="0">
    <cfargument name="new_payrate" type="string" required="false" default="">
    <cfargument name="new_buyout" type="string" required="false" default="">
    <!--- Additional booking form arguments --->
    <cfargument name="new_incometypeid" type="numeric" required="false" default="0">
    <cfargument name="new_netincome" type="string" required="false" default="">
    <cfargument name="new_paycycleid" type="numeric" required="false" default="0">
    <cfargument name="new_audprojectID" type="numeric" required="true">

<!--- Update audprojects table with project-level fields --->
<cfquery>
    UPDATE audprojects
    SET
        projName = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_projName#" maxlength="500" null="#NOT len(trim(arguments.new_projName))#">
        
        <cfif len(trim(arguments.new_projDescription))>
            ,projDescription = <cfqueryparam cfsqltype="CF_SQL_LONGVARCHAR" value="#arguments.new_projDescription#">
        </cfif>

         

        <cfif arguments.new_unionID EQ 0>
            ,unionID = NULL
        <cfelse>
            ,unionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_unionID#">
        </cfif>

        <cfif arguments.new_networkID EQ 0>
            ,networkID = NULL
        <cfelse>
            ,networkID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_networkID#">
        </cfif>

        <cfif arguments.new_toneID EQ 0>
            ,toneID = NULL
        <cfelse>
            ,toneID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_toneID#">
        </cfif>

        <cfif arguments.new_contractTypeID EQ 0>
            ,contractTypeID = NULL
        <cfelse>
            ,contractTypeID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contractTypeID#">
        </cfif>

        <cfif arguments.new_contactid EQ 0>
            ,contactid = NULL
        <cfelse>
            ,contactid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contactid#">
        </cfif>

    WHERE audprojectID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audprojectID#">
</cfquery>

<!--- Update audroles table with role-level booking fields --->
<cfquery>
    UPDATE audroles
    SET 
        <cfset needsComma = false>
        <cfif len(trim(arguments.new_payrate))>
            payrate = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_payrate#" maxlength="100">
            <cfset needsComma = true>
        </cfif>

        <cfif len(trim(arguments.new_netincome))>
            <cfif needsComma>,</cfif>netincome = <cfqueryparam cfsqltype="CF_SQL_DECIMAL" value="#arguments.new_netincome#">
            <cfset needsComma = true>
        </cfif>

        <cfif len(trim(arguments.new_buyout))>
            <cfif needsComma>,</cfif>buyout = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_buyout#" maxlength="255">
            <cfset needsComma = true>
        </cfif>

        <cfif arguments.new_incometypeid GT 0>
            <cfif needsComma>,</cfif>incometypeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_incometypeid#">
            <cfset needsComma = true>
        </cfif>

        <cfif arguments.new_paycycleid GT 0>
<<<<<<< HEAD
            <cfif len(trim(arguments.new_payrate)) OR len(trim(arguments.new_netincome)) OR len(trim(arguments.new_buyout))>,</cfif>paycycleid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_paycycleid#">
        </cfif>

        <cfif arguments.new_incometypeid GT 0>
            <cfif len(trim(arguments.new_payrate)) OR len(trim(arguments.new_netincome)) OR len(trim(arguments.new_buyout)) OR arguments.new_paycycleid GT 0>,</cfif>incometypeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_incometypeid#">
=======
            <cfif needsComma>,</cfif>paycycleid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_paycycleid#">
>>>>>>> dev
        </cfif>

    WHERE audprojectID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audprojectID#">
    AND (
        <cfset needsOr = false>
        <cfif len(trim(arguments.new_payrate))>
            payrate != <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_payrate#">
            <cfset needsOr = true>
        </cfif>
        <cfif len(trim(arguments.new_netincome))>
            <cfif needsOr> OR </cfif>netincome != <cfqueryparam cfsqltype="CF_SQL_DECIMAL" value="#arguments.new_netincome#">
            <cfset needsOr = true>
        </cfif>
        <cfif len(trim(arguments.new_buyout))>
            <cfif needsOr> OR </cfif>buyout != <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_buyout#">
            <cfset needsOr = true>
        </cfif>
        <cfif arguments.new_incometypeid GT 0>
            <cfif needsOr> OR </cfif>incometypeid != <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_incometypeid#">
            <cfset needsOr = true>
        </cfif>
        <cfif arguments.new_paycycleid GT 0>
            <cfif needsOr> OR </cfif>paycycleid != <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_paycycleid#">
        </cfif>
        <cfif arguments.new_incometypeid GT 0>
            <cfif len(trim(arguments.new_payrate)) OR len(trim(arguments.new_netincome)) OR arguments.new_paycycleid GT 0> OR </cfif>incometypeid != <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_incometypeid#">
        </cfif>
    )
</cfquery>

</cffunction>

<cffunction output="false" name="DETaudprojects" access="public" returntype="query">
    <cfargument name="eventId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                pr.audprojectid AS recid, 
                ad.eventid, 
                pr.audprojectid, 
                ad.audLocation, 
                ad.eventStart, 
                ad.eventStartTime, 
                ad.eventStopTime, 
                ad.parkingDetails, 
                ad.workwithcoach, 
                t.audtype, 
                s.audstep, 
                s.audstepid, 
                ad.audroleid, 
                ad.trackmileage, 
                ad.eventLocation, 
                pl.audplatform, 
                r.audprojectID, 
                pr.audSubCatID, 
                ad.audlocid, 
                t.islocation, 
                ad.audbooktypeid, 
                bt.audbooktype, 
                cbt.callbacktype, 
                cbt.callbacktypeid, 
                sub.audcatid, 
                ad.audtypeid, 
                ad.audlocadd1, 
                ad.audzip, 
                ad.audlocadd2, 
                ad.audcity, 
                ad.region_id, 
                rg.countryid, 
                c.countryname, 
                rg.regionname
            FROM audprojects pr
            INNER JOIN audroles r ON pr.audprojectID = r.audprojectID
            LEFT OUTER JOIN events ad ON r.audroleid = ad.audroleid
            LEFT OUTER JOIN audsubcategories sub ON sub.audsubcatid = pr.audsubcatid
            LEFT OUTER JOIN audcallbacktypes cbt ON cbt.callbacktypeid = ad.callbacktypeid
            LEFT OUTER JOIN audtypes t ON t.audtypeid = ad.audtypeid
            LEFT OUTER JOIN audplatforms pl ON pl.audplatformid = ad.audplatformid
            LEFT OUTER JOIN audsteps s ON s.audstepid = ad.audstepid
            LEFT OUTER JOIN audbooktypes bt ON bt.audbooktypeid = ad.audbooktypeid
            LEFT OUTER JOIN regions rg ON rg.region_id = ad.region_id
            LEFT OUTER JOIN countries c ON rg.countryid = c.countryid
            WHERE ad.eventid = <cfqueryparam value="#arguments.eventId#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudprojects" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT DISTINCT 
                c.contactfullname AS cd, 
                c.contactid 
            FROM 
                audprojects p 
            INNER JOIN 
                contactdetails c 
            ON 
                c.contactid = p.contactid 
            WHERE 
                p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
            ORDER BY 
                c.contactfullname
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudprojects_23795" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT DISTINCT i.valueCompany 
            FROM audprojects p 
            INNER JOIN contactdetails c ON c.contactid = p.contactid 
            INNER JOIN contactitems i ON i.contactid = c.contactid 
            WHERE p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
            AND i.valueCategory = <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR"> 
            ORDER BY i.valueCompany
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETaudprojects_23811" access="public" returntype="query">
    <cfargument name="audprojectid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                a.audprojectid, 
                a.projname, 
                a.projDescription, 
                a4.payrate,
                a4.buyout,
                a.userid, 
                a.audSubCatID, 
                a2.audcatid, 
                a.unionid, 
                a.networkID, 
                a.toneid, 
                a.contracttypeid, 
                a.isdeleted, 
                a.contactid, 
                a.recordname
            FROM audprojects a
            LEFT OUTER JOIN audnetworks a1 ON (a.networkID = a1.networkid)
            LEFT OUTER JOIN audsubcategories a2 ON (a.audSubCatID = a2.audSubCatId)
            LEFT OUTER JOIN audunions a3 ON (a.unionID = a3.unionID)
            LEFT OUTER JOIN audroles a4 ON (a.audprojectID = a4.audprojectID)
            WHERE a.audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="UPDaudprojects" access="public" returntype="void">
    <cfargument name="new_audSubCatID" type="numeric" required="true">
    <cfargument name="new_audprojectID" type="numeric" required="true">

<cfquery result="result" >
            UPDATE audprojects 
            SET audSubCatID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audSubCatID#" null="#NOT len(trim(arguments.new_audSubCatID))#">
            WHERE audprojectID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audprojectID#">
         
</cfquery>

</cffunction>
<cffunction output="false" name="SELaudprojects_23961" access="public" returntype="query">
    <cfargument name="mediaid" type="numeric" required="true">

<cfquery name="result" >
            SELECT DISTINCT p.audprojectid
            FROM audprojects p
            INNER JOIN audmedia_auditions_xref x ON p.audprojectID = x.audprojectid
            WHERE p.isdeleted = 0 
            AND x.mediaid = <cfqueryparam value="#arguments.mediaid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDaudprojects_24011" access="public" returntype="void">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="audprojectids" type="string" required="true">

<cfquery result="result" name="updateQuery">
        UPDATE audprojects 
        SET projdate = NULL 
        WHERE isdeleted <> 1 
        AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        AND audprojectid IN (
            SELECT r.audprojectid 
            FROM audroles r 
            INNER JOIN events e ON e.audRoleID = r.audroleid
            WHERE r.audprojectid IN (
                <cfqueryparam value="#arguments.audprojectids#" cfsqltype="CF_SQL_INTEGER" list="true">
            )
        )
     
</cfquery>
</cffunction>

<cffunction output="false" name="UPDaudprojects_24013" access="public" returntype="void">
    <cfargument name="new_projdate" type="date" required="true">
    <cfargument name="audprojectID" type="numeric" required="true">

<cfquery result="result" >
            UPDATE audprojects 
            SET projdate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_projdate#"/> 
            WHERE audprojectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.audprojectID#"/>
         
</cfquery>

</cffunction>
<cffunction output="false" name="UPDaudprojects_24015" access="public" returntype="void">
    <cfargument name="new_projdate" type="date" required="true">
    <cfargument name="audprojectID" type="numeric" required="true">

<cfquery result="result" >
            UPDATE audprojects 
            SET projdate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_projdate#"/> 
            WHERE audprojectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.audprojectID#"/>
         
</cfquery>

</cffunction>
<cffunction output="false" name="SELaudprojects_24016" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                p.audprojectID, 
                CAST(p.audprojectdate AS DATE) AS new_projDate 
            FROM 
                audprojects p 
            WHERE 
                p.isdeleted <> 1 
                AND p.projdate IS null 
                AND p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDaudprojects_24017" access="public" returntype="void">
    <cfargument name="new_projdate" type="date" required="true">
    <cfargument name="audprojectID" type="numeric" required="true">

<cfquery result="result" >
            UPDATE audprojects 
            SET projdate = <cfqueryparam value="#arguments.new_projdate#" cfsqltype="cf_sql_date"/>
            WHERE audprojectid = <cfqueryparam value="#arguments.audprojectID#" cfsqltype="cf_sql_integer"/>
         
</cfquery>

</cffunction>
<cffunction output="false" name="UPDaudprojects_24019" access="public" returntype="void">
    <cfargument name="projDate" type="string" required="true">

<cfquery result="result" name="updateQuery" >
            UPDATE audprojects p
            INNER JOIN auditionsimport i ON i.audprojectid = p.audprojectid
            SET p.projdate = <cfqueryparam value="#arguments.projDate#" cfsqltype="CF_SQL_DATE">
            WHERE STR_TO_DATE(i.projdate, '%Y-%m-%d') IS NOT NULL
         
</cfquery>

</cffunction>
<cffunction output="false" name="SELaudprojects_24062" access="public" returntype="query">
    <cfargument name="audprojectid" type="numeric" required="true">

<cfquery name="result" >
            SELECT DISTINCT e.eventid, e.eventstart
            FROM audprojects p 
            INNER JOIN audroles r ON r.audprojectID = p.audprojectID 
            INNER JOIN events a ON a.audroleid = r.audroleid 
            INNER JOIN events e ON e.eventid = a.eventid 
            WHERE p.audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER"> 
            AND a.isDeleted = 0 
            AND r.isdeleted = 0 
            AND p.isdeleted = 0
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudprojects_24085" access="public" returntype="query">
    <cfargument name="audprojectid" type="numeric" required="true">

<cfquery name="result" >
            SELECT projname, projdescription, contactid
            FROM audprojects
            WHERE audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETaudprojects_24089" access="public" returntype="query">
    <cfargument name="audprojectID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                proj.audprojectID, 
                r.audroleid, 
                proj.projName, 
                proj.projDescription, 
                r.payrate,
                r.buyout,
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
            FROM audprojects proj
            INNER JOIN audroles r ON r.audprojectid = proj.audprojectid
            LEFT OUTER JOIN audcontracttypes ct ON proj.contractTypeID = ct.contracttypeid
            LEFT OUTER JOIN audsubcategories subcat ON proj.audSubCatID = subcat.audSubCatId
            LEFT OUTER JOIN audcategories cat ON subcat.audCatId = cat.audCatId
            LEFT OUTER JOIN audtones ton ON proj.toneID = ton.toneid
            LEFT OUTER JOIN audnetworks net ON proj.networkID = net.networkid
            LEFT OUTER JOIN contactdetails c ON c.contactid = proj.contactid
            LEFT OUTER JOIN audunions un ON proj.unionID = un.unionID
            WHERE proj.audprojectID = <cfqueryparam value="#arguments.audprojectID#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudprojects_24097" access="public" returntype="query">
    <cfargument name="eventid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                ad.eventid, 
                a4.audroleid, 
                a.projName, 
                a.projDescription, 
                a4.payrate,
                a4.buyout,
                ad.eventStartTime, 
                ad.eventStopTime, 
                ad.eventStart, 
                a1.network, 
                a2.audSubCatName, 
                a3.unionName, 
                a2.audsubcatid, 
                ad.audlocid, 
                a4.audRoleName, 
                a4.charDescription, 
                a4.holdStartDate, 
                a4.holdEndDate, 
                a5.audroletype, 
                a6.auddialect, 
                c.audcatid, 
                t.audtypeid, 
                ad.workwithcoach, 
                ad.audstepid, 
                ad.audlocation, 
                ad.parkingdetails, 
                ad.audroleid, 
                ad.audplatformid, 
                ad.trackmileage, 
                t.audtype, 
                step.audstep, 
                t.islocation, 
                ad.audbooktypeid,
                ad.eventLocation,
                ad.audlocadd1,
                ad.audzip,
                ad.audlocadd2,
                ad.audcity,
                ad.region_id,
                r.countryid,
                truncate(hour(TIMEDIFF(ad.eventStopTime, ad.eventStartTime)), 2) + truncate(minute(TIMEDIFF(ad.eventStopTime, ad.eventStartTime)), 2) / 60 AS new_durhours
            FROM audprojects a
            LEFT OUTER JOIN audnetworks a1 ON (a.networkID = a1.networkid)
            INNER JOIN audsubcategories a2 ON (a.audSubCatID = a2.audSubCatId)
            INNER JOIN audcategories c ON c.audcatid = a2.audcatid
            LEFT OUTER JOIN audunions a3 ON (a.unionID = a3.unionID)
            INNER JOIN audroles a4 ON (a.audprojectID = a4.audprojectID)
            INNER JOIN events_tbl ad ON (ad.audroleid = a4.audroleid)
            LEFT OUTER JOIN audsteps step ON step.audstepid = ad.audstepid
            LEFT OUTER JOIN audroletypes a5 ON (a4.audRoleTypeID = a5.audroletypeid)
            LEFT OUTER JOIN auddialects a6 ON (a4.audDialectID = a6.auddialectid)
            LEFT JOIN audtypes t ON t.audtypeid = ad.audtypeid
            LEFT OUTER JOIN regions r ON r.region_id = ad.region_id
            WHERE ad.eventid = <cfqueryparam value="#arguments.eventid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETaudprojects_24106" access="public" returntype="query">
    <cfargument name="new_eventid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                pr.audprojectid AS recid, 
                ad.eventid, 
                pr.audprojectid, 
                r.payrate,
                r.buyout,
                ad.audLocation, 
                ad.eventStart, 
                ad.eventStartTime, 
                ad.eventStopTime, 
                ad.parkingDetails, 
                ad.workwithcoach, 
                t.audtype, 
                s.audstep, 
                s.audstepid, 
                ad.audroleid, 
                ad.trackmileage, 
                ad.eventLocation, 
                pl.audplatform, 
                r.audprojectID, 
                pr.audSubCatID, 
                ad.audlocid, 
                t.islocation, 
                ad.audbooktypeid, 
                bt.audbooktype, 
                cbt.callbacktype, 
                cbt.callbacktypeid, 
                sub.audcatid, 
                ad.audtypeid, 
                ad.audlocadd1, 
                ad.audzip, 
                ad.audlocadd2, 
                ad.audcity, 
                ad.region_id, 
                rg.countryid, 
                c.countryname, 
                rg.regionname
            FROM audprojects pr
            INNER JOIN audroles r ON pr.audprojectID = r.audprojectID
            LEFT OUTER JOIN events_tbl ad ON r.audroleid = ad.audroleid
            LEFT OUTER JOIN audsubcategories sub ON sub.audsubcatid = pr.audsubcatid
            LEFT OUTER JOIN audcallbacktypes cbt ON cbt.callbacktypeid = ad.callbacktypeid
            LEFT OUTER JOIN audtypes t ON t.audtypeid = ad.audtypeid
            LEFT OUTER JOIN audplatforms pl ON pl.audplatformid = ad.audplatformid
            LEFT OUTER JOIN audsteps s ON s.audstepid = ad.audstepid
            LEFT OUTER JOIN audbooktypes bt ON bt.audbooktypeid = ad.audbooktypeid
            LEFT OUTER JOIN regions rg ON rg.region_id = ad.region_id
            LEFT OUTER JOIN countries c ON rg.countryid = c.countryid
            WHERE ad.eventid = <cfqueryparam value="#arguments.new_eventid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETaudprojects_24107" access="public" returntype="query">
    <cfargument name="audprojectID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                proj.audprojectID, 
                r.audroleid, 
                proj.projName, 
                proj.projDescription, 
                r.payrate,
                r.buyout,
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
            FROM audprojects proj
            INNER JOIN audroles r ON r.audprojectid = proj.audprojectid
            LEFT OUTER JOIN audcontracttypes ct ON proj.contractTypeID = ct.contracttypeid
            LEFT OUTER JOIN audsubcategories subcat ON proj.audSubCatID = subcat.audSubCatId
            LEFT OUTER JOIN audcategories cat ON subcat.audCatId = cat.audCatId
            LEFT OUTER JOIN audtones_user ton ON proj.toneID = ton.toneid
            LEFT OUTER JOIN audnetworks_user net ON proj.networkID = net.networkid
            LEFT OUTER JOIN contactdetails c ON c.contactid = proj.contactid
            LEFT OUTER JOIN audunions un ON proj.unionID = un.unionID
            WHERE proj.audprojectID = <cfqueryparam value="#arguments.audprojectID#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="UPDaudprojects_24125" access="public" returntype="void">
    <cfargument name="audprojectid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE audprojects 
            SET isdeleted = 1 
            WHERE audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

</cffunction>
<cffunction output="false" name="SELaudprojects_24230" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_rangestart" type="date" required="true">
    <cfargument name="new_rangeend" type="date" required="true">

<cfquery name="result" >
            SELECT count(p.audprojectID) as totals, 
                   'Number of Callbacks' as label, 
                   'Auditions' as itemDataset 
            FROM audprojects p 
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID 
            WHERE r.isdeleted = 0 
              AND p.isDeleted = 0 
              AND r.iscallback = 1 
              AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" /> 
              AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_rangestart#" /> 
              AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_rangeend#" />
         
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELaudprojects_24236" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">

<cfquery name="result" >
            SELECT 
                count(p.audprojectID) as totals, 
                'Number of Redirects' as label, 
                'Auditions' as itemDataset
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID
            WHERE 
                r.isdeleted = 0 
                AND p.isDeleted = 0 
                AND r.isredirect = 1 
                AND p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer"> 
                AND p.projdate >= <cfqueryparam value="#arguments.rangestart#" cfsqltype="cf_sql_date"> 
                AND p.projdate <= <cfqueryparam value="#arguments.rangeend#" cfsqltype="cf_sql_date">
         
</cfquery>

<cfreturn result>

= #arguments.rangestart# AND p.projdate <= #arguments.rangeend#">

</cffunction>
<cffunction output="false" name="SELaudprojects_24237" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">

<cfquery name="result" >
            SELECT 
                count(p.audprojectID) as totals, 
                'Number of Pins/Avails' as label, 
                'Auditions' as itemDataset
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID
            WHERE 
                r.isdeleted = 0
                AND p.isDeleted = 0
                AND r.ispin = 1
                AND p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                AND p.projdate >= <cfqueryparam value="#arguments.rangestart#" cfsqltype="CF_SQL_DATE">
                AND p.projdate <= <cfqueryparam value="#arguments.rangeend#" cfsqltype="CF_SQL_DATE">
         
</cfquery>

= #arguments.rangestart# AND p.projdate <= #arguments.rangeend#">

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudprojects_24238" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">

<cfquery name="result" >
            SELECT 
                count(p.audprojectID) as totals, 
                'Number of Auditions' as label, 
                'Auditions' as itemDataset
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID
            WHERE 
                r.isdeleted = 0 
                AND p.isDeleted = 0 
                AND p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
                AND p.projdate >= <cfqueryparam value="#arguments.rangestart#" cfsqltype="CF_SQL_DATE"> 
                AND p.projdate <= <cfqueryparam value="#arguments.rangeend#" cfsqltype="CF_SQL_DATE">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudprojects_24239" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">

<cfquery name="result" >
            SELECT 
                count(p.audprojectID) as totals, 
                'Number of Bookings' as label, 
                'Auditions' as itemDataset
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID
            WHERE 
                r.isdeleted = 0 
                AND p.isDeleted = 0 
                AND r.isbooked = 1 
                AND p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
                AND p.projdate >= <cfqueryparam value="#arguments.rangestart#" cfsqltype="CF_SQL_DATE"> 
                AND p.projdate <= <cfqueryparam value="#arguments.rangeend#" cfsqltype="CF_SQL_DATE">
         
</cfquery>

= #arguments.rangestart# AND p.projdate <= #arguments.rangeend#">

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudprojects_24240" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">

<cfquery name="result" >
            SELECT 
                count(p.audprojectid) as totals, 
                c.audcatname as label, 
                'Auditions' as itemDataset 
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID 
            INNER JOIN 
                audroletypes rt ON rt.audroletypeid = r.audroletypeid 
            INNER JOIN 
                audcategories c ON c.audCatId = rt.audcatid 
            WHERE 
                r.isdeleted IS FALSE 
                AND p.isDeleted IS FALSE 
                AND p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer"> 
                AND p.projdate >= <cfqueryparam value="#arguments.rangestart#" cfsqltype="cf_sql_date"> 
                AND p.projdate <= <cfqueryparam value="#arguments.rangeend#" cfsqltype="cf_sql_date"> 
            GROUP BY 
                c.audcatname 
            ORDER BY 
                c.audcatname
         
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELaudprojects_24241" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">

<cfquery name="result" >
            SELECT 
                count(p.audprojectid) as totals, 
                e.essencename as label, 
                'Auditions' as itemDataset 
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID 
            INNER JOIN 
                audessences_audtion_xref x ON x.audroleid = r.audroleid 
            INNER JOIN 
                essences e ON e.essenceid = x.essenceid 
            WHERE 
                r.isdeleted IS FALSE 
                AND p.isDeleted IS FALSE 
                AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" /> 
                AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangestart#" /> 
                AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeend#" />
            GROUP BY 
                e.essencename 
            ORDER BY 
                e.essencename
         
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELaudprojects_24242" access="public" returntype="query">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                count(p.audprojectid) as totals, 
                IFNULL(s.audsource, 'Unknown') as label, 
                'Auditions' as itemDataset 
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID 
            INNER JOIN 
                audsources s ON s.audsourceid = r.audsourceid 
            WHERE 
                r.isdeleted = 0 
                AND p.isDeleted = 0 
                AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangestart#" /> 
                AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeend#" /> 
                AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" />
            GROUP BY 
                label 
            ORDER BY 
                label
         
</cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudprojects_24244" access="public" returntype="query">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                count(p.audprojectid) as totals, 
                IFNULL(ss.submitsitename, 'Unknown') as label, 
                'Auditions' as itemDataset 
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID 
            INNER JOIN 
                audsources s ON s.audsourceid = r.audsourceid 
            LEFT JOIN 
                audsubmitsites_user ss ON ss.submitsiteid = r.submitsiteid 
            WHERE 
                r.isdeleted = 0 
                AND p.isDeleted = 0 
                AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangestart#" />
                AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeend#" />
                AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" />
                AND s.audsourceid = <cfqueryparam cfsqltype="cf_sql_integer" value="2" />
            GROUP BY 
                label 
            ORDER BY 
                label
         
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELaudprojects_24245" access="public" returntype="query">
    <cfargument name="rangeStart" type="date" required="true">
    <cfargument name="rangeEnd" type="date" required="true">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                count(p.audprojectid) as totals, 
                IFNULL(c.recordname, 'Unknown') as label, 
                'Auditions' as itemDataset 
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID 
            INNER JOIN 
                audsources s ON s.audsourceid = r.audsourceid 
            LEFT JOIN 
                contactdetails c ON c.contactid = r.contactid 
            WHERE 
                r.isdeleted IS FALSE 
                AND p.isDeleted IS FALSE 
                AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeStart#" /> 
                AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeEnd#" /> 
                AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userId#" /> 
                AND s.audsourceid = <cfqueryparam cfsqltype="cf_sql_integer" value="3" /> 
            GROUP BY label 
            ORDER BY label
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudprojects_24246" access="public" returntype="query">
    <cfargument name="rangeStart" type="date" required="true">
    <cfargument name="rangeEnd" type="date" required="true">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                COUNT(p.audprojectid) AS totals, 
                IFNULL(o.opencallname, 'Unknown') AS label, 
                'Auditions' AS itemDataset
            FROM 
                audprojects p
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID
            INNER JOIN 
                audsources s ON s.audsourceid = r.audsourceid
            LEFT JOIN 
                audopencalloptions_user o ON o.opencallid = r.opencallid
            WHERE 
                r.isdeleted IS FALSE 
                AND p.isDeleted IS FALSE 
                AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeStart#" />
                AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeEnd#" />
                AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userId#" />
                AND s.audsourceid = <cfqueryparam cfsqltype="cf_sql_integer" value="4" />
            GROUP BY 
                label
            ORDER BY 
                label
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction name="getAuditionData" access="public" returntype="query" output="false">
    <cfargument name="rangeselected" type="struct" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            COUNT(p.audprojectid) AS totals, 
            IFNULL(c.recordname, 'Unknown') AS label, 
            'Auditions' AS itemDataset 
        FROM 
            audprojects p 
        INNER JOIN 
            audroles r ON p.audprojectID = r.audprojectID 
        INNER JOIN 
            audsources s ON s.audsourceid = r.audsourceid 
        LEFT JOIN 
            contactdetails c ON c.contactid = r.contactid 
        WHERE 
            r.isdeleted IS FALSE 
            AND p.isDeleted IS FALSE 
            AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeselected.rangestart#">
            AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeselected.rangeend#">
            AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
            AND s.audsourceid = 1 
        GROUP BY 
            label 
        ORDER BY 
            label
     
</cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudprojects_24248" access="public" returntype="query">
    <cfargument name="new_audsourceid" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rangeselected" type="struct" required="true">

<cfquery name="result" >
            SELECT count(p.audprojectid) as totals, 'Non-Union' as label, 'Auditions' as itemDataset
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            INNER JOIN audunions u ON u.unionid = p.unionid
            INNER JOIN audsources s ON s.audsourceid = r.audsourceid
            WHERE r.isdeleted IS FALSE
            AND p.isDeleted IS FALSE
            AND u.unionName = 'Non-Union'
            <cfif arguments.new_audsourceid neq "0">
                AND s.audsourceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_audsourceid#">
            </cfif>
            AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
            AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeselected.rangestart#">
            AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeselected.rangeend#">
            GROUP BY label, itemDataset

UNION ALL

SELECT count(p.audprojectid) as totals, 'Union' as label, 'Auditions' as itemDataset
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            INNER JOIN audunions u ON u.unionid = p.unionid
            INNER JOIN audsources s ON s.audsourceid = r.audsourceid
            WHERE r.isdeleted IS FALSE
            AND p.isDeleted IS FALSE
            AND u.unionName <> 'Non-Union'
            <cfif arguments.new_audsourceid neq "0">
                AND s.audsourceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_audsourceid#">
            </cfif>
            AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
            AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeselected.rangestart#">
            AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeselected.rangeend#">
            GROUP BY label, itemDataset

ORDER BY label
         
</cfquery>
        <cfreturn result>

</cffunction>
<cffunction output="false" name="SELaudprojects_24250" access="public" returntype="query">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                count(r.audroleid) AS totals, 
                a.rangename AS label, 
                'Auditions' AS itemDataset 
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID 
            INNER JOIN 
                audageranges_audtion_xref x ON x.audroleid = r.audroleid 
            INNER JOIN 
                audageranges a ON a.rangeid = x.rangeid 
            WHERE 
                r.isdeleted = 0 
                AND p.isDeleted = 0 
                AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangestart#" /> 
                AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeend#" /> 
                AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" /> 
            GROUP BY 
                a.rangename 
            HAVING 
                a.rangename <> 'Unknown' 
            ORDER BY 
                a.rangename
         
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELaudprojects_24251" access="public" returntype="query">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_audcatid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                count(r.audroleid) AS totals, 
                g.audgenre AS label, 
                'Auditions' AS itemDataset
            FROM 
                audprojects p
            INNER JOIN 
                audroles r ON p.audprojectID = r.audprojectID
            INNER JOIN 
                audsubcategories s ON s.audsubcatid = p.audsubcatid
            INNER JOIN 
                audgenres_audition_xref x ON x.audroleid = r.audroleid
            INNER JOIN 
                audgenres g ON g.audgenreid = x.audgenreid
            WHERE 
                r.isdeleted IS FALSE 
                AND p.isDeleted IS FALSE 
                AND p.projdate >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangestart#" />
                AND p.projdate <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.rangeend#" />
                AND p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" />
                AND s.audcatid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_audcatid#" />
            GROUP BY 
                g.audgenre
            ORDER BY 
                g.audgenre
         
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELaudprojects_24353" access="public" returntype="query">
    <cfargument name="projname" type="string" required="true">

<cfquery name="result" >
            SELECT *
            FROM audprojects
            WHERE projname = <cfqueryparam value="#arguments.projname#" cfsqltype="CF_SQL_VARCHAR">
            AND userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER">
            AND isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INSaudprojects" access="public" returntype="numeric">
    <cfargument name="new_projName" type="string" required="true">
    <cfargument name="new_projDescription" type="string" required="false" default="">
    <cfargument name="new_audSubCatID" type="numeric" required="false">
    <cfargument name="new_isDeleted" type="boolean" required="false" default=false>
    <cfargument name="isdirect" type="boolean" required="false" default=false>
    <cfargument name="new_contactid" type="numeric" required="false">
    <cfargument name="new_payrate" type="string" required="false" default="">
    <cfargument name="new_projdate" type="date" required="true">

<cfquery result="result" >
            INSERT INTO audprojects (
                projName,
                projDescription,
                userid,
                audSubCatID,
                isDeleted,
                IsDirect,
                contactid,
                projdate
            ) VALUES (
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_projName#" maxlength="500" null="#NOT len(trim(arguments.new_projName))#" />,
                <cfqueryparam cfsqltype="CF_SQL_LONGVARCHAR" value="#arguments.new_projDescription#" null="#NOT len(trim(arguments.new_projDescription))#" />,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#cookie.userid#" />,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audSubCatID#" null="#NOT len(trim(arguments.new_audSubCatID))#" />,
                <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#" />,
                <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.isdirect#" null="#NOT len(trim(arguments.isdirect))#" />,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contactid#" null="#NOT len(trim(arguments.new_contactid))#" />,
                <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.new_projdate#" />
            )
         
</cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELaudprojects_24500" access="public" returntype="query">
    <cfargument name="eventid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                a4.audroleid, 
                a.projName, 
                a.projDescription, 
                a4.payrate,
                a4.buyout,
                a1.network, 
                a2.audSubCatName, 
                a3.unionName, 
                a4.audRoleName, 
                a4.charDescription, 
                a4.holdStartDate, 
                a4.holdEndDate, 
                a5.audroletype, 
                a6.auddialect, 
                ad.*
            FROM audprojects a
            LEFT OUTER JOIN audnetworks a1 ON (a.networkID = a1.networkid)
            INNER JOIN audsubcategories a2 ON (a.audSubCatID = a2.audSubCatId)
            LEFT OUTER JOIN audunions a3 ON (a.unionID = a3.unionID)
            INNER JOIN audroles a4 ON (a.audprojectID = a4.audprojectID)
            INNER JOIN events ad ON (ad.audroleid = a4.audroleid)
            LEFT OUTER JOIN audroletypes a5 ON (a4.audRoleTypeID = a5.audroletypeid)
            LEFT OUTER JOIN auddialects a6 ON (a4.audDialectID = a6.auddialectid)
            LEFT JOIN audtypes t ON t.audtypeid = ad.audtypeid
            WHERE ad.eventid = <cfqueryparam value="#arguments.eventid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETaudprojects_24543" access="public" returntype="query">
    <cfargument name="audprojectID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                proj.audprojectID, 
                r.audroleid, 
                proj.projName, 
                proj.projDescription, 

                cat.audCatName, 
                cat.audcatid, 
                subcat.audSubCatName, 
                subcat.audsubcatid, 
                proj.audprojectdate, 
                proj.contactid, 
                ct.contracttype, 
                r.payrate,
                r.netincome,
                r.buyout,
                ton.tone, 
                net.network, 
                un.unionName, 
                c.recordname AS castingFullName, 
                proj.isdirect
            FROM audprojects proj
            INNER JOIN audroles r ON r.audprojectid = proj.audprojectid
            LEFT JOIN audcontracttypes ct ON proj.contractTypeID = ct.contracttypeid
            LEFT JOIN audsubcategories subcat ON proj.audSubCatID = subcat.audSubCatId
            LEFT JOIN audcategories cat ON subcat.audCatId = cat.audCatId
            LEFT JOIN audtones_user ton ON proj.toneID = ton.toneid
            LEFT JOIN audnetworks_user net ON proj.networkID = net.networkid
            LEFT JOIN contactdetails c ON c.contactid = proj.contactid
            LEFT JOIN audunions un ON proj.unionID = un.unionID
            WHERE proj.audprojectID = <cfqueryparam value="#arguments.audprojectID#" cfsqltype="cf_sql_integer">
         
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELaudprojects_24550" access="public" returntype="query">
    <cfargument name="audprojectID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                p.audprojectid, 
                p.contactid 
            FROM 
                audprojects p 
            INNER JOIN 
                audroles r ON r.audprojectID = p.audprojectID 
            WHERE 
                p.isdeleted IS FALSE 
                AND r.isdeleted IS FALSE 
                AND p.audprojectID = <cfqueryparam value="#arguments.audprojectID#" cfsqltype="cf_sql_integer">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETaudprojects_24553" access="public" returntype="query">
    <cfargument name="eventid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                a4.audroleid, 
                a.projName, 
                a.projDescription, 
                a4.payrate,
                a4.buyout,
                a1.network, 
                a2.audSubCatName, 
                a3.unionName, 
                a4.audRoleName, 
                a4.charDescription, 
                a4.holdStartDate, 
                a4.holdEndDate, 
                a5.audroletype, 
                a6.auddialect, 
                ad.*
            FROM audprojects a
            LEFT OUTER JOIN audnetworks a1 ON (a.networkID = a1.networkid)
            INNER JOIN audsubcategories a2 ON (a.audSubCatID = a2.audSubCatId)
            LEFT OUTER JOIN audunions a3 ON (a.unionID = a3.unionID)
            INNER JOIN audroles a4 ON (a.audprojectID = a4.audprojectID)
            INNER JOIN events ad ON (ad.audroleid = a4.audroleid)
            LEFT OUTER JOIN audroletypes a5 ON (a4.audRoleTypeID = a5.audroletypeid)
            LEFT OUTER JOIN auddialects a6 ON (a4.audDialectID = a6.auddialectid)
            LEFT JOIN audtypes t ON t.audtypeid = ad.audtypeid
            WHERE ad.eventid = <cfqueryparam value="#arguments.eventid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETaudprojects_24554" access="public" returntype="query">
    <cfargument name="audprojectid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                a4.audroleid,
                a.audprojectid, 
                a.projname, 
                a4.netincome,
                a4.paycycleid,
                a.projDescription, 
                a4.payrate,
                a4.buyout,
                a.userid, 
                a.audSubCatID, 
                a4.incometypeid,
                a2.audcatid, 
                a.unionid, 
                a.networkID, 
                a.toneid, 
                a.contracttypeid, 
                a.isdeleted, 
                a.contactid, 
                a.recordname, 
                a4.incometypeid,
                a2.audSubCatName, 
                ac.audcatname, 
                ac.audcatid
            FROM audprojects a
            LEFT OUTER JOIN audnetworks a1 ON (a.networkID = a1.networkid)
            LEFT OUTER JOIN audsubcategories a2 ON (a.audSubCatID = a2.audSubCatId)
            LEFT OUTER JOIN audunions a3 ON (a.unionID = a3.unionID)
            LEFT OUTER JOIN audroles a4 ON (a.audprojectID = a4.audprojectID)
            LEFT OUTER JOIN audcategories ac ON (ac.audcatid = a2.audcatid)
            WHERE a.audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELaudprojects_24559" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="sel_coname" type="string" required="true">

<cfquery name="result" >
            SELECT DISTINCT c.contactid
            FROM audprojects p
            INNER JOIN contactdetails c ON c.contactid = p.contactid
            INNER JOIN contactitems i ON i.contactid = c.contactid
            WHERE p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            AND i.valueCompany = <cfqueryparam value="#arguments.sel_coname#" cfsqltype="CF_SQL_VARCHAR">
         
</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="getAuditions" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="byimport" type="string" required="false" default="">
    <cfargument name="sel_contactid" type="string" required="false" default="%">
    <cfargument name="colist" type="string" required="false" default="%">
    <cfargument name="sel_audcatid" type="string" required="false" default="%">
    <cfargument name="sel_audstepid" type="string" required="false" default="%">
    <cfargument name="sel_audtype" type="string" required="false" default="%">
    <cfargument name="auddate" type="string" required="false" default="">
    <cfargument name="cur_date" type="date" required="false">
    <cfargument name="materials" type="string" required="false" default="%">
    <cfargument name="audsearch" type="string" required="false" default="">
    <cfargument name="sel_date_from" type="string" required="false" default="">
    <cfargument name="sel_date_to" type="string" required="false" default="">
    <cfargument name="sel_year" type="string" required="false" default="">

<cfquery name="result" >
            SELECT 
                p.audprojectid AS recid, 
                p.audprojectid, 
                r.payrate,
                r.buyout,
                r.audroleid, 
                st.audstep, 
                st.stepcss, 
                r.iscallback, 
                c.contactfullname, 
                r.isredirect, 
                ca.audcatname, 
                r.ispin, 
                r.isbooked, 
                'Date' AS head1, 
                'Project' AS head2, 
                'Category' AS head3, 
                'Role' AS head4, 
                'Source' AS head5, 
                'Status' AS head6, 
                p.projdate AS col1, 
                p.audprojectdate AS col1b, 
                p.projname AS col2, 
                ca.audcatname AS col3, 
                ca.aud_cat_icon,
                r.audrolename AS col4, 
                s.audsource AS col5, 
                c2.recordname AS contactname, 
                c.recordname,
                c.recordname as castingfullname,
                sc.audsubcatname, 
                p.projdate,
                rt.audroletype,
                CONCAT_WS("|", p.projname, rt.audroletype, c.recordname, st.audstep, rt.audroletype, s.audsource, p.projdescription) AS search_query,
                GROUP_CONCAT(c3.recordname) AS contacts_list
            FROM audprojects p
            INNER JOIN audroles r ON p.audprojectID = r.audprojectID
            LEFT JOIN events a ON r.audroleid = a.audroleid
            LEFT JOIN audsources s ON s.audSourceID = r.audSourceID
            LEFT JOIN contactdetails c ON c.contactID = p.contactid
            LEFT JOIN contactdetails c2 ON c2.contactID = r.contactid
            LEFT JOIN audroletypes rt ON rt.audroletypeid = r.audroletypeid
            LEFT JOIN audsteps st ON st.audstepid = a.audstepid
            LEFT JOIN audsubcategories sc ON sc.audsubcatid = p.audsubcatid
            LEFT JOIN audcategories ca ON ca.audcatid = sc.audcatid
            LEFT JOIN audcontacts_auditions_xref x ON x.audprojectid = p.audprojectid
            LEFT JOIN contactdetails c3 ON c3.contactid = x.contactid
            WHERE r.isdeleted = 0 AND p.isDeleted = 0 AND p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">

<cfif arguments.byimport neq "">
                AND p.audprojectid IN (
                    SELECT audprojectid FROM auditionsimport WHERE uploadid = <cfqueryparam value="#arguments.byimport#" cfsqltype="CF_SQL_INTEGER">
                )
            </cfif>

<cfif arguments.sel_contactid neq "%">
                AND c.contactid = <cfqueryparam value="#arguments.sel_contactid#" cfsqltype="CF_SQL_INTEGER">
            </cfif>

<cfif arguments.colist neq "%" and arguments.colist neq "">
                AND c.contactid IN (#arguments.colist#)
            </cfif>

<cfif arguments.sel_audcatid neq "%">
                AND sc.audcatid = <cfqueryparam value="#arguments.sel_audcatid#" cfsqltype="CF_SQL_INTEGER">
            </cfif>

<cfif arguments.sel_audstepid neq "%">
                <cfif arguments.sel_audstepid eq "2"> AND r.iscallback = 1 </cfif>
                <cfif arguments.sel_audstepid eq "3"> AND r.isredirect = 1 </cfif>
                <cfif arguments.sel_audstepid eq "4"> AND r.ispin = 1 </cfif>
                <cfif arguments.sel_audstepid eq "5"> AND r.isbooked = 1 </cfif>
                <cfif arguments.sel_audstepid eq "1"> AND p.isDirect = 0 </cfif>
                <cfif arguments.sel_audstepid eq "999"> AND p.isDirect = 1 </cfif>
            </cfif>

<cfif arguments.sel_audtype neq "%">
                AND t.audtype = <cfqueryparam value="#arguments.sel_audtype#" cfsqltype="CF_SQL_VARCHAR">
            </cfif>

            <cfif arguments.auddate eq "future">
                AND p.projdate >= <cfqueryparam value="#arguments.cur_date#" cfsqltype="CF_SQL_DATE">
            </cfif>

            <cfif arguments.auddate eq "past">
                AND p.projdate <= <cfqueryparam value="#arguments.cur_date#" cfsqltype="CF_SQL_DATE">
            </cfif>

            <!--- Date range filtering --->
            <cfif len(trim(arguments.sel_date_from)) and isDate(arguments.sel_date_from)>
                AND p.projdate >= <cfqueryparam value="#arguments.sel_date_from#" cfsqltype="CF_SQL_DATE">
            </cfif>

            <cfif len(trim(arguments.sel_date_to)) and isDate(arguments.sel_date_to)>
                AND p.projdate <= <cfqueryparam value="#arguments.sel_date_to#" cfsqltype="CF_SQL_DATE">
            </cfif>

            <!--- Year filtering --->
            <cfif len(trim(arguments.sel_year)) and isNumeric(arguments.sel_year)>
                AND YEAR(p.projdate) = <cfqueryparam value="#arguments.sel_year#" cfsqltype="CF_SQL_INTEGER">
            </cfif><cfif arguments.materials neq "%" and arguments.materials neq "">
                AND p.audprojectid IN (#arguments.materials#)
            </cfif>

GROUP BY r.audroleid, p.projname, s.audsource, rt.audroletype, r.iscallback, r.isredirect, r.ispin, r.isbooked

<cfif arguments.audsearch neq "">
              HAVING (search_query LIKE '%#arguments.audsearch#%' OR contacts_list LIKE '%#arguments.audsearch#%')
            </cfif>

ORDER BY p.projdate DESC
         
</cfquery>

<!--- Return the query result --->
        <cfreturn result>

</cffunction>
<cffunction output="false" name="INSaudprojects_24585" access="public" returntype="numeric">
    <cfargument name="new_projName" type="string" required="true">
    <cfargument name="new_projDescription" type="string" required="false">
    <cfargument name="new_userid" type="numeric" required="false">
    <cfargument name="new_audSubCatID" type="numeric" required="false">
    <cfargument name="new_unionID" type="numeric" required="false">
    <cfargument name="new_networkID" type="numeric" required="false">
    <cfargument name="new_toneID" type="numeric" required="false">
    <cfargument name="new_contractTypeID" type="numeric" required="false">
    <cfargument name="new_isDeleted" type="string" required="false">
    <cfargument name="isdirect" type="string" required="false">
    <cfargument name="new_contactid" type="numeric" required="false">
    <cfargument name="new_payrate" type="string" required="false">
    <cfargument name="new_buyout" type="string" required="false">
    <cfargument name="new_eventStart" type="string" required="true">

    <cfquery result="result">
        INSERT INTO audprojects (
            projName,
            projDescription,
            audprojectdate,
            projdate
            <cfif structKeyExists(arguments, "new_userid") AND arguments.new_userid NEQ 0>, userid</cfif>
            <cfif structKeyExists(arguments, "new_audSubCatID") AND arguments.new_audSubCatID NEQ 0>, audSubCatID</cfif>
            <cfif structKeyExists(arguments, "new_unionID") AND arguments.new_unionID NEQ 0>, unionID</cfif>
            <cfif structKeyExists(arguments, "new_networkID") AND arguments.new_networkID NEQ 0>, networkID</cfif>
            <cfif structKeyExists(arguments, "new_toneID") AND arguments.new_toneID NEQ 0>, toneID</cfif>
            <cfif structKeyExists(arguments, "new_contractTypeID") AND arguments.new_contractTypeID NEQ 0>, contractTypeID</cfif>
            <cfif structKeyExists(arguments, "new_isDeleted")>, isDeleted</cfif>
            <cfif structKeyExists(arguments, "isdirect")>, isDirect</cfif>
            <cfif structKeyExists(arguments, "new_contactid") AND arguments.new_contactid NEQ 0>, contactid</cfif>
        ) VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_projName#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_LONGVARCHAR" value="#arguments.new_projDescription#">,
            <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.new_eventStart#">,
            <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.new_eventStart#">
            <cfif structKeyExists(arguments, "new_userid") AND arguments.new_userid NEQ 0>, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_userid#"></cfif>
            <cfif structKeyExists(arguments, "new_audSubCatID") AND arguments.new_audSubCatID NEQ 0>, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audSubCatID#"></cfif>
            <cfif structKeyExists(arguments, "new_unionID") AND arguments.new_unionID NEQ 0>, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_unionID#"></cfif>
            <cfif structKeyExists(arguments, "new_networkID") AND arguments.new_networkID NEQ 0>, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_networkID#"></cfif>
            <cfif structKeyExists(arguments, "new_toneID") AND arguments.new_toneID NEQ 0>, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_toneID#"></cfif>
            <cfif structKeyExists(arguments, "new_contractTypeID") AND arguments.new_contractTypeID NEQ 0>, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contractTypeID#"></cfif>
            <cfif structKeyExists(arguments, "new_isDeleted")>, <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#"></cfif>
            <cfif structKeyExists(arguments, "isdirect")>, <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.isdirect#"></cfif>
            <cfif structKeyExists(arguments, "new_contactid") AND arguments.new_contactid NEQ 0>, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contactid#"></cfif>
        )
    </cfquery>

    <!--- Return the generated key --->
    <cfreturn result.generatedKey>
</cffunction>


<cffunction output="false" name="DETaudprojects_24716" access="public" returntype="query">
    <cfargument name="audprojectID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                proj.audprojectID, 
                proj.projName, 
                r.payrate,
                cat.audCatName, 
                cat.audcatid, 
                subcat.audSubCatName, 
                ct.contracttype, 
                ton.tone, 
                net.network, 
                un.unionName, 
                c.recordname AS castingFullName
            FROM 
                audprojects proj
            INNER JOIN 
                audroles r ON r.audprojectid = proj.audprojectid
            INNER JOIN 
                audcontracttypes ct ON proj.contractTypeID = ct.contracttypeid
            INNER JOIN 
                audsubcategories subcat ON proj.audSubCatID = subcat.audSubCatId
            INNER JOIN 
                audcategories cat ON subcat.audCatId = cat.audCatId
            LEFT OUTER JOIN 
                audtones ton ON proj.toneID = ton.toneid
            LEFT OUTER JOIN 
                audnetworks net ON proj.networkID = net.networkid
            LEFT OUTER JOIN 
                contactdetails c ON c.contactid = proj.contactid
            LEFT OUTER JOIN 
                audunions un ON proj.unionID = un.unionID
            WHERE 
                proj.audprojectID = <cfqueryparam value="#arguments.audprojectID#" cfsqltype="CF_SQL_INTEGER">
         
</cfquery>

<cfreturn result>

</cffunction>
</cfcomponent>
