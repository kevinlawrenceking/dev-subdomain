<!--- 
    account_info.cfm - Optimized Version
    Provides account management functionality with tab-based interface
--->

<!--- Parameter Initialization --->
<cfparam name="ctaction" default="view"/>
<cfparam name="teamaction" default="view"/>
<cfparam name="t2" default="0"/>
<cfparam name="t3" default="0"/>
<cfparam name="t7" default="0"/>
<cfparam name="ITEMIDD" default="0"/>
<cfparam name="currentid" default="0"/>
<cfparam name="new_region_id" default=""/>
<cfparam name="new_countryid" default=""/>
<cfparam name="def_region_id" default=""/>
<cfparam name="DEF_COUNTRYID" default=""/>
 
<!--- Set Session Variables --->
<cfset session.pgrtn="P"/>
<cfset pgrtn="P"/>

<!--- Include Required Query Files --->
<cfinclude template="/include/qry/countries_457_1.cfm"/>
<cfinclude template="/include/qry/regions_518_1.cfm"/>
<cfinclude template="/include/qry/timezones_547_1.cfm"/>
<cfinclude template="/include/qry/timezones_min_547_2.cfm"/>
<cfinclude template="/include/qry/dateformats_463_1.cfm"/>
<cfinclude template="/include/qry/details_1693_1.cfm"/>
<cfinclude template="/include/qry/FindUser_1694_2.cfm"/>

<!--- Action Handling --->
<cfswitch expression="#ctaction#">
    <cfcase value="includeaction">
        <cfquery name="update">
            UPDATE actionusers_tbl
            SET isdeleted = 0
            WHERE id = #new_id#
        </cfquery>
        <cfset ctaction = "view" />
    </cfcase>
    
    <cfcase value="deleteitem">
        <cfinclude template="/include/qry/deleteTeam.cfm"/>
        <cfset ctaction = "view"/>
        <cfset teamaction = "view"/>
        <cfset t2 = 1/>
    </cfcase>
    
    <cfcase value="addmember">
        <cfinclude template="/include/qry/addTeam.cfm"/>
        <cfset ctaction = "view"/>
        <cfset teamaction = "view"/>
        <cfset t2 = 1/>
    </cfcase>
</cfswitch>

<!--- Default Values Management --->
<cfif new_region_id is "" and def_region_id is not "">
    <cfset new_region_id = def_region_id/>
</cfif>

<cfif new_countryid is "" and def_countryid is not "">
    <cfset new_countryid = def_countryid/>
</cfif>

<!--- Mobile Redirection Logic --->
<cfif devicetype is "mobile">
    <cfif t2 is "1">
        <cflocation url="/app/contact/?contactid=#contactid#&new_pgid=122"/>
    <cfelseif t3 is "1">
        <cflocation url="/app/contact/?contactid=#contactid#&new_pgid=124"/>
    <cfelseif t7 is "1">
        <cflocation url="/app/contact/?contactid=#contactid#&new_pgid=125"/>
    </cfif>
</cfif>

<cfoutput>
    <!--- Set Current Contact ID --->
    <cfset CURRENTID = userContactid/>
</cfoutput>

