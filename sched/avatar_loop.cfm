 

<cfset default_avatar_filename = "C:\home\theactorsoffice.com\media-app\users\13\avatar.jpg">
 <cfset default_avatar_data = FileReadBinary(default_avatar_filename)>
<cfset default_avatar_hash = Hash(default_avatar_data, "MD5")>

<cfquery result="result" name="x"  maxrows="1000">
SELECT distinct
d.contactid,
d.contactfullname,
d.userid,
i.itemid,
i.valuetext as contactemail
FROM
contactdetails d INNER JOIN contactitems i ON i.contactid = d.contactid
INNER JOIN taousers u ON u.userid = d.userid
WHERE i.valuecategory = 'Email' AND i.valuetext <> '' AND i.valuetext NOT LIKE '%test%'
AND i.avatar_yn IS NULL
AND u.userid <> 30 and u.userid in (1,12,17,99)
ORDER BY d.contactid
</cfquery>

<cfloop query="x">

<cfset contact_avatar_filename = "#session.userContactsPath#\#x.contactid#\avatar.jpg" />
<cfoutput>#x.contactfullname# avatar: #session.userContactsPath#\#x.contactid#\avatar.jpg<BR></cfoutput>

<cfset contact_avatar_data = FileReadBinary(contact_avatar_filename)>
<cfset contact_avatar_hash = Hash(contact_avatar_data, "MD5")>  
<cfoutput>
[#default_avatar_hash#]<BR>
[#contact_avatar_hash#]<BR></cfoutput>
        <cfif  default_avatar_hash neq contact_avatar_hash>
<cfquery result="result" name="update"  >
update contactitems set avatar_yn = 'Y' where itemid = #x.itemid# 
</cfquery>

     <cfoutput>#x.contactfullname# avatar already exists<BR></cfoutput>
        <cfelse>

<cfset emailHash = LCase(Hash(Trim(x.contactemail), "MD5"))>

<cfset gravatarURL = "https://www.gravatar.com/avatar/#emailHash#?s=200&d=404">

<!--- Make HTTP Request to Gravatar --->
<cfhttp url="#gravatarURL#" method="get" result="httpResponse">
</cfhttp>

<!--- Check if Gravatar exists (HTTP status code 200) --->
<cfif httpResponse.StatusCode eq "200 OK">
<Cfoutput>
<img src="#gravatarURL#" alt="User Avatar" />
</cfoutput>
<BR>
    <!--- Download and save the image --->
    <cfhttp url="#gravatarURL#" method="get" path="#session.userContactsPath#\#x.contactid#" file="avatar.jpg">
    </cfhttp>
    <cfoutput>
       #x.contactfullname#: Gravatar exists and has been saved.<BR>
    </cfoutput>

        <cfquery result="result" name="update"  >
update contactitems set avatar_yn = 'Y' where itemid = #x.itemid# 
</cfquery>

<cfelse>
    <!--- Gravatar doesn't exist. Ignore --->
    <cfoutput>
    <span style="color:red;">    #x.contactfullname#: No Gravatar found. Ignoring.</span><BR>
    </cfoutput>

     <cfquery result="result" name="update"  >
update contactitems set avatar_yn = 'N' where itemid = #x.itemid# 
</cfquery>

</cfif>

</cfif>

</cfloop>
