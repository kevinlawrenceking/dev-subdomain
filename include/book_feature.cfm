<!---
  Book (master contact directory) feature switch - 2026-10-29 meeting stabilization.

  ONE server-side switch for every Book surface:
    - include/contact_info.cfm   (Book band, "Find in the Book", link-preview modal shell,
                                  master-link JS, WO-6 primary inline editor, on-read sync)
    - include/master_link_preview.cfm
    - ajax/master/*.cfm          (search, locations, link-confirm, unlink, resyncall)
    - ajax/contact/updateprimary.cfm (WO-6 editor; ships with the Book)

  false = Book hidden and its endpoints refuse with FEATURE_DISABLED. No code or data is removed.
  To re-enable: set true here. contact_info.cfm still ANDs this with its host gate (Book stays
  off on app.* until the WO-8 prod promotion), and the gitignored contact_info_PROD.cfm stays
  hard false.

  Audition "Booked" status (aud_book_pane.cfm, bookupdateform.cfm) is NOT the Book and is not
  affected by this switch.
--->
<cfset request.bookFeatureEnabled = false>
