# Google OAuth Verification Guide

## Purpose
This guide helps you eliminate "unsafe app" warnings when users connect their Google Calendar to TAO.

## Current Status
✅ **OAuth scope has been minimized** to `https://www.googleapis.com/auth/calendar.events`
- This is the most specific scope for calendar event management
- It only allows creating/reading/updating calendar events
- It does NOT allow access to Gmail, Drive, or other Google services

## Next Steps to Eliminate "Unsafe App" Warnings

### 1. Update Your OAuth Consent Screen

Go to [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → OAuth consent screen:

1. **App Information**
   - App name: "The Actor's Office - TAO"
   - User support email: Your support email
   - App logo: Upload TAO logo (512x512 PNG recommended)

2. **App Domain**
   - Application home page: `https://app.theactorsoffice.com`
   - Application privacy policy: `https://app.theactorsoffice.com/privacy.html`
   - Application terms of service: `https://app.theactorsoffice.com/tos.html`

3. **Authorized Domains**
   - Add: `theactorsoffice.com`
   - Add: `app.theactorsoffice.com`

4. **Developer Contact Information**
   - Add your email addresses

### 2. Update Scopes Section

In the OAuth consent screen, go to "Scopes":

1. Click "Add or Remove Scopes"
2. Find and select: `https://www.googleapis.com/auth/calendar.events`
3. Remove any other scopes if present
4. Save changes

### 3. Request Verification (Optional but Recommended)

For production apps, Google recommends verification:

1. Go to OAuth consent screen → "Publishing status"
2. Click "Publish App" 
3. If you have 100+ users, submit for verification:
   - Provide detailed explanation of calendar usage
   - Include screenshots of your app
   - Explain why calendar access is necessary

### 4. Update Your Privacy Policy

Ensure your privacy policy mentions:
- What calendar data you access (events only)
- How you use it (scheduling appointments)
- That you don't store personal calendar data long-term
- How users can revoke access

## Technical Implementation Notes

### Current Scope
```
https://www.googleapis.com/auth/calendar.events
```

This scope allows:
- ✅ Create calendar events
- ✅ Read calendar events  
- ✅ Update calendar events
- ✅ Delete calendar events
- ❌ Access other calendars
- ❌ Access Gmail
- ❌ Access Drive or other services

### Files Updated
- `include/calendarSectionCalendar.cfm` - Updated OAuth scope
- `oauth/oauth_callback.cfm` - Enhanced error handling

## Testing

After making these changes:

1. Test the OAuth flow with a fresh Google account
2. Verify that the consent screen shows:
   - Your app name and logo
   - Only calendar events permission
   - Links to privacy policy and terms
3. Check that no "unsafe app" warning appears

## Verification Timeline

- **Immediate**: Scope reduction takes effect immediately
- **1-7 days**: Updated consent screen information
- **2-6 weeks**: Google verification process (if submitted)

## Support Resources

- [Google OAuth Verification Guide](https://developers.google.com/identity/protocols/oauth2)
- [OAuth Consent Screen Best Practices](https://developers.google.com/identity/protocols/oauth2/web-server#creatingcred)
- [Calendar API Scopes](https://developers.google.com/calendar/auth)
