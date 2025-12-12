# TAO 1.0 Contacts Module - ContactItems Type/Category Map

**Generated:** 2025-11-30
**Purpose:** Complete mapping of valueType and valueCategory combinations for TAO 2.0 migration
**Scope:** All type/category combinations observed in code

---

## EXECUTIVE SUMMARY

TAO 1.0 uses an Entity-Attribute-Value (EAV) model in `contactitems` where:

- **valueCategory** = High-level category (Email, Phone, Address, Company, Tag, etc.)
- **valueType** = Specific type within category (Business, Personal, Work, Mobile, etc.)
- **Category determines field usage** - which value* columns are populated

This document maps all observed combinations, their business rules, and migration recommendations.

---

## TABLE OF CONTENTS

1. [Category-to-CatID Mapping](#1-category-to-catid-mapping)
2. [Category-Specific Field Usage](#2-category-specific-field-usage)
3. [Complete Type/Category Combinations](#3-complete-typecategory-combinations)
4. [Special Categories](#4-special-categories)
5. [Migration Recommendations](#5-migration-recommendations)

---

## 1. CATEGORY-TO-CATID MAPPING

### catid Values (inferred from include/remoteaddC.cfm)

| catid | valueCategory | catFieldSet | Fields Used | Add Form Section |
|-------|---------------|-------------|-------------|------------------|
| 1 | Phone | text | valuetext | Lines 123-130 |
| 2 | Address | address | valueStreetAddress, valueExtendedAddress, valueCity, valueRegion, valueCountry, valuePostalCode | Lines 132-183 |
| 4 | URL | text | valuetext | Lines 84-120 (url validation) |
| 5 | Social Profile | text | valuetext | Lines 84-120 (url validation) |
| 9 | Company | company | valueCompany, valueDepartment, valueTitle | Lines 193-227 |
| 10 | Email | text | valuetext | Lines 84-120 (email type) |
| 12 | Acting Links | text | valuetext | Lines 84-120 (url validation) |
| 13 | Important Date | text | itemDate | Lines 185-191 |
| (unknown) | Tag | text | valuetext | Not in add form (added via separate tag interface) |
| (unknown) | Profile | text | valuetext | Similar to Social Profile |

**Note:** catid values extracted from conditionals in include/remoteaddC.cfm. Some categories may have different catid values.

---

## 2. CATEGORY-SPECIFIC FIELD USAGE

### 2.1 TEXT CATEGORIES (catFieldSet = 'text')

**Categories:** Email, Phone, URL, Tag, Social Profile, Acting Links, Profile

**Fields used:**
- `valuetext` (PRIMARY - stores the actual value)
- `valueType` (type within category)
- `primary_yn` (one primary per category per contact)
- `itemStatus` ('Active', 'Pending', 'Inactive')

**Fields NULL/unused:**
- valueCompany, valueDepartment, valueTitle
- valueStreetAddress, valueExtendedAddress, valueCity, valueRegion, valueCountry, valuePostalCode
- itemDate (except Important Date category)
- itemNotes (rarely used)

**Business rules:**
- valuetext is REQUIRED
- Max length varies by category:
  - Email: 500 chars (valuetext column max)
  - Phone: 500 chars
  - URL: 500 chars (validated as URL format)
  - Tag: 40 chars (enforced by `LEFT(tagname, 40)` in queries)
  - Social Profile/Acting Links: 500 chars (URLs)

---

### 2.2 ADDRESS CATEGORY (catFieldSet = 'address')

**Category:** Address

**Fields used:**
- `valueStreetAddress` (street address line 1) - REQUIRED
- `valueExtendedAddress` (apt, suite, unit)
- `valueCity` (city/town)
- `valueRegion` (state/province/region) - REQUIRED
- `valueCountry` (country name, from lookup) - REQUIRED, defaults to 'US'
- `valuePostalCode` (zip/postal code)
- `valueType` (Business, Work, Home, etc.)
- `primary_yn`
- `itemStatus`

**Fields NULL/unused:**
- `valuetext` - NOT USED for addresses
- valueCompany, valueDepartment, valueTitle
- itemDate, itemNotes

**Business rules:**
- valueStreetAddress is REQUIRED (min 5 chars)
- valueRegion and valueCountry REQUIRED (dropdowns)
- Other address fields optional
- Country defaults to 'US'
- Region dropdown chained to Country selection (include/remoteaddC.cfm:239)

**Form handling:**
- include/remoteaddC.cfm lines 132-183
- include/remoteUpdateC.cfm (similar structure for edit)

---

### 2.3 COMPANY CATEGORY (catFieldSet = 'company')

**Category:** Company

**Fields used:**
- `valueCompany` (company name) - REQUIRED - **NOT valuetext!**
- `valueDepartment` (department/division)
- `valueTitle` (job title within company)
- `valueType` (always 'Company' - single type)
- `primary_yn`
- `itemStatus`

**Fields NULL/unused:**
- `valuetext` - **NOT USED** (company uses valueCompany instead)
- Address fields (valueStreetAddress, etc.)
- itemDate, itemNotes

**Business rules:**
- valueCompany is REQUIRED
- Dropdown pre-populated with existing companies (from include/qry/companies_198_4.cfm)
- User can select existing or add custom (option value="custom")
- valueDepartment and valueTitle are optional
- valueType always 'Company' (no variation)

**Form handling:**
- include/remoteaddC.cfm lines 193-227
- Select existing company OR enter custom
- Custom company via special toggle (toggleCustomField function)

**Migration note:** **CRITICAL INCONSISTENCY** - Company category uses valueCompany field while all other text categories use valuetext. Consider normalizing in TAO 2.0.

---

### 2.4 TAG CATEGORY (special case)

**Category:** Tag

**Fields used:**
- `valuetext` (tag name)
- `valueType` (always 'Tags')
- `valueCategory` (always 'Tag')
- `itemStatus` ('Active' only - no Inactive tags visible)

**Fields NULL/unused:**
- All other value* fields
- primary_yn - not applicable (no "primary tag")
- itemDate, itemNotes

**Business rules:**
- valueType always 'Tags' (singular type)
- valuetext stores tag name (max 40 chars enforced by queries)
- Tag names must match tags_user.tagname for Casting Director detection
- Tags NOT added via remoteaddC.cfm form - separate tag interface
- Special tags:
  - 'My Team' - adds contact to team view
  - Casting Director tags (from tags_user WHERE tagtype='C')

**Casting Director detection (ContactItemService.cfc:9-30):**
```
IF contact has tag in tags_user WHERE tagtype='C'
  THEN systemscope = 'Casting Director'
  ELSE systemscope = 'Industry'
```

**Tag operations:**
- Add: ContactItemService.addContactItemsTag() or addTeam()
- Delete: ContactItemService.DELcontactitems() (soft delete? or hard?)
- List: ContactItemService.SELcontactitems() WHERE valueCategory='Tag'

**Tag length enforcement:**
- Application: `LEFT(tagname, 40)` in queries
- Database: likely varchar(500) but truncated
- **Migration:** Add varchar(40) constraint or validation

---

### 2.5 IMPORTANT DATE CATEGORY (rare)

**Category:** (valueCategory unclear - possibly 'Important Date')

**Fields used:**
- `itemDate` (the actual date)
- `valueType` (type of date?)
- `valueCategory` (unknown - not visible in code)

**Form handling:**
- include/remoteaddC.cfm lines 185-191 (when new_catid eq "13")

**Usage:** Rarely referenced in code - possible feature flag or incomplete feature

**Migration note:** Clarify purpose or deprecate if unused

---

## 3. COMPLETE TYPE/CATEGORY COMBINATIONS

### 3.1 EMAIL (valueCategory = 'Email', catid = 10)

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Business | Primary business email | Default/common |
| Personal | Personal email | User-selectable |
| Work | Work email (synonym for Business?) | User-selectable |

**Field storage:**
- `valuetext` = email address
- `valueType` = Business/Personal/Work
- `primary_yn` = 'Y' for default email

**Business rules:**
- Email format validation (data-parsley-type="email" in forms)
- Used for duplicate detection (ContactImportValidationService.cfc)
- Used for contact lookup/matching
- contacts_ss view shows "first" email (col4) where primary_yn='Y' or itemStatus='Active'

**Form validation:**
- include/remoteaddC.cfm: valuefieldtype='email' when new_catid eq "10"
- Email format enforced by Parsley.js

**Duplicate detection:**
- include/qry/duplicatesByEmail.cfm:20 - `WHERE valueCategory='Email' AND valuetext=...`
- ContactDuplicateService.findDuplicatesByEmail() - matches by email valuetext

**Migration notes:**
- Standard email types - keep all three
- Consider adding validation for email format at DB level
- Clarify difference between Business and Work (synonyms?)

---

### 3.2 PHONE (valueCategory = 'Phone', catid = 1)

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Work | Work phone number | Common |
| Mobile | Mobile/cell phone | Common |
| mobile | Mobile (lowercase - INCONSISTENT) | Found in some queries |
| Home | Home phone | Less common |

**Field storage:**
- `valuetext` = phone number
- `valueType` = Work/Mobile/mobile/Home
- `primary_yn` = 'Y' for default phone

**Business rules:**
- Phone format validation (data-parsley-phone in forms)
- contacts_ss view shows "first" phone (col3) where primary_yn='Y'
- No standardized format (US vs international)

**Form validation:**
- include/remoteaddC.cfm lines 123-130
- data-parsley-phone validation (custom validator)
- Min/max length constraints

**Casing inconsistency:**
- **CRITICAL:** 'Mobile' vs 'mobile' found in code
- ContactItemService likely has both
- **Migration:** Standardize to 'Mobile' (title case)

**Migration notes:**
- Standardize casing: 'Mobile' not 'mobile'
- Keep Work, Mobile, Home
- Consider phone number formatting/normalization
- International phone number support?

---

### 3.3 ADDRESS (valueCategory = 'Address', catid = 2)

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Business | Business address | Common |
| Work | Work address (synonym for Business?) | Common |
| Home | Home address | Less common |

**Field storage (6 fields):**
- `valueStreetAddress` = street address line 1 (REQUIRED)
- `valueExtendedAddress` = apt, suite, unit
- `valueCity` = city/town
- `valueRegion` = state/province (REQUIRED)
- `valueCountry` = country name (REQUIRED, defaults 'US')
- `valuePostalCode` = zip/postal code
- `valueType` = Business/Work/Home
- `primary_yn` = 'Y' for default address

**Business rules:**
- valueStreetAddress REQUIRED (min 5 chars)
- valueRegion and valueCountry REQUIRED
- Country defaults to 'US'
- Region dropdown chained to Country (jquery.chained.js)
- Other fields optional

**Form handling:**
- include/remoteaddC.cfm lines 132-183
- Multi-field address form
- Country → Region cascading dropdowns
- include/qry/fetchLocationService.cfm - loads countries/regions

**Migration notes:**
- Consider separate address table (normalize out of EAV)
- Clarify Business vs Work (synonyms?)
- Validate international addresses
- Consider address verification/autocomplete in TAO 2.0

---

### 3.4 COMPANY (valueCategory = 'Company', catid = 9)

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Company | Only type for Company category | Default/only option |

**Field storage (3 fields):**
- `valueCompany` = company name (REQUIRED) - **NOT valuetext!**
- `valueDepartment` = department/division
- `valueTitle` = job title within company
- `valueType` = 'Company' (always)
- `primary_yn` = 'Y' for primary company

**Business rules:**
- valueCompany REQUIRED
- Pre-populated dropdown from existing companies (include/qry/companies_198_4.cfm)
- Option to add custom company
- valueDepartment and valueTitle optional
- No type variation (always 'Company')

**Form handling:**
- include/remoteaddC.cfm lines 193-227
- Dropdown with existing companies + "***ADD NEW***" option
- Custom company entry via special field (toggleCustomField)

**Display:**
- contacts_ss view - col5 shows first company (from valueCompany, not valuetext)
- sharez view:35 - `ci_company.valueCompany AS Company`

**Migration notes:**
- **CRITICAL DESIGN ISSUE:** Company uses valueCompany while Email/Phone use valuetext - inconsistent EAV model
- Consider normalizing: either all use valuetext, or create dedicated company table
- Single valueType ('Company') suggests this could be a separate table, not EAV

---

### 3.5 URL (valueCategory = 'URL', catid = 4)

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Company Website | Company/casting office website | Common |
| (others) | User-defined via itemtypes_user | Custom |

**Field storage:**
- `valuetext` = URL (REQUIRED)
- `valueType` = Company Website / custom types
- `primary_yn` = 'Y' for primary URL

**Business rules:**
- URL format validation (data-parsley-type="url")
- Must start with http:// or https://
- Pattern validation: no @ symbol (distinguish from email)
- Placeholder: "https://www.yourwebsite.com"

**Form validation:**
- include/remoteaddC.cfm lines 84-120
- data-parsley-type="url"
- data-parsley-pattern="^(?!.*@).*$" (no @ symbol)

**Migration notes:**
- Standard URL validation
- Consider storing protocol separately (http vs https)
- Link click tracking?

---

### 3.6 SOCIAL PROFILE (valueCategory = 'Social Profile', catid = 5)

**valueType values observed in code (from itemtypes_user):**

| valueType | Usage | Icon | Code References |
|-----------|-------|------|-----------------|
| Facebook | Facebook profile URL | fe-facebook | User-customizable |
| Twitter | Twitter profile URL | fe-twitter | User-customizable |
| Instagram | Instagram profile URL | fe-instagram | User-customizable |
| LinkedIn | LinkedIn profile URL | fe-linkedin | User-customizable |
| (custom) | Any social media user adds | Custom icon | Via itemtypes_user |

**Field storage:**
- `valuetext` = profile URL (REQUIRED)
- `valueType` = Facebook/Twitter/Instagram/LinkedIn/custom (from itemtypes_user)
- `primary_yn` = 'Y' for primary profile?

**Business rules:**
- valueType defined in itemtypes_user table (user-customizable)
- Each user can define which social media types they track
- Icons from itemtypes_user.typeIcon
- URL format validation (https://)

**Form handling:**
- include/remoteaddC.cfm lines 84-120
- Dropdown populated from itemtypes_user WHERE userid=:userid
- Icon display via ContactItemService.getSocialIcons()

**Display:**
- include/contact_pane.cfm - Icons displayed alongside profile links
- Clickable links to social profiles

**Migration notes:**
- User-customizable social media types = good flexibility
- Consider pre-seeding common types (Facebook, Twitter, Instagram, LinkedIn, TikTok, YouTube)
- Icon handling via itemtypes_user works well - keep pattern

---

### 3.7 ACTING LINKS (valueCategory = 'Acting Links', catid = 12)

**valueType values observed in code (from itemtypes_user):**

| valueType | Usage | Icon | Code References |
|-----------|-------|------|-----------------|
| IMDb | IMDb profile URL | Custom | User-customizable |
| Actors Access | Actors Access profile | Custom | User-customizable |
| Backstage | Backstage profile | Custom | User-customizable |
| Casting Networks | Casting Networks profile | Custom | User-customizable |
| (custom) | Other casting platforms | Custom icon | Via itemtypes_user |

**Field storage:**
- `valuetext` = profile URL (REQUIRED)
- `valueType` = IMDb/Actors Access/custom (from itemtypes_user)
- `primary_yn` = 'Y' for primary acting profile?

**Business rules:**
- Similar to Social Profile but for acting/casting platforms
- valueType defined in itemtypes_user (user-customizable)
- URL format validation

**Form handling:**
- include/remoteaddC.cfm lines 84-120
- Same pattern as Social Profile

**Migration notes:**
- Industry-specific category - important for actors
- Consider pre-seeding common types
- IMDb integration possibilities?

---

### 3.8 PROFILE (valueCategory = 'Profile')

**valueType values:** (Similar to Acting Links - user-defined)

**Purpose:** Unclear distinction from Social Profile and Acting Links

**Field storage:**
- `valuetext` = profile URL
- `valueType` = from itemtypes_user

**Business rules:**
- User-customizable via itemtypes_user

**Migration note:** **CLARIFICATION NEEDED** - What's the difference between Profile, Social Profile, and Acting Links? Consider consolidating.

---

### 3.9 TAG (valueCategory = 'Tag')

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Tags | Only type for Tag category | ContactItemService.cfc:42 (INSERT) |

**Field storage:**
- `valuetext` = tag name (max 40 chars)
- `valueType` = 'Tags' (always)
- `valueCategory` = 'Tag'

**Business rules:**
- valueType always 'Tags' (no variation)
- Tag names must be unique per contact (no duplicate tags)
- Tag names in tags_user define special behavior:
  - tagtype='C' → Casting Director tag → affects relationship system scope
  - 'My Team' → adds to team view
  - 'My Rep Team' → agent/representative designation

**Special tag handling:**

**'My Team' tag:**
- ContactItemService.addTeam() - adds 'My Team' tag
- ContactItemService.deleteTeam() - removes 'My Team' tag (HARD DELETE - line 67)
- Used to filter ContactService.GetMyTeam() - team view
- Can only be added once per contact (duplicate check)

**Casting Director tags:**
- Defined in tags_user WHERE tagtype='C'
- ContactItemService.getContactTagStatus() - determines scope
- If contact has CD tag → systemscope='Casting Director' → Targeting/Follow-Up systems
- Else → systemscope='Industry' → different system workflows

**Tag length:**
- Enforced by `LEFT(tagname, 40)` in queries
- Database likely varchar(500) but truncated in application

**Tag add/delete:**
- Add: ContactItemService.addContactItemsTag(), addTeam()
- Delete: ContactItemService.DELcontactitems(), deleteTeam()
- List: ContactItemService.SELcontactitems() WHERE valueCategory='Tag'

**Migration notes:**
- **CRITICAL:** Tag business logic is core to relationship system workflows
- Ensure tags_user.tagtype='C' mapping migrates correctly
- Fix HARD DELETE in deleteTeam() - should soft delete
- Add varchar(40) constraint
- Consider separate tag table (many-to-many) vs EAV

---

## 4. SPECIAL CATEGORIES

### 4.1 Relationship (Synthetic Category)

**Not a real contactitems category** - added by ContactItemService in queries

**Purpose:** Display relationship systems in contact item lists

**Code reference:**
- ContactItemService.cfc:123 - `SELECT 'Relationship' AS valueCategory, 'fe-users' AS caticon, 'text' AS catFieldSet`
- UNION with actual categories

**Migration note:** Synthetic category for UI purposes only - not stored in contactitems

---

## 5. MIGRATION RECOMMENDATIONS

### 5.1 Standardization Required

**1. Casing inconsistencies:**
- valueType: 'Mobile' vs 'mobile' → standardize to 'Mobile'
- itemStatus: 'Active' vs 'active' → standardize to 'Active'
- IsDeleted vs isdeleted → standardize to 'IsDeleted'

**2. Synonym clarification:**
- Email: 'Business' vs 'Work' - are these the same?
- Address: 'Business' vs 'Work' - are these the same?
- Company: only 'Company' type - why have valueType at all?

**3. Add constraints:**
- valueType FK to itemtypes OR itemtypes_user
- valueCategory FK to itemcategory.valueCategory
- CHECK constraints for itemStatus ('Active', 'Pending', 'Inactive')
- Tag max length 40 chars

---

### 5.2 Schema Normalization Options

**Option A: Keep EAV, fix inconsistencies**
- Pros: Flexible, user-customizable
- Cons: Complex queries, hard to enforce constraints
- Changes:
  - Company uses valuetext (not valueCompany)
  - Add FK constraints
  - Add indexed views for performance

**Option B: Normalize core categories**
- Separate tables for:
  - contact_emails (id, contactid, email, type, is_primary)
  - contact_phones (id, contactid, phone, type, is_primary)
  - contact_addresses (id, contactid, street1, street2, city, region, country, postal, type, is_primary)
  - contact_companies (id, contactid, company, department, title, is_primary)
  - contact_tags (many-to-many: contact_id, tag_id)
- Keep EAV for custom/rare categories (URL, Social Profile, Acting Links)
- Pros: Better performance, constraints, indexing
- Cons: More tables, less flexible

**Option C: Hybrid approach**
- Core categories (Email, Phone, Company) → dedicated tables
- Flexible categories (Social Profile, Acting Links, URL) → EAV
- Tags → many-to-many table
- Address → separate table with full address model
- Pros: Best of both worlds
- Cons: More complex migration

**Recommendation:** **Option C - Hybrid approach** for optimal performance and flexibility

---

### 5.3 Type/Category Matrix Validation

**Create reference data for valid combinations:**

```sql
CREATE TABLE contactitem_valid_types (
  valuecategory VARCHAR(100),
  valuetype VARCHAR(100),
  is_deprecated BIT DEFAULT 0,
  notes TEXT,
  PRIMARY KEY (valuecategory, valuetype)
);

-- Seed valid combinations
INSERT INTO contactitem_valid_types VALUES
  ('Email', 'Business', 0, 'Business email'),
  ('Email', 'Personal', 0, 'Personal email'),
  ('Email', 'Work', 0, 'Work email - synonym for Business?'),
  ('Phone', 'Work', 0, 'Work phone'),
  ('Phone', 'Mobile', 0, 'Mobile phone'),
  ('Phone', 'mobile', 1, 'DEPRECATED - use Mobile'),
  ('Phone', 'Home', 0, 'Home phone'),
  ('Address', 'Business', 0, 'Business address'),
  ('Address', 'Work', 0, 'Work address'),
  ('Address', 'Home', 0, 'Home address'),
  ('Company', 'Company', 0, 'Only valid type'),
  ('URL', 'Company Website', 0, 'Company website URL'),
  ('Tag', 'Tags', 0, 'Only valid type'),
  ... (Social Profile, Acting Links from itemtypes_user)
;
```

**Enforce via FK:**
```sql
ALTER TABLE contactitems
ADD CONSTRAINT fk_contactitems_valid_type
FOREIGN KEY (valuecategory, valuetype)
REFERENCES contactitem_valid_types(valuecategory, valuetype);
```

---

### 5.4 Migration Script Priorities

**Phase 1: Data cleanup**
1. Standardize casing (Mobile, Active, etc.)
2. Merge synonyms (Business vs Work - user choice or auto-merge?)
3. Fix Company category (migrate valueCompany → valuetext OR keep as-is with documentation)
4. Truncate tags to 40 chars (or expand limit)

**Phase 2: Schema updates**
5. Add FK constraints (valueCategory → itemcategory)
6. Add CHECK constraints (itemStatus)
7. Add unique constraint on primary_yn
8. Add indexes per rebuild_sharez_view.sql recommendations

**Phase 3: Normalization (if Option B or C chosen)**
9. Create dedicated tables (contact_emails, contact_phones, etc.)
10. Migrate data from contactitems to new tables
11. Update application code to use new tables
12. Drop old contactitems EAV data (or keep for legacy)

**Phase 4: Testing**
13. Test all type/category combinations
14. Test primary_yn enforcement
15. Test tag-based system scope detection
16. Test contacts_ss view performance

---

## 6. COMPLETE TYPE/CATEGORY REFERENCE TABLE

| valueCategory | valueType | Fields Used | Required | Primary | Status | Notes |
|---------------|-----------|-------------|----------|---------|--------|-------|
| Email | Business | valuetext | Yes | Supported | Active | Primary business email |
| Email | Personal | valuetext | Yes | Supported | Active | Personal email |
| Email | Work | valuetext | Yes | Supported | Active | Work email (synonym for Business?) |
| Phone | Work | valuetext | Yes | Supported | Active | Work phone |
| Phone | Mobile | valuetext | Yes | Supported | Active | Mobile/cell phone |
| Phone | mobile | valuetext | Yes | Supported | **DEPRECATED** | Casing inconsistency - standardize to Mobile |
| Phone | Home | valuetext | Yes | Supported | Active | Home phone |
| Address | Business | 6 address fields | valueStreetAddress req | Supported | Active | Business address |
| Address | Work | 6 address fields | valueStreetAddress req | Supported | Active | Work address |
| Address | Home | 6 address fields | valueStreetAddress req | Supported | Active | Home address |
| Company | Company | valueCompany, valueDepartment, valueTitle | valueCompany req | Supported | Active | Only type - uses valueCompany NOT valuetext |
| URL | Company Website | valuetext | Yes | Supported | Active | Company/office website |
| URL | (custom) | valuetext | Yes | Supported | Active | User-defined via itemtypes_user |
| Social Profile | Facebook | valuetext | Yes | Supported | Active | Facebook profile URL |
| Social Profile | Twitter | valuetext | Yes | Supported | Active | Twitter profile URL |
| Social Profile | Instagram | valuetext | Yes | Supported | Active | Instagram profile URL |
| Social Profile | LinkedIn | valuetext | Yes | Supported | Active | LinkedIn profile URL |
| Social Profile | (custom) | valuetext | Yes | Supported | Active | User-defined via itemtypes_user |
| Acting Links | IMDb | valuetext | Yes | Supported | Active | IMDb profile URL |
| Acting Links | Actors Access | valuetext | Yes | Supported | Active | Actors Access profile |
| Acting Links | Backstage | valuetext | Yes | Supported | Active | Backstage profile |
| Acting Links | Casting Networks | valuetext | Yes | Supported | Active | Casting Networks profile |
| Acting Links | (custom) | valuetext | Yes | Supported | Active | User-defined via itemtypes_user |
| Profile | (custom) | valuetext | Yes | Supported | **UNCLEAR** | Purpose unclear - consolidate with Social Profile? |
| Tag | Tags | valuetext | Yes | **N/A** | Active | Only type - max 40 chars |
| Tag | 'My Team' | valuetext='My Team' | Yes | N/A | Active | Special tag - team view filter |
| Tag | (CD tags) | valuetext=tagname from tags_user | Yes | N/A | Active | Casting Director tags - affects system scope |

---

## 7. TAG NAMES WITH SPECIAL BEHAVIOR

| Tag Name | Source | Special Behavior | Code References |
|----------|--------|------------------|-----------------|
| 'My Team' | User-added | Adds contact to team view | ContactItemService.addTeam(), deleteTeam() |
| 'My Rep Team' | User-added | Agent/representative designation | ContactService.GetMyTeam() (implied) |
| _(Any CD tag)_ | tags_user WHERE tagtype='C' | Sets systemscope='Casting Director' → enables Targeting/Follow-Up systems | ContactItemService.getContactTagStatus() |
| _(Other tags)_ | User-added | Sets systemscope='Industry' → different system workflows | ContactItemService.getContactTagStatus() |

**Casting Director Tag Examples (likely in tags_user):**
- 'Casting Director'
- 'CD'
- 'Casting Associate'
- (User-defined tags with tagtype='C')

---

## 8. CATID REFERENCE (for form handling)

| catid | valueCategory | Form Section | Validation |
|-------|---------------|--------------|------------|
| 1 | Phone | remoteaddC.cfm:123-130 | data-parsley-phone |
| 2 | Address | remoteaddC.cfm:132-183 | Street required (min 5), Region required, Country required |
| 4 | URL | remoteaddC.cfm:84-120 | data-parsley-type="url", no @ symbol |
| 5 | Social Profile | remoteaddC.cfm:84-120 | data-parsley-type="url" |
| 9 | Company | remoteaddC.cfm:193-227 | Company name required |
| 10 | Email | remoteaddC.cfm:84-120 | data-parsley-type="email" |
| 12 | Acting Links | remoteaddC.cfm:84-120 | data-parsley-type="url" |
| 13 | Important Date | remoteaddC.cfm:185-191 | data-parsley-type="date" |
| _(unknown)_ | Tag | Separate tag interface | Max 40 chars |

---

## 9. UNUSED OR AMBIGUOUS CATEGORIES

**Profile category:**
- Purpose unclear
- Distinct from Social Profile and Acting Links?
- **Recommendation:** Clarify use case or consolidate with Social Profile

**Important Date category (catid 13):**
- Rarely referenced
- Uses itemDate field (uncommon)
- **Recommendation:** Verify usage or deprecate

---

## END OF TYPE/CATEGORY MAP

**Summary Statistics:**
- **Core Categories:** 9 (Email, Phone, Address, Company, URL, Social Profile, Acting Links, Profile, Tag)
- **Email Types:** 3 (Business, Personal, Work)
- **Phone Types:** 4 (Work, Mobile, mobile-deprecated, Home)
- **Address Types:** 3 (Business, Work, Home)
- **Company Types:** 1 (Company)
- **URL Types:** 1+ (Company Website + custom)
- **Social Profile Types:** 4+ (Facebook, Twitter, Instagram, LinkedIn + custom)
- **Acting Links Types:** 4+ (IMDb, Actors Access, Backstage, Casting Networks + custom)
- **Tag Types:** 1 (Tags)
- **User-customizable:** Social Profile, Acting Links, Profile (via itemtypes_user)

**Migration Priorities:**
1. **HIGH:** Standardize casing (Mobile, Active)
2. **HIGH:** Fix Company category field inconsistency (valueCompany vs valuetext)
3. **HIGH:** Add FK constraints (valueCategory, valueType)
4. **MEDIUM:** Clarify synonyms (Business vs Work)
5. **MEDIUM:** Normalize schema (Option C recommended)
6. **LOW:** Deprecate unused categories (Profile?, Important Date?)

**Next Documentation File:** tao1_contacts_feature_map.md
