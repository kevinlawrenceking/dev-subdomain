# Contact Duplicate Management Tool

## Overview

The Contact Duplicate Management Tool is designed to help users identify and merge duplicate contact records within the TAO Relationship System. This tool maintains data integrity while consolidating relationship information, appointments, notes, and other associated data.

## Features

### Duplicate Detection
- **Name-based Detection**: Finds contacts with identical first and last names
- **Email-based Detection**: Identifies contacts sharing the same email address
- Excludes deleted records automatically
- User-scoped (only shows duplicates for the current user)

### Merge Process
1. **Primary Contact Selection**: User selects which contact record to keep
2. **Field Value Resolution**: For conflicting field values, user chooses which value to retain
3. **Data Consolidation**: Automatically merges:
   - Contact items (email, phone, etc.) - removes exact duplicates
   - Notes and appointments
   - Relationship systems and notifications
   - Tags (removes duplicate tag assignments)
4. **Safe Deletion**: Marks duplicate contact as `isdeleted = 1`

## File Structure

```
app/contact-duplicates/
├── index.cfm                    # Main interface
include/
├── merge_contacts_interface.cfm # Modal merge interface
├── qry/
│   ├── duplicatesByName.cfm     # Name-based duplicate query
│   └── duplicatesByEmail.cfm    # Email-based duplicate query
services/
└── ContactDuplicateService.cfc  # Core service logic
```

## Access

Navigate to: `/app/contact-duplicates/`

Or add this link to your contacts interface:
```html
<a href="/app/contact-duplicates/" class="btn btn-warning btn-sm">
    <i class="fe-shuffle"></i> Manage Duplicates
</a>
```

## Usage

1. **Access the Tool**: Navigate to the duplicate management page
2. **Choose Detection Method**: Select "Duplicates by Name" or "Duplicates by Email" tab
3. **Review Results**: View potential duplicates with count indicators
4. **Initiate Merge**: Click "Merge" button for a duplicate group
5. **Select Primary**: Choose which contact to keep as the primary record
6. **Resolve Conflicts**: For fields with different values, select preferred value
7. **Complete Merge**: Confirm to execute the merge operation

## Safety Features

- **Transaction Wrapped**: All merge operations are database transaction-protected
- **Validation**: Ensures minimum 2 contacts before allowing merge
- **Confirmation**: Requires user confirmation before executing merge
- **Error Handling**: Comprehensive error catching with rollback capability
- **Data Preservation**: Moves all related data before marking duplicate as deleted

## Technical Details

### Database Operations
- Uses `GROUP_CONCAT` for efficient duplicate identification
- Employs careful JOIN logic to avoid data loss during merge
- Handles NULL values appropriately in merge decisions
- Maintains referential integrity across all related tables

### Performance Considerations
- Queries are optimized with proper indexing requirements
- Uses DataTables for efficient large dataset handling
- AJAX loading for responsive interface
- Limited result sets to prevent browser overload

## Related Tables
- `contactdetails` - Primary contact information
- `contactitems` - Email, phone, addresses
- `contactnotes` - User notes
- `events` - Appointments
- `fusystemusers` - Relationship systems
- `funotifications` - Reminders and notifications
- `tagsuser` - Contact tags

## Error Handling
- Service layer returns structured response with success/failure status
- User-friendly error messages for common issues
- Detailed logging for troubleshooting
- Graceful degradation for partial failures
