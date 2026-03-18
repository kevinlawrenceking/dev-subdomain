 
  

<cfparam name="new_projName" default=""/>

<cfparam name="new_projDescription" default=""/>

<cfparam name="new_audSubCatID" default=""/>

<cfparam name="new_unionID" default=""/>

<cfparam name="new_networkID" default=""/>

<cfparam name="new_toneID" default=""/>

<cfparam name="new_contractTypeID" default=""/>

<cfparam name="new_contactid" default=""/>

<cfparam name="isdirect" default="0"/>

<cfparam name="isbooked" default="0"/>

<cfparam name="ispin" default="0"/>



<cfparam name="new_audsourceid" default="0"/>

<cfset currentURL = cgi.server_name/>
<cfset host = ListFirst(currentURL, ".")/>

<cfquery name="FindUser">
    SELECT
    u.userid
    ,u.userFirstName
    ,u.recordname
    ,u.userLastName
    ,u.userEmail
    ,u.contactid
    ,u.userRole
    ,u.contactid AS userContactID
    FROM taousers u
    WHERE u.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#" />
</cfquery>

<!--- WO-4.4: Transaction wraps upload record + staging inserts + transfer + date fix --->
<cftransaction>

<cfquery name="INSERT" result="result">
    INSERT INTO `uploads` (userid)
    VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#userid#" />)
</cfquery>

<cfset new_uploadid = result.generatedkey>

<cfoutput>

    <cfset cUploadFolder = "C:\home\theactorsoffice.com\wwwroot\#host#-subdomain\media-#host#\users\#finduser.userid#"/>
</cfoutput>

<cfif not DirectoryExists("#cUploadFolder#")>

    <cfdirectory directory="#cUploadFolder#" action="create">
</cfif>

<cffile action="upload" filefield="form.file" destination="#cUploadFolder#\" 
        nameconflict="MAKEUNIQUE"/>

<!--- read the spreadsheet data into a query object --->
<cfspreadsheet action="read" query="importdata" src="#cUploadFolder#\#cffile.serverfile#" 
columnnames="projDate,projName,audRoleName,audcatsubname,audsource,cdfirstname,cdlastname,callback_yn,redirect_yn,pin_yn,booked_yn,projDescription,charDescription,note" 
               headerrow="1"/>

<cffunction name="arraysAreEqual" returntype="boolean">
    <cfargument name="array1" type="array" required="true">
    <cfargument name="array2" type="array" required="true">
    <cfset var i = "">
    
    <!--- Check if arrays are of same size --->
    <cfif arrayLen(arguments.array1) neq arrayLen(arguments.array2)>
        <cfreturn false>
    </cfif>
    
    <!--- Check if arrays have same elements in same order --->
    <cfloop index="i" from="1" to="#arrayLen(arguments.array1)#">
        <cfif arguments.array1[i] neq arguments.array2[i]>
            <cfreturn false>
        </cfif>
    </cfloop>
    
    <!--- If no differences were found, the arrays are equal --->
    <cfreturn true>
</cffunction>

<!--- Get the column names from the imported data --->
<cfset spreadsheetColumns = importdata.columnList/>

<!--- Convert the string of column names to an array --->
<cfset spreadsheetColumnsArray = ListToArray(spreadsheetColumns) />

<!--- Define the correct columns for your application --->
<cfset correctColumns = "projdate,projname,audrolename,audcatsubname,audsource,cdfirstname,cdlastname,callback_yn,redirect_yn,pin_yn,booked_yn,projdescription,chardescription,note" />

<!--- Convert the correct column list to an array --->
<cfset correctColumnsArray = ListToArray(correctColumns) />

<!--- Compare the arrays --->
 

<!--- create a variable to store the codes of products that could not be imported --->
<cfset failedimports = ""/>

<!--- loop through the query starting with the first row containing data (row 2) --->
<cfloop query="importdata" startrow="2">
    <!--- check row contains valid data (all fields must contain a value and price must be numeric)
    --->
    <!--- Null-safe field extraction: cfspreadsheet can return Java nulls for empty cells --->
    <cfset safe_projName = len(importdata.projName) ? trim(importdata.projName) : "">
    <cfset safe_audRoleName = len(importdata.audRoleName) ? trim(importdata.audRoleName) : "">
    <cfset safe_audcatsubname = len(importdata.audcatsubname) ? trim(importdata.audcatsubname) : "">
    <cfset safe_audsource = len(importdata.audsource) ? trim(importdata.audsource) : "">
    <cfset safe_cdfirstname = len(importdata.cdfirstname) ? trim(importdata.cdfirstname) : "">
    <cfset safe_cdlastname = len(importdata.cdlastname) ? trim(importdata.cdlastname) : "">
    <cfset safe_callback_yn = len(importdata.callback_yn) ? left(importdata.callback_yn, 1) : "">
    <cfset safe_redirect_yn = len(importdata.redirect_yn) ? left(importdata.redirect_yn, 1) : "">
    <cfset safe_pin_yn = len(importdata.pin_yn) ? left(importdata.pin_yn, 1) : "">
    <cfset safe_booked_yn = len(importdata.booked_yn) ? left(importdata.booked_yn, 1) : "">
    <cfset safe_projDescription = len(importdata.projDescription) ? trim(importdata.projDescription) : "">
    <cfset safe_charDescription = len(importdata.charDescription) ? trim(importdata.charDescription) : "">
    <cfset safe_note = len(importdata.note) ? trim(importdata.note) : "">
    <cfset safe_projDate = len(importdata.projDate) ? trim(importdata.projDate) : "">

    <cfif LEN(safe_projName) gt 0>

    <cftry>

