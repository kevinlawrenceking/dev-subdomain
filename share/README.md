# Share Module Documentation

## Overview

The TAO Share Module allows actors to share specific content (relationships, calendar) with their managers, agents, and collaborators through secure, unique links without requiring password authentication.

## Architecture

The Share Module runs as an independent application within the `/share` directory, but efficiently reuses resources from the main application to maintain visual consistency and avoid code duplication.

### Key Components

1. **`Applicationx.cfc`**: Independent application component with mappings to main app resources
2. **`remote_load.cfm`**: Validates share tokens and loads appropriate content
3. **Content Templates**: Specialized templates for each share type (relationships, calendar)
4. **Database Tables**: `shareTokens` and `shareViews` to manage and track shares

## URL Structure

Share URLs follow this pattern:
```
https://theactorsoffice.com/share/index.cfm?shareToken=abc123-def456-ghi789
```

Legacy URL structure is still supported:
```
https://theactorsoffice.com/share/index.cfm?u=abc123def4
```

## Security Considerations

1. Tokens are cryptographically generated using multiple random sources
2. Optional expiration dates prevent indefinite access
3. Each view is logged with timestamp and IP address
4. No authentication required (deliberately)
5. Only specifically allowed data is exposed

## Adding New Share Types

1. Create a new template (e.g., `myfeature_shared.cfm`)
2. Add a new case in the switch statement in `remote_load.cfm`
3. Update services as needed to support the new share type

## Database Schema

### shareTokens

| Column      | Type         | Description                              |
|-------------|--------------|------------------------------------------|
| shareID     | INT          | Primary key                              |
| userID      | INT          | Reference to taousers                    |
| token       | VARCHAR(64)  | Unique share token                       |
| shareType   | VARCHAR(32)  | Type of share (relationships, calendar)  |
| createdDate | DATETIME     | When the share was created               |
| expiryDate  | DATETIME     | When the share expires (NULL = no expiry)|
| isActive    | TINYINT(1)   | Whether the share is currently active    |

### shareViews

| Column      | Type         | Description                              |
|-------------|--------------|------------------------------------------|
| viewID      | INT          | Primary key                              |
| shareID     | INT          | Reference to shareTokens                 |
| viewDate    | DATETIME     | When the share was viewed                |
| ipAddress   | VARCHAR(45)  | IP address of viewer                     |

## Creating Share Links in UI

To generate a share link in the main app:

```cfml
<cfquery name="createToken" datasource="#application.dsn#">
    CALL sp_CreateShareToken(#session.userid#, 'relationships', 30)
</cfquery>

<cfset shareLink = "https://theactorsoffice.com/share/index.cfm?shareToken=" & createToken.token />
```

## Resources

The Share Module uses these resources from the main app:

- CSS styles (`/app/assets/css/`)
- JavaScript libraries (`/app/assets/js/`)
- Images and icons (`/app/assets/images/`)
- Service components (`/services/`)
- Database utility functions (`/include/qry/`)

## Testing

Test URLs with these scenarios:

1. Valid token, not expired
2. Valid token, expired
3. Invalid/tampered token
4. No token provided
5. Legacy URL format
