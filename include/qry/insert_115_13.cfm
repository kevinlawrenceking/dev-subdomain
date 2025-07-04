<cfset componentPath = "/services/ExportItemService">
<cfset exportItemService = createObject("component", componentPath)>

<cfset exportItemService.INSexportitems(
    new_exportid = new_exportid,
    new_contactid = new_contactid,
    new_FirstName = new_FirstName,
    new_LastName = new_LastName,
    new_Tag1 = new_Tag1,
    new_Tag2 = new_Tag2,
    new_Tag3 = new_Tag3,
    new_BusinessEmail = new_BusinessEmail,
    new_PersonalEmail = new_PersonalEmail,
    new_WorkPhone = new_WorkPhone,
    new_MobilePhone = new_MobilePhone,
    new_HomePhone = new_HomePhone,
    new_Company = new_Company,
    new_Address = new_Address,
    new_Address2 = new_Address2,
    new_City = new_City,
    new_State = new_State,
    new_Zip = new_Zip,
    new_Country = new_Country,
    new_ContactMeetingDate = isDate(new_ContactMeetingDate) ? createODBCDate(new_ContactMeetingDate) : "",
    new_ContactMeetingLoc = new_ContactMeetingLoc,
    new_contactBirthday = isDate(new_contactBirthday) ? createODBCDate(new_contactBirthday) : "",
    new_Website = new_Website
)>