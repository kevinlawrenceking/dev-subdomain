

<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<cfinclude template="/include/qry/INSERT_315_1.cfm" />

<cfset new_uploadid = result.generatedkey />

<cfoutput>
upload id: #new_uploadid#<BR>
    <cfset session.userMediaPath = "C:\home\theactorsoffice.com\wwwroot\#host#-subdomain\media-#host#\users\#userid#" />
</cfoutput>

<!--- Check if the user media path exists, if not, create it --->
<CFIF not DirectoryExists("#session.userMediaPath#")>
    <CFDIRECTORY directory="#session.userMediaPath#" action="create">
</CFIF>

<cffile action="upload" filefield="form.file" destination="#session.userMediaPath#\" nameconflict="MAKEUNIQUE" />

<!--- Phase 1: Detect file type and parse accordingly --->
<cfset fileExtension = lcase(listLast(cffile.serverFile, "."))>
<cfset templateColumns = "FirstName,LastName,Tag1,Tag2,Tag3,BusinessEmail,PersonalEmail,WorkPhone,MobilePhone,HomePhone,Company,Address,Address2,City,State,Zip,Country,contactMeetingDate,contactMeetingLoc,Birthday,website,Notes">

<cfif fileExtension EQ "csv">
    <!--- Parse CSV file using CsvParserService --->
    <cfset csvParser = createObject("component", "services.CsvParserService")>
    <cfset uploadedFilePath = "#session.userMediaPath#\#cffile.serverfile#">

    <cftry>
        <cfset importdata = csvParser.csvFileToQuery(uploadedFilePath, templateColumns, true)>

        <cfcatch>
            <!--- Log error and provide user-friendly message --->
            <cfoutput>
                <div class="alert alert-danger">
                    <h4>CSV Parsing Error</h4>
                    <p>There was an error parsing your CSV file: #cfcatch.message#</p>
                    <p>Please ensure your CSV file matches the template format.</p>
                    <a href="/app/contacts-import/" class="btn btn-primary">Go Back</a>
                </div>
            </cfoutput>
            <cfabort>
        </cfcatch>
    </cftry>

<cfelseif fileExtension EQ "xlsx">
    <!--- Parse XLSX file using existing cfspreadsheet --->
    <cftry>
        <cfspreadsheet action="read"
            src="#session.userMediaPath#\#cffile.serverfile#"
            query="importdata"
            columnnames="#templateColumns#"
            headerrow="1" />

        <cfcatch>
            <!--- Log error and provide user-friendly message --->
            <cfoutput>
                <div class="alert alert-danger">
                    <h4>Excel File Error</h4>
                    <p>There was an error reading your Excel file: #cfcatch.message#</p>
                    <p>Please ensure your file is a valid .xlsx file and matches the template format.</p>
                    <a href="/app/contacts-import/" class="btn btn-primary">Go Back</a>
                </div>
            </cfoutput>
            <cfabort>
        </cfcatch>
    </cftry>

<cfelse>
    <!--- Unsupported file type --->
    <cfoutput>
        <div class="alert alert-danger">
            <h4>Unsupported File Type</h4>
            <p>The file type ".<strong>#fileExtension#</strong>" is not supported.</p>
            <p>Please upload either a <strong>.xlsx</strong> (Excel) or <strong>.csv</strong> file.</p>
            <a href="/app/contacts-import/" class="btn btn-primary">Go Back</a>
        </div>
    </cfoutput>
    <cfabort>
</cfif>




<cfoutput>
importdata: #importdata.recordcount#<BR>
</cfoutput>

<!--- ========================================
      PHASE 1: VALIDATE IMPORT DATA
     ======================================== --->
<cfset validationService = createObject("component", "services.ContactImportValidationService")>
<cfset validationResult = validationService.validateImportData(importdata, userid)>

<!--- Store validation result in session for preview --->
<cfset session.pendingImport = {
    uploadid: new_uploadid,
    validationResult: validationResult,
    filename: cffile.serverFile,
    uploadDate: now()
}>

<!--- If there are errors or this needs user review, redirect to preview --->
<cfif validationResult.errorCount GT 0 OR validationResult.updateCount GT 0>
    <cflocation url="/app/contacts-import/?preview=true&uploadid=#new_uploadid#" addtoken="false">
    <cfabort>
</cfif>

<!--- Otherwise continue with automatic processing --->

<cfinclude template="/include/qry/find_315_2.cfm" />
<cfoutput>
Contacts imported: #find#<BR>
</cfoutput>

