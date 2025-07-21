<!---
    PURPOSE: Display detailed contact information for the share modal view
    AUTHOR: GitHub Copilot
    DATE: 2025-07-20
    PARAMETERS: contactid (from the parent loop)
    DEPENDENCIES: remote_load_common.cfm
--->

<cfparam name="contactid" default="#shares.contactid#">

<!--- Get detailed contact information --->
<cfquery name="qGetContactDetail" datasource="#dsn#">
    SELECT c.*, 
           ct.contacttypename,
           cg.contactcategoryname
    FROM contacts c
    LEFT JOIN contacttypes ct ON c.contacttypeid = ct.contacttypeid
    LEFT JOIN contactcategories cg ON c.contactcategoryid = cg.contactcategoryid
    WHERE c.contactid = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- Get contact events --->
<cfquery name="qGetContactEvents" datasource="#dsn#">
    SELECT eventid, eventTitle, eventDescription, eventLocation, eventstatus, 
           eventcreation, eventStart, eventStop, eventTypeName
    FROM events
    WHERE contactid = <cfqueryparam value="#contactid#" cfsqltype="cf_sql_integer">
    AND EventTypeName IN ('Meeting', 'Audition')
    AND isDeleted = 0
    ORDER BY eventStart DESC
</cfquery>

<!--- Contact Information Section --->
<div class="row">
    <div class="col-md-12">
        <h5 class="text-primary">Contact Information</h5>
        <div class="table-responsive">
            <table class="table table-sm table-striped mb-3">
                <tbody>
                    <cfoutput query="qGetContactDetail">
                        <tr>
                            <th style="width:30%">Type</th>
                            <td>#contacttypename#</td>
                        </tr>
                        <tr>
                            <th>Category</th>
                            <td>#contactcategoryname#</td>
                        </tr>
                        <tr>
                            <th>Company</th>
                            <td>#Company#</td>
                        </tr>
                        <tr>
                            <th>Title</th>
                            <td>#Title#</td>
                        </tr>
                        <tr>
                            <th>Where Met</th>
                            <td>#Wheremet#</td>
                        </tr>
                        <tr>
                            <th>When Met</th>
                            <td>
                                <cfif isDate(whenmet)>
                                    #dateFormat(whenmet, "mmm d, yyyy")#
                                </cfif>
                            </td>
                        </tr>
                        <cfif len(trim(phone))>
                            <tr>
                                <th>Phone</th>
                                <td>#phone#</td>
                            </tr>
                        </cfif>
                        <cfif len(trim(email))>
                            <tr>
                                <th>Email</th>
                                <td>#email#</td>
                            </tr>
                        </cfif>
                    </cfoutput>
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
                                <td>#dateFormat(eventStart, "mmm d, yyyy")#</td>
                                <td>#eventTypeName#</td>
                                <td>#eventTitle#</td>
                                <td>#left(eventDescription, 100)##iif(len(eventDescription) GT 100, de("..."), de(""))#</td>
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
