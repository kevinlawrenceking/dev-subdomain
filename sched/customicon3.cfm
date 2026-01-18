 

<cfquery result="result" datasource="abo" name="x" maxrows="10">
SELECT id,sitename,siteurl,siteicon FROM sitelinks_user 
WHERE iscustom = 1 
AND siteicon = 'not found' 
</cfquery>

<cfloop query="x">
 <cfset id = x.id />
    <cfset siteurl = x.siteurl />

    <!--- Add 'http' if missing --->
    <cfif NOT findNoCase("http", siteurl)>
        <cfset siteurl = "http://" & siteurl />
    </cfif>

    <!--- Extract the root URL --->
    <cfset protocol = listFirst(siteurl, "://") & "://">
    <cfset tempUrl = listRest(siteurl, "://")>
    <cfset domain = listFirst(tempUrl, "/")>
    <cfset rootUrl = protocol & domain>

    <!--- Retrieve the HTML source code --->
    <cfhttp url="#rootUrl#" method="get" result="result"></cfhttp>
    <cfset htmlContent = result.fileContent.toString()>
    
    <!--- Search for .ico and extract its URL --->
    <cfset startPosition = FindNoCase(".ico", htmlContent)>
    
    <cfif startPosition NEQ 0>
        <cfset startQuote = FindLast("<a href=""", htmlContent, startPosition)>
        <cfset endQuote = Find(">", htmlContent, startPosition)>
        <cfset icoUrl = Mid(htmlContent, startQuote + 10, endQuote - startQuote - 10)>

        <!--- Download the ICO --->
        <cfhttp url="#rootUrl#/#icoUrl#" method="get" getAsBinary="yes" result="icoResult"></cfhttp>

        <cfif icoResult.statusCode EQ "200 OK">
            <!--- File Paths --->
            <cfset tempDir = GetTempDirectory()>
            <cfset tempFileName = tempDir & CreateObject("java", "java.io.File").separator & "favicon_#id#.ico">
            <cfset pngFileName = tempDir & CreateObject("java", "java.io.File").separator & "favicon_#id#.png">
            
            <!--- Write the ICO file --->
            <cffile action="write"
                    file="#tempFileName#"
                    output="#icoResult.fileContent#"
                    mode="777">
            </cffile>
            
            <!--- Convert ICO to PNG using ImageMagick --->
            <cfexecute name="C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe" 
                       arguments="convert #tempFileName# #pngFileName#"
                       timeout="60">
            </cfexecute>
            
            <!--- Read PNG and Save --->
            <cfimage action="read" source="#pngFileName#" name="imageObj">
            <cfimage action="write" destination="#image_dir#\custom_#id#.png" source="#imageObj#" format="png"></cfimage>
            
            <!--- Update Record --->
            <cfset new_siteicon = "custom_#id#.png">
            <cfquery result="result" datasource="abo" name="update">
                update sitelinks_user 
                set siteicon = '#new_siteicon#'
                where id = #id#
            </cfquery>
            
    <cfoutput>#x.id#<BR></cfoutput>
        </cfif>
    <cfelse>
        <!--- No .ico found in the source code. Update the database accordingly --->
        <cfquery result="result" datasource="abo" name="update">
            update sitelinks_user 
            set siteicon = 'unknown.png'
            where id = #id#
        </cfquery>
    </cfif>

</cfloop>

