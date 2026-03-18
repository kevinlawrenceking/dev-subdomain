<!---
    PURPOSE: Left navigation sidebar for The Actors Office
    AUTHOR: Kevin King
    DATE: 2025-08-06
    REVISED: 2026-03-18 -- Full redesign: externalized CSS, Lucide icons,
             active state detection, accessibility, responsive support,
             migration-prep annotations

    DEPENDENCIES:
        - Bootstrap 5 (collapse component for admin sections)
        - Lucide Icons (CDN, loaded at bottom of this template)
        - /app/assets/css/sidebar.css (externalized sidebar styles)
        - Session variables: session.userAvatarUrl
        - Variables scope (leaked from cfinclude chain -- see TECH-DEBT notes):
            variables.avatarname       -- user display name (from fetchUsers.cfm)
            variables.userrole         -- "Administrator" or role string (from fetchUsers.cfm)
            variables.userIsBetaTester -- "1" or "0"
        - Query objects (from qry/ includes in core.cfm):
            menuItemsU   -- user menu items (compDir, compicon, compName)
            menuItemsA   -- admin Relationships sub-items
            menuItemsAud -- admin Auditions sub-items

    ACTIVE STATE:
        Detects current page by parsing cgi.SCRIPT_NAME for the compDir segment.
        URL pattern: /app/{compDir}/
        Applies .tao-sidebar__item--active CSS class and aria-current="page".
        Admin sections auto-expand if a child item is active.

    HTML STRUCTURE:
        <nav.tao-sidebar.left-side-menu>               -- outer nav (framework JS compat)
          <div.tao-sidebar__scroll>                     -- native scrollable area
            <div#sidebar-menu.tao-sidebar__menu-wrap>   -- framework condensed CSS compat
              <div.tao-sidebar__profile>                -- user avatar + name
              <ul.tao-sidebar__menu>                    -- single list for ALL items
                <li.tao-sidebar__item>                  -- primary nav links
                <li.tao-sidebar__divider-wrap>          -- section dividers
                <li.tao-sidebar__section>               -- collapsible admin sections
                  <ul.tao-sidebar__submenu>             -- admin sub-items

    FRAMEWORK COMPAT:
        - .left-side-menu on <nav> keeps the Hyper framework JS working
          (body.sidebar-enable toggle, condensed mode via data-leftbar-size)
        - #sidebar-menu on the wrapper div keeps the framework's condensed-mode
          CSS selectors working (#sidebar-menu > ul > li > a span { display:none })
        - No SimpleBar: native CSS overflow-y replaces the JS scrollbar library

    MIGRATE: Menu items should come from a MenuRepository.listByRole(userId, role) call
    MIGRATE: Active state detection will be handled by Flutter's router, not server-side
    MIGRATE: Icon mapping should be a shared constant, not DB-stored strings
    TECH-DEBT: avatarname is unscoped -- traces back to fetchUsers.cfm variable leak
    TECH-DEBT: userrole is unscoped -- traces back to fetchUsers.cfm variable leak
    TECH-DEBT: Three separate query includes for menu sections -- should be one query
               with a section/category column
--->

<!--- Sidebar stylesheet (externalized from inline <style> block) --->
<link rel="stylesheet" href="/app/assets/css/sidebar.css" />

<!--- =====================================================================
     CF Logic: defaults, icon mapping, active state detection
     ===================================================================== --->

<!--- Defensive defaults for upstream variables that may be unscoped --->
<cfparam name="variables.avatarname" default="User" />
<cfparam name="variables.userrole" default="" />
<cfparam name="variables.userIsBetaTester" default="0" />

<!---
    MIGRATE: Icon mapping should be a shared constant, not DB-stored strings.
    This CF-side mapping translates compDir values to Lucide icon names,
    avoiding a DB migration while providing semantically correct icons.
    Keyed by lowercase compDir for case-insensitive matching.
    Fallback: if compDir is not in the map, the DB compicon value is used
    (most Feather names work in Lucide since Lucide is a Feather fork).
--->
<cfset variables.lucideIconMap = {
    "dashboard":       "layout-dashboard",
    "relationships":   "users",
    "calendar-new":    "calendar-days",
    "calendar":        "calendar-days",
    "reminders":       "bell-ring",
    "auditions":       "clapperboard",
    "events":          "clapperboard",
    "reports":         "bar-chart-3",
    "myaccount":       "circle-user-round",
    "my-account":      "circle-user-round",
    "image-upload":    "image",
    "contacts":        "contact",
    "notifications":   "bell",
    "settings":        "settings",
    "testings":        "clipboard-check"
} />

<!---
    Active state detection: extract compDir segment from the current URL.
    URL pattern: /app/{compDir}/index.cfm or /app/{compDir}/
    MIGRATE: Active state detection will be handled by Flutter's router.
--->
<cfset variables.currentSection = "" />
<cfset variables.pathSegments = listToArray(cgi.SCRIPT_NAME, "/") />
<cfif arrayLen(variables.pathSegments) GTE 2 AND lCase(variables.pathSegments[1]) EQ "app">
    <cfset variables.currentSection = lCase(variables.pathSegments[2]) />
</cfif>

<!--- Pre-compute whether any admin sub-item is active (for auto-expand) --->
<cfset variables.adminRelActive = false />
<cfloop query="menuItemsA">
    <cfif lCase(menuItemsA.compDir) EQ variables.currentSection>
        <cfset variables.adminRelActive = true />
        <cfbreak />
    </cfif>
</cfloop>

<cfset variables.adminAudActive = false />
<cfloop query="menuItemsAud">
    <cfif lCase(menuItemsAud.compDir) EQ variables.currentSection>
        <cfset variables.adminAudActive = true />
        <cfbreak />
    </cfif>
</cfloop>


<!--- =====================================================================
     Sidebar HTML
     ===================================================================== --->

<nav class="tao-sidebar left-side-menu" role="navigation" aria-label="Main navigation">
    <div class="tao-sidebar__scroll">
        <div id="sidebar-menu" class="tao-sidebar__menu-wrap">

        <!--- User Profile Section --->
        <div class="tao-sidebar__profile">
            <cfoutput>
                <a href="/app/image-upload/?ref_pgid=7"
                   class="tao-sidebar__avatar-link"
                   title="Change profile photo">
                    <img src="#session.userAvatarUrl#?v=#dateFormat(now(),'yyyymmdd')##timeFormat(now(),'HHmmss')#"
                         alt="Profile photo for #xmlFormat(variables.avatarname)#"
                         class="tao-sidebar__avatar" />
                    <span class="tao-sidebar__username">#xmlFormat(variables.avatarname)#</span>
                </a>
            </cfoutput>
        </div>

        <!--- Primary Navigation Items --->
        <!--- MIGRATE: Menu items should come from a MenuRepository.listByRole(userId, role) call --->
        <ul class="tao-sidebar__menu">
            <cfoutput query="menuItemsU">
                <cfset variables.itemDir = lCase(menuItemsU.compDir) />
                <cfset variables.isActive = (variables.itemDir EQ variables.currentSection) />
                <cfset variables.iconName = menuItemsU.compicon />
                <cfif structKeyExists(variables.lucideIconMap, variables.itemDir)>
                    <cfset variables.iconName = variables.lucideIconMap[variables.itemDir] />
                </cfif>

                <li class="tao-sidebar__item<cfif variables.isActive> tao-sidebar__item--active</cfif>">
                    <a href="/app/#menuItemsU.compDir#/"
                       class="tao-sidebar__link"
                       <cfif variables.isActive>aria-current="page"</cfif>>
                        <i data-lucide="#variables.iconName#" class="tao-sidebar__icon"></i>
                        <span class="tao-sidebar__label">#xmlFormat(menuItemsU.compName)#</span>
                    </a>
                </li>
            </cfoutput>

                <!--- Administrator Menu Sections --->
                <cfif variables.userrole IS "Administrator">

                    <!--- Section Divider --->
                    <li class="tao-sidebar__divider-wrap" role="separator" aria-hidden="true">
                        <div class="tao-sidebar__admin-divider"></div>
                    </li>

                    <!--- Relationships Admin Section --->
                    <li class="tao-sidebar__section<cfif variables.adminRelActive> tao-sidebar__section--active</cfif>">
                        <a href="#sidebar-admin-relationships"
                           class="tao-sidebar__section-toggle"
                           data-bs-toggle="collapse"
                           role="button"
                           aria-expanded="<cfif variables.adminRelActive>true<cfelse>false</cfif>"
                           aria-controls="sidebar-admin-relationships">
                            <i data-lucide="users" class="tao-sidebar__icon"></i>
                            <span class="tao-sidebar__label">Relationships - Admin</span>
                            <i data-lucide="chevron-down" class="tao-sidebar__arrow"></i>
                        </a>
                        <div class="collapse<cfif variables.adminRelActive> show</cfif>"
                             id="sidebar-admin-relationships">
                            <ul class="tao-sidebar__submenu">
                                <cfoutput query="menuItemsA">
                                    <cfset variables.subDir = lCase(menuItemsA.compDir) />
                                    <cfset variables.subActive = (variables.subDir EQ variables.currentSection) />
                                    <li class="tao-sidebar__subitem<cfif variables.subActive> tao-sidebar__subitem--active</cfif>">
                                        <a href="/app/#menuItemsA.compDir#/"
                                           class="tao-sidebar__sublink"
                                           <cfif variables.subActive>aria-current="page"</cfif>>
                                            #xmlFormat(menuItemsA.compName)#
                                        </a>
                                    </li>
                                </cfoutput>
                            </ul>
                        </div>
                    </li>

                    <!--- Audition Admin Section --->
                    <li class="tao-sidebar__section<cfif variables.adminAudActive> tao-sidebar__section--active</cfif>">
                        <a href="#sidebar-admin-auditions"
                           class="tao-sidebar__section-toggle"
                           data-bs-toggle="collapse"
                           role="button"
                           aria-expanded="<cfif variables.adminAudActive>true<cfelse>false</cfif>"
                           aria-controls="sidebar-admin-auditions">
                            <i data-lucide="clapperboard" class="tao-sidebar__icon"></i>
                            <span class="tao-sidebar__label">Audition - Admin</span>
                            <i data-lucide="chevron-down" class="tao-sidebar__arrow"></i>
                        </a>
                        <div class="collapse<cfif variables.adminAudActive> show</cfif>"
                             id="sidebar-admin-auditions">
                            <ul class="tao-sidebar__submenu">
                                <cfoutput query="menuItemsAud">
                                    <cfset variables.subDir = lCase(menuItemsAud.compDir) />
                                    <cfset variables.subActive = (variables.subDir EQ variables.currentSection) />
                                    <li class="tao-sidebar__subitem<cfif variables.subActive> tao-sidebar__subitem--active</cfif>">
                                        <a href="/app/#menuItemsAud.compDir#/"
                                           class="tao-sidebar__sublink"
                                           <cfif variables.subActive>aria-current="page"</cfif>>
                                            #xmlFormat(menuItemsAud.compName)#
                                        </a>
                                    </li>
                                </cfoutput>
                            </ul>
                        </div>
                    </li>

                </cfif><!--- end Administrator --->

                <!--- Beta Tester Menu Item --->
                <cfif variables.userIsBetaTester IS "1">
                    <li class="tao-sidebar__divider-wrap" role="separator" aria-hidden="true">
                        <div class="tao-sidebar__admin-divider"></div>
                    </li>
                    <cfset variables.testActive = (variables.currentSection EQ "testings") />
                    <li class="tao-sidebar__item<cfif variables.testActive> tao-sidebar__item--active</cfif>">
                        <a href="/app/Testings/"
                           class="tao-sidebar__link"
                           <cfif variables.testActive>aria-current="page"</cfif>>
                            <i data-lucide="clipboard-check" class="tao-sidebar__icon"></i>
                            <span class="tao-sidebar__label">Testing Log</span>
                        </a>
                    </li>
                </cfif>

            </ul>

        </div><!--- /#sidebar-menu --->
    </div><!--- /.tao-sidebar__scroll --->
</nav>

<!--- Mobile backdrop overlay (shown when sidebar is open on small screens) --->
<div class="tao-sidebar-backdrop" id="taoSidebarBackdrop"></div>

<!--- =====================================================================
     Lucide Icons CDN + Sidebar Initialization
     =====================================================================
     Lucide is the maintained fork of Feather Icons with 2x the icon set.
     Only the sidebar uses Lucide; the rest of the app continues to use
     Feather Icons via the .fe-* font classes and feather.replace() in
     app.min.js. No conflict: data-lucide and data-feather are separate.

     MIGRATE: When the full app migrates to Lucide, move this CDN link to
     the <head> in core.cfm and remove the per-page initialization below.
     For production, download lucide.min.js locally to /app/assets/libs/lucide/.
     ===================================================================== --->
<script src="https://cdn.jsdelivr.net/npm/lucide@0.469.0/dist/umd/lucide.min.js"></script>
<script>
(function() {
    // Initialize Lucide icons within the sidebar only
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

    // Mobile sidebar: close when backdrop is clicked
    var backdrop = document.getElementById('taoSidebarBackdrop');
    if (backdrop) {
        backdrop.addEventListener('click', function() {
            document.body.classList.remove('sidebar-enable');
        });
    }

    // Sync Bootstrap collapse aria-expanded with arrow rotation
    // Bootstrap 5 updates aria-expanded automatically, but we listen
    // for the event to ensure our CSS arrow rotation stays in sync.
    var toggles = document.querySelectorAll('.tao-sidebar__section-toggle');
    for (var i = 0; i < toggles.length; i++) {
        var collapseId = toggles[i].getAttribute('aria-controls');
        if (collapseId) {
            var collapseEl = document.getElementById(collapseId);
            if (collapseEl) {
                collapseEl.addEventListener('shown.bs.collapse', function() {
                    var toggle = document.querySelector('[aria-controls="' + this.id + '"]');
                    if (toggle) toggle.setAttribute('aria-expanded', 'true');
                });
                collapseEl.addEventListener('hidden.bs.collapse', function() {
                    var toggle = document.querySelector('[aria-controls="' + this.id + '"]');
                    if (toggle) toggle.setAttribute('aria-expanded', 'false');
                });
            }
        }
    }
})();
</script>
