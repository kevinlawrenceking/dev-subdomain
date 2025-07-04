                

<cfquery result="result"  name="events">
                    SELECT distinct e.eventid,e.eventtitle,e.eventstop,u.recordname,u.userid,d.contactid
                    FROM events e
                    INNER JOIN eventcontactsxref x ON x.eventid = e.eventid
                    INNER JOIN contactdetails d ON d.contactid = x.contactid
                    inner join taousers u on e.userid = u.userid
                    WHERE e.eventstatus = 'Completed' AND e.eventstop < CURDATE() 
                    AND d.contactid NOT IN (SELECT contactid FROM fusystemusers)                                                              
                                                                                 
                    order by e.eventstop 
                    </cfquery>

                        <cfloop query="events">

                            <cfset new_eventid=events.eventid />
                            
                            <cfset new_contactid=events.contactid />

                            <cfset new_userid=events.userid />

                            <cfset new_eventtitle=events.eventtitle />

                            <cfset new_eventstop=events.eventstop />

                            <cfquery result="result"  name="fu">
                                SELECT distinct i.contactid, d.recordname, 1 as new_systemid
                                FROM
                                contactitems i
                                INNER JOIN tags_user tu ON tu.tagname = i.valuetext
                                INNER JOIN eventcontactsxref x ON x.contactid = i.contactid
                                INNER JOIN events e on e.eventid = x.eventid
                                INNER JOIN eventtypes_user eu on eu.eventtypename = e.eventtypename
                                INNER JOIN contactdetails d on d.contactid = i.contactid
                                INNER JOIN taousers u on u.userid = e.userid
                                WHERE i.itemstatus = 'Active'
                                AND tu.tagtype = 'C'
                                AND i.valuecategory = 'tag'
                                AND eu.eventtypename not in ('Rehearsal')
                                AND x.eventid = #new_eventid#
                                AND tu.userid = #new_userid#
                                AND eu.userid = #new_userid#
                                AND i.contactid = #new_contactid#
                                AND eu.userid = u.userid
                                AND tu.userid = u.userid
                                UNION
                                SELECT distinct i.contactid, d.recordname, 2 as new_systemid
                                FROM
                                contactitems i
                                INNER JOIN tags_user tu ON tu.tagname = i.valuetext
                                INNER JOIN eventcontactsxref x ON x.contactid = i.contactid
                                INNER JOIN events e on e.eventid = x.eventid
                                INNER JOIN eventtypes_user eu on eu.eventtypename = e.eventtypename
                                INNER JOIN contactdetails d on d.contactid = i.contactid
                                INNER JOIN taousers u on u.userid = e.userid
                                WHERE i.itemstatus = 'Active'
                                AND tu.tagtype = 'I'
                                AND i.valuecategory = 'tag'
                                AND eu.eventtypename not in ('Rehearsal','CD Workshop')
                                AND x.eventid = #new_eventid#
                                AND tu.userid = #new_userid#
                                AND eu.userid = #new_userid#
                                AND i.contactid = #new_contactid#
                                AND eu.userid = u.userid
                                AND tu.userid = u.userid
                            </cfquery>

                            <cfloop query="fu">
                                <cfset new_contactid=fu.contactid />
                                <cfset new_contactname=fu.recordname />
                                <cfset new_systemid=fu.new_systemid />

                                <cfquery result="result"  name="find_fu">
                                    SELECT su.suid
                                    FROM fusystems s
                                    INNER JOIN fusystemusers su ON su.systemID = s.systemid

                                    WHERE su.suStatus = 'Active'
                                    AND su.userid = #new_userid#
                                    AND su.contactid = #new_contactid#
                                    AND (s.systemid = #new_systemid#

                                    <cfif #new_systemid# is "1" or #new_systemid# is "2">

                                        OR
                                        s.systemid in (3,4)
                                    </cfif>
                                    )
                                </cfquery>

