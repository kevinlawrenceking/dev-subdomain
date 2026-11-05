"""D1 security acceptance over real HTTP against a DEV ColdFusion instance (never prod).

Covers include/get_reminders.cfm, include/dashboardupdate2.cfm (+ PanelUserService) and
include/icsmaker.cfm for three caller classes: unauthenticated, authorized owner, cross-user.

Run it BEFORE the D1 dev deploy (records how the old code behaves) and AFTER (expect PASS).
Output is one JSON line per check plus a summary; no credentials or cookies are printed.

Environment:
  TAO_HTTP_BASE            default https://dev.theactorsoffice.com. Allowed hosts: dev.*, uat.*,
                           and localhost/127.0.0.1 (isolated test instance). Never app.* / www.*.
  TAO_TEST_A_EMAIL / TAO_TEST_A_PASSWORD   dedicated dev test account A
  TAO_TEST_B_EMAIL / TAO_TEST_B_PASSWORD   dedicated dev test account B
  TAO_TEST_A_CONTACTID     a contact owned by A that has at least one reminder
  TAO_TEST_B_CONTACTID     a contact owned by B that has at least one reminder
  TAO_DB_HOST / TAO_DB_USER / TAO_DB_PASSWORD   read-only evidence from new_development
  TAO_ICS_DIR              optional: the instance's media-abod\\calendar directory as seen from this
                           machine. Enables the ICS owner/cross-user checks, which WRITE .ics files,
                           so only set it where those files can be removed afterwards.

Redirects are never followed automatically. A redirect is followed by hand only when it stays on
the same host as TAO_HTTP_BASE; any other target aborts the run without requesting it.

Side effects (dev test accounts only): the dashboard checks re-post each account's own
current panel set, then restore it, so A and B end with the panels they started with.

Usage: python tests/http/d1_security_http.py
"""
import glob
import hashlib
import json
import os
import re
import sys
from urllib.parse import urljoin, urlparse

import requests

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "regression"))
from _tao import db_available, dev_ro  # noqa: E402

BASE = os.environ.get("TAO_HTTP_BASE", "https://dev.theactorsoffice.com").rstrip("/")
HOST = (urlparse(BASE).hostname or "").lower()
LOCAL = HOST in ("localhost", "127.0.0.1")
if not (HOST.startswith("dev.") or HOST.startswith("uat.") or LOCAL):
    sys.exit("refusing to run against %r: only dev./uat./localhost hosts are allowed" % HOST)

RESULTS = []


def record(check, outcome, **evidence):
    row = {"check": check, "outcome": outcome}
    row.update(evidence)
    RESULTS.append(row)
    print(json.dumps(row, default=str), flush=True)


def env(name, required=True):
    v = os.environ.get(name, "")
    if required and not v:
        sys.exit("missing %s" % name)
    return v


class GuardedSession(requests.Session):
    """requests.Session that refuses to leave the target host, even via a redirect."""

    def request(self, method, url, **kw):
        follow = kw.pop("allow_redirects", True)
        kw["allow_redirects"] = False
        kw.setdefault("timeout", 60)
        target = (urlparse(url).hostname or "").lower()
        if target != HOST:
            raise SystemExit("blocked request to foreign host %r" % target)
        r = super().request(method, url, **kw)
        if LOCAL:
            # the app sets Secure session cookies; the isolated instance is plain http on localhost
            for c in self.cookies:
                c.secure = False
        hops = 0
        while follow and r.is_redirect and hops < 5:
            nxt = urljoin(r.url, r.headers.get("Location", ""))
            if (urlparse(nxt).hostname or "").lower() != HOST:
                raise SystemExit("blocked redirect to foreign host %r" % urlparse(nxt).hostname)
            r = super().request("GET", nxt, allow_redirects=False, timeout=kw["timeout"])
            hops += 1
        return r


def anon():
    s = GuardedSession()
    s.headers["User-Agent"] = "tao-d1-acceptance/1.1"
    return s


def login(email, password):
    s = anon()
    s.get(BASE + "/loginform.cfm")
    r = s.post(BASE + "/login/login2.cfm", allow_redirects=True,
               data={"j_username": email, "j_password": password, "pwrong": "N", "pwpass": "Y"})
    if "loginform.cfm" in r.url:
        sys.exit("login failed for a test account (landed on %s)" % urlparse(r.url).path)
    page = s.get(BASE + "/app/dashboard_new/")
    m = re.search(r'<meta name="csrf-token" content="([^"]+)"', page.text)
    s.csrf = m.group(1) if m else ""
    s.landing = urlparse(r.url).path
    return s


def json_or_none(r):
    try:
        return r.json()
    except ValueError:
        return None