<cfinclude template="/include/qry/getContactsImportByUploadID.cfm" />
<cfoutput>contactimports to loop: #new.recordcount#<BR></cfoutput>
<cfoutput>notes: #new.notes#<BR></cfoutput>
<cfloop query="new">

 <!--- Migrated from /include/qry/add_315_6.cfm - inline service call --->
 <cfset contactService = createObject("component", "services.ContactService")>
 <cfset result = contactService.INScontactdetails_24399(new_x=new_x, userid=userid)>

   <cfset select_userid = userid />
        <cfset select_contactid = result.new_contactid />
        <cfinclude template="/include/folder_setup.cfm" />


     <cfif #new.notes# is not ""> 
New notes arent empty <BR>
        <cfinclude template="/include/qry/find_note_315_7.cfm" />
        
        <cfif #find_Note.recordcount# is "0">
            <cfinclude template="/include/qry/InsertNote_315_8.cfm" />
        </cfif> 
    </cfif>


</cfloop>


<cfinclude template="/include/qry/tag_315_10.cfm" />
<cfloop query="tag">
    <cfset new_tag1 = tag.tag1 />
    <cfinclude template="/include/qry/tag_insert_315_11.cfm" />
</cfloop>

<cfinclude template="/include/qry/tag_315_12.cfm" />
<cfloop query="tag2">
    <cfset new_tag2 = tag2.tag2 />

    <cfinclude template="/include/qry/tag_insert_315_13.cfm" />
</cfloop>

<cfinclude template="/include/qry/tag_315_14.cfm" />
<cfloop query="tag3">
    <cfset new_tag3 = tag3.tag3 />
    <cfinclude template="/include/qry/tag_insert_315_15.cfm" />
</cfloop>

<cfinclude template="/include/qry/e_315_16.cfm" />
<cfloop query="e">
    <cfinclude template="/include/qry/e_insert_315_17.cfm" />
</cfloop>

<cfinclude template="/include/qry/f_315_18.cfm" />
<cfloop query="f">
    <cfinclude template="/include/qry/f_insert_315_19.cfm" />
</cfloop>

<cfinclude template="/include/qry/g_315_20.cfm" />
<cfloop query="g">
    <cfinclude template="/include/qry/g_insert_315_21.cfm" />
</cfloop>

<cfinclude template="/include/qry/h_315_22.cfm" />
<cfloop query="h">
    <cfinclude template="/include/qry/h_insert_315_23.cfm" />
</cfloop>

<cfinclude template="/include/qry/i_315_24.cfm" />
<cfloop query="i">
    <cfinclude template="/include/qry/i_insert_315_25.cfm" />
</cfloop>

<cfinclude template="/include/qry/j_315_26.cfm" />
<cfloop query="j">
    <cfinclude template="/include/qry/j_insert_315_27.cfm" />
</cfloop>

<cfinclude template="/include/qry/u_315_28.cfm" />
<cfloop query="u">
    <cfinclude template="/include/qry/u_insert_315_29.cfm" />
</cfloop>

<cfinclude template="/include/qry/address_315_30.cfm" />
<cfloop query="address">
    <cfif #TRIM(address.address)# is "" and #trim(address.address_second)# is "" and #TRIM(address.city)# is "" and #trim(address.state)# is "" and #TRIM(address.zip)# is "" and #TRIM(address.country)# is "">
    <cfelse>
        <cfinclude template="/include/qry/address_insert_315_31.cfm" />
    </cfif>
</cfloop>



<Cfif isdefined('usingMaint')>
<cfinclude template="/include/qry/maints_315_32.cfm" />
<Cfloop query="maints">
    <cfoutput>
        <cfset maint_contactid = #maints.contactid# />
    </cfoutput>

    <cfif #maints.tag# is "Casting Director" or #maints.tag# is "Casting Assistant" or #maints.tag# is "Casting Associate">
        <cfset maint_systemid = 3 />
    <cfelse>
        <cfset maint_systemid = 4 />
    </cfif>

    <cfinclude template="/include/qry/findsystem_315_33.cfm" />
    <cfif #findsystem.recordcount# is "0">
        <cfoutput>
            <Cfset suStartDate = "#DateFormat(Now(),'yyyy-mm-dd')#" />
            <Cfset currentStartDate = "#DateFormat(Now(),'yyyy-mm-dd')#" />
        </cfoutput>

        <cfinclude template="/include/qry/addSystem_315_34.cfm" />
        <cfset NewSUID = result.generatedkey />

        <cfinclude template="/include/qry/addDaysNo_315_35.cfm" />
        <cfloop query="addDaysNo">
            <cfinclude template="/include/qry/checkUnique_315_36.cfm" />
            <cfif #checkunique.recordcount# is "0">
             <cfset notstartdate = dateAdd('d', actionDaysNo, currentstartdate) />
                <cfif notstartdate lte currentstartdate>
                    <cfinclude template="/include/qry/addNotification_315_37.cfm" />
                <cfelse>
                    <cfinclude template="/include/qry/addNotification_315_38.cfm" />
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
</Cfloop>
     
 
</cfif>

<cflocation url="/app/contacts-import/?uploadid=#new_uploadid#">

