<!---
    PURPOSE: Display detailed contact information for the share modal view
    AUTHOR: GitHub Copilot
    DATE: 2025-07-20
    PARAMETERS: contactid (from the parent loop)
    DEPENDENCIES: remote_load_common.cfm
--->

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
    SELECT s.name, s.company, s.title, s.wheremet, s.last_met, s.noteslog, s.lasteventtype,c.col3 as phone, c.col4 as email, c.contactid, c.col2 as tag
    FROM sharez s
    INNER JOIN contacts_ss c on c.contactid = s.contactid
    WHERE s.contactid = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- If no record is found, create an empty query with the expected columns --->
    <cfif qGetContactDetail.recordCount EQ 0>
        <cfset qGetContactDetail = QueryNew("name,company,title,wheremet,last_met,noteslog,lasteventtype,phone,email,contactid,tag", 
                                          "varchar,varchar,varchar,varchar,timestamp,varchar,varchar,varchar,varchar,integer,varchar")>
    </cfif>
    
    <cfcatch type="any">
        <cfset qGetContactDetail = QueryNew("name,company,title,wheremet,last_met,noteslog,lasteventtype,phone,email,contactid,tag", 
                                          "varchar,varchar,varchar,varchar,timestamp,varchar,varchar,varchar,varchar,integer,varchar")>
    </cfcatch>
</cftry>

<!--- Get contact events --->
<cftry>
    <cfquery name="qGetContactEvents" datasource="#dsn#">
        SELECT eventid, eventTitle, eventDescription, eventLocation, eventstatus, 
               eventcreation, eventStart, eventStop, eventTypeName
        FROM events
        WHERE contactid = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">
        AND EventTypeName IN ('Meeting', 'Audition')
        AND isDeleted = 0
        ORDER BY eventStart DESC
    </cfquery>
    
    <cfcatch type="any">
        <cfset qGetContactEvents = QueryNew("eventid,eventTitle,eventDescription,eventStart,eventTypeName", 
                                          "integer,varchar,varchar,timestamp,varchar")>
    </cfcatch>
</cftry>

<!--- Contact Information Section --->
<div class="row">
    <div class="col-md-12">
        <h5 class="text-primary">Contact Information</h5>
        <div class="table-responsive">
            <table class="table table-sm table-striped mb-3">
                <tbody>
                    <cfif qGetContactDetail.recordCount GT 0>
                        <cfoutput query="qGetContactDetail">
                            <tr>
                                <th style="width:30%">Type</th>
                                <td>#IIF(isDefined('lasteventtype') AND len(trim(lasteventtype)), "lasteventtype", "''")#</td>
                            </tr>
                       
                                <th>Company</th>
                                <td>#IIF(isDefined('Company') AND len(trim(Company)), "Company", "''")#</td>
                            </tr>
                            <tr>
                                <th>Title</th>
                                <td>#IIF(isDefined('Title') AND len(trim(Title)), "Title", "''")#</td>
                            </tr>
                            <tr>
                                <th>Where Met</th>
                                <td>#IIF(isDefined('Wheremet') AND len(trim(Wheremet)), "Wheremet", "''")#</td>
                            </tr>
                            <tr>
                                <th>Last Met</th>
                                <td>
                                    <cfif isDefined('last_met') AND isDate(whenmet)>
                                        #dateFormat(last_met, "mmm d, yyyy")#
                                    </cfif>
                                </td>
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
                        </cfoutput>
                    <cfelse>
                        <tr>
                            <td colspan="2" class="text-center">No contact details available</td>
                        </tr>
                    </cfif>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!--- Events Section --->
<cfif qGetContactEvents.recordcount GT 0>
    <div class="row mt-3">
        <div class="col-md-12">
            <h5 class="text-primary">Events History</h5>
            <div class="table-responsive">
                <table class="table table-sm table-striped">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Title</th>
                            <th>Description</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="qGetContactEvents" maxrows="10">
                            <tr>
                                <td>
                                    <cfif isDefined('eventStart') AND isDate(eventStart)>
                                        #dateFormat(eventStart, "mmm d, yyyy")#
                                    <cfelse>
                                        &nbsp;
                                    </cfif>
                                </td>
                                <td>#IIF(isDefined('eventTypeName') AND len(trim(eventTypeName)), "eventTypeName", "''")#</td>
                                <td>#IIF(isDefined('eventTitle') AND len(trim(eventTitle)), "eventTitle", "''")#</td>
                                <td>
                                    <cfif isDefined('eventDescription') AND len(trim(eventDescription))>
                                        #left(eventDescription, 100)##iif(len(eventDescription) GT 100, de("..."), de(""))#
                                    <cfelse>
                                        &nbsp;
                                    </cfif>
                                </td>
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
