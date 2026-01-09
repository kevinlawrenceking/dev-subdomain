# Appendix B: Import Edge Cases

## File Format Edge Cases

### CSV Parsing

| Edge Case | Input Example | V1 Behavior | V2 Behavior | Recommended |
|-----------|---------------|-------------|-------------|-------------|
| Quoted commas | `"Smith, John",email@test.com` | N/A (XLSX only) | Parsed correctly | Keep V2 |
| Embedded newlines | `"Line 1\nLine 2"` | N/A | Parsed correctly | Keep V2 |
| Unclosed quotes | `"Partial quote,email` | N/A | Parses with warning | Keep V2 |
| Mixed line endings | CR, LF, CRLF | N/A | Handles all | Keep V2 |
| UTF-8 BOM | `\xEF\xBB\xBF...` | N/A | Detected, stripped | Keep V2 |
| UTF-16 files | Unicode encoded | N/A | Detected | Keep V2 |
| Tab delimiter | `John\tDoe\temail` | N/A | Auto-detected | Keep V2 |
| Semicolon delimiter | `John;Doe;email` | N/A | Auto-detected | Keep V2 |
| Empty file | 0 bytes | Error | Error message | Keep V2 |
| Header only | 1 row | No data imported | 0 rows, success | Keep V2 |
| No header | Data starts row 1 | Assumes header | Option available | Keep V2 |

### Excel Parsing

| Edge Case | Input Example | V1 Behavior | V2 Behavior | Recommended |
|-----------|---------------|-------------|-------------|-------------|
| Date serial number | 44562 (Excel date) | Stored as number | Attempts conversion | Improve conversion |
| Formula cell | `=A1+B1` | Stores result | Stores result | Keep |
| Empty cells | Blank | Stored as empty | Stored as empty | Keep |
| Merged cells | Spanning A1:B2 | First cell only | First cell only | Document limitation |
| Multiple sheets | Sheet1, Sheet2 | First sheet only | First sheet (configurable) | Keep V2 |
| Hidden rows | Row hidden in Excel | Included | Included | Consider skipping |
| Very long text | 10,000+ chars | Truncated silently | May error | Add limit warning |
| Password protected | Encrypted | Fails silently | Fails with message | Keep V2 |

---

## Data Validation Edge Cases

### Name Fields

| Edge Case | Input | V1 Behavior | V2 Behavior | Recommended |
|-----------|-------|-------------|-------------|-------------|
| First name only | `John, ` | Creates "John " | Validates, warns | Keep V2 |
| Last name only | `, Doe` | Creates " Doe" | Validates, warns | Keep V2 |
| Full name only | `John Doe` | N/A (uses first+last) | Accepts fullName | Keep V2 |
| Very long name | 500+ characters | Stored, may truncate | Should warn | Add length check |
| Unicode name | `Jean-Pierre` | Works | Works | Keep |
| Emoji in name | `John 😀 Doe` | Stored | Stored | Consider stripping |
| All caps | `JOHN DOE` | Stored as-is | Stored as-is | Consider normalizing |
| Leading/trailing spaces | `  John  ` | Stored with spaces | Trimmed | Keep V2 |
| Multiple spaces | `John    Doe` | Stored | Stored | Consider normalizing |
| Empty name | ` ` | Created empty | Error | Keep V2 |

### Email Fields

| Edge Case | Input | V1 Behavior | V2 Behavior | Recommended |
|-----------|-------|-------------|-------------|-------------|
| Valid email | `john@example.com` | Stored | Stored | Keep |
| Multiple emails | `a@b.com, c@d.com` | Stores first | Parses first, warns | Keep V2 |
| Invalid format | `john@` | Stored | Error | Keep V2 |
| Spaces in email | `john @example.com` | Stored | Error after trim | Keep V2 |
| Very long email | 254+ chars | Stored | Should warn | Add length check |
| Case sensitivity | `John@Example.COM` | Stored as-is | Lowercased for matching | Keep V2 |
| Plus addressing | `john+tag@gmail.com` | Stored | Stored | Keep |
| IDN domain | `john@exämple.com` | May fail | May fail | Test needed |

### Phone Fields

