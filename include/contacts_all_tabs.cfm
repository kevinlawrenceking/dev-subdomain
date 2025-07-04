<!--- This ColdFusion page manages contacts, allowing users to add relationships, tags, and systems to selected contacts. It includes modals for user interactions and displays contact information in a tabbed interface. --->
<cfparam name="contact_expand" default="true" />
<cfparam name="a" default="0" />
<cfparam name="d" default="0" />
<cfparam name="s" default="0" />
<cfparam name="contactcheckvisible" default="false" />
<cfparam name="maintenance_expand" default="false" />
<cfparam name="bytag" default="" />
<cfparam name="target_expand" default="false" />
<cfparam name="followup_expand" default="false" />
<cfparam name="all_expand" default="false" />
<cfparam name="pgaction" default="view" />

<style>
    /* Extra small devices (phones, less than 768px) */
    /* No media query since this is the default in Bootstrap */
    .font-size: 11px; 
    .large {
        font-size: 20px;
    }

    /* Small devices (tablets, 768px and up) */
    @media (min-width: @screen-sm-min) {
        .font-size: 13px; 
        .large {
            font-size: 50px;
        }
    }

    /* Medium devices (desktops, 992px and up) */
    @media (min-width: @screen-md-min) {
        .font-size: 16px; 
        .large {
            font-size: 100px;
        }
    }

    /* Large devices (large desktops, 1200px and up) */
    @media (min-width: @screen-lg-min) {
        .font-size: 18px; 
        .large {
            font-size: 150px;
        }
    }
</style>

<!--- Check if session action is defined; if not, set it to 'view' --->
<cfif NOT isdefined('session.pgaction')>
    <cfset session.pgaction = "view">
</cfif>

<!--- Include last updates query --->
<cfinclude template="/include/qry/lastupdates.cfm" />

<!--- Initialize modal for adding a relationship --->
<script>
    $(document).ready(function() {
        $("#remoteAddName").on("show.bs.modal", function(event) {
            
            $(this).find(".modal-body").load("/include/remoteAddName.cfm");
        });
    });
</script>

<div id="remoteAddName" class="modal fade" tabindex="-1" role="dialog" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">Add A Relationship</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body">
            </div>
        </div>
    </div>
</div>

<!--- Check if session action is 'bulk' and handle modal display accordingly --->
<cfif session.pgaction is "bulk">
    <cfset session.pgaction = "view" />
    <script>
        $(document).ready(function() {
            $("#bulkModal").modal('show');
        });
    </script>

    <script>
        var table = $("#contacts_ss");
        var btn = $('#btnSelectedRows');

        function enableBtn() {
            btn.prop("disabled", table.find("input:checked").length === 0);
        }

        table.on("change", "input", enableBtn);
        enableBtn();
    </script>

    <div id="bulkModal" class="modal fade">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Selected Updated Summary</h5>
                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                </div>
                <div class="modal-body">
                    <cfif a is not "0">
                        <p>
                            <cfoutput>#a# #bt#<cfif a is not "1">s</cfif> added.</cfoutput>
                        </p>
                    </cfif>

                    <cfif d is not "0">
                        <p>
                            <cfoutput>#d# #bt#<cfif d is not "1">s</cfif> removed.</cfoutput>
                        </p>
                    </cfif>

                    <cfif s is not "0">
                        <p>
                            <cfoutput>#s# relationship<cfif s is not "1">s</cfif> skipped.</cfoutput>
                        </p>
                    </cfif>

                    <div class="form-group text-center col-md-12">
                        <a href="/app/contacts/">
                            <button class="btn btn-primary waves-effect waves-light" type="button" style="background-color: #406e8e; border: #406e8e;">Continue</button>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cfif>

<!--- If session action is not 'bulk', hide the bulk modal --->
<cfif session.pgaction is not "bulk">
    <script>
        $(document).ready(function() {
            $("#bulkModal").modal('hide');
        });
    </script>
</cfif>

