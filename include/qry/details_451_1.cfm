<!--- This ColdFusion page retrieves contact details from the database based on the provided contact ID. --->

<cfquery name="details">
    SELECT 
        d.contactid,
        d.contacttitle,
        d.recordname,
        d.contactmeetingdate,
        d.contactmeetingloc,
        d.refer_contact_id,
        d.contactFullName AS fullname,
        d.contactfullname,
        d.contactNickname,
        d.contactID,
        d.userID,
        d.contactStatus,
        d.contactCreationDate,
        d.contactLastUpdated,
        d.contactphoto,
        d.contactBirthday,
        d.contactPronoun,
        d.newsletter_yn,
        d.googlealert_yn,
        d.socialmedia_yn
    FROM 
        contactdetails d
    INNER JOIN 
        taousers u ON u.userid = d.userid
    WHERE 
        d.contactID = #contactid#
</cfquery>