| Edge Case | Input | V1 Behavior | V2 Behavior | Recommended |
|-----------|-------|-------------|-------------|-------------|
| 10 digits | `5551234567` | Stored | Formatted | Keep V2 |
| With formatting | `(555) 123-4567` | Stored as-is | Normalized | Keep V2 |
| International | `+1 555 123 4567` | Stored | Strips +1 | Keep V2 |
| Too short | `555123` | Stored | Warning | Keep V2 |
| Too long | `15551234567890` | Stored | Warning | Keep V2 |
| Letters | `555-GET-HELP` | Stored | Warning | Consider converting |
| Extension | `555-123-4567 x123` | Stored | May parse incorrectly | Improve parsing |
| Multiple phones | `555-1234, 555-5678` | First only | First only | Document |

### Date Fields

| Edge Case | Input | V1 Behavior | V2 Behavior | Recommended |
|-----------|-------|-------------|-------------|-------------|
| MM/DD/YYYY | `12/25/2025` | Parsed | Parsed | Keep |
| YYYY-MM-DD | `2025-12-25` | May fail | Parsed | Keep V2 |
| DD/MM/YYYY | `25/12/2025` | Wrong date | May be wrong | Add locale option |
| Invalid date | `02/30/2025` | Stored | Error | Keep V2 |
| Future date | `01/01/2099` | Stored | Warning | Add warning |
| Very old date | `01/01/1800` | Stored | Warning | Add warning |
| Text date | `December 25` | Stored as text | May fail | Improve parsing |
| Excel serial | `44555` | Stored as number | Attempts conversion | Improve |

### Address Fields

| Edge Case | Input | V1 Behavior | V2 Behavior | Recommended |
|-----------|-------|-------------|-------------|-------------|
| Long address | 500+ chars | Stored, may truncate | Should warn | Add limit |
| PO Box | `PO Box 123` | Stored | Stored | Keep |
| International | Non-US format | Stored | Stored | Keep |
| State code | `CA` | Stored | Validated | Keep V2 |
| Full state name | `California` | Stored | Should convert | Improve |
| Invalid state | `ZZ` | Stored | Warning | Keep V2 |
| ZIP+4 | `90210-1234` | Stored | Stored | Keep |
| Unicode address | `123 Rue de Paris` | Stored | Stored | Keep |

---

## Duplicate Detection Edge Cases

### Email Matching

| Scenario | Import | Existing | Match Score | Expected |
|----------|--------|----------|-------------|----------|
| Exact match | `john@test.com` | `john@test.com` | 50 | Flag duplicate |
| Case difference | `John@Test.com` | `john@test.com` | 50 | Flag duplicate |
| Plus addressing | `john+work@gmail.com` | `john@gmail.com` | 0 | No match (correct) |
| Typo | `jhon@test.com` | `john@test.com` | 0 | No match (correct) |
| Different domain | `john@test.com` | `john@other.com` | 0 | No match (correct) |

### Phone Matching

| Scenario | Import | Existing | Match Score | Expected |
|----------|--------|----------|-------------|----------|
| Exact match | `5551234567` | `5551234567` | 40 | Flag duplicate |
| Different format | `(555) 123-4567` | `555-123-4567` | 40 | Flag duplicate |
| With country code | `+1 555 123 4567` | `5551234567` | 40 | Flag duplicate |
| Partial match | `5551234567` | `555123` | 0 | No match |
| Typo | `5551234567` | `5551234568` | 0 | No match |

### Name Matching

| Scenario | Import | Existing | Match Score | Expected |
|----------|--------|----------|-------------|----------|
| Exact match | `John Doe` | `John Doe` | 30 | Flag potential |
| Case difference | `JOHN DOE` | `John Doe` | 30 | Flag potential |
| Middle name | `John A. Doe` | `John Doe` | 0 | No match (correct?) |
| Nickname | `Johnny Doe` | `John Doe` | 0 | No match (correct) |
| Reversed | `Doe, John` | `John Doe` | 0 | No match (consider) |
| Common name | `John Smith` | `John Smith` (different person) | 30 | Flag (may be false positive) |

### Combined Matching

| Scenario | Email Match | Phone Match | Name Match | Total Score | Expected |
|----------|-------------|-------------|------------|-------------|----------|
| Definite dupe | Yes (50) | Yes (40) | Yes (30) | 120 | Auto-skip |
| Likely dupe | Yes (50) | No | No | 50 | Flag, review |
| Possible dupe | No | No | Yes (30) + Company (25) | 55 | Flag, review |
| Unlikely dupe | No | No | Yes (30) | 30 | Import with warning |
| Different | No | No | No | 0 | Import |

