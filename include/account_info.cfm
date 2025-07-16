<!---
================================================================================
ACCOUNT_INFO.CFM - User Account Management Interface
================================================================================

Purpose:
This file provides a comprehensive user account management interface within the
TAO Relationship System. It handles user profile information, preferences,
team management, branding, materials, and system settings through a tabbed
interface design.

TAO System Integration:
- Part of the user account management system
- Supports user profile maintenance and customization
- Manages user preferences and system settings
- Handles team member management and collaboration features
- Integrates with materials and headshots management

Database Tables:
- actionusers_tbl (team member actions)
- taousers (main user account table)
- contactdetails (user contact information)
- countries (country lookup)
- regions (region lookup)
- timezones (timezone settings)
- dateformats (date format preferences)
- User preference and settings tables

Key Features:
- Tab-based interface for different account sections
- User profile information management
- Dashboard preferences and customization
- Team member management
- Brand/essence management
- Headshots and materials management
- System preferences and settings
- Billing information
- Mobile-responsive design with redirection logic

Dependencies:
- jQuery for tab navigation and modal management
- Bootstrap for UI components
- Parsley for form validation
- ColdFusion for server-side processing

Modal Components:
- Dashboard update modal
- User account update modal
- Add contact modal
- Calendar preferences modal

Author: TAO Development Team
Last Updated: 2025
================================================================================
--->

<!--- Parameter initialization --->
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
<cfparam name="REGION" default=""/>
<cfparam name="NLETTER_YN" default=""/>

<!--- Session variable setup --->
<cfset session.pgrtn="P"/>
<cfset pgrtn="P"/>

<!--- Include required query files --->
<cfinclude template="/include/qry/countries_457_1.cfm"/>
<cfinclude template="/include/qry/regions_518_1.cfm"/>
<cfinclude template="/include/qry/timezones_547_1.cfm"/>
<cfinclude template="/include/qry/timezones_min_547_2.cfm"/>
<cfinclude template="/include/qry/dateformats_463_1.cfm"/>
<cfinclude template="/include/qry/details_1693_1.cfm"/>
<cfinclude template="/include/qry/FindUser_1694_2.cfm"/>

<!--- Action handling logic --->
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

<!--- Default values management --->
<cfif new_region_id is "" and def_region_id is not "">
    <cfset new_region_id = def_region_id/>
</cfif>

<cfif new_countryid is "" and def_countryid is not "">
    <cfset new_countryid = def_countryid/>
</cfif>

<!--- Mobile redirection logic --->
<cfif devicetype is "mobile">
    <cfif t2 is "1">
        <cflocation url="/app/contact/?contactid=#contactid#&new_pgid=122"/>
    <cfelseif t3 is "1">
        <cflocation url="/app/contact/?contactid=#contactid#&new_pgid=124"/>
    <cfelseif t7 is "1">
        <cflocation url="/app/contact/?contactid=#contactid#&new_pgid=125"/>
    </cfif>
</cfif>

<!--- Current contact ID setup --->
<cfoutput>
    <cfset CURRENTID = userContactid/>
</cfoutput>