def row_ids(rows):
    ids = set()
    for row in rows if isinstance(rows, list) else []:
        if isinstance(row, dict):
            for k, v in row.items():
                if k.lower() == "id":
                    ids.add(v)
    return ids


def user_id(email):
    with dev_ro() as cur:
        cur.execute("SELECT userID FROM taousers_tbl WHERE userEmail=%s AND isdeleted=0 LIMIT 1", (email,))
        row = cur.fetchone()
        return row["userID"] if row else None


def db_reminder_ids(uid, cid):
    with dev_ro() as cur:
        cur.execute("SELECT n.notID FROM funotifications n JOIN fusystemusers f ON f.suID=n.suID "
                    "WHERE f.userid=%s AND f.contactid=%s AND f.sustatus='Active' AND n.notStatus='Pending' "
                    "AND n.notStartDate <= NOW()", (uid, cid))
        return {r["notID"] for r in cur.fetchall()}


def panels(uid):
    with dev_ro() as cur:
        cur.execute("SELECT pnID, IsVisible+0 AS v FROM pgpanels_user WHERE userid=%s ORDER BY pnID", (uid,))
        return [(r["pnID"], int(r["v"])) for r in cur.fetchall()]


def visible_list(snapshot):
    return ",".join(str(p) for p, v in snapshot if v == 1)


def post_panels(session, pnids, userid_param=None):
    data = {"new_isvisible": pnids, "csrfToken": getattr(session, "csrf", "")}
    if userid_param is not None:
        data["userid"] = userid_param
    return session.post(BASE + "/include/dashboardupdate2.cfm", data=data, allow_redirects=False)


def loc(r):
    return urlparse(r.headers.get("Location", "")).path


def ics_snapshot(ics_dir):
    out = {}
    for p in glob.glob(os.path.join(ics_dir, "*.ics")):
        with open(p, "rb") as fh:
            out[os.path.basename(p)] = hashlib.sha256(fh.read()).hexdigest()
    return out


def ics_name(uid):
    with dev_ro() as cur:
        cur.execute("SELECT REPLACE(REPLACE(recordname,' ',''),'-','') AS n FROM taousers WHERE userid=%s", (uid,))
        return cur.fetchone()["n"] + ".ics"


