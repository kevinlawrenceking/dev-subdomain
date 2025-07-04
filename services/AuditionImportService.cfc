<cfcomponent displayname="Audition Import Service" output="false">


    <cffunction name="RESauditionsimport_23917" access="public" returntype="query" output="false">
        <!--- Arguments --->
        <cfargument name="uploadid" type="numeric" required="true">

        <!--- Query --->
        <cfquery name="result" >
            SELECT 
                ai.id, 
                sc.audsubcatid as selected_id, 
                p.audprojectid AS recid, 
                ai.uploadid, 
                p.audprojectid, 
                r.audroleid, 
                st.audstep, 
                st.stepcss, 
                r.iscallback, 
                r.isredirect, 
                ca.audcatname, 
                r.ispin, 
                r.isbooked, 
                st.stepcss, 
                'Date/Time' AS head1, 
                'Project' AS head2, 
                'Category' as head3, 
                'Role' AS head4, 
                'Source' as head5, 
                'Import Status' as head6,
                ai.projdate AS col1, 
                ai.projdate as col1b, 
                ai.projname AS col2, 
                ai.audcatname as col3, 
                ai.audrolename as col4,
                ai.audsource AS col5, 
                concat(ai.cdfirstname, " ", ai.cdlastname) as contactname, 
                ai.audsubcatname,
                CASE
                    WHEN ai.callback_yn = "y" THEN 'Callback'
                    WHEN ai.redirect_yn = "y" THEN 'Redirect'
                    WHEN ai.pin_yn = "y" THEN 'Pin'
                    WHEN ai.booked_yn = "y" THEN 'Book'
                    ELSE 'Audition'
                END AS col6a,
                ai.status as col6
            FROM 
                auditionsimport ai
            LEFT JOIN audprojects p ON p.audprojectID = ai.audprojectID
            LEFT JOIN audroles r ON p.audprojectID = r.audprojectID
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
            WHERE 
                ai.uploadid = <cfqueryparam value="#arguments.uploadid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

        <!--- Return Query Result --->
        <cfreturn result>
    </cffunction>


    <cffunction name="DETauditionsimport" access="public" returntype="query" output="false">
        <!--- Arguments --->
        <cfargument name="uploadid" type="numeric" required="true">

        <!--- Query --->
        <cfquery name="result" >
            SELECT 
                audprojectid 
            FROM 
                auditionsimport 
            WHERE 
                uploadid = <cfqueryparam value="#arguments.uploadid#" cfsqltype="CF_SQL_INTEGER"> 
                AND status = 'Added'
        </cfquery>

        <!--- Return Query Result --->
        <cfreturn result>
    </cffunction>

    <cffunction name="auditionImports" access="public" returntype="query" hint="Returns a query of imports from auditionsimport table">
              <cfargument name="userid" type="numeric" required="true">
      
        <cfquery name="imports" >
SELECT i.uploadid, i.timestamp, u.userid
            FROM auditionsimport i
           inner join uploads u on u.uploadid = i.uploadid
           where u.userid = #arguments.userid#
        </cfquery>
        <cfreturn imports>
    </cffunction>

</cfcomponent>
