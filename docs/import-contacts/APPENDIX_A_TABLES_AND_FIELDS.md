# Appendix A: Tables and Fields

## Contact Data Model

### contactdetails (Core Contact Record)

| Column | Type | Purpose | Import Source |
|--------|------|---------|---------------|
| contactid | INT PK | Primary key | Auto-generated |
| userid | INT | Owner user | Session |
| contactFullName | NVARCHAR | Display name | firstName + lastName or contactFullName |
| recordname | NVARCHAR | Alternate name | Same as contactFullName |
| contactStatus | VARCHAR | Active/Deleted | Set to 'Active' |
| contactMeetingLoc | NVARCHAR | First meeting location | V1: col17 |
| contactMeetingDate | DATE | First meeting date | V1: col18 |
| birthday_mm | VARCHAR | Birthday month | V1: col19 |
| birthday_dd | VARCHAR | Birthday day | V1: col20 |
| isDeleted | BIT | Soft delete flag | 0 |
| uploadid | INT | V1 import batch ID | V1 upload tracking |
| import_job_id | INT | V2 import job ID | V2 (needs to be added) |

### contactitems (Multi-Value Contact Data)

| Column | Type | Purpose | Categories |
|--------|------|---------|------------|
| itemid | INT PK | Primary key | Auto-generated |
| contactid | INT FK | Parent contact | From contactdetails |
| valueCategory | VARCHAR | Item type | Email, Phone, Address, Company, Tag, Social |
| valueType | VARCHAR | Subtype | Business, Personal, Work, Mobile, Home |
| itemStatus | VARCHAR | Active/Deleted | 'Active' |
| primary_yn | CHAR(1) | Primary flag | 'Y' or 'N' |
| valuetext | NVARCHAR | Generic text value | Email address, phone number, tag |
| valueCompany | NVARCHAR | Company name | For Company category |
| valueTitle | NVARCHAR | Job title | For Company category |
| valueDepartment | NVARCHAR | Department | For Company category |
| valueStreetAddress | NVARCHAR | Street line 1 | For Address category |
| valueExtendedAddress | NVARCHAR | Street line 2 | For Address category |
| valueCity | NVARCHAR | City | For Address category |
| valueRegion | NVARCHAR | State/Province | For Address category |
| valuePostalCode | NVARCHAR | ZIP/Postal code | For Address category |
| valueCountry | NVARCHAR | Country | For Address category |
| isDeleted | BIT | Soft delete | 0 |

### contactitems Category/Type Combinations

| valueCategory | valueType Options | Notes |
|---------------|-------------------|-------|
| Email | Business, Personal, Other | valuetext = email address |
| Phone | Work, Mobile, Home, Other | valuetext = phone number |
| Address | Work, Home, Other | Uses address fields |
| Company | Company | valueCompany, valueTitle, valueDepartment |
| Tag | Tags | valuetext = tag name |
| Social | LinkedIn, Twitter, Instagram, Website | valuetext = URL/handle |

---

## V1 Import Staging Table

### contactsimport

| Column | Type | Purpose | Source Column |
|--------|------|---------|---------------|
| id | INT PK | Primary key | Auto-generated |
| userEmail | VARCHAR | User identifier | Derived from session |
| fname | NVARCHAR | First name | Column 1 |
| lname | NVARCHAR | Last name | Column 2 |
| work_phone | VARCHAR | Work phone | Column 3 |
| mobile_phone | VARCHAR | Mobile phone | Column 4 |
| home_phone | VARCHAR | Home phone | Column 5 |
| business_email | VARCHAR | Business email | Column 6 |
| personal_email | VARCHAR | Personal email | Column 7 |
| company | NVARCHAR | Company name | Column 8 |
| tag | NVARCHAR | Single tag | Column 9 |
| address | NVARCHAR | Street address | Column 10 |
| address_second | NVARCHAR | Address line 2 | Column 11 |
| city | NVARCHAR | City | Column 12 |
| state | VARCHAR | State | Column 13 |
| country | NVARCHAR | Country | Column 14 |
| zip | VARCHAR | ZIP code | Column 15 |
| website | NVARCHAR | Website URL | Column 16 |
| contactMeetingLoc | NVARCHAR | Meeting location | Column 17 |
| contactMeetingDate | DATE | Meeting date | Column 18 |
| birthday_month | INT | Birthday month | Column 19 |
| birthday_day | INT | Birthday day | Column 20 |
| maintenance_or_target | VARCHAR | System enrollment | Column 21 |
| status | VARCHAR | Pending/Completed/Duplicate | Processing state |
| uploadid | INT | Batch identifier | Per upload |
| timestamp | DATETIME | Created time | NOW() |

---

