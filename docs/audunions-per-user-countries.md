# Audition Unions — Per-User Country Preferences

**Status:** Shipped to dev 2026-05-06; ready for prod review.
**Owner:** Kevin King

## What this is

Each TAO user can now choose which countries' acting unions appear in
their audition project dropdown. Default is the user's home country
(e.g. `US`). Users who work across borders (e.g. US + Canada) can
opt in to additional countries from a single Preferences screen.

Before: every user saw a hard-coded list of unions for the project's
country, with no way to mix.

After: the union dropdown reflects the user's stated country mix, and
when more than one country is selected the country name is appended to
each union for clarity.

---

## What users see

### 1. New Preferences tile

`My Account > Preferences > Audition Union Countries`

- Shows the currently selected countries (e.g. *"United States"* or
  *"Canada, United States"*).
- Click the pencil to edit.

### 2. Country picker modal

- A 2-column checkbox grid of every country that has at least one
  active union (17 countries today).
- Tick any combination, click **Update**.
- If you uncheck everything, the system silently keeps you on `US` so
  you never end up with an empty dropdown.

### 3. Audition project union dropdown

- **Single country selected** — dropdown shows union names only:
  `SAG-AFTRA`, `Actor's Equity Association`, `AGMA`, `AGVA`, `Non-Union`.
- **Multiple countries selected** — every option shows its country so
  there's no ambiguity:
  `Non-Union (Canada)`, `ACTRA (Canada)`, `Canadian Actor's Equity (Canada)`,
  `UBCP/ACTRA (Canada)`, `UDA - Union des Artistes (Canada)`,
  `Actor's Equity Association (United States)`, `AGMA (United States)`,
  `AGVA (United States)`, `Non-Union (United States)`,
  `SAG-AFTRA (United States)`.
- Options are still filtered by the project's category (the chained
  category-to-union behaviour is unchanged).

---

## How to add a second country (user-facing)

1. Click **My Account** in the left nav.
2. Click the **Preferences** tab at the top.
3. Find the **Audition Union Countries** section.
4. Click the pencil (edit) button.
5. Tick the box(es) for any additional country.
6. Click **Update**.
7. The next time you open or update an audition project, the union
   dropdown will include unions from every checked country, each
   suffixed with its country name.

To go back to a single country, just uncheck the others and update.

---

## What changed behind the scenes (for sign-off)

### Database (`actorsbusinessoffice` on prod, `new_development` on dev)

| Object | Change | Migration script |
|---|---|---|
| `audunions` | Removed two cross-listed data-entry errors: `unionID=24` (AGMA at GB — AGMA is American) and `unionID=34` (Equity (UK) at US — Equity is British). | `database/2026-05-06_audunions_crosslist_cleanup.sql` |
| `audunions` | Dev-only: cleaned up duplicate seed rows + added unique key `uk_audunions_name_country` (prod was already clean). | `database/2026-05-06_audunions_dev_dedupe.sql` |
| `taousers_tbl` | Added `prefCountryIDList VARCHAR(50) NOT NULL DEFAULT 'US'`; backfilled non-US users from existing `countryid`. | inline ALTER + UPDATE (run by hand) |
| `taousers` view | Rebuilt with `SQL SECURITY INVOKER` to expose the new column. | `database/2026-05-06_rebuild_taousers_view_prefCountryIDList.sql` |

Affected projects on prod: zero (no audition project was pointing at
either cross-listed row). On dev, one project (`audprojectid=712`) had
its `unionID` reset to `0` and its old value snapshotted in
`_audprojects_crosslist_snapshot_20260506` for audit/rollback.

### Application code

| File | Purpose |
|---|---|
| `include/qry/audunions_sel.cfm` | Wrapper resolves `new_countryid` from caller → `taousers_tbl.prefCountryIDList` → `'US'` fallback. Coerces `audcatid` to a valid integer. Emits a dev-only HTML comment for trace. |
| `include/qry/audunions_sel_433_1.cfm` | Country filter switched from `=` to `FIND_IN_SET` so a CSV like `'US,CA'` returns multi-country unions. Adds `c.countryname` to the SELECT. Orders by country then name so dropdowns group cleanly. |
| `include/qry/audunion_countries_sel.cfm` *(new)* | Returns the set of countries that have at least one active union — drives the picker modal so users can't tick countries that would add nothing. |
| `include/qry/fetchUsers.cfm` | Adds bare-scope `prefCountryIDList` (defaults `'US'`) for downstream templates. |
| `include/prefs_pane.cfm` | New "Audition Union Countries" section + edit modal between Newsletter and Submission Sites. |
| `app/myaccount/update_pref_countries.cfm` *(new)* | Save endpoint. Whitelist-validates submitted countryids against the active-unions set. Falls back to `'US'` if all are unchecked. Busts session cache and redirects back to the Preferences tab. |
| `include/remote_aud_project_update.cfm` | Conditionally suffixes each option with its country name when the user's pref spans more than one country. |

### Trust boundary

- All SQL writes use `cfqueryparam`.
- The save endpoint whitelists submitted country codes against the live
  `audunions` country list — the form cannot persist arbitrary values.
- The new column is `NOT NULL DEFAULT 'US'`; the save logic also
  defaults to `'US'` if a user submits an empty selection. Together
  these guarantee the union dropdown is never empty.

---

## Acceptance test plan

Each of these should be runnable in 5 minutes by a coworker on dev.

1. **Default case unchanged.** Log in as a US user. Open any audition
   project's update modal. Union dropdown should show only US unions
   with no country suffix. View-source comment should read
   `audunions_sel filter: countryid=US audcatid=...`.
2. **Pick the picker.** `My Account > Preferences > Audition Union Countries`.
   The "Selected Countries" line shows *"United States"*. Click the pencil.
   Modal opens with US pre-checked and 16 other countries unchecked.
3. **Add a country.** Tick **Canada**, click **Update**. Page reloads
   on the Preferences tab. Tile now reads *"Canada, United States"*.
4. **Verify dropdown.** Open an audition project's update modal. Union
   dropdown now shows 5 CA unions and 5 US unions, each suffixed with
   its country name (e.g. *"SAG-AFTRA (United States)"*).
   View-source comment reads `countryid=US,CA audcatid=...`.
5. **Empty-input safety.** Open the picker, uncheck every box, click
   Update. Tile reverts to *"United States"* (silent fallback to `US`).
6. **Cross-list cleanup.** Confirm `Equity (UK)` is no longer offered
   to a US-only user, and `AGMA` is no longer offered to a GB-only user.

---

## Rollback

If something goes wrong, the changes back out cleanly:

1. **Drop the column** — `ALTER TABLE taousers_tbl DROP COLUMN prefCountryIDList;`
2. **Restore the view** — rollback header in
   `database/2026-05-06_rebuild_taousers_view_prefCountryIDList.sql`.
3. **Revert CFML** — `git revert` the commit.
4. **Restore deleted unions** — only needed if anyone wants
   `unionID=24`/`34` back; the prod snapshot table is empty (no projects
   were affected) so there's nothing to remap.

The dropdown reverts to the prior hard-coded behaviour with no user-facing
data loss.
