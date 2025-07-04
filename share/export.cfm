<CFINCLUDE template="remote_load.cfm" />

<cfoutput>
<cfset share_dir = "C:\home\theactorsoffice.com\media-#host#\share" />
</cfoutput>


<cfquery name="shares" datasource="#dsn#" >	
SELECT 
	`d`.`recordname` AS `Name`
	,`ci_company`.`valueCompany` AS `Company`
	,`ci_tag`.`valueText` AS `Title`
	,`mx`.`audstep` AS `Audition Status`
	,`d`.`contactMeetingLoc` AS `WhereMet`
	,`d`.`contactMeetingDate` AS `WhenMet`

	
	,p.projname AS `Project`
	,c.audcatname AS `Category`
	,sc.audsubcatname AS `SubCategory`
	,rt.audroletype AS `RoleType`
	,group_concat(`n`.`noteDetails` separator ',') AS `NotesLog`
FROM (
	(
		(
			(
				(
					(
						`actorsbusinessoffice`.`contactdetails` `d` 
			LEFT JOIN audcontacts_auditions_xref x ON d.contactid = x.contactid
			LEFT JOIN audprojects p ON p.audprojectID = x.audprojectid
inner JOIN audroles r ON r.audprojectID = p.audprojectid
			LEFT JOIN audsubcategories sc ON  sc.audsubcatid = p.audsubcatid
LEFT JOIN audcategories c ON  c.audcatid = sc.audcatid
LEFT JOIN audroletypes rt ON rt.audroletypeid = r.audroletypeid						
						LEFT JOIN `actorsbusinessoffice`.`maxaudition` `mx` ON ((`mx`.`contactid` = `d`.`contactID`))
						) INNER JOIN `actorsbusinessoffice`.`taousers` `u` ON ((`u`.`userID` = `d`.`userID`))
					) LEFT JOIN `actorsbusinessoffice`.`contactitems` `ci_company` ON (
						(
							(`ci_company`.`contactID` = `d`.`contactID`)
							AND (`ci_company`.`valueCategory` = 'Company')
							AND (`ci_company`.`itemStatus` = 'active')
							)
						)
				) LEFT JOIN `actorsbusinessoffice`.`contactitems` `ci_tag` ON (
					(
						(`ci_tag`.`contactID` = `d`.`contactID`)
						AND (`ci_tag`.`valueCategory` = 'Tag')
						AND (`ci_tag`.`itemStatus` = 'Active')
						)
					)
			) LEFT JOIN `actorsbusinessoffice`.`noteslog` `n` ON (
				(
					(`n`.`contactID` = `d`.`contactID`)
					AND (`n`.`isPublic` = 1)
					)
				)
		) INNER JOIN `actorsbusinessoffice`.`fusystemusers` `su` ON ((`su`.`contactID` = `d`.`contactID`))
	)
WHERE
r.userid = d.userid AND 

left(`u`.`passwordHash`, 10) ='#u#' AND 
 (
		(`su`.`userid` = `d`.`userID`)
		AND (`su`.`suStatus` = 'Active')
		AND (
			`su`.`systemID` IN (
				1
				,2
				,3
				,4
				)
			)
		)
GROUP BY `d`.`contactID` 
</cfquery>

<cfquery name="x" datasource="#dsn#" >	
select * from taousers 
where left(passwordhash,10) = '#U#'
</cfquery>	   
        

<cfoutput>
    
    <cfset sub_name_a = "#x.userfirstname#_#x.userlastname#" />
    
 
    <cfset sub_name_b = "#Replace(sub_name_a,' ','','all')#" />


    <cfset sub_name_c = "#dateformat('#now()#','YYYYMMDD')#" />   
    <cfset sub_name_d = "#timeformat('#now()#','HHMMSS')#" />   
    
    
<cfset fileName = "#sub_name_b##sub_name_c##sub_name_d#.xls" />
 

<cfscript>
cfspreadsheet( action="write", fileName="#share_dir#\#fileName#", query="shares", overwrite=true );
    </cfscript>

    <cfheader name="content-disposition"  value="Attachment;filename=#fileName#">
<cfcontent  file="#share_dir#\#fileName#"  type="application/vnd.ms-excel">

    </cfoutput>