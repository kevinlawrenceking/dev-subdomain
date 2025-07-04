
 <cfparam name="check" default="N" />

 <Cfif #check# is "Y">
     <cfquery result="result"  name="z">
         SELECT id,sitename,siteurl,siteicon FROM sitelinks_user WHERE iscustom = 1 AND siteicon <> 'unknown.png'
     </cfquery>

     <cfloop query="z">
         <cfoutput>

             <cfset image_dir="#application.retinaIcons14Path#" />

         </cfoutput>

         <cfset image_location="#image_dir#\#z.siteicon#" />

         <!--- check to see if #image_location# file is an image and exists.  --->

         <cfif FileExists(image_location) AND IsImageFile(image_location)>
             <!--- File exists and is an image, do nothing --->
             <cfelse>

                 <cfquery result="result"  name="update">
                     UPDATE sitelinks_user set siteicon = 'unknown.png' where id = #z.id#
                 </cfquery>
                 <cfoutput>#id# removed!<BR></cfoutput>
         </cfif>

     </cfloop>
 </cfif>

<cfquery result="result"  name="x" maxrows="50">
     SELECT id,sitename,siteurl,siteicon FROM sitelinks_user WHERE iscustom = 1 AND siteicon = 'unknown.png'
 </cfquery>

 <cfloop query="x">

     <cftry>

         <cfset id=x.id />

         <cfset siteurl=x.siteurl />

         <h2>
             <cfoutput>siteurl: #siteurl#</cfoutput>
         </h2>

         <p>id:<cfoutput>#id#</cfoutput>
         </p>

         <!--- Add 'http' if missing --->

         <cfif NOT findNoCase("http", siteurl)>

             <cfset siteurl="http://" & siteurl />

         </cfif>

         <!--- Extract the root URL --->

         <cfset protocol=listFirst(siteurl, "://" ) & "://" />

         <cfset tempUrl=listRest(siteurl, "://" ) />

         <cfset domain=listFirst(tempUrl, "/" ) />

         <cfset rootUrl=protocol & domain />

         <cfif left(domain, 4) is "www.">

             <cfset domain=right(domain, len(domain) - 4) />

         </cfif>

         <cfoutput>

             <cfset image_dir="#application.retinaIcons14Path#" />

         </cfoutput>

         <cfset image_dir_app="application.retinaIcons14Url" />

         <cfset image_dir_dev="C:\home\theactorsoffice.com\wwwroot\dev-subdomain\app\assets\images\retina-circular-icons\14" />

         <cfset image_dir_uat="C:\home\theactorsoffice.com\wwwroot\uat-subdomain\app\assets\images\retina-circular-icons\14" />

<cfhttp url="https://icon.horse/icon/#domain#?apikey=996ca328-b4b1-47a7-8d41-e5255525ab6b&fallback_bg=406e8e&size=small&ignore_other_sizes=false" method="get" getAsBinary="yes" result="icoResult"></cfhttp>

         <cfdump var="#icoResult#">

             <p>
                 <cfoutput>cfhttp: https://icon.horse/icon/#domain#?apikey=996ca328-b4b1-47a7-8d41-e5255525ab6b&fallback_bg=406e8e&size=small&ignore_other_sizes=false</cfoutput>
             </p>

             <cfif icoResult.statusCode EQ "200 OK">

                 <!--- Determine the file extension based on Content-Type --->
                 <cfset contentType=icoResult.responseHeader["Content-Type"]>

                     <cfset fileExtension=".ico">
                         <!--- Default to .ico --->
                         <cfif contentType EQ "image/png">
                             <cfset fileExtension=".png">
                                 <cfelseif contentType EQ "image/jpeg">
                                     <cfset fileExtension=".jpg">
                         </cfif>

<p>status is ok</p>

                         <cfset tempFile="#image_dir#\temp\custom_#id##fileExtension#" />

                         <cfset pngFile="#image_dir#\custom_#id#.png" />

                         <p>temp file: <cfoutput>#tempFile#</cfoutput>
                         </p>

                         <p>png file: <cfoutput>#pngFile#</cfoutput>
                         </p>

                         <cffile action="write" file="#tempFile#" output="#icoResult.filecontent#" />

                         <cfexecute name="C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe" arguments="convert #tempFile# #pngFile#" timeout="60">
                         </cfexecute>

                         <!--- Filename --->

                         <cfset fileName="custom_#id#.png">

                             <p>filename: <cfoutput>#filename#</cfoutput>
                             </p>

                             <!--- Determine which environment we're in --->

                             <cfif image_dir EQ image_dir_dev>

                                 <cffile action="copy" source="#image_dir#\#fileName#" destination="#targetDir_uat#" />

                                 <cfelseif image_dir EQ image_dir_uat>

                                     <cfset otherDir=[image_dir_dev] />

                             </cfif>

                             <cffile action="copy" source="#tempfile#" destination="#targetDir#" />

                             <!--- Loop over the other two directories to copy the file --->
                             <cfif #isdefined('blah')#>
                                 <cfloop array="#otherDirs#" index="targetDir">

                                     <cffile action="copy" source="#image_dir#\#fileName#" destination="#targetDir#" />

                                 </cfloop>

                             </cfif>
                             <cfquery result="result"  name="update">
                                 update sitelinks_user
                                 set siteicon = '#filename#'
                                 where id = #id#
                             </cfquery>

                             <cfif #dsn# is "abo">

                                 <cfquery result="result" datasource="abod" name="update">
                                     update sitelinks_user
                                     set siteicon = '#filename#'
                                     where siteurl = '#siteurl#'
                                 </cfquery>

                             </cfif>

                             <cfif #dsn# is "abod">

                                 <cfquery result="result" datasource="abo" name="update">
                                     update sitelinks_user
                                     set siteicon = '#filename#'
                                     where siteurl = '#siteurl#'
                                 </cfquery>

                             </cfif>

             </cfif>

             <cfcatch type="any">
                 <cfoutput>
                     <!--- Basic error information --->
                     <p><strong>Error Type:</strong> #cfcatch.type#</p>
                     <p><strong>Error Message:</strong> #cfcatch.message#</p>
                     <p><strong>Error Detail:</strong> #cfcatch.detail#</p>

                     <!--- Advanced error information --->
                     <p><strong>Extended Info:</strong> #cfcatch.ExtendedInfo#</p>
                     <p><strong>Error Code:</strong> #cfcatch.ErrorCode#</p>

</cfoutput>
             </cfcatch>
     </cftry>
 </cfloop>