## V2 Import Staging Tables

### import_jobs

| Column | Type | Purpose |
|--------|------|---------|
| job_id | INT PK | Primary key |
| userid | INT | Owner user |
| filename | NVARCHAR(255) | Original filename |
| filetype | VARCHAR(10) | csv, xls, xlsx |
| filesize | INT | File size in bytes |
| stored_file_path | NVARCHAR(500) | Server path to file |
| status | VARCHAR(20) | uploaded, parsed, mapping, reviewing, importing, completed, failed |
| total_rows | INT | Rows in file |
| parsed_rows | INT | Successfully parsed |
| imported_rows | INT | Successfully imported |
| error_rows | INT | Failed validation |
| options | NVARCHAR(MAX) | JSON options |
| created_at | DATETIME | Created timestamp |
| updated_at | DATETIME | Last update |
| completed_at | DATETIME | Completion timestamp |

### import_job_rows

| Column | Type | Purpose |
|--------|------|---------|
| row_id | INT PK | Primary key |
| job_id | INT FK | Parent job |
| row_num | INT | Row number in file |
| status | VARCHAR(20) | pending, ready, problem, dupe, skipped, importing, imported, failed |
| data | NVARCHAR(MAX) | JSON row data |
| validation_result | NVARCHAR(MAX) | JSON validation errors/warnings |
| error_count | INT | Number of errors |
| warning_count | INT | Number of warnings |
| best_match_contactid | INT | Duplicate match contact |
| best_match_score | INT | Duplicate match score |
| duplicates | NVARCHAR(MAX) | JSON array of candidates |
| action | VARCHAR(20) | User action: skip, import_new, update_existing |
| created_contactid | INT | Result contact ID |
| created_at | DATETIME | Created timestamp |
| updated_at | DATETIME | Last update |

### import_job_columns

| Column | Type | Purpose |
|--------|------|---------|
| column_id | INT PK | Primary key |
| job_id | INT FK | Parent job |
| source_index | INT | Column position (0-based) |
| source_name | NVARCHAR(255) | Header from file |
| suggested_field | VARCHAR(50) | Auto-detected TAO field |
| confirmed_field | VARCHAR(50) | User-confirmed mapping |
| confidence | DECIMAL(5,2) | Auto-detection confidence (0-1) |
| created_at | DATETIME | Created timestamp |

### import_job_errors (Optional - for detailed error logging)

| Column | Type | Purpose |
|--------|------|---------|
| error_id | INT PK | Primary key |
| job_id | INT FK | Parent job |
| row_id | INT FK | Row with error |
| field_name | VARCHAR(50) | Field that failed |
| error_type | VARCHAR(50) | Validation type |
| error_message | NVARCHAR(500) | Human-readable message |
| severity | VARCHAR(20) | error, warning, info |
| created_at | DATETIME | Created timestamp |

---

## Relationship System Tables

### fusystems

| Column | Type | Purpose |
|--------|------|---------|
| systemid | INT PK | Primary key |
| systemtype | VARCHAR | Targeted List, Maintenance List, Follow-Up, etc. |
| systemscope | VARCHAR | Industry, Casting Director, Personal, etc. |
| systemname | NVARCHAR | Display name |
| description | NVARCHAR | System description |
| isActive | BIT | Active flag |

### fusystemusers

| Column | Type | Purpose |
|--------|------|---------|
| fusystemuserid | INT PK | Primary key |
| systemid | INT FK | Parent system |
| userid | INT FK | User enrolled |
| contactid | INT FK | Contact enrolled |
| enrollmentdate | DATETIME | When enrolled |
| currentactionid | INT | Current action in sequence |
| status | VARCHAR | Active, Completed, Paused |
| nexttouchdate | DATE | Next scheduled action |

### funotifications (Generated by system actions)

| Column | Type | Purpose |
|--------|------|---------|
| notificationid | INT PK | Primary key |
| userid | INT FK | Owner user |
| contactid | INT FK | Related contact |
| actionid | INT FK | Source action |
| fusystemuserid | INT FK | System enrollment |
| notstartdate | DATE | When to show |
| notduedate | DATE | Due date |
| nottype | VARCHAR | Notification type |
| notstatus | VARCHAR | Pending, Completed, Skipped |
| nottext | NVARCHAR | Notification text |

---

## V2 Field Mappings

### Supported Import Fields