def main():
    if not db_available():
        sys.exit("TAO_DB_* is required for before/after evidence")
    a_email, b_email = env("TAO_TEST_A_EMAIL"), env("TAO_TEST_B_EMAIL")
    a_cid, b_cid = int(env("TAO_TEST_A_CONTACTID")), int(env("TAO_TEST_B_CONTACTID"))
    a_uid, b_uid = user_id(a_email), user_id(b_email)
    if not (a_uid and b_uid) or a_uid == b_uid:
        sys.exit("test accounts A and B must be two distinct users in new_development")

    nobody = anon()
    a = login(a_email, env("TAO_TEST_A_PASSWORD"))
    b = login(b_email, env("TAO_TEST_B_PASSWORD"))
    # The accounts exist only in new_development, so a successful login proves the target reads it.
    record("target.reads_new_development", "PASS", base=BASE, a_landing=a.landing, b_landing=b.landing,
           a_csrf=bool(a.csrf), b_csrf=bool(b.csrf))

    # --- get_reminders.cfm -------------------------------------------------------------
    a_expected, b_expected = db_reminder_ids(a_uid, a_cid), db_reminder_ids(b_uid, b_cid)

    r = nobody.get(BASE + "/include/get_reminders.cfm", params={"currentid": b_cid, "userid": b_uid})
    body = json_or_none(r)
    leaked = row_ids(body) & b_expected
    record("reminders.unauthenticated", "PASS" if r.status_code == 401 and body == [] else "FAIL",
           status=r.status_code, json=body is not None, rows=len(body) if isinstance(body, list) else None,
           leaked_b_rows=len(leaked))

    r = a.get(BASE + "/include/get_reminders.cfm", params={"currentid": a_cid})
    got = row_ids(json_or_none(r))
    record("reminders.owner", "PASS" if r.status_code == 200 and a_expected and got == a_expected else "FAIL",
           status=r.status_code, expected_rows=len(a_expected), got_rows=len(got))

    for label, params in (("reminders.cross_user_userid_param", {"currentid": b_cid, "userid": b_uid}),
                          ("reminders.cross_user_contact_only", {"currentid": b_cid})):
        r = a.get(BASE + "/include/get_reminders.cfm", params=params)
        body = json_or_none(r)
        leaked = row_ids(body) & b_expected
        if not b_expected:
            record(label, "INCONCLUSIVE", reason="B's contact has no due reminders in new_development")
        else:
            record(label, "PASS" if not leaked and r.status_code == 200 else "FAIL",
                   status=r.status_code, b_rows=len(b_expected), leaked_rows=len(leaked))

    r = a.get(BASE + "/include/get_reminders.cfm", params={"currentid": "0 OR 1=1", "userid": "%s OR 1=1" % b_uid})
    leaked = row_ids(json_or_none(r)) & b_expected
    record("reminders.injection_payload", "PASS" if not leaked else "FAIL", status=r.status_code, leaked_rows=len(leaked))

    # --- dashboardupdate2.cfm / PanelUserService -----------------------------------------
    a0, b0 = panels(a_uid), panels(b_uid)
    if len({v for _, v in b0}) < 2:
        sys.exit("B needs both visible and hidden panels so a foreign write is observable")
    b_changed_list = str(b0[0][0])  # if this lands, B ends with exactly one visible panel

    r = nobody.post(BASE + "/include/dashboardupdate2.cfm", allow_redirects=False,
                    data={"new_isvisible": b_changed_list, "userid": b_uid})
    record("panels.unauthenticated", "PASS" if panels(b_uid) == b0 and r.status_code in (302, 401, 403) else "FAIL",
           status=r.status_code, location=loc(r), b_unchanged=panels(b_uid) == b0)

    a_target = [(p, 1 if i % 2 == 0 else 0) for i, (p, _) in enumerate(a0)]
    r = post_panels(a, visible_list(a_target))
    record("panels.owner", "PASS" if panels(a_uid) == a_target and r.status_code in (200, 302) else "FAIL",
           status=r.status_code, location=loc(r), a_applied=panels(a_uid) == a_target, b_unchanged=panels(b_uid) == b0)

    r = post_panels(a, b_changed_list, userid_param=b_uid)
    record("panels.cross_user_userid_param", "PASS" if panels(b_uid) == b0 else "FAIL",
           status=r.status_code, b_unchanged=panels(b_uid) == b0)

    # Confined payload: on the old code it would make every one of B's panels visible (and only B's).
    r = post_panels(a, "0) OR (userid=%d" % b_uid, userid_param=a_uid)
    record("panels.injection_payload", "PASS" if panels(b_uid) == b0 else "FAIL",
           status=r.status_code, b_unchanged=panels(b_uid) == b0)

    # restore both accounts through their own sessions, then prove it
    post_panels(a, visible_list(a0))
    post_panels(b, visible_list(b0))
    record("panels.restored", "PASS" if panels(a_uid) == a0 and panels(b_uid) == b0 else "FAIL",
           a_restored=panels(a_uid) == a0, b_restored=panels(b_uid) == b0)

    # --- icsmaker.cfm -------------------------------------------------------------------
    r = nobody.get(BASE + "/include/icsmaker.cfm", params={"target_userid": b_uid}, allow_redirects=False)
    record("ics.unauthenticated", "PASS" if r.status_code in (302, 401) else "FAIL", status=r.status_code, location=loc(r))

    ics_dir = os.environ.get("TAO_ICS_DIR", "")
    if not ics_dir:
        record("ics.owner", "NOT_RUN", reason="TAO_ICS_DIR not set; the check writes .ics files that must be removable")
        record("ics.cross_user", "NOT_RUN", reason="TAO_ICS_DIR not set; the check writes .ics files that must be removable")
    else:
        a_file, b_file = ics_name(a_uid), ics_name(b_uid)
        before = ics_snapshot(ics_dir)
        r = a.get(BASE + "/include/icsmaker.cfm", params={"target_userid": b_uid}, timeout=180)
        after = ics_snapshot(ics_dir)
        changed = sorted(k for k in set(before) | set(after) if before.get(k) != after.get(k))
        record("ics.cross_user", "PASS" if b_file not in changed and set(changed) <= {a_file} else "FAIL",
               status=r.status_code, changed_files=changed, b_file_unchanged=b_file not in changed)
        a_path = os.path.join(ics_dir, a_file)
        a_text = open(a_path, encoding="utf-8", errors="replace").read() if os.path.exists(a_path) else ""
        record("ics.owner", "PASS" if r.status_code == 200 and "D1FIXTURE-A-MARKER" in a_text
               and "D1FIXTURE-B-MARKER" not in a_text else "FAIL",
               status=r.status_code, a_file_written=bool(a_text), has_own_event="D1FIXTURE-A-MARKER" in a_text,
               has_foreign_event="D1FIXTURE-B-MARKER" in a_text)

    summary = {k: sum(1 for x in RESULTS if x["outcome"] == k) for k in ("PASS", "FAIL", "INCONCLUSIVE", "NOT_RUN")}
    print(json.dumps({"summary": summary, "base": BASE}))
    return 1 if summary["FAIL"] else 0


if __name__ == "__main__":
    sys.exit(main())
