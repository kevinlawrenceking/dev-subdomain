---
mode: instruct
---
The TAO Relationship System manages contact workflows like Targeting, Follow-Up, and Maintenance.

- Tracks are stored in `fusystemusers`
- Actions are in `funotifications`
- Templates are in `fuactions`
- Timing rules in `actionusers`

Only one `Pending` action should be active at a time. Unique actions update `contactdetails.uniquename`.

Use ReminderService.cfc for status updates. Filter reminders using `notstatus` and `notstartdate`.
