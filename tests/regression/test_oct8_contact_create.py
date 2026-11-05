"""Contact creation repairs: session-pinned owner, media paths, default avatar, retry idempotency.

Retry identity is a per-render submission token held in the session; the old same-name
within-120-seconds rule was removed because two real contacts can share a name.
"""
import os
import re
import unittest

from _tao import REPO, head_src, src, strip_cf_comments

NAME_ADD = "include/remoteAddNameAdd.cfm"
ITEM_ADD = "include/remoteAddContactAdd.cfm"


def session_guard_before(text, marker):
    t = strip_cf_comments(text)
    guard = t.find('NOT structKeyExists(session, "userid")')
    pin = t.find("<cfset userid = session.userid />")
    work = t.find(marker)
    return 0 <= guard < pin < work


def submission_token_guard(text):
    """Retry identity is the per-render submission token, never owner+name+time."""
    t = strip_cf_comments(text)
    lock = re.search(r'<cflock scope="session" type="exclusive"[^>]*>(.*?)</cflock>', t, re.S)
    if not lock:
        return False
    body = lock.group(1)
    lookup = body.find("structKeyExists(session.contactSubmitResults, submissionToken)")
    insert = body.find("qry/add_211_1.cfm")
    record = body.find("session.contactSubmitResults[submissionToken] =")
    return (0 <= lookup < insert < record
            and 'reFind("^[a-f0-9]{64}$"' in t
            and "contactFullName" not in body and "contactCreationDate" not in body)


def form_renders_token(text):
    return re.search(r'name="submissionToken"\s+value="<cfoutput>#lCase\(hash\(generateSecretKey', text) is not None


class ContactCreateStatic(unittest.TestCase):
    def test_fixed_in_tree(self):
        self.assertTrue(session_guard_before(src(NAME_ADD), "qry/add_211_1.cfm"))
        self.assertTrue(session_guard_before(src(ITEM_ADD), '<cfparam name="deleteitem"'))
        self.assertTrue(submission_token_guard(src(NAME_ADD)))
        self.assertTrue(form_renders_token(src("include/remoteAddName.cfm")))
        self.assertIn("<cfset ensureUserMediaPaths() />", src("include/Application.cfc"))

    def test_detects_defect_at_head(self):
        self.assertFalse(session_guard_before(head_src(NAME_ADD), "qry/add_211_1.cfm"))
        self.assertFalse(session_guard_before(head_src(ITEM_ADD), '<cfparam name="deleteitem"'))
        self.assertFalse(submission_token_guard(head_src(NAME_ADD)))
        self.assertFalse(form_renders_token(head_src("include/remoteAddName.cfm")))
        self.assertNotIn("ensureUserMediaPaths", head_src("include/Application.cfc"))

    def test_media_paths_cover_every_session_key_folder_setup_reads(self):
        helper = re.search(r'name="ensureUserMediaPaths".*?</cffunction>', src("app/Application.cfc"), re.S).group(0)
        built = set(re.findall(r"session\.(user\w+)\s*=", helper))
        needed = set()
        for f in ("include/folder_setup.cfm", "include/contactfolder_setup.cfm"):
            needed |= set(re.findall(r"session\.(user(?:Media|Contacts|Imports|Exports|Share|Avatar)\w*)", src(f)))
        self.assertTrue(needed, "expected folder setup to read session media keys")
        self.assertEqual(needed - built, set())

    def test_no_avatar_copy_from_a_url(self):
        offenders = []
        for root, _, files in os.walk(REPO):
            if ".git" in root or "node_modules" in root:
                continue
            for fn in files:
                if fn.endswith((".cfm", ".cfc")):
                    with open(os.path.join(root, fn), encoding="utf-8", errors="replace") as fh:
                        t = fh.read()
                    if re.search(r'<cffile[^>]*action="copy"[^>]*source="#(application\.)?defaultAvatarUrl#"', t, re.I):
                        offenders.append(os.path.relpath(os.path.join(root, fn), REPO))
        self.assertEqual(offenders, [])


if __name__ == "__main__":
    unittest.main()
