<cfsetting requesttimeout="9999" />

<cftry>
     <cfset image_dir_app="application.retinaIcons14Url" />

     <cfset image_dir_dev="C:\home\theactorsoffice.com\wwwroot\dev-subdomain\app\assets\images\retina-circular-icons\14" />

     <cfset image_dir_uat="C:\home\theactorsoffice.com\wwwroot\uat-subdomain\app\assets\images\retina-circular-icons\14" />

<cfset dir_source_uat="C:\home\theactorsoffice.com\wwwroot\uat-subdomain\app\assets\images\retina-circular-icons\32" />
<cfset dir_dest_uat="C:\home\theactorsoffice.com\wwwroot\uat-subdomain\app\assets\images\retina-circular-icons\14" />

<!--- Read the source directory to get the list of files --->
<cfdirectory directory="#dir_source_uat#" name="files" filter="*.png" />

<!--- Loop through each file in the directory --->
<cfloop query="files">
    <cfset sourceimage = "#dir_source_uat#\#files.name#">
    <cfset destimage = "#dir_dest_uat#\#files.name#">

    <!--- Convert the image using ImageMagick --->

    <cfif NOT FileExists(destimage)>

    <cfexecute name="C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe" 
               arguments="convert #sourceimage# -resize 28x #destimage#" 
               timeout="60"></cfexecute>

               </cfif>
</cfloop>

<cfset dir_source_dev="C:\home\theactorsoffice.com\wwwroot\dev-subdomain\app\assets\images\retina-circular-icons\32" />
<cfset dir_dest_dev="C:\home\theactorsoffice.com\wwwroot\dev-subdomain\app\assets\images\retina-circular-icons\14" />

<!--- Read the source directory to get the list of files --->
<cfdirectory directory="#dir_source_dev#" name="files" filter="*.png" />

<!--- Loop through each file in the directory --->
<cfloop query="files">
    <cfset sourceimage = "#dir_source_dev#\#files.name#">
    <cfset destimage = "#dir_dest_dev#\#files.name#">

    <!--- Convert the image using ImageMagick --->

    <cfif NOT FileExists(destimage)>

    <cfexecute name="C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe" 
               arguments="convert #sourceimage# -resize 28x #destimage#" 
               timeout="60"></cfexecute>

               </cfif>
</cfloop>

<cfset dir_source_app="C:\home\theactorsoffice.com\wwwroot\app-subdomain_1.5\app\assets\images\retina-circular-icons\32" />
<cfset dir_dest_app="application.retinaIcons14Url" />

<!--- Read the source directory to get the list of files --->
<cfdirectory directory="#dir_source_app#" name="files" filter="*.png" />

<!--- Loop through each file in the directory --->
<cfloop query="files">
    <cfset sourceimage = "#dir_source_app#\#files.name#">
    <cfset destimage = "#dir_dest_app#\#files.name#">

    <!--- Convert the image using ImageMagick --->

    <cfif NOT FileExists(destimage)>
    <cfexecute name="C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe" 
               arguments="convert #sourceimage# -resize 28x #destimage#" 
               timeout="60"></cfexecute>

               </cfif>
</cfloop>

<cfset dir_dest_dev="C:\home\theactorsoffice.com\wwwroot\dev-subdomain\app\assets\images\retina-circular-icons\14" />
<cfset dir_dest_uat="C:\home\theactorsoffice.com\wwwroot\uat-subdomain\app\assets\images\retina-circular-icons\14" />

<!--- Read the dev directory to get the list of files --->
<cfdirectory directory="#dir_dest_dev#" name="files_dev" filter="*.png" />

<!--- Read the uat directory to get the list of files --->
<cfdirectory directory="#dir_dest_uat#" name="files_uat" filter="*.png" />

<!--- Create arrays to store file names from each directory --->
<cfset devFiles = [] />
<cfset uatFiles = [] />

<!--- Populate the devFiles array --->
<cfloop query="files_dev">
    <cfset arrayAppend(devFiles, files_dev.name)>
</cfloop>

<!--- Populate the uatFiles array --->
<cfloop query="files_uat">
    <cfset arrayAppend(uatFiles, files_uat.name)>
</cfloop>

<!--- Loop through devFiles to find missing files in uatFiles and copy them --->
<cfloop array="#devFiles#" index="filename">
    <cfif not arrayFind(uatFiles, filename)>
        <cffile action="copy" 
                source="#dir_dest_dev#\#filename#" 
                destination="#dir_dest_uat#\#filename#" 
                nameconflict="skip" />
    </cfif>
</cfloop>

<!--- Loop through uatFiles to find missing files in devFiles and copy them --->
<cfloop array="#uatFiles#" index="filename">
    <cfif not arrayFind(devFiles, filename)>
        <cffile action="copy" 
                source="#dir_dest_uat#\#filename#" 
                destination="#dir_dest_dev#\#filename#" 
                nameconflict="skip" />
    </cfif>
</cfloop>

<cfcatch type="any">
    <!--- Custom error message --->
    <cfdump var="#cfcatch#">
    <cfoutput>
      <p>An error occurred: #cfcatch.message#</p>
      <p>Error type: #cfcatch.type#</p>
      <p>Error detail: #cfcatch.detail#</p>
    </cfoutput>

      <cfabort>
  </cfcatch>
</cftry>
