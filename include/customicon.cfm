<!--- This ColdFusion page fetches favicons from specified URLs and saves them as PNG images. --->
<cfinclude template="/include/qry/x_91_1.cfm" />

<!--- Loop through each record in the query x --->
<cfloop query="x">
    <cfset id = x.id />
    <cfset siteurl = x.siteurl />
    
    <!--- Add 'http' if missing in the site URL --->
    <cfif NOT findNoCase("http", siteurl)>
        <cfset siteurl = "http://" & siteurl />
    </cfif>
    
    <Cfabort>
    <cftry>
        <!--- Fetch the favicon from the site URL --->
        <cfhttp url="#siteurl#/favicon.ico" method="get" getAsBinary="yes" result="result"></cfhttp>
        
        <!--- Check if cfhttp was successful and the content type indicates an image --->
        <cfif result.statusCode EQ "200 OK" AND findNoCase("image/", result.responseHeader["Content-Type"])>
            <!--- Write the favicon to a temporary file --->
            <cffile action="write"
                    file="#GetTempDirectory()#/favicon.ico"
                    output="#result.fileContent#"
                    mode="777">
            </cffile>
            
            <!--- New image name and directory --->
            <cfset new_siteicon = "custom_#id#.png" />
            <cfoutput>
            <cfset image_dir = "#application.retinaIcons14Url#" />
            </cfoutput>
            
            <!--- Convert to PNG and Save --->
            <cfimage action="read" source="#GetTempDirectory()#/favicon.ico" name="imageObj">
            <cfimage action="write" destination="#image_dir#/custom_#id#.png" source="#imageObj#" format="png"></cfimage>
            
            <!--- Update Record with the new favicon --->
            <cfinclude template="/include/qry/update_91_2.cfm" />
        </cfif>
        
        <!--- Catch any errors during the process --->
        <cfcatch type="any">
            <!--- Log the error if fetching the favicon fails --->
            <cflog file="fetch_favicon_error" text="Error fetching favicon for ID #id# - #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfloop>