---

## Large File Edge Cases

| Scenario | Row Count | V1 Behavior | V2 Behavior | Recommended |
|----------|-----------|-------------|-------------|-------------|
| Small file | 10 rows | OK | OK | Keep |
| Medium file | 1,000 rows | OK | OK | Keep |
| Large file | 10,000 rows | Slow, may timeout | Slow, may timeout | Add chunking |
| Very large | 50,000 rows | Likely fails | Likely fails | Add chunking + progress |
| Huge file | 100,000+ rows | Fails | Fails | Background job needed |

### Memory Concerns

| File Size | Rows | Memory Est. | Risk |
|-----------|------|-------------|------|
| 1 MB | ~5,000 | 50 MB | Low |
| 10 MB | ~50,000 | 500 MB | Medium |
| 50 MB | ~250,000 | 2.5 GB | High (limit hit) |

---

## Security Edge Cases

### Injection Attacks

| Attack | Input | V1 Risk | V2 Risk | Mitigation |
|--------|-------|---------|---------|------------|
| SQL injection | `'; DROP TABLE--` | HIGH (unparameterized) | LOW (cfqueryparam) | Fix V1 |
| XSS | `<script>alert(1)</script>` | Medium | LOW (escaped output) | Keep V2 |
| Formula injection | `=HYPERLINK("http://evil")` | N/A | LOW (text only) | Keep V2 |
| Path traversal | `../../etc/passwd` | LOW | LOW | Keep validation |
| Shell injection | `$(rm -rf /)` | LOW | LOW | Keep validation |

### File Upload Attacks

| Attack | Method | V1 Protection | V2 Protection | Mitigation |
|--------|--------|---------------|---------------|------------|
| Large file DoS | 1GB upload | 50MB limit | 50MB limit | Keep |
| Malicious Excel | Macro-enabled | Extension check | Extension check | Keep |
| Polyglot file | Excel+HTML | Extension check | Extension + magic bytes | Keep V2 |
| Filename attack | `../../../etc/passwd` | MAKEUNIQUE | MAKEUNIQUE | Keep |

---

## Business Logic Edge Cases

### Import + Relationship Enrollment

| Scenario | V1 Behavior | V2 Behavior | Impact |
|----------|-------------|-------------|--------|
| Target + Casting Director tag | Enrolls in CD Target system | Does not enroll | V2 broken |
| Target + no tag | Enrolls in Industry Target system | Does not enroll | V2 broken |
| Maintenance + CD tag | Enrolls in CD Maintenance | Does not enroll | V2 broken |
| No system specified | No enrollment | No enrollment | OK |
| Invalid system type | No enrollment | N/A | OK |

### Duplicate Resolution

| User Action | Expected Result | V2 Behavior |
|-------------|-----------------|-------------|
| Skip | Row not imported | Correct |
| Import New | New contact created | Correct |
| Update Existing | Merge data | Not implemented |
| Merge | Manual field selection | Not implemented |

---

## Recommended Test Cases

### Critical Path Tests

1. Import 10-row CSV with valid data
2. Import 100-row XLSX with mixed valid/invalid
3. Import Google Contacts export (no modifications)
4. Import file with exact duplicate email
5. Import file with relationship system specified

### Edge Case Tests

1. CSV with BOM + semicolon delimiter
2. Excel with date columns (verify formatting)
3. 5000+ row file (verify timeout handling)
4. Unicode names and addresses
5. Empty required fields
6. Multiple emails in single cell

### Security Tests

1. SQL injection in name field (verify parameterization)
2. XSS in company name (verify escaping in UI)
3. 51MB file upload (verify rejection)
4. Formula in CSV cell (verify text treatment)

---

## Known Limitations to Document for Users

1. **Maximum file size:** 50MB
2. **Maximum recommended rows:** 5,000 (larger may be slow)
3. **Date formats:** MM/DD/YYYY or YYYY-MM-DD preferred
4. **Phone numbers:** US 10-digit format expected
5. **Multiple values:** Only first email/phone per type imported
6. **Tags:** Comma-separated, imported as individual tags
7. **Relationship systems:** Must be spelled exactly ("Target" or "Maintenance")
8. **Duplicate detection:** Based on email (primary), phone, name
