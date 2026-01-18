 

<cfquery result="result" name="x"  maxrows="1000">
SELECT distinct
d.contactid,
d.contactfullname,
d.userid,
i.itemid,
i.valuetext as contactemail,
d.avatar_yn
FROM
contactdetails d INNER JOIN contactitems i ON i.contactid = d.contactid
INNER JOIN taousers u ON u.userid = d.userid
WHERE i.valuecategory = 'Email' AND i.valuetext <> '' AND i.valuetext NOT LIKE '%test%'
AND i.avatar_yn = 'N' AND d.avatar_yn is NULL
AND u.userid <> 30 and u.userid in (1,12,17,99)
ORDER BY d.contactid
</cfquery>

<cfloop query="x">

<cfset contact_avatar_filename = "#session.userContactsPath#\#x.contactid#\avatar.jpg" />
<cfoutput>
#x.contactfullname# avatar: #session.userContactsPath#\#x.contactid#\avatar.jpg

<BR>
</cfoutput>

<!--- The email for which you want to get the avatar --->
<cfset email = "#x.contactemail#">

<cfset requestBody = SerializeJSON({
    "username": "#username#",
    "password": "#password#",
    "email": "#email#"
})>

<cfoutput>  "username": "#username#",
    "password": "#password#",
    "email": "#email#"</cfoutput>

<!--- Make the POST request to AvatarAPI --->
<cfhttp url="#apiEndpoint#" method="post" result="httpResponse">
    <cfhttpparam type="header" name="Content-Type" value="text/plain">
    </cfhttpparam>
    <cfhttpparam type="body" value="#requestBody#">
    </cfhttpparam>
</cfhttp>

<!--- Parse JSON response --->
<cfset apiResponse = DeserializeJSON(httpResponse.FileContent)>

<Cfdump var="#apiResponse#">

<!--- Check for 'success' field in the response --->
    <cfif structKeyExists(apiResponse, "success") AND apiResponse.success eq true>
        <!--- Check if it's the default avatar --->
            <cfhttp url="#apiResponse.Image#" method="get" path="#session.userContactsPath#\#x.contactid#" file="avatar.jpg">
            </cfhttp>
            <cfoutput>
                Custom avatar exists and has been saved.

                <a href="https://app.theactorsoffice.com/app/contact/?contactid=#x.contactid#"> LINK</a>
            </cfoutput>

            <cfquery result="result" name="update"  >
update contactitems set avatar_yn = 'Y' where itemid = #x.itemid# 
</cfquery>

<cfelse>
        <!--- Avatar doesn't exist --->
        <cfoutput>
            No avatar found. Ignoring.
        </cfoutput>

        <cfquery result="result" name="update"  >
update contactitems set avatar_yn = 'X' where itemid = #x.itemid# 
</cfquery>

    </cfif>

</cfloop>