<!--- Desktop layout and tab configuration --->
<cfif devicetype is not "mobile">
    <!--- Tab configuration setup --->
    <cfinclude template="/include/tab_check_account.cfm"/>
    
    <!--- Tab expansion parameters --->
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
    
    <!--- Default to Info tab if none selected --->
    <cfif tab0_expand is "false" and tab1_expand is "false" and tab2_expand is "false" 
          and tab3_expand is "false" and tab4_expand is "false" and tab7_expand is "false" 
          and tab8_expand is "false" and tab9_expand is "false" and tab10_expand is "false">
        <cfset tab0_expand = "true"/>
        <cfset t0 = 1/>
    </cfif>

    <!--- Modal setup and configuration --->
    <cfset modalStructs = [
        {id: "dashboardupdate", title: "Dashboard Preferences", include: "/include/modal.cfm"},
        {id: "remoteUserUpdate", title: "Update Account", include: "/include/modal.cfm"},
        {id: "remoteAddContact", title: "Add Contact", include: "/include/modal.cfm"}
    ]>
    
    <!--- Create modal components --->
    <cfloop array="#modalStructs#" index="modalData">
        <cfset modalid = modalData.id>
        <cfset modaltitle = modalData.title>
        <cfinclude template="#modalData.include#">
    </cfloop>

    <!--- Modal initialization JavaScript --->
    <cfoutput>
        <script>
            $(document).ready(function () {
                // Dashboard update modal handler
                $("##dashboardupdate").on("show.bs.modal", function (event) {
                    $(this).find(".modal-body").load("/include/dashboardupdate.cfm?userid=#userid#");
                });
                
                // User update modal handler
                $("##remoteUserUpdate").on("show.bs.modal", function (event) {
                    $(this).find(".modal-body").load("/include/remoteUserUpdate.cfm?userid=#userid#&src=account");
                });
                
                // Add contact modal handler
                $("##remoteAddContact").on("show.bs.modal", function (event) {
                    $(this).find(".modal-body").load("/include/remoteAddContact.cfm?userid=#userid#&src=account");
                });
            });
        </script>
    </cfoutput>
    
    <!--- Calendar preferences modal --->
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
                            <input type="hidden" name="ctaction" value="update_cal"/>
                            <input type="hidden" name="t4" value="1"/>
                        </cfoutput>
                        
                        <!--- Time selection configuration --->
                        <cfset startTime = createTime(5, 0, 0)>
                        <cfset endTime = createTime(23, 45, 0)>
                        
                        <!--- Start time selection --->
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
                        
                        <!--- End time selection --->
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
                        
                        <!--- Rows per page selection --->
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
                        
                        <!--- Date format selection --->
                        <div class="form-group col-md-12">
                            <label for="dateformatid">Date Format</label>
                            <select class="form-control" name="dateformatid" id="dateformatid">
                                <cfoutput query="dateformats">
                                    <option value="#dateformats.id#" <cfif details.dateformatid is dateformats.id>selected</cfif>>#dateformats.formatexample# - (Example: #dateformat(now(), dateformats.formatexample)#)</option>
                                </cfoutput>
                            </select>
                        </div>
                        
                        <!--- Timezone selection --->
                        <div class="form-group col-md-12">
                            <label for="tzid">Timezone<span class="text-danger">*</span></label>
                            <select class="form-control" name="tzid" id="tzid" data-parsley-required data-parsley-error-message="Timezone is required">
                                <cfoutput query="timezones_min">
                                    <option value="#timezones_min.tzid#" <cfif details.tzid is timezones_min.tzid>selected</cfif>>(#timezones_min.gmt#) #timezones_min.tzgeneral#</option>
                                </cfoutput>
                            </select>
                        </div>
                        
                        <cfoutput>
                            <input type="hidden" name="viewtypeid" value="#details.viewtypeid#"/>
                        </cfoutput>
                        
                        <!--- Submit button --->
                        <div class="form-group text-center col-md-12">
                            <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: ##406e8e; border: ##406e8e;">Update</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!--- Main content area with tabbed interface --->
    <div class="card mb-3">
        <div class="card-body">
            <!--- Tab navigation --->
           <ul class="nav nav-pills navtab-bg nav-justified p-1">

    <cfoutput>

      <li class="nav-item">
        <a href="##info" data-bs-toggle="tab" aria-expanded="#tab0_expand#" class="nav-link<cfif #tab0_expand# is 'true'> active</cfif>">Info
        </a>
      </li>

      <li class="nav-item">
        <a href="##profile" data-bs-toggle="tab" aria-expanded="#tab1_expand#" class="nav-link<cfif #tab1_expand# is 'true'> active</cfif>">Dashboard
        </a>
      </li>

      <li class="nav-item">
        <a href="##myteam" data-bs-toggle="tab" aria-expanded="#tab2_expand#" class="nav-link<cfif #tab2_expand# is 'true'> active</cfif>">Team</a>
      </li>

      <li class="nav-item">
        <a href="##mybrand" data-bs-toggle="tab" aria-expanded="#tab3_expand#" class="nav-link<cfif #tab3_expand# is 'true'> active</cfif>">Essence</a>
      </li>

      <li class="nav-item">
        <a href="##myheadshots" data-bs-toggle="tab" aria-expanded="#tab8_expand#" class="nav-link<cfif #tab8_expand# is 'true'> active</cfif>">Headshots</a>
      </li>

      <li class="nav-item">
        <a href="##mymaterials" data-bs-toggle="tab" aria-expanded="#tab9_expand#" class="nav-link<cfif #tab9_expand# is 'true'> active</cfif>">Materials</a>
      </li>

      <li class="nav-item">
        <a href="##pref" data-bs-toggle="tab" aria-expanded="#tab4_expand#" class="nav-link<cfif #tab4_expand# is 'true'> active</cfif>">Preferences</a>
      </li>

      <li class="nav-item">
        <a href="##systems" data-bs-toggle="tab" aria-expanded="#tab7_expand#" class="nav-link<cfif #tab7_expand# is 'true'> active</cfif>">Systems</a>
      </li>

      <li class="nav-item">
        <a href="##billing" data-bs-toggle="tab" aria-expanded="#tab10_expand#" class="nav-link<cfif #tab10_expand# is 'true'> active</cfif>">Billing</a>
      </li>

      <span class="ml-auto padding-bottom:11px;text-nowrap border border-top-0 !important border-left-0 !important border-right-0 !important" style="border-top:0 !important;border-left:0 !important;border-right:0 !important;"></span>

    </cfoutput>

  </ul>

            
            <!--- Tab content areas --->
            <div class="tab-content">
                <cfoutput>
                    <cfloop array="#tabsConfig#" index="tab">
                        <div class="tab-pane<cfif tab.expand is 'true'> show active</cfif>" id="#tab.id#">
                            <cfinclude template="/include/#tab.template#"/>
                        </div>
                    </cfloop>
                </cfoutput>
            </div>
        </div>
    </div>
</cfif>
