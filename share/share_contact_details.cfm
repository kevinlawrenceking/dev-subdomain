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
<cfparam name="contactid" default="0">
<cfparam name="shares" default="#QueryNew('contactid', 'integer')#">

<!--- If contactid is passed via URL, use that; otherwise try to get from shares query --->
<cfif isDefined('url.contactid') AND isNumeric(url.contactid)>
    <cfset contactid = val(url.contactid)>
<cfelseif isDefined('shares.contactid') AND shares.recordCount GT 0 AND isNumeric(shares.contactid)>
    <cfset contactid = val(shares.contactid)>
</cfif>

<!--- Validate that we have a valid contactid before proceeding --->
<cfif NOT isNumeric(contactid) OR val(contactid) LTE 0>
    <div class="alert alert-danger">
        <h5>Error: Invalid Contact ID</h5>
        <p>Unable to load contact details. Contact ID is missing or invalid.</p>
        <cfoutput><small class="text-muted">Contact ID: #contactid#</small></cfoutput>
    </div>
    <cfabort>
</cfif>

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
                        <cfoutput query="qGetContactNotes">
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
                                    <cfif isDefined('notedetailshtml') AND len(trim(notedetailshtml))>
                                        <button type="button" 
                                                class="btn btn-sm btn-outline-primary note-details-btn" 
                                                data-note-details="#HTMLEditFormat(notedetails)#"
                                                data-note-html="#HTMLEditFormat(notedetailshtml)#"
                                                data-note-timestamp="#dateFormat(notetimestamp, "mmm d, yyyy")# at #timeFormat(notetimestamp, "h:mm tt")#"
                                                title="View detailed note">
                                            <i class="fe-search"></i>
                                        </button>
                                    <cfelse>
                                        <span class="text-muted">—</span>
                                    </cfif>
                                </td>
                            </tr>
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

<!--- Note Details Modal --->
<div class="modal fade" id="noteDetailsModal" tabindex="-1" role="dialog" aria-labelledby="noteDetailsModalLabel">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="noteDetailsModalLabel">Note Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="noteDetailsContent">
                <div class="text-center">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!--- JavaScript for note details functionality --->
<script>
// Use event delegation to handle button clicks
document.addEventListener('click', function(event) {
    if (event.target.closest('.note-details-btn')) {
        const button = event.target.closest('.note-details-btn');
        const noteDetails = button.getAttribute('data-note-details');
        const noteDetailsHtml = button.getAttribute('data-note-html');
        const noteTimestamp = button.getAttribute('data-note-timestamp');
        
        showNoteDetails(noteDetails, noteDetailsHtml, noteTimestamp);
    }
});

function showNoteDetails(noteDetails, noteDetailsHtml, noteTimestamp) {
    // Set modal title
    const previewText = noteDetails && noteDetails.length > 50 ? noteDetails.substring(0, 50) + '...' : noteDetails || 'Note Details';
    document.getElementById('noteDetailsModalLabel').textContent = 'Note Details: ' + previewText;
    
    // Create elements safely to avoid XSS issues
    const noteDetailsDiv = document.createElement('div');
    noteDetailsDiv.className = 'note-details';
    
    // Note Summary section
    const summaryHeader = document.createElement('h6');
    summaryHeader.className = 'text-primary';
    summaryHeader.textContent = 'Note Summary:';
    noteDetailsDiv.appendChild(summaryHeader);
    
    const summaryP = document.createElement('p');
    summaryP.className = 'mb-3';
    summaryP.textContent = noteDetails || 'No summary available';
    noteDetailsDiv.appendChild(summaryP);
    
    // Detailed Information section
    const detailsHeader = document.createElement('h6');
    detailsHeader.className = 'text-primary';
    detailsHeader.textContent = 'Detailed Information:';
    noteDetailsDiv.appendChild(detailsHeader);
    
    const detailsDiv = document.createElement('div');
    detailsDiv.className = 'border rounded p-3 bg-light';
    if (noteDetailsHtml && noteDetailsHtml.trim()) {
        // Since the HTML is already encoded in the database, we need to decode it
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = noteDetailsHtml;
        detailsDiv.innerHTML = tempDiv.innerHTML;
    } else {
        const emptyMsg = document.createElement('em');
        emptyMsg.className = 'text-muted';
        emptyMsg.textContent = 'No detailed information available';
        detailsDiv.appendChild(emptyMsg);
    }
    noteDetailsDiv.appendChild(detailsDiv);
    
    // Timestamp section
    if (noteTimestamp) {
        const timestampSmall = document.createElement('small');
        timestampSmall.className = 'text-muted mt-3 d-block';
        timestampSmall.textContent = 'Created: ' + noteTimestamp;
        noteDetailsDiv.appendChild(timestampSmall);
    }
    
    // Update modal content and show
    document.getElementById('noteDetailsContent').innerHTML = '';
    document.getElementById('noteDetailsContent').appendChild(noteDetailsDiv);
    
    // Show the modal
    var modal = new bootstrap.Modal(document.getElementById('noteDetailsModal'));
    modal.show();
}
</script>