<!---
    PURPOSE: Display detailed contact information for the share modal view
    AUTHOR: GitHub Copilot
    DATE: 2025-07-20
    PARAMETERS: contactid (from the parent loop)
    DEPENDENCIES: remote_load_common.cfm
--->
<style>
.text-primary {
    color: #406e8e !important;
}
.btn-outline-primary:hover {
    color: #fff;
    background-color:  #406e8e !important;
    border-color:  #406e8e !important;
}

</style>
<!--- Include common settings if not already included --->
<cfif NOT isDefined('dsn')>
    <cfinclude template="remote_load_common.cfm">
</cfif>

<!--- Set defaults for required variables --->
<cfparam name="shares" default="#QueryNew('contactid', 'integer')#">
<cfparam name="contactid" default="#IIF(isDefined('shares.contactid') AND shares.recordCount GT 0, 'shares.contactid', 0)#">

<!--- Get detailed contact information

SELECT `Name`,`Company`,`Title`,`WhereMet`,`WhenMet`,`NotesLog`
FROM sharez where contactid = '#contactid#'

--->
<cftry>
    <cfquery name="qGetContactDetail" datasource="#dsn#">
    SELECT 
    '/media/images/defaults/avatar.jpg' AS default_share_avatar,
    s.name, 
    s.company, 
    s.title, 
    s.wheremet, 
    s.last_met, 
    s.noteslog, 
    s.lasteventtype,
    c.col3 AS phone, 
    c.col4 AS email, 
    c.contactid, 
    c.col2 AS tag,
    CONCAT(
        '/media/users/', c.userid, 
        '/contacts/', c.contactid, 
        '/avatar.jpg?rev=', FLOOR(RAND() * 90000 + 10000)
    ) AS share_avatar
FROM sharez s
INNER JOIN contacts_ss c ON c.contactid = s.contactid
    WHERE s.contactid = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">

    </cfquery>

    <!--- If no record is found, create an empty query with the expected columns --->
    <cfif qGetContactDetail.recordCount EQ 0>
        <cfset qGetContactDetail = QueryNew("default_share_avatar,name,company,title,wheremet,last_met,noteslog,lasteventtype,phone, email,contactid,tag,share_avatar", 
                                          "varchar,varchar,varchar,varchar,varchar,timestamp,varchar,varchar,varchar,varchar,integer,varchar,varchar,varchar")>
    </cfif>
    
    <cfcatch type="any">
         <cfset qGetContactDetail = QueryNew("default_share_avatar,name,company,title,wheremet,last_met,noteslog,lasteventtype,phone, email,contactid,tag,share_avatar", 
                                          "varchar,varchar,varchar,varchar,varchar,timestamp,varchar,varchar,varchar,varchar,integer,varchar,varchar,varchar")>
    </cfcatch>
</cftry>

<!--- Get contact events --->






<cftry>
    <cfquery name="qGetContactEvents" datasource="#dsn#">
SELECT DISTINCT 
    p.projdate AS col1,
    p.projname AS col2,
    s.audstep AS col3
FROM audprojects p
INNER JOIN audroles r ON p.audprojectID = r.audprojectID
INNER JOIN events a ON r.audroleid = a.audroleid
INNER JOIN audsteps s ON a.audstepid = s.audstepid
INNER JOIN audcontacts_auditions_xref x ON x.audprojectid = p.audprojectid
INNER JOIN (
    SELECT 
        p.audprojectID, 
        MAX(s.audstepid) AS max_audstepid
    FROM audprojects p
    INNER JOIN audroles r ON p.audprojectID = r.audprojectID
    INNER JOIN events a ON r.audroleid = a.audroleid
    INNER JOIN audsteps s ON a.audstepid = s.audstepid
    INNER JOIN audcontacts_auditions_xref x ON x.audprojectid = p.audprojectid
    WHERE r.isdeleted = 0 AND p.isDeleted = 0
      AND x.contactid = #contactid#
    GROUP BY p.audprojectID
) AS max_values 
  ON p.audprojectID = max_values.audprojectID 
  AND s.audstepid = max_values.max_audstepid
WHERE r.isdeleted = 0 
  AND p.isDeleted = 0
  AND x.contactid = #contactid#;
    </cfquery>
    
    <cfcatch type="any">
        <cfset qGetContactEvents = QueryNew("col1,col2,col3", 
                                          "varchar,varchar,varchar")>
    </cfcatch>