<cfif #find_fu.recordcount# is "0">

                                    <cfoutput>

                                        <Cfset suStartDate="#DateFormat(new_eventstop,'yyyy-mm-dd')#" />
                                        <Cfset currentStartDate="#DateFormat(new_eventstop,'yyyy-mm-dd')#" />

                                    </cfoutput>

                                    <cfquery  name="addSystem" result="result">
                                        INSERT INTO fuSystemUsers (systemID,contactID,userID,suStartDate,sunotes)
                                        VALUES (#new_systemid#,#new_contactid#,#new_userid#,'#suStartDate#','events_completed_wo_system')
                                    </cfquery>

                                    <cfset NewSUID=result.generatedkey />

                                    <cfquery result="result"  name="CompleteTargetSystems">
                                        UPDATE fusystemusers set sustatus = 'Completed' WHERE userid = #new_userid# AND systemid IN (5,6) AND contactid = #new_contactid#;
                                    </cfquery>

                                    <cfquery result="result"  name="sudetails">
                                        select * from fusystems where systemid = #new_systemid#

                                    </cfquery>

                                    <cfquery  name="Insert" result="result">
                                        INSERT INTO `notifications`
                                        (`subtitle`, `userid`, `notifUrl`, `notifTitle`, `notifType`, `contactid`, `read`,`notifdescript`)

                                        VALUES ('Appointment completed. Follow-Up with #new_contactname#', #new_userid#, '/app/contact/?contactid=#new_contactid#&t4=1', 'Follow-Up System Created!','System Added', #new_contactid#, 0,'events_completed_wo_system')
                                    </cfquery>

                                    <cfset Newnotification=result.generatedkey>

                                        <cfquery result="result"  name="addDaysNo">
                                            SELECT
                                            s.systemID
                                            ,s.systemName
                                            ,s.SystemType
                                            ,s.SystemScope
                                            ,s.SystemDescript
                                            ,s.SystemTriggerNote
                                            ,a.actionID
                                            ,a.actionNo
                                            ,a.actionDetails
                                            ,a.actionTitle
                                            ,a.navToURL
                                            ,au.actionDaysNo
                                            ,au.actionDaysRecurring
                                            ,a.actionNotes
                                            ,a.actionInfo
                                            ,a.IsUnique
                                            ,a.uniquename
                                            FROM fusystems s
                                            INNER JOIN fuactions a ON s.systemid = a.systemid
                                            INNER JOIN actionusers au on au.actionid = a.actionid
                                            WHERE a.systemID = #new_systemid#
                                            and au.userid = #new_userid#
                                            and au.actionDaysNo is NOT null
                                            and a.actionID is not null
                                            ORDER BY a.actionNo
                                        </cfquery>

<cfset add_action="Y" />

                                        <cfset new_actionid=addDaysNo.actionid />
                                        <cfset actiondaysno=numberformat(addDaysNo.actiondaysno) />
                                        <cfif #adddaysno.isunique# is "1">

<cfquery result="result"  name="checkUnique">
                                                SELECT d.contactid from
                                                contactdetails d
                                                where d.#adddaysno.uniquename# = 'Y'
                                                and d.contactid = #contactid# limit 1
                                            </cfquery>

<cfif #checkunique.recordcount# is "1">
                                                <cfset #add_action#="N">

                                            </cfif>

                                        </cfif>

                                        <cfif #add_action# is "Y">

                                            <cfif #actiondaysno# is "">
                                                <cfset actiondaysno=0 />
                                            </cfif>

                                            <cfset notstartdate=dateAdd('d', actionDaysNo, currentstartdate) />

                                            <cfif notstartdate lte currentstartdate>

<cfquery  name="addNotification" result="result">
                                                    INSERT INTO funotifications (actionid,userid,suID,notstartdate,notnotes)
                                                    VALUES (
                                                    
                                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#new_actionid#" />,
                                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />,
                                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#NewSuid#" />,
                                                 <cfqueryparam cfsqltype="cf_sql_date" value="#notstartdate#" />,
                                               <cfqueryparam cfsqltype="cf_sql_varchar" value="events_completed_wo_system" />

                                                    )
                                                </cfquery>

                                                <cfelse>

                                                    <cfquery  name="addNotification" result="result">
                                                        INSERT INTO funotifications (actionid,userid,suID,notstartdate,notstatus,notnotes)
                                                        VALUES (
                                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_actionid#" />,
                                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />,
                                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#NewSuid#" />,
                                                 <cfqueryparam cfsqltype="cf_sql_date" value="#notstartdate#" />,
                                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="Pending" />,
                                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="events_completed_wo_system" />
                                                        )
                                                    </cfquery>

                                            </cfif>

                                        </cfif>

                                        <cfelse>

</cfif>

                            </cfloop>

</cfloop>