<!--- Check if the hyphen exists in the string --->
<cfif find('-', safe_audcatsubname)>
  <cfset parts = listToArray(safe_audcatsubname, '-')>
  <cfset audcatname = parts[1]>
  <cfset audsubcatname = parts[2]>

   <cfquery  name="findSubCatId">
        SELECT s.audsubcatid as new_audsubcatid
        FROM audcategories c
        INNER JOIN audsubcategories s ON s.audcatid = c.audcatid
        WHERE c.audcatname = <cfqueryparam value="#audcatname#" cfsqltype="CF_SQL_VARCHAR">
          AND s.audsubcatname = <cfqueryparam value="#audsubcatname#" cfsqltype="CF_SQL_VARCHAR">

    </cfquery>


 <cfif #findSubCatId.recordcount# is "1">
   <cfset new_audsubcatid = "#findSubCatId.new_audsubcatid#" />

<cfelse>
  <cfset new_audsubcatid = "0">
</cfif>
<cfelse>
  <!--- Handle the case where there's no hyphen --->
  <cfset audcatname = "">
  <cfset audsubcatname = "">
   <cfset new_audsubcatid = "0">
</cfif>


        <cfquery  name="find">
            INSERT INTO `auditionsimport` (`audsubcatid`,`uploadid`
            <cfif safe_projDate is not "">
                , `projDate`
            </cfif>
            , `projName`, `audRoleName`, `audCatName`,`audsubcatname`,  `audsource`,
            `cdfirstname`,`cdlastname`, `callback_yn`, `redirect_yn`, `pin_yn`, `booked_yn`,
            `projDescription`, `charDescription`, `note`)
            VALUES
            (<cfqueryparam cfsqltype="cf_sql_integer" value="#new_audsubcatid#"/>, <cfqueryparam cfsqltype="cf_sql_integer" value="#new_uploadid#"/>

            <cfif safe_projDate is not "">

                ,
                <cfqueryparam cfsqltype="cf_sql_varchar"
                              value="#dateformat(safe_projDate,"yyyy-mm-dd")#"/>
            </cfif>

        ,<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="500"
                      value="#safe_projName#"/>
            ,<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="500"
                      value="#safe_audRoleName#"/>
            ,<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100"
                      value="#TRIM(audCatName)#"/>

              ,<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100"
                      value="#TRIM(audSubCatName)#"/>

            ,<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100"
                      value="#safe_audsource#"/>
            ,<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100"
                      value="#safe_cdfirstname#"/>
            ,<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100"
                      value="#safe_cdlastname#"/>
            ,<cfqueryparam cfsqltype="cf_sql_char" maxlength="1"
                      value="#safe_callback_yn#"/>
            ,<cfqueryparam cfsqltype="cf_sql_char" maxlength="1"
                      value="#safe_redirect_yn#"/>
            ,<cfqueryparam cfsqltype="cf_sql_char" maxlength="1" value="#safe_pin_yn#"/>
            ,<cfqueryparam cfsqltype="cf_sql_char" maxlength="1"
                      value="#safe_booked_yn#"/>
            ,<cfqueryparam cfsqltype="cf_sql_longvarchar"
                      value="#safe_projDescription#"/>
            ,<cfqueryparam cfsqltype="cf_sql_longvarchar"
                      value="#safe_charDescription#"/>
            ,<cfqueryparam cfsqltype="cf_sql_longvarchar"
                      value="#safe_note#"/>
            )
        </cfquery>

    <cfcatch type="any">
        <cfset failedimports = listAppend(failedimports, importdata.currentrow)>
        <cflog file="audition_import" type="error" text="Row #importdata.currentrow# insert failed: #cfcatch.message# | #cfcatch.detail#">
    </cfcatch>
    </cftry>

    </cfif>
</cfloop>


<cfinclude template="transfer_audition.cfm" />


    <cfquery name="fix">
UPDATE audprojects p
INNER JOIN auditionsimport i ON i.audprojectid = p.audprojectid
SET p.projdate = i.projdate
WHERE STR_TO_DATE(i.projdate, '%Y-%m-%d') IS NOT NULL;
</cfquery>

</cftransaction><!--- end WO-4.4 transaction --->

<cflocation url="/app/auditions-import/?uploadid=#new_uploadid#">