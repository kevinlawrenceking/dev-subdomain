# Device-Dependent Ticket Verification

**Date:** 2026-04-04
**Status:** Awaiting hardware access

## Tickets Requiring Physical Device Testing

### #1675 - Photo Uploads Squished on Safari (EXIF Orientation)

**Fix Applied:** CSS `image-orientation: from-image` added to:
- `app/assets/css/tao-components.css` (lines 26, 68)
- `include/image-upload.cfm` (line 121)
- `include/image-upload-contact.cfm` (line 132)

**Test Required:**
1. Open TAO in Safari on a Mac
2. Upload a portrait-orientation photo taken with an iPhone
3. Verify the photo displays correctly (not rotated or squished)
4. Check both the upload preview and the saved contact photo

**Hardware Needed:** Mac with Safari browser

---

### #1614 - Blank Screen on iPhone 14 Pro Max

**Status:** Deferred by Chris Ansoff to a future release ("This does not feel critical").

**If testing becomes priority:**
1. Open TAO on iPhone 14 Pro Max in Safari
2. Navigate through login, dashboard, contacts, and auditions
3. Check for blank/white screen rendering issues
4. Check both portrait and landscape orientation

**Hardware Needed:** iPhone 14 Pro Max

---

## Action Items

- [ ] Schedule 15 minutes with someone who has a Mac to verify #1675
- [ ] #1614 remains deferred per Chris's direction
