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

/* Smooth slide animation for note details */
.note-details-row {
    transition: all 0.4s ease-in-out;
    overflow: hidden;
    max-height: 0;
    opacity: 0;
}

.note-details-row.expanded {
    max-height: 500px;
    opacity: 1;
}

.note-details-content {
    padding: 15px 0;
}

/* Icon rotation animation */
.note-toggle-icon {
    transition: transform 0.3s ease-in-out;
    cursor: pointer;
}

.note-toggle-icon.expanded {
    transform: rotate(45deg);
}

</style>
<!--- Include common settings if not already included --->
<cfif NOT isDefined('dsn')>
    <cfinclude template="remote_load_common.cfm">
</cfif>

<!--- Set defaults for required variables --->
<cfparam name="contactid" default="0">
<cfparam name="shares" default="#QueryNew('contactid', 'integer')#">

<!--- If contactid is passed via URL, use that; otherwise try to get from shares query --->
<cfif isDefined('url.contactid') AND isNumeric(url.contactid)>
    <cfset contactid = val(url.contactid)>
<cfelseif isDefined('shares.contactid') AND shares.recordCount GT 0 AND isNumeric(shares.contactid)>
    <cfset contactid = val(shares.contactid)>
</cfif>

<!--- Only proceed if we have a valid contactid --->
<cfif isNumeric(contactid) AND val(contactid) GT 0>

<!--- Get individual notes for this contact --->
<cfquery name="qGetContactNotes" datasource="#dsn#">
    SELECT 
        noteid,
        notedetails,
        notedetailshtml,
        notetimestamp
    FROM noteslog 
    WHERE contactid = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">
    ORDER BY notetimestamp DESC
</cfquery>
 
<cftry>
    <cfquery name="qGetContactDetail" datasource="#dsn#">
    SELECT 
    '/media/images/defaults/avatar.jpg' AS default_share_avatar,
    s.name, 
    s.company, 
    s.title, 
    s.wheremet, 
    s.last_met, 
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
        <cfset qGetContactDetail = QueryNew("default_share_avatar,name,company,title,wheremet,last_met,lasteventtype,phone,email,contactid,tag,share_avatar", 
                                          "varchar,varchar,varchar,varchar,varchar,timestamp,varchar,varchar,varchar,integer,varchar,varchar")>
    </cfif>
    
    <cfcatch type="any">
         <cfset qGetContactDetail = QueryNew("default_share_avatar,name,company,title,wheremet,last_met,lasteventtype,phone,email,contactid,tag,share_avatar", 
                                          "varchar,varchar,varchar,varchar,varchar,timestamp,varchar,varchar,varchar,integer,varchar,varchar")>
    </cfcatch>
</cftry>



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
      AND x.contactid = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">
    GROUP BY p.audprojectID
) AS max_values 
  ON p.audprojectID = max_values.audprojectID 
  AND s.audstepid = max_values.max_audstepid
WHERE r.isdeleted = 0 
  AND p.isDeleted = 0
  AND x.contactid = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">;
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

<!--- Notes Section --->
<cfif qGetContactNotes.recordcount GT 0>
    <div class="row mt-3">
        <div class="col-md-12">
            <h5 class="text-primary">Notes</h5>
            <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
                <table class="table table-sm table-striped">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Note</th>
                            <th style="width: 50px;">Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfset noteIndex = 0>
                        <cfoutput query="qGetContactNotes">
                            <cfset noteIndex = noteIndex + 1>
                            
                            <tr>
                                <td style="white-space: nowrap;">
                                    <cfif isDefined('notetimestamp') AND isDate(notetimestamp)>
                                        #dateFormat(notetimestamp, "mmm d, yyyy")#
                                    <cfelse>
                                        &nbsp;
                                    </cfif>
                                </td>
                                <td>
                                    <cfif isDefined('notedetails') AND len(trim(notedetails))>
                                        #left(HTMLEditFormat(notedetails), 100)#<cfif len(notedetails) GT 100>...</cfif>
                                    <cfelse>
                                        <em class="text-muted">No note text</em>
                                    </cfif>
                                </td>
                                <td class="text-center">
                                    <cfif len(trim(qGetContactNotes.notedetailshtml))>
                                        <a href="##" onclick="toggleNoteDetails(#noteid#); return false;" title="View Details">
                                            <i class="fe-plus-circle note-toggle-icon" id="icon-#noteid#"></i>
                                        </a>
                                    <cfelse>
                                        <span class="text-muted">--</span>
                                    </cfif>
                                </td>
                            </tr>
                            
                            <!--- Expandable details row --->
                            <cfif len(trim(qGetContactNotes.notedetailshtml))>
                                <tr id="details-row-#noteid#" class="note-details-row">
                                    <td colspan="3">
                                        <div class="note-details-content">
                                            <div class="alert alert-light border-left border-info" style="border-left-width: 4px !important;">
                                                <h6 class="text-primary mb-2">Note Details:</h6>
                                                <div style="max-height: 300px; overflow-y: auto;">
                                                    #qGetContactNotes.notedetailshtml#
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </cfif>
                        </cfoutput>
                    </tbody>
                </table>
                
                <cfif qGetContactNotes.recordcount GT 10>
                    <div class="text-center mt-2">
                        <small class="text-muted">Showing recent notes</small>
                    </div>
                </cfif>
            </div>
        </div>
    </div>
</cfif>

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

<!--- Close the contactid validation condition --->
</cfif>

<script>
function toggleNoteDetails(noteid) {
    var detailsRow = document.getElementById('details-row-' + noteid);
    var icon = document.getElementById('icon-' + noteid);
    
    if (detailsRow.style.display === 'none' || detailsRow.style.display === '') {
        // Expand - show details
        detailsRow.style.display = 'table-row';
        icon.className = 'fe-minus-circle';
    } else {
        // Collapse - hide details
        detailsRow.style.display = 'none';
        icon.className = 'fe-plus-circle';
    }
}
</script>

<!--- Remove the old modal and JavaScript since we're using the working pattern now --->