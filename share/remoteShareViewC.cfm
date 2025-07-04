<CFINCLUDE template="remote_load.cfm" />

 
<cfquery name="details" datasource="#dsn#">
SELECT `Name`,`Company`,`Title`,`WhereMet`,`WhenMet`,`NotesLog`
FROM sharez where contactid = '#contactid#'
</cfquery>

<cfoutput query="details">
 
                                            <p>
                                              <cfif #Title# is not "">#Title# </cfif>
                                                <cfif #Company# is not ""><cfif #title# is not ""><BR></cfif>#Company# </cfif>
                                               
                                            </p>
                                       
    
    
    
    </cfoutput>

<cfquery name="events" datasource="#dsn#">
SELECT distinct p.projdate AS col1,
       p.projname AS col2,
       s.audstep AS col3
FROM audprojects p
INNER JOIN audroles r ON p.audprojectID = r.audprojectID
INNER JOIN events a ON r.audroleid = a.audroleid
INNER JOIN audsteps s ON s.audstepid = a.audstepid
INNER JOIN audcontacts_auditions_xref x ON x.audprojectid = p.audprojectid
INNER JOIN (
    SELECT p.audprojectID, MAX(s.audstepid) AS max_audstepid
    FROM audprojects p
    INNER JOIN audroles r ON p.audprojectID = r.audprojectID
    INNER JOIN events a ON r.audroleid = a.audroleid
    INNER JOIN audsteps s ON s.audstepid = a.audstepid
    INNER JOIN audcontacts_auditions_xref x ON x.audprojectid = p.audprojectid
    WHERE r.isdeleted IS FALSE AND p.isDeleted IS false
    AND x.contactid = #contactid#
    GROUP BY p.audprojectID
) AS max_values ON p.audprojectID = max_values.audprojectID AND s.audstepid = max_values.max_audstepid
WHERE r.isdeleted IS FALSE AND p.isDeleted IS false
AND x.contactid = #contactid#
</cfquery>

    

<cfquery name="auditionz" datasource="#dsn#">
    SELECT 
p.audprojectid AS recid
    ,p.audprojectid
,r.audroleid
,st.audstep
,st.stepcss
,r.iscallback
,r.isredirect
,ca.audcatname   
,r.ispin
,r.isbooked
,st.stepcss
,'Date' AS head1
,'Project' AS head2
,'Category' as head3
,'Role' AS head4
,'Source' as head5
,'Status' as head6

,ca.audcatname as col3
,r.audrolename as col4
,s.audsource AS col5
,c2.recordname as contactname
,sc.audsubcatname

,CONCAT_WS(p.projname,"|",rt.audroletype,"|",c.recordname,"|",st.audstep,"|",rt.audroletype,"|",s.audsource,"|",p.projdescription) AS search_query
    ,GROUP_CONCAT(c3.recordname) AS contacts_list
 
 FROM audprojects p
    
    INNER join audroles r on p.audprojectID = r.audprojectID

  
 LEFT JOIN events a ON r.audroleid = a.audroleid 
 
 LEFT JOIN audsources s ON s.audSourceID = r.audSourceID
 LEFT JOIN contactdetails c ON c.contactID = p.contactid
 LEFT JOIN contactdetails c2 ON c2.contactID = r.contactid
 LEFT JOIN audroletypes rt ON rt.audroletypeid = r.audroletypeid
 LEFT JOIN audsteps st ON st.audstepid = a.audstepid
LEFT join audsubcategories sc on sc.audsubcatid = p.audsubcatid
    LEFT join audcategories ca on ca.audcatid = sc.audcatid
 
    LEFT JOIN audcontacts_auditions_xref x on x.audprojectid = p.audprojectid
    
    left join contactdetails c3 on c3.contactid = x.contactid

  WHERE r.isdeleted IS FALSE AND p.isDeleted IS false

 AND x.contactid = #contactid#
            
GROUP BY r.audroleid, p.projname,s.audsource,rt.audroletype,r.iscallback,r.isredirect,r.ispin,r.isbooked    

</cfquery>













  <cfif #events.recordcount# is not "0">
<hr>
      <p>Audition History</p>

      <table id="contactview<cfoutput>#contactid#</cfoutput>" class="table dt-responsive nowrap w-100 table-striped" role="grid">
                <thead>
                    <tr>
            
                        <th>Date</th>
                        <th>Project</th>
<th>Audition Status</th>
                    </tr>
                </thead>
                <cfloop query="events">
                    <cfoutput>

                                
                                
                                <tr>
                        <td>#dateformat('#col1#','medium')#</td>
                                                        <td>#col2#</td>
                                   <td>#col3#</td>
                                </tr>
                    </cfoutput>
                </cfloop>
            </table>
        </div>
    </div>
</div>


<SCRIPT>
    $(document).ready(function() {
        $("#<cfoutput>contactview#contactid#</cfoutput>").DataTable({
            "searching": true,
            
            language: {
                paginate: {
                    previous: "<i class='mdi mdi-chevron-left'>",
                    next: "<i class='mdi mdi-chevron-right'>"
                }
            },
            drawCallback: function() {
                $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
            }
        });
        var a = $("#datatable-buttons").DataTable({
            lengthChange: !1,
            language: {
                paginate: {
                    previous: "<i class='mdi mdi-chevron-left'>",
                    next: "<i class='mdi mdi-chevron-right'>"
                }
            },
            drawCallback: function() {
                $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
            }
        });
    });

</SCRIPT>
</cfif>


