<div class="row">
    <div class="col-lg-12">
        <div class="card mb-3">
            <div class="card-body">
                <div class="button-list nomobile">
                    <button type="button" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteAddName" data-bs-placement="top" class="btn btn-warning waves-effect waves-light">
                        <span class="btn-label"><i class="fe-user-plus"></i></span>Add Relationship
                    </button>

                    <button type="button" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#exampleModal4" data-bs-placement="top" class="btn btn-warning waves-effect waves-light">
                        <span class="btn-label"><i class="mdi mdi-tag-plus"></i></span>Add Tag to Selected
                    </button>

                    <button type="button" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#exampleModal3" data-bs-placement="top" class="btn btn-warning waves-effect waves-light">
                        <span class="btn-label"><i class="mdi mdi-checkbox-multiple-marked"></i></span>Add System to Selected
                    </button>

                    <button type="button" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#exampleModal2" data-bs-placement="top" class="btn btn-warning waves-effect waves-light">
                        <span class="btn-label"><i class="mdi mdi-tag-plus-outline"></i></span>Search Tag
                    </button>

                    <a href="/app/contacts-import/" target="import" class="text-reset font-18 py-1 px-2 d-inline-block" data-toggle="tooltip" data-placement="top" title="Import Relationships" data-original-title="Import Relationships">
                        <button type="button" class="btn btn-warning waves-effect waves-light">
                            <span class="btn-label"><i class="fe-upload"></i></span>Import Relationships
                        </button>
                    </a>
                </div>

                <ul class="nav nav-pills navtab-bg nav-justified">
                    <li class="nav-item">
                        <a href="#all" data-bs-toggle="tab" aria-expanded="true" class="nav-link active">
                            All
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="#targeted" data-bs-toggle="tab" aria-expanded="false" class="nav-link">
                            Targeted
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="#followup" data-bs-toggle="tab" aria-expanded="false" class="nav-link">
                            Follow Up
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="#maintenance" data-bs-toggle="tab" aria-expanded="false" class="nav-link">
                            Maintenance
                        </a>
                    </li>
                </ul>

                <div class="tab-content">
                    <div class="tab-pane" id="all">
                        <cfset contacts_table = "contacts_ss" />
                        <cfinclude template="/include/contacts_table.cfm" />
                    </div>
                    <div class="tab-pane show active" id="targeted">
                        <cfset contacts_table = "contacts_ss_target" />
                        <cfinclude template="/include/contacts_table.cfm" />
                    </div>
                    <div class="tab-pane" id="followup">
                        <cfset contacts_table = "contacts_ss_followup" />
                        <cfinclude template="/include/contacts_table.cfm" />
                    </div>
                    <div class="tab-pane" id="maintenance">
                        <cfset contacts_table = "contacts_ss_maint" />
                        <cfinclude template="/include/contacts_table.cfm" />
                    </div>
                </div>

                <!--- Display tag if defined --->
                <cfif bytag is not "">
                    <cfoutput>
                        <div style="padding-top:10px;padding-bottom:10px">
                            <cfset bytag = "#bytag#">
                            <a href="/app/contacts/">
                                <span class="badge badge-blue">#bytag# X</span>
                            </a>
                        </div>
                    </cfoutput>
                <cfelse>
                    <div style="padding-top:10px;padding-bottom:10px">&nbsp;</div>
                </cfif>
            </div>
        </div>
    </div>

    <!--- Include tags query --->
    <cfinclude template="/include/qry/tags_76_1.cfm" />

    <!--- Modal for tag selection --->
    <div class="modal fade" id="exampleModal2" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel2" >

        <div class="modal-dialog modal-dialog-slideout modal-sm" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Tag Selector</h5>
                    <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                        <span >
