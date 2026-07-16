#!/usr/bin/env bash
# ============================================================================
#  DIR-LNK-WO-6 · P4 LANDING CHECK · dev.theactorsoffice.com
#  READ-ONLY: GET requests only. No POST, no login attempt, no writes.
#  Unauthenticated requests die at the Application.cfc auth wall (401)
#  before any template code executes — holds intact.
#
#  What it proves:
#    A  The NEW template ajax/contact/update-primary.cfm is present on the
#       deployed tree, via 3-way status discrimination:
#         target  vs  known-existing /ajax template  vs  guaranteed-missing name.
#       (Pattern-matched, not hardcoded — if the auth wall answers even for
#        missing files, the script says AMBIGUOUS instead of lying.)
#    G  /.git web exposure. If exposed (a register finding on its own), it
#       reads the deployed dev SHA directly and compares to local HEAD.
#    B  OPTIONAL, with --cookie + --contact-url: greps a rendered contact
#       page for 'update-primary' markup — proves the MODIFIED templates are
#       serving fresh output (the trusted-cache stale-compile trap).
#
#  Usage (Git Bash, from workspace root /c/Users/kevin/TAO/dev-subdomain):
#    bash p4-landing-check.sh
#    bash p4-landing-check.sh --cookie "CFID=1234;CFTOKEN=abcd1234" \
#         --contact-url "https://dev.theactorsoffice.com/<UNLINKED contact page URL>"
#
#  Best evidence: run once BEFORE the Hostek git-update (target should
#  classify MISSING) and again AFTER (target should classify PRESENT).
#  That one-file flip is the landing proof.
#
#  Exit codes: 0 LANDED · 1 NOT LANDED · 2 AMBIGUOUS · 3 host unreachable
# ============================================================================

HOST="https://dev.theactorsoffice.com"
TARGET_PATH="/ajax/contact/update-primary.cfm"
CONTROL_EXISTING="/ajax/setup-wizard/save-step2.cfm"   # existence evidenced in the P1/P3 record
CONTROL_MISSING="/ajax/contact/wo6-missing-control-${RANDOM}${RANDOM}.cfm"

COOKIE=""; CONTACT_URL=""
while [ $# -gt 0 ]; do
  case "$1" in
    --cookie)      COOKIE="$2";      shift 2 ;;
    --contact-url) CONTACT_URL="$2"; shift 2 ;;
    *) echo "unknown arg: $1"; exit 2 ;;
  esac
done

probe() {  # $1 = url → echoes HTTP status, 000 on transport failure
  local c
  c=$(curl -s -o /dev/null -m 25 -w '%{http_code}' "$1" 2>/dev/null)
  [ -n "$c" ] && echo "$c" || echo "000"
}
say()  { printf '%s\n' "$*"; }
line() { printf '%s\n' "----------------------------------------------------------------"; }

# ---- local repo cross-check ------------------------------------------------
LOCAL_SHA=$(git rev-parse --short=8 HEAD 2>/dev/null || echo "n/a")
LOCAL_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "n/a")
if [ -f ".${TARGET_PATH}" ]; then LOCAL_TARGET="present"; else LOCAL_TARGET="MISSING — run from workspace root"; fi

say "== DIR-LNK-WO-6 · P4 landing check · $(date '+%Y-%m-%d %H:%M:%S') =="
say "local branch/HEAD : ${LOCAL_BRANCH} @ ${LOCAL_SHA}   (deployed tree should equal this)"
say "local target file : ${LOCAL_TARGET}"
line

# ---- probes ------------------------------------------------------------------
C_HOME=$(probe "${HOST}/")
C_TGT=$(probe  "${HOST}${TARGET_PATH}")
C_EXIST=$(probe "${HOST}${CONTROL_EXISTING}")
C_MISS=$(probe  "${HOST}${CONTROL_MISSING}")

say "host reachability                : ${C_HOME}"
say "TARGET  update-primary.cfm       : ${C_TGT}"
say "CONTROL existing (save-step2)    : ${C_EXIST}   (expected 401 auth wall)"
say "CONTROL missing  (random name)   : ${C_MISS}   (expected 404)"
line

