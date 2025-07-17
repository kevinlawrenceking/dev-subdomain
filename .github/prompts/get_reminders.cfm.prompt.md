---
mode: instruct
---

This file returns a JSON list of relationship reminders for use with a DataTable UI.

Inputs:
- `contactid` (required): filters by specific contact
- `showInactive` (optional): when 1, includes Completed and Skipped; otherwise only Pending

It queries `funotifications`, joined to:
- `fusystemusers` (to get system type)
- `fuactions` (to get action name)

Output:
- JSON array of reminders including id, reminder_text, status, due date, and last updated

The JavaScript front end expects this data to be formatted as:
```json
[
  {
    "id": 123,
    "reminder_text": "Send follow-up email",
    "status": "Pending",
    "due_date": "2025-07-20",
    "last_updated": "2025-07-10"
  },
  ...
]
