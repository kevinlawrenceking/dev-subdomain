---
mode: instruct
---

ReminderService.cfc contains the business logic for TAO relationship reminders.

Core methods include:

- `getPendingReminders(userID, contactID)`  
  Returns all reminders where `notstatus = 'Pending'` and `notstartdate <= now()`. Used by the AJAX reminder pane.

- `markReminderStatus(reminderID, status)`  
  Updates a single reminder’s `notstatus`, sets `notenddate`, and applies `isUnique` logic:
  - If action is marked unique, also set `contactdetails.uniquename = 'Y'`
  - If action is recurring, insert a new notification with future `notstartdate`
  - Otherwise, activate the next pending step using `actionDaysNo`

- `insertNewSystemTrack(contactID, systemID)`  
  Creates a `fusystemusers` row and loops through `fuactions` to generate `funotifications`. Honors uniqueness and user-specific timing (`actionusers`).

- `autoStartMaintenanceIfNeeded(contactID, userID)`  
  Called when a Follow-Up system completes. Starts a Maintenance system if one doesn’t exist.

Tables used:
- `funotifications`
- `fusystemusers`
- `fuactions`
- `actionusers`
- `contactdetails`

This component encapsulates all step advancement and recurrence logic. No reminder logic should be handled in `.cfm` templates directly.