<!--- Desktop Layout --->
<cfif devicetype is not "mobile">
    <!--- Tab Configuration --->
    <cfinclude template="/include/tab_check_account.cfm"/>
    <cfparam name="tab0_expand" default="false"/>
    <cfparam name="tab1_expand" default="false"/>
    <cfparam name="tab2_expand" default="false"/>
    <cfparam name="tab3_expand" default="false"/>
    <cfparam name="tab4_expand" default="false"/>
    <cfparam name="tab5_expand" default="false"/>
    <cfparam name="tab6_expand" default="false"/>
    <cfparam name="tab7_expand" default="false"/>
    <cfparam name="tab8_expand" default="false"/>
    <cfparam name="tab9_expand" default="false"/>
    <cfparam name="tab10_expand" default="false"/>
    
    <!--- Default to Info Tab if none selected --->
    <cfif tab0_expand is "false" and tab1_expand is "false" and tab2_expand is "false" 
          and tab3_expand is "false" and tab4_expand is "false" and tab7_expand is "false" 
          and tab8_expand is "false" and tab9_expand is "false" and tab10_expand is "false">
        <cfset tab0_expand = "true"/>
        <cfset t0 = 1/>
    </cfif>

    <!--- Define and Include Modals --->
    <cfset modalStructs = [
        {id: "dashboardupdate", title: "Dashboard Preferences", include: "/include/modal.cfm"},
        {id: "remoteUserUpdate", title: "Update Account", include: "/include/modal.cfm"},
        {id: "remoteAddContact", title: "Add Contact", include: "/include/modal.cfm"}
    ]>
    
    <!--- Create Modal Components --->
    <cfloop array="#modalStructs#" index="modalData">
        <cfset modalid = modalData.id>
        <cfset modaltitle = modalData.title>
        <cfinclude template="#modalData.include#">
    </cfloop>

    <!--- JavaScript for Modal Loading --->
    <script>
    $(document).ready(function () {
        // Dashboard update modal handler
        $("#dashboardupdate").on("show.bs.modal", function (event) {
            $(this).find(".modal-body").load("<cfoutput>/include/dashboardupdate.cfm?userid=#userid#</cfoutput>");
        });
        
        // User update modal handler
        $("#remoteUserUpdate").on("show.bs.modal", function (event) {
            $(this).find(".modal-body").load("<cfoutput>/include/remoteUserUpdate.cfm?userid=#userid#&src=account</cfoutput>");
        });
        
        // Add contact modal handler
        $("#remoteAddContact").on("show.bs.modal", function (event) {
            $(this).find(".modal-body").load("<cfoutput>/include/remoteAddContact.cfm?userid=#userid#&src=account</cfoutput>");
        });
    });
    </script>
    
    <!--- Calendar Update Modal --->
    <div id="updatecal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="standard-modalLabel">Default Settings Update</h4>
                    <button type="button" class="close" data-bs-dismiss="modal">
                        <i class="mdi mdi-close-thick"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <p>Update your default settings.</p>
                    <form action="/include/update_cal.cfm" method="post" class="parsley-examples" 
                          data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" 
                          data-parsley-trigger="keyup" data-parsley-validate="data-parsley-validate" id="preferences">
                        
                        <cfoutput>
                            <input type="hidden" name="userid" value="#userid#"/>
                        </cfoutput>
                        <input type="hidden" name="ctaction" value="update_cal"/>
                        <input type="hidden" name="t4" value="1"/>
                        
                        <!--- Time Selection Fields --->
                        <cfset startTime = createTime(5, 0, 0)>
                        <cfset endTime = createTime(23, 45, 0)>
                        
                        <!--- Start Time Selection --->
                        <div class="form-group col-md-6">
                            <label for="calstarttime">Start Time<span class="text-danger">*</span></label>
                            <select class="form-control" name="calstarttime" id="calstarttime">
                                <cfloop from="#startTime#" to="#endTime#" step="#createTimeSpan(0, 0, 15, 0)#" index="timeSlot">
                                    <cfset formattedTime = timeFormat(timeSlot, "HH:mm:ss")>
                                    <cfset displayTime = timeFormat(timeSlot, "h:mm tt")>
                                    <cfoutput>
                                        <option value="#formattedTime#" <cfif timeFormat(details.calstarttime) EQ formattedTime>selected</cfif>>#displayTime#</option>
                                    </cfoutput>
                                </cfloop>
                            </select>
                        </div>
                        
                        <!--- End Time Selection --->
                        <div class="form-group col-md-6">
                            <label for="calendtime">End Time<span class="text-danger">*</span></label>
                            <select class="form-control" name="calendtime" id="calendtime">
                                <cfloop from="#startTime#" to="#endTime#" step="#createTimeSpan(0, 0, 15, 0)#" index="timeSlot">
                                    <cfset formattedTime = timeFormat(timeSlot, "HH:mm:ss")>
                                    <cfset displayTime = timeFormat(timeSlot, "h:mm tt")>
                                    <cfoutput>
                                        <option value="#formattedTime#" <cfif timeFormat(details.calendtime) EQ formattedTime>selected</cfif>>#displayTime#</option>
                                    </cfoutput>
                                </cfloop>
                            </select>
                        </div>
                        
                        <!--- Rows Per Page Selection --->
                        <div class="form-group col-md-6">
                            <label for="defrows">Rows Per Page<span class="text-danger">*</span></label>
                            <select class="form-control" name="defrows" id="defrows">
                                <cfoutput>
                                    <cfloop list="10,25,50,100" index="rowOption">
                                        <option value="#rowOption#" <cfif details.defrows is rowOption>selected</cfif>>#rowOption#</option>
                                    </cfloop>
                                </cfoutput>
                            </select>
                        </div>
                        
                        <!--- Date Format Selection --->
                        <div class="form-group col-md-12">
                            <label for="dateformatid">Date Format</label>
                            <select class="form-control" name="dateformatid" id="dateformatid">
                                <cfoutput query="dateformats">
                                    <option value="#dateformats.id#" <cfif details.dateformatid is dateformats.id>selected</cfif>>#dateformats.formatexample# - (Example: #dateformat(now(), dateformats.formatexample)#)</option>
                                </cfoutput>
                            </select>
                        </div>
                        
                        <cfoutput>
                            <input type="hidden" name="viewtypeid" value="#details.viewtypeid#"/>
                        </cfoutput>
                        
                        <!--- Timezone Selection --->
                        <div class="form-group col-md-12">
                            <label for="tzid">Timezone<span class="text-danger">*</span></label>
                            <select class="form-control" name="tzid" id="tzid" data-parsley-required data-parsley-error-message="Timezone is required">
                                <cfoutput query="timezones_min">
                                    <option value="#timezones_min.tzid#" <cfif details.tzid is timezones_min.tzid>selected</cfif>>(#timezones_min.gmt#) #timezones_min.tzgeneral#</option>
                                </cfoutput>
                            </select>
                        </div>
                        
                        <!--- Submit Button --->
                        <div class="form-group text-center col-md-12">
                            <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: ##406e8e; border: ##406e8e;">Update</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!--- Main Content Area with Tabs --->
    <div class="card mb-3">
        <div class="card-body">
            <!--- Tab Navigation --->
            <ul class="nav nav-pills navtab-bg nav-justified p-1">
                <cfoutput>
                    <cfset tabsConfig = [
                        {id: "info", name: "Info", expand: tab0_expand},
                        {id: "profile", name: "Dashboard", expand: tab1_expand},
                        {id: "myteam", name: "Team", expand: tab2_expand},
                        {id: "mybrand", name: "Essence", expand: tab3_expand},
                        {id: "myheadshots", name: "Headshots", expand: tab8_expand},
                        {id: "mymaterials", name: "Materials", expand: tab9_expand},
                        {id: "pref", name: "Preferences", expand: tab4_expand},
                        {id: "systems", name: "Systems", expand: tab7_expand},
                        {id: "billing", name: "Billing", expand: tab10_expand}
                    ]>
                    
                    <cfloop array="#tabsConfig#" index="tab">
                        <li class="nav-item">
                            <a href="###tab.id#" data-bs-toggle="tab" aria-expanded="#tab.expand#" 
                               class="nav-link<cfif tab.expand is 'true'> active</cfif>">#tab.name#</a>
                        </li>
                    </cfloop>
                    
                    <span class="ml-auto" style="border-top:0 !important;border-left:0 !important;border-right:0 !important;"></span>
                </cfoutput>
            </ul>
            
            <!--- Tab Content --->
            <div class="tab-content">
                <cfoutput>
                    <cfloop array="#tabsConfig#" index="tab">
                        <div class="tab-pane<cfif tab.expand is 'true'> show active</cfif>" id="#tab.id#">
                            <cfinclude template="/include/#tab.id#_pane.cfm"/>
                        </div>
                    </cfloop>
                </cfoutput>
            </div>
        </div>
    </div>
</cfif>