X</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <cfoutput query="tags">
                            <div class="col-md-6">
                                <a href="/app/contacts?bytag=#tagname#">
                                    <span class="badge badge-blue">#tagname#</span>
                                </a>
                            </div>
                        </cfoutput>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!--- Modal for system update --->
    <div id="exampleModal3" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="standard-modalLabel">System Selected Update</h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                </div>

                <div class="modal-body">
                    <form method="post" class="parsley-examples demo-default selectize-close-btn" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="" novalidate="" id="myform" name="myform" action="/include/tmpcontactgroups.cfm" method="POST">
                        <div class="form-group col-md-12">
                            <label for="valuetext">Add systems to all selected relationships</label>
                        </div>

                        <div class="form-group col-md-6">
                            <select id="select-system" name="new_systemtype" class="form-control" data-parsley-required="" data-parsley-error-message="System is required" onchange="showDiv('hidden_div', this)">
                                <option value="">Select a System...</option>
                                <cfloop query="systems">
                                    <cfset new_systemname = systems.systemname />
                                    <cfset new_select = "" />
                                    <cfoutput>
                                        <option value="#new_systemname#" #new_select#>#new_systemname#</option>
                                    </cfoutput>
                                </cfloop>
                            </select>
                        </div>

                        <div class="form-group col-md-12">
                            <label for="valuetext">If a relationship already has an active system:</label>
                        </div>

                        <div class="form-group col-md-12">
                            <div class="form-group col-md-5">
                                <div class="form-check mb-2 form-check-success">
                                    <input class="form-check-input" type="radio" name="keeplist" value="skip" id="customradio2" checked="checked" />
                                    <label class="form-check-label" for="customradio2">Skip</label>
                                </div>
                            </div>

                            <div class="form-group col-md-6">
                                <div class="form-check mb-2 form-check-danger">
                                    <input class="form-check-input" type="radio" name="keeplist" value="replace" id="customradio4" />
                                    <label class="form-check-label" for="customradio4">Replace</label>
                                </div>
                            </div>
                        </div>

                        <div class="form-group text-center col-md-12">
                            <button class="btn btn-primary editable-submit waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Add System</button>
                        </div>
                    </form>

                    <script>
                        function showDiv(divId, element) {
                            document.getElementById(divId).style.display = element.value == "Custom" ? 'block' : 'none';
                        }
                    </script>

                    <script>
                        $(document).ready(function() {
                            $(".parsley-examples").parsley();
                        });
                    </script>
                </div>
            </div>
        </div>
    </div>

    <!--- Modal for tag update --->
    <div id="exampleModal4" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="standard-modalLabel">Tag Selected Update</h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                </div>

                <div class="modal-body">
                    <form method="post" class="parsley-examples demo-default selectize-close-btn" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="" novalidate="" id="myformtag" name="myformtag" action="/include/tmpcontacttags.cfm" method="POST">
                        <div class="form-group col-md-12">
                            <label for="valuetext">Select Tag to add or remove from selected relationships</label>
                        </div>

                        <div class="form-group col-md-6">
                            <select id="select-tag" name="new_tagname" class="form-control" data-parsley-required="" data-parsley-error-message="Tag is required">
                                <option value="">Select a Tag...</option>
                                <cfloop query="tags">
                                    <cfset new_tagname = tags.tagname />
                                    <cfset new_tagselect = "" />
                                    <cfoutput>
                                        <option value="#new_tagname#" #new_tagselect#>#new_tagname#</option>
                                    </cfoutput>
                                </cfloop>
                            </select>
                        </div>

                        <div class="form-group col-md-12">
                            <label for="valuetext">Action:</label>
                        </div>

                        <div class="form-group col-md-12">
                            <div class="form-group col-md-5">
                                <div class="form-check mb-2 form-check-success">
                                    <input class="form-check-input" type="radio" name="addremove" value="add" id="add" checked="checked" />
                                    <label class="form-check-label" for="customradio2">Add it</label>
                                </div>
                            </div>

                            <div class="form-group col-md-6">
                                <div class="form-check mb-2 form-check-danger">
                                    <input class="form-check-input" type="radio" name="addremove" value="remove" id="remove" />
                                    <label class="form-check-label" for="customradio4">Remove it</label>
                                </div>
                            </div>
                        </div>

                        <div class="form-group text-center col-md-12">
                            <button class="btn btn-primary editable-submit waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Continue</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        (function($) {
            function storeTabs($tabs, $destination) {
                
                $tabs.each(function() {
                    var width = $(this).outerWidth(true);
                    $(this).find('a').data('width', width);
                });
                $tabs.prependTo($destination);
                $tabs.find('a').unwrap().removeClass('nav-link').addClass('dropdown-item');
            }

            function makeTabsResponsive($element) {
                var $tabs = $element.find('li');
                var $firstTab = $tabs.first();
                var individualTabHeight = $firstTab.outerHeight();
                var tabsHeight = $element.outerHeight();

                if (tabsHeight > individualTabHeight) {
                    // get y pos of first tab
                    var firstTabPos = $firstTab.offset();
                    var thisTabPos;

                    $tabs.each(function() {
                        var $thisTab = $(this);
                        thisTabPos = $thisTab.offset();

                        if (thisTabPos.top > firstTabPos.top) {
                            var $dropdown = $element.find('.responsivetabs-more');

                            if (!$dropdown.length) {
                                var dropdownMarkup = '<li class="dropdown show responsivetabs-more">'
                                    + '<a href="#" class="dropdown-toggle" data-toggle="dropdown">...</a>'
                                    + '<div class="dropdown-menu dropdown-menu-right">'
                                    + '</div></li>';
                                $dropdown = $(dropdownMarkup);
                                $element.append($dropdown);
                            }

                            var $previousTab = $thisTab.prev();
                            var $followingTabs = $thisTab.nextAll().not('.dropdown');
                            var $destination = $('.dropdown-menu', $dropdown);

                            if (!$thisTab.hasClass('dropdown')) {
                                storeTabs($followingTabs, $destination);
                                storeTabs($thisTab, $destination);
                            }
                            storeTabs($previousTab, $destination);
                            return;
                        }
                    });
                } else {
                    var parentWidth = $element.parent().width();
                    var tabSetWidth = 0;
                    var xPxAvailable;

$element.children('li').each(function() {
                        tabSetWidth += $(this).outerWidth(true);
                    });

xPxAvailable = parentWidth - tabSetWidth;

                    $element.find('.dropdown-menu a').each(function() {
                        if ($(this).data('width') <= xPxAvailable) {
                            // fix for bootstrap 4
                            $(this).removeClass('dropdown-item').addClass('nav-link');
                            $(this).insertBefore($element.find('.responsivetabs-more')).wrap('<li class="nav-item"></li>');
                            xPxAvailable -= $(this).data('width');
                        } else {
                            return false;
                        }
                    });

                    if (!$element.find('.dropdown-menu a').length) {
                        $element.find('.responsivetabs-more').remove();
                    }
                }
            }

            $.fn.responsiveTabs = function() {
                this.each(function() {
                    var tabs = $(this);
                    makeTabsResponsive(tabs);
                    $(window).resize(function() {
                        makeTabsResponsive(tabs);
                    });
                });
                return this;
            };
        })(jQuery);
    </script>

    <script>
        $(function() {
            $('.nav-justified').responsiveTabs();
        });
    </script>

<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), " \")#" />
