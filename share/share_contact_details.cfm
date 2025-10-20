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

.contact-hero {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-start;
    gap: 1rem;
}

.contact-hero-left {
    flex: 1 1 33%;
    min-width: 200px;
    display: flex;
    flex-direction: column;
    align-items: center;
}

.contact-hero-right {
    flex: 2 1 66%;
    min-width: 300px;
}

.badge-soft-info {
    background-color: rgba(116, 192, 252, 0.22);
    color: #285a7a;
    border: 1px solid rgba(116, 192, 252, 0.35);
    border-radius: 999px;
    font-weight: 600;
}

.tag-row {
    display: flex;
    flex-wrap: wrap;
    gap: 0.35rem;
    margin-top: 0.65rem;
}

.tag-row .badge {
    border-radius: 999px;
    font-weight: 600;
    padding: 0.3rem 0.8rem;
    background-color: rgba(116, 192, 252, 0.22);
    color: #285a7a;
    border: 1px solid rgba(116, 192, 252, 0.3);
}

.contact-hero h4 {
    font-size: 1.5rem;
    font-weight: 600;
}

.contact-info-box {
    background: rgba(116, 192, 252, 0.15);
    border: 1px solid rgba(116, 192, 252, 0.3);
    border-radius: 12px;
    padding: 1rem 1.25rem;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
    gap: 0.75rem 1rem;
}

.contact-info-item {
    display: flex;
    flex-direction: column;
    gap: 0.15rem;
}

.contact-info-item h6 {
    font-size: 0.7rem;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: #5a7a8f;
    margin-bottom: 0;
    font-weight: 600;
}

.contact-info-item p {
    font-size: 0.92rem;
    color: #24313f;
    margin-bottom: 0;
}

.contact-info-item a {
    color: #406e8e;
    text-decoration: none;
}

.contact-info-item a:hover {
    text-decoration: underline;
}

.contact-info-item p.empty {
    color: #7a8fa3;
    font-style: italic;
    font-size: 0.88rem;
}

.modal-body h5 {
    font-size: 1.05rem;
    font-weight: 600;
    margin-bottom: 0.75rem;
}

.table.table-sm th,
.table.table-sm td {
    padding: 0.55rem 0.75rem;
}

/* Smooth slide animation for note details */
.note-details-row {
    display: none;
    transition: all 0.4s ease-in-out;
}

.note-details-row.expanded {
    display: table-row;
}

.note-details-content {
    padding: 15px 0;
}

/* Icon rotation animation */
.note-toggle-icon {
    transition: transform 0.3s ease-in-out;
    cursor: pointer;
    color: #406e8e !important;
    text-decoration: none !important;
}

/* Remove underline from note toggle links */
a:hover .note-toggle-icon,
a:focus .note-toggle-icon,
a .note-toggle-icon {
    text-decoration: none !important;
}

.note-toggle-icon.expanded {
    transform: rotate(45deg);
}

/* Custom border color for note details */
.border-custom {
    border-left-color: #406e8e !important;
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
        <cfif qGetContactDetail.recordCount GT 0>
            <cfoutput query="qGetContactDetail">
             <div class="contact-hero mb-2">
                <div class="contact-hero-left">
                    <img src="#share_avatar#"
                        class="rounded-circle img-thumbnail shadow-sm"
                        style="width: 96px; height: 96px; object-fit: cover;"
                        alt="Contact Avatar"
                        onerror="this.src='#default_share_avatar#';">
                    <h4 class="mt-2 mb-0 text-primary">#HTMLEditFormat(name)#</h4>
                </div>
                <div class="contact-hero-right">
                    <div class="contact-info-box">
                        <div class="contact-info-item">
                            <h6>Title</h6>
                            <p class="#len(trim(Title)) ? '' : 'empty'#">#len(trim(Title)) ? HTMLEditFormat(Title) : 'Not provided'#</p>
                        </div>
                        <div class="contact-info-item">
                            <h6>Company</h6>
                            <p class="#len(trim(Company)) ? '' : 'empty'#">#len(trim(Company)) ? HTMLEditFormat(Company) : 'Not provided'#</p>
                        </div>
                        <cfif len(trim(phone))>
                            <div class="contact-info-item">
                                <h6>Phone</h6>
                                <p>#HTMLEditFormat(phone)#</p>
                            </div>
                        </cfif>
                        <cfif len(trim(email))>
                            <div class="contact-info-item">
                                <h6>Email</h6>
                                <p><a href="mailto:#HTMLEditFormat(email)#">#HTMLEditFormat(email)#</a></p>
                            </div>
                        </cfif>
                        <div class="contact-info-item">
                            <h6>Originally Met</h6>
                            <p class="#len(trim(Wheremet)) ? '' : 'empty'#">#len(trim(Wheremet)) ? HTMLEditFormat(Wheremet) : 'Not recorded'#</p>
                        </div>
                        <div class="contact-info-item">
                            <h6>Last Meeting</h6>
                            <p class="#isDate(last_met) ? '' : 'empty'#">
                                <cfif isDate(last_met)>
                                    #dateFormat(last_met, "mmmm d, yyyy")#
                                <cfelse>
                                    Not recorded
                                </cfif>
                            </p>
                        </div>
                        <div class="contact-info-item">
                            <h6>Last Meeting Type</h6>
                            <p class="#len(trim(lasteventtype)) ? '' : 'empty'#">#len(trim(lasteventtype)) ? HTMLEditFormat(lasteventtype) : 'Not recorded'#</p>
                        </div>
                    </div>
                </div>
                </div>
                <cfif len(trim(tag))>
                    <div class="tag-row">
                        <cfif findNoCase("<", tag)>
                            #tag#
                        <cfelse>
                            <span class="badge">#HTMLEditFormat(tag)#</span>
                        </cfif>
                    </div>
                </cfif>
            </cfoutput>
        <cfelse>
            <div class="alert alert-light border text-center mb-4">
                No contact details available.
            </div>
        </cfif>
    </div>
</div>

<!--- Events Section --->
<cfif qGetContactEvents.recordcount GT 0>
    <div class="row mt-2">
        <div class="col-md-12">
            <h5 class="text-primary">Events History</h5>
            <div class="table-responsive" style="max-height: 200px; overflow-y: auto;">
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

<!--- Notes Section --->
<cfif qGetContactNotes.recordcount GT 0>
    <div class="row mt-2">
        <div class="col-md-12">
            <h5 class="text-primary">Notes</h5>
            <div class="table-responsive" style="max-height: 220px; overflow-y: auto;">
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
                                        <span class="text-muted">&nbsp;</span>
                                    </cfif>
                                </td>
                            </tr>
                            
                            <!--- Expandable details row --->
                            <cfif len(trim(qGetContactNotes.notedetailshtml))>
                                <tr id="details-row-#noteid#" class="note-details-row">
                                    <td colspan="3">
                                        <div class="note-details-content">
                                            <div class="alert alert-light border-left border-custom" style="border-left-width: 4px !important;">
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

<!--- Close the contactid validation condition --->
</cfif>

<script>
function toggleNoteDetails(noteid) {
    var detailsRow = document.getElementById('details-row-' + noteid);
    var icon = document.getElementById('icon-' + noteid);
    
    if (detailsRow.classList.contains('expanded')) {
        // Collapse - hide details
        detailsRow.classList.remove('expanded');
        icon.className = 'fe-plus-circle note-toggle-icon';
    } else {
        // Expand - show details
        detailsRow.classList.add('expanded');
        icon.className = 'fe-minus-circle note-toggle-icon expanded';
    }
}
</script>

<!--- Remove the old modal and JavaScript since we're using the working pattern now --->