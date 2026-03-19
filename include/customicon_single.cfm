<!--- This ColdFusion page retrieves link details, processes an icon from a specified domain, and updates the site icon in the database. --->
<cfparam name="dbug" default="N" />

<!--- Guard: valid link id --->
<cfif NOT isDefined("id") OR NOT val(id) GT 0>
    <cflog file="tao-linkicon" text="customicon_single: skipped — missing or invalid id" />
    <cfexit />
</cfif>

<!--- Guard: required application paths and keys --->
<cfif NOT isDefined("application.retinaIcons14Path") OR NOT len(application.retinaIcons14Path)>
    <cflog file="tao-linkicon" text="customicon_single: skipped — application.retinaIcons14Path not set" />
    <cfexit />
</cfif>
<cfif NOT isDefined("application.secrets.iconHorseApiKey") OR NOT len(application.secrets.iconHorseApiKey)>
    <cflog file="tao-linkicon" text="customicon_single: skipped — iconHorseApiKey not set" />
    <cfexit />
</cfif>

<cfset siteLinksService = createObject("component", "services.SiteLinksService")>
<cfset linkDetails = siteLinksService.getLinkDetailsById(id)>

<!--- Guard: query returned a row --->
<cfif linkDetails.recordCount EQ 0>
    <cflog file="tao-linkicon" text="customicon_single: skipped — no link found for id=#id#" />
    <cfexit />
</cfif>

<cfset siteurl = linkDetails.siteurl />

<!--- Ensure the site URL has a protocol --->
<cfif NOT findNoCase("http", siteurl)>
    <cfset siteurl = "http://" & siteurl />
</cfif>

<!--- Extract the root URL --->
<cfset protocol = listFirst(siteurl, "://") & "://" />
<cfif #dbug# neq "N">
    <cfoutput>protocol: [#protocol#]</cfoutput><br>
</cfif>

<cfset tempUrl = listRest(siteurl, "://") />
<cfif #dbug# neq "N">
    <cfoutput>tempUrl: [#tempUrl#]</cfoutput><br>
</cfif>

<cfset domain = listFirst(tempUrl, "/") />
<cfif #dbug# neq "N">
    <cfoutput>domain: [#domain#]</cfoutput><br>
</cfif>

<cfset rootUrl = protocol & domain />
<cfif #dbug# neq "N">
    <cfoutput>rootUrl: [#rootUrl#]</cfoutput><br>
</cfif>

<!--- Remove 'www.' from the domain if present --->
<cfif left(domain, 4) is "www.">
    <cfset domain = right(domain, len(domain) - 4) />
    <cfif #dbug# neq "N">
        <cfoutput>domain: [#domain#]<br></cfoutput>
    </cfif>
</cfif>

<!--- Fix the image_dir path and use correct path formatting --->
<cfset image_dir = replace("#application.retinaIcons14Path#", "\", "/", "all") />
<cfif #dbug# neq "N">
    <cfoutput>image_dir: [#image_dir#]</cfoutput><br>
</cfif>

<!--- Check if the temp directory exists, create it if not --->
<cfif NOT directoryExists("#image_dir#/temp")>
    <cfdirectory action="create" directory="#image_dir#/temp">
</cfif>

<!--- Make the CFHTTP request to retrieve the icon --->
<cfhttp url="https://icon.horse/icon/#domain#?apikey=#application.secrets.iconHorseApiKey#&fallback_bg=406e8e&size=small&ignore_other_sizes=false"
        method="get"
        getAsBinary="yes"
        timeout="15"
        result="icoResult">
</cfhttp>

<cfif #dbug# eq "Y">
    <cfdump var="#icoResult#">
    <p>
        <cfoutput>cfhttp: https://icon.horse/icon/#domain#?apikey=#application.secrets.iconHorseApiKey#&fallback_bg=406e8e&size=small&ignore_other_sizes=false</cfoutput>
    </p>
</cfif>

<!--- Check if the HTTP request was successful --->
<cfif icoResult.statusCode EQ "200 OK">
    
    <!--- Determine the file extension based on Content-Type --->
    <cfset contentType = icoResult.responseHeader["Content-Type"]>
    <cfset fileExtension = ".ico"> <!--- Default to .ico --->
    
    <cfif contentType EQ "image/png">
        <cfset fileExtension = ".png">
    <cfelseif contentType EQ "image/jpeg">
        <cfset fileExtension = ".jpg">
    </cfif>

    <!--- Fix the tempFile and pngFile paths --->
    <cfset tempFile = "#replace(application.retinaIcons14Path, '\', '/', 'all')#/temp/custom_#id##fileExtension#" />
    <cfset pngFile = "#replace(application.retinaIcons14Path, '\', '/', 'all')#/custom_#id#.png" />

    <cfif #dbug# neq "N">
        <p>temp file: <cfoutput>#tempFile#</cfoutput></p>
        <p>png file: <cfoutput>#pngFile#</cfoutput></p>
    </cfif>

    <!--- Write the image to the file system --->
    <cffile action="write" file="#tempFile#" output="#icoResult.filecontent#" />

    <!--- Convert the image using ImageMagick --->
    <cfexecute name="C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe"
        arguments="convert #tempFile# -resize 28x #pngFile#"
        timeout="60">
    </cfexecute>

    <!--- Update the sitelinks_user table with the new siteicon --->
    <cfset fileName = "custom_#id#.png">

    <cfinclude template="/include/qry/update_92_1.cfm" />

</cfif>
