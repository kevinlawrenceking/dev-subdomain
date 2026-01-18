         <cfquery result="result" name="sitelinks" datasource="abod">
    SELECT id, siteicon 
    FROM sitelinks_user 
    WHERE isdeleted = 0
</cfquery>

<!--- Define the path where the images are stored --->
<cfset application.application.retinaIconsPath = "C:\home\theactorsoffice.com\media-abod\images\retina-circular-icons\14\" />

<cfoutput>
    <!--- Loop through the records --->
    <cfloop query="siteLinks">
        <!--- Build the full path to the site icon --->
        <cfset siteiconPath = application.application.retinaIconsPath & siteLinks.siteicon />

        <!--- Check if the file exists --->
        <cfif NOT fileExists(siteiconPath)>
            <!--- If the file doesn't exist, update the record to "unknown.png" --->
             <cfquery result="result" datasource="abod">
                UPDATE sitelinks_user 
                SET siteicon = 'unknown.png' 
                WHERE id = <cfqueryparam value="#siteLinks.id#" cfsqltype="cf_sql_integer">
            </cfquery>
            <!--- Output the updated record ID for reference --->
            site icon path: #siteiconPath#<BR>
            Updated record ID: #siteLinks.id# with unknown.png<br>
        </cfif>
    </cfloop>

    <!--- Completion message --->
    Maintenance cleanup completed!
</cfoutput>