</cftry>

<!--- Contact Information Section --->
<div class="row">
    <div class="col-md-12">
        <h5 class="text-primary">Contact Information</h5>
        <div class="row">
            <cfif qGetContactDetail.recordCount GT 0>
                <cfoutput query="qGetContactDetail">
                    <!--- Avatar Column (1/3 width) --->
                    <div class="col-md-4 text-center mb-3">
                        <img src="#share_avatar#" 
                             class="rounded-circle img-thumbnail" 
                             style="width: 120px; height: 120px; object-fit: cover;" 
                             alt="Contact Avatar" 
                             onerror="this.src='#default_share_avatar#';">
                        <h4 class="mt-3 mb-1 text-primary">#HTMLEditFormat(name)#</h4>
                        <cfif len(trim(tag))>
                            <p >#tag#</p>
                        </cfif>
                    </div>
                    
                    <!--- Contact Details Column (2/3 width) --->
                    <div class="col-md-8">
                        <div class="table-responsive">
                            <table class="table table-sm table-striped mb-3">
                                <tbody>
                                    <tr>
                                        <th>Title</th>
                                        <td>#IIF(isDefined('Title') AND len(trim(Title)), "Title", "''")#</td>
                                    </tr>
                                    <tr>
                                        <th>Company</th>
                                        <td>#IIF(isDefined('Company') AND len(trim(Company)), "Company", "''")#</td>
                                    </tr>
                                    <cfif isDefined('phone') AND len(trim(phone))>
                                        <tr>
                                            <th>Phone</th>
                                            <td>#phone#</td>
                                        </tr>
                                    </cfif>
                                    <cfif isDefined('email') AND len(trim(email))>
                                        <tr>
                                            <th>Email</th>
                                            <td>#email#</td>
                                        </tr>
                                    </cfif>
                                    <tr>
                                        <th>Originally Met</th>
                                        <td>#IIF(isDefined('Wheremet') AND len(trim(Wheremet)), "Wheremet", "''")#</td>
                                    </tr>
                                    <tr>
                                        <th>Last Mtg.</th>
                                        <td>
                                            <cfif isDefined('last_met') AND isDate(last_met)>
                                                #dateFormat(last_met, "mmm d, yyyy")#
                                            </cfif>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th style="width:40%">Last Mtg. Type</th>
                                        <td>#IIF(isDefined('lasteventtype') AND len(trim(lasteventtype)), "lasteventtype", "''")#</td>
                                    </tr>
                                <TR><TD colspan="2">
<strong>Notes:</strong> #qGetContactDetail.noteslog#

                                </TD></TR>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </cfoutput>
            <cfelse>
                <div class="col-md-12">
                    <div class="table-responsive">
                        <table class="table table-sm table-striped mb-3">
                            <tbody>
                                <tr>
                                    <td colspan="2" class="text-center">No contact details available</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </cfif>
        </div>
    </div>
</div>

<!--- Events Section --->
<cfif qGetContactEvents.recordcount GT 0>
    <div class="row mt-3">
        <div class="col-md-12">
            <h5 class="text-primary">Events History</h5>
            <div class="table-responsive" style="max-height: 250px; overflow-y: auto;">
                <table class="table table-sm table-striped">
                    <thead>
                        <tr>
                            <th>Date</th>
                            
                            <th>Project</th>
                      <th>Type</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="qGetContactEvents" maxrows="10">
                            <tr>
                    
                                <td style="white-space: nowrap;">
                                    <cfif isDefined('col1') AND isDate(col1)>
                                        #dateFormat(col1, "mmm d, yyyy")#
                                    <cfelse>
                                        &nbsp;
                                    </cfif>
                                </td>
                                <td>#IIF(isDefined('col2') AND len(trim(col2)), "col2", "''")#</td>
                                <td style="white-space: nowrap;">#IIF(isDefined('col3') AND len(trim(col3)), "col3", "''")#</td>
                   
                            </tr>
                        </cfoutput>
                    </tbody>
                </table>
                
                <cfif qGetContactEvents.recordcount GT 10>
                    <div class="text-center mt-2">
                        <small class="text-muted">Showing 10 of #qGetContactEvents.recordcount# events</small>
                    </div>
                </cfif>
            </div>
        </div>
    </div>
</cfif>
