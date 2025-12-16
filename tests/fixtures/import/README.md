# Contact Import V2 Test Fixtures

Test files for validating the Contact Import V2 parser and validation services.

## CSV Test Files

### valid_contacts.csv
Standard well-formed CSV with all required fields. Use as baseline for testing.

### bad_quotes.csv
CSV with various quoting errors:
- Missing end quotes
- Nested quotes (escaped and unescaped)
- Quotes in middle of fields
- Mismatched quotes
Tests parser's quote handling tolerance.

### mixed_delimiters.csv
File with mixed delimiters (comma, semicolon, tab) within same file.
Tests parser's delimiter detection and handling of edge cases.

### semicolon_delimited.csv
European-style CSV using semicolons as delimiter.
Tests delimiter auto-detection.

### tab_delimited.csv
Tab-separated values file.
Tests delimiter auto-detection for TSV files.

### utf8_with_bom.csv
UTF-8 file with special characters:
- Spanish: José, García
- German: Müller, München
- Chinese: 中文, 北京
- Greek: Αλέξανδρος
Tests encoding detection and Unicode handling.

### embedded_newlines.csv
CSV with newline characters inside quoted fields.
Tests proper handling of multi-line field values.

### varying_columns.csv
CSV where rows have different numbers of columns.
Tests handling of:
- Rows with fewer columns than header
- Rows with more columns than header

### validation_errors.csv
CSV with various validation errors:
- Invalid email formats
- Invalid phone numbers
- Missing required fields (name)
- Invalid URLs
Tests field-level validation.

### duplicates.csv
CSV with rows that might be duplicates:
- Same email, different phone
- Same phone, different email
- Similar names with variations
Tests duplicate detection scoring.

### empty_file.csv
Completely empty file (0 bytes).
Tests handling of empty input.

### header_only.csv
File with header row but no data rows.
Tests handling of empty datasets.

### unusual_headers.csv
CSV with non-standard header names:
- FIRST_NAME (uppercase, underscore)
- E-Mail Address (with hyphen)
- Phone Number (with space)
- Company / Organization (with special chars)
Tests column auto-mapping with fuzzy matching.

### date_formats.csv
CSV with various date formats:
- ISO: 1985-03-15
- US: 03/20/1990
- Written: March 5 1988
- Short year: 5/10/92
- Year only: 2018
- No delimiter: 19850315
- Invalid: invalid-date
Tests date parsing and normalization.

### phone_formats.csv
CSV with various phone formats:
- Parentheses: (555) 123-4567
- Dashes only: 555-123-4567
- No delimiter: 5551234567
- Dots: 555.123.4567
- International: +1-555-123-4567
- Spaces: 555 123 4567
- Too short: 123-4567
- Invalid: abcdefghij
Tests phone normalization and validation.

## Usage

These files can be used for:
1. Unit testing FileParserService.cfc
2. Unit testing ValidationService.cfc
3. Integration testing the full import flow
4. Manual QA testing

## Expected Behavior

The importer should:
1. NEVER crash on malformed input
2. Capture errors per-cell, not per-file
3. Auto-detect delimiters and encodings
4. Provide helpful error messages
5. Allow users to fix issues in the review grid
