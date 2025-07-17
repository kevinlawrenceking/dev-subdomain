# GitHub Copilot Instructions: TAO Relationship System (Relationships Module)

## Project Context

The TAO Relationship System helps actors strategically build and maintain professional relationships with casting directors, agents, and industry collaborators. It’s not just a contact database — it schedules actionable relationship steps and drives them with reminders.

Copilot will be assisting in a ColdFusion (CFML) + SQL + JS/Bootstrap app structured around modular, service-oriented architecture. Follow these guidelines for consistent, performant, and maintainable contributions.

---

##  Core Architecture

### Folder Structure (High-Level)

```text
app/                    # Public-facing modules (UI, workflows)
├── contact*/           # Contact profiles, system setup, actions
├── reminders*/         # Reminder views and modals
├── dashboard*/         # Summary widgets and alerts
├── [feature-modules]/  # Other actor tools (essences, auditions, etc.)

services/               # Business logic (ContactItemService, ReminderService, etc.)
include/
├── qry/                # Parameterized CFQuery modules
├── [utils]/            # Shared utilities, HTML renderers
setup/                  # First-run logic, migrations
```

---

## Development Guidelines

### CFML Standards

#### Escaping Literal `#` Characters

```cfml
<!-- Inside cfoutput: Escape pound signs with ## -->
<cfoutput>
    $("##elementId").hide();  <!-- Correct -->
    var url = "page.cfm?id=#someid#"; <!-- CF variable -->
</cfoutput>
```

#### Documentation Header (Standard)

```cfml
<!---
    PURPOSE: Explain file function (e.g. show all pending notifications)
    AUTHOR: Kevin King
    DATE: 2025-07-16
    PARAMETERS: contactid, userid
    DEPENDENCIES: services.ContactItemService
--->
```

#### Use Service Layer for Logic

```cfml
<cfset reminderService = createObject("component", "services.ReminderService")>
<cfset reminders = reminderService.getPendingReminders(userid)>
```

#### Database Query Standards

* **Always use `<cfqueryparam>`**
* Name queries descriptively (`qGetUpcomingNotifications`)
* Break complex logic into `include/qry/`
* Avoid inline SQL in `.cfm` templates

#### Sample Query Module

```cfml
<!-- include/qry/getPendingNotifications.cfm -->
<cfquery name="qGetPendingNotifications" datasource="#application.dsn#">
    SELECT *
    FROM funotifications
    WHERE notstatus = 'Pending'
      AND notstartdate <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
</cfquery>
```

---

## Frontend/UI Best Practices

### DataTables Integration

```javascript
$('#remindersTable').DataTable({
    ajax: { url: '/include/get_reminders.cfm', data: { showInactive: 0 } },
    columns: [...],
    responsive: true,
    pageLength: 25
});
```

### Modals

Use Bootstrap 4/5 modal patterns, always include:

* `.modal-header` (with title and close)
* `.modal-body` (with dynamic content)
* `.modal-footer` (with action buttons)

### Form Validation

* Use Parsley.js for client-side
* Validate again in service layer on submit
* Prefer AJAX submit with meaningful feedback

---

##  Workflow System Logic (for Reference)

**Relationship tracks** are composed of:

* `fusystemusers` → Relationship track (per contact)
* `funotifications` → Scheduled actions (e.g. “Send Postcard”)
* `actionusers` → User-specific timing per action
* `contactdetails.uniquename` → Used to block duplicate unique actions

Flow:

1. `fusystemusers` inserted when user starts system.
2. Action templates (`fuactions`) copied and personalized using `actionusers`.
3. Actions inserted into `funotifications`.
4. As actor completes them, recurrence or next step is triggered.
5. On completion, optional Maintenance system is created.

---

##  Common Copilot Tasks

### Add a New Follow-Up Action

1. Update `fuactions` with new template step.
2. Create matching UI form and modal.
3. Add handler in `ReminderService.cfc`.
4. Include proper logic in `get_reminders.cfm`.

### Implement New Reminder Filter

1. Add checkbox to reminders pane.
2. Use jQuery to trigger `table.ajax.reload()`.
3. Update `get_reminders.cfm` to handle filter param.

### Add Button Actions (Complete / Skip)

Use standard markup:

```html
<button class="btn btn-success btn-sm mark-complete" data-id="123">✔</button>
```

Bind handlers via jQuery and use AJAX POST to update `funotifications.notstatus`.

---

## Testing & Debugging

### CFML

* Watch for unescaped `#` inside `<cfoutput>`
* Confirm queries use `cfqueryparam`
* Validate service methods return correct types

### JavaScript

* Check modals load via `.on('show.bs.modal')`
* Validate event delegation for dynamic tables
* Confirm AJAX responses contain expected keys

### Workflow Bugs

* If actions don’t trigger: check `notstartdate IS NULL`
* If uniqueness fails: check `contactdetails.uniquename`
* If Maintenance not auto-starting: validate `fusystemusers` logic

---

##  Security Guidelines

* Validate user inputs both client + server side
* Sanitize outputs
* All queries must use `cfqueryparam`
* Use session checks before performing mutations

---

##  Deployment Reminders

* Update `Application.cfc` for environment-specific settings
* Ensure DB connections, error logging, and DSNs are correct
* SSL enforced in production
* Always backup `actionusers` and `fusystemusers` before schema updates

---

##  Helpful References

* [ColdFusion Docs](https://helpx.adobe.com/coldfusion/cfml-reference.html)
* [Bootstrap Docs](https://getbootstrap.com/)
* [jQuery API](https://api.jquery.com/)
* [DataTables](https://datatables.net/)