# ---- verdict logic (equality classes, not hardcoded codes) -------------------
VERDICT="AMBIGUOUS"; DETAIL=""; RC=2
if [ "$C_HOME" = "000" ]; then
  VERDICT="NO-RUN"; RC=3
  DETAIL="host unreachable — DNS/TLS/network problem before anything else."
elif [ "$C_EXIST" = "$C_MISS" ]; then
  VERDICT="AMBIGUOUS"; RC=2
  DETAIL="existing and missing controls return the same code (${C_EXIST}) — status alone cannot prove file presence here. Use the .git result below or the authenticated UI probe."
elif [ "$C_TGT" = "$C_MISS" ]; then
  VERDICT="NOT LANDED"; RC=1
  DETAIL="target classifies with the MISSING control (${C_MISS}) — the deployed tree does not have the new file. Run/verify the Hostek git-update, then re-run this script."
elif [ "$C_TGT" = "$C_EXIST" ]; then
  VERDICT="LANDED (probe A PASS)"; RC=0
  DETAIL="target classifies with the EXISTING control (${C_EXIST}) and apart from the missing class (${C_MISS}) — the new template is present and served behind the auth wall."
else
  VERDICT="AMBIGUOUS"; RC=2
  DETAIL="target (${C_TGT}) matches neither control class (exist=${C_EXIST}, miss=${C_MISS}). Paste this whole output back for adjudication before proceeding."
fi

# ---- .git exposure / direct SHA read -----------------------------------------
C_GIT=$(probe "${HOST}/.git/HEAD")
if [ "$C_GIT" = "200" ]; then
  GIT_HEAD=$(curl -s -m 25 "${HOST}/.git/HEAD" 2>/dev/null | tr -d '\r')
  REMOTE_SHA=$(curl -s -m 25 "${HOST}/.git/refs/heads/dev" 2>/dev/null | tr -d '\r' | cut -c1-8)
  say ".git exposure                    : 200 — EXPOSED. Register finding: block /.git at the web layer (web.config / IIS rule)."
  say "  deployed HEAD ref              : ${GIT_HEAD:-unreadable}"
  if [ -n "$REMOTE_SHA" ]; then
    say "  deployed refs/heads/dev        : ${REMOTE_SHA}"
    if [ "$REMOTE_SHA" = "$LOCAL_SHA" ]; then
      say "  SHA compare                    : MATCH — deployed dev == local ${LOCAL_SHA}"
    else
      say "  SHA compare                    : MISMATCH — deployed ${REMOTE_SHA} vs local ${LOCAL_SHA} — deploy did not advance."
    fi
  else
    say "  deployed refs/heads/dev        : not directly readable (packed refs) — no SHA compare available."
  fi
else
  say ".git exposure                    : ${C_GIT} — not exposed (good; no direct SHA read by this route)."
fi
line

# ---- optional probe B: authenticated UI grep ----------------------------------
if [ -n "$COOKIE" ] && [ -n "$CONTACT_URL" ]; then
  UI_HITS=$(curl -s -m 40 -H "Cookie: ${COOKIE}" "$CONTACT_URL" 2>/dev/null | grep -o "update-primary" | wc -l | tr -d ' ')
  say "PROBE B (authenticated UI grep)  : ${UI_HITS} occurrence(s) of 'update-primary' in rendered page"
  if [ "${UI_HITS:-0}" -gt 0 ] 2>/dev/null; then
    say "  modified templates fresh       : YES — stale-compile trap cleared."
  else
    say "  modified templates fresh       : NOT PROVEN — 0 hits. Possible causes: contact is LINKED (controls hidden by design), session cookie invalid, markup names the endpoint differently, or contact_info is serving a stale compile. Re-try with an UNLINKED contact; if still 0, fall back to the manual browser check."
  fi
else
  say "PROBE B (authenticated UI)       : SKIPPED — no --cookie/--contact-url given. Manual step stands: logged-in browser, open an UNLINKED contact, confirm the primary-field edit UI renders."
fi
line
say "VERDICT: ${VERDICT}"
say "DETAIL : ${DETAIL}"
say "(read-only run complete — zero POSTs issued; mutation probes belong to P5)"
exit $RC