| Field Name | Type | Validation | Maps To |
|------------|------|------------|---------|
| firstName | text | Non-empty (if no fullName) | contactdetails.contactFullName part |
| lastName | text | Non-empty (if no fullName) | contactdetails.contactFullName part |
| contactFullName | text | Non-empty (if no first/last) | contactdetails.contactFullName |
| email_business | email | RFC format | contactitems (Email, Business) |
| email_personal | email | RFC format | contactitems (Email, Personal) |
| phone_work | phone | 10+ digits | contactitems (Phone, Work) |
| phone_mobile | phone | 10+ digits | contactitems (Phone, Mobile) |
| phone_home | phone | 10+ digits | contactitems (Phone, Home) |
| company | text | - | contactitems (Company, Company) |
| title | text | - | contactitems.valueTitle |
| address1 | text | - | contactitems.valueStreetAddress |
| address2 | text | - | contactitems.valueExtendedAddress |
| city | text | - | contactitems.valueCity |
| state | state | US state code | contactitems.valueRegion |
| zip | text | - | contactitems.valuePostalCode |
| country | text | - | contactitems.valueCountry |
| birthday | date | Valid date | contactdetails.birthday_mm, birthday_dd |
| relationship_start | date | Valid date | contactdetails.contactMeetingDate |
| website | url | URL format | contactitems (Social, Website) |
| linkedin | url | URL format | contactitems (Social, LinkedIn) |
| twitter | text | - | contactitems (Social, Twitter) |
| instagram | text | - | contactitems (Social, Instagram) |
| notes | textarea | - | contactitems (Note) |
| tags | tags | Comma-separated | contactitems (Tag) - multiple |
| category | select | casting, agent, manager, producer, director, other | contactdetails.category (needs column) |
| contactType | select | industry, personal, vendor | contactdetails.contactType (needs column) |

### Missing Fields (Not in V2) - RESOLVED

| Field | V1 Column | Purpose | Status |
|-------|-----------|---------|--------|
| maintenance_or_target | 21 | Relationship enrollment | IMPLEMENTED as `relationship_system` (Target/Maintenance) |
| contactMeetingLoc | 17 | Meeting location | Maps to `meetingLocation` |

### V2 Additional Fields (Added January 2026)

| Field Name | Type | Purpose | Maps To |
|------------|------|---------|---------|
| relationship_system | select | Enroll in Target or Maintenance list | fusystemusers enrollment |
| file_hash | varchar(64) | SHA-256 hash for duplicate detection | import_jobs.file_hash |

---

## Google Contacts CSV Mapping

| Google Field | TAO Field |
|--------------|-----------|
| Given Name | firstName |
| Family Name | lastName |
| Name | contactFullName |
| E-mail 1 - Type | (derive Business/Personal) |
| E-mail 1 - Value | email_business |
| E-mail 2 - Value | email_personal |
| Phone 1 - Type | (derive Work/Mobile/Home) |
| Phone 1 - Value | phone_work |
| Phone 2 - Value | phone_mobile |
| Phone 3 - Value | phone_home |
| Organization 1 - Name | company |
| Organization 1 - Title | title |
| Address 1 - Street | address1 |
| Address 1 - City | city |
| Address 1 - Region | state |
| Address 1 - Postal Code | zip |
| Address 1 - Country | country |
| Birthday | birthday |
| Notes | notes |
| Website 1 - Value | website |

---

## Apple Contacts vCard Mapping (IMPLEMENTED - January 2026)

VCF (vCard) files are now supported by `FileParserService.cfc`. The parser handles:
- RFC 6350 line folding (continuation lines starting with space/tab)
- Quoted-printable encoding with soft line breaks (`=\n`)
- Multiple EMAIL/TEL properties with type detection
- Blank-name contacts (generates warning, attempts name from email/org)

| vCard Field | TAO Field | Notes |
|-------------|-----------|-------|
| FN | fn (contactFullName) | Full name |
| N | n_family, n_given | Format: family;given;middle;prefix;suffix |
| EMAIL;type=WORK | email_work | First WORK email |
| EMAIL;type=HOME | email_home | First HOME email |
| TEL;type=WORK | tel_work | First WORK phone |
| TEL;type=CELL | tel_cell | Mobile/cell phone |
| TEL;type=HOME | tel_home | Home phone |
| ORG | org | Company (first component if semicolon-separated) |
| TITLE | title | Job title |
| ADR | adr_street, adr_city, adr_region, adr_postal, adr_country | Format: PO;ext;street;city;region;postal;country |
| BDAY | bday | Birthday (handles --MMDD and YYYYMMDD formats) |
| NOTE | note | Notes (escaped newlines decoded) |
| URL | url | Website |

### VCF Parser Internal Headers

The VCF parser uses these normalized headers:
```
fn, n_family, n_given, email_work, email_home,
tel_work, tel_cell, tel_home, org, title,
adr_street, adr_city, adr_region, adr_postal, adr_country,
bday, note, url
```

These map to TAO fields via `import_field_aliases` table entries.
