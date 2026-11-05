"""Ticket 2757 - Book-dependent contact-panel controls stay off when the Book is off.

Static checks on include/contact_info.cfm (dev, tracked) and include/contact_info_PROD.cfm
(the prod variant; gitignored, so those checks skip when the file is absent).

Set TAO_TEST_GIT_REV=<rev> to run the dev-file checks against a committed revision
(e.g. HEAD) instead of the working tree; they are expected to FAIL on c7bdde78.
"""
import difflib
import os
import re
import subprocess
import unittest

from _tao import REPO, src

DEV = "include/contact_info.cfm"
PROD = "include/contact_info_PROD.cfm"


def read(rel):
    rev = os.environ.get("TAO_TEST_GIT_REV")
    if rev:
        return subprocess.run(["git", "show", "%s:%s" % (rev, rel)], cwd=REPO, check=True,
                              capture_output=True, text=True, encoding="utf-8").stdout
    return src(rel)


def gated_regions(text, flag):
    """[start, end) offsets of every <cfif FLAG> ... </cfif><!--- FLAG ---> block."""
    opens = [m.start() for m in re.finditer(r"<cfif %s>" % flag, text)]
    closes = [m.end() for m in re.finditer(r"</cfif><!--- %s --->" % flag, text)]
    if len(opens) != len(closes):
        raise AssertionError("unbalanced %s gates: %d opens, %d closes" % (flag, len(opens), len(closes)))
    return list(zip(opens, closes))


def live_hits(text, needle):
    """Offsets of needle that are not inside a <!--- ... ---> CFML comment."""
    comments = [(m.start(), m.end()) for m in re.finditer(r"<!---.*?--->", text, re.S)]
    return [m.start() for m in re.finditer(re.escape(needle), text)
            if not any(a <= m.start() < b for a, b in comments)]


def ungated(text, needle, flag):
    """Live offsets of needle that sit outside every FLAG region (the closing marker of a
    region is itself a CFML comment, so regions are found on the unstripped text)."""
    regions = gated_regions(text, flag)
    return [p for p in live_hits(text, needle) if not any(a <= p < b for a, b in regions)]


class DevFileGates(unittest.TestCase):
    def setUp(self):
        self.text = read(DEV)

    def test_primary_editor_follows_book_flag(self):
        self.assertIn("<cfset primaryEditEnabled = masterBookEnabled>", self.text)

    def test_updateprimary_post_only_when_editor_enabled(self):
        self.assertEqual(ungated(self.text, "/ajax/contact/updateprimary.cfm", "primaryEditEnabled"), [])

    def test_master_endpoints_only_when_book_enabled(self):
        for needle in ("/ajax/master/", "master_link_preview.cfm", 'id="masterLinkToggle"', 'id="masterLinkSearch"'):
            with self.subTest(needle=needle):
                self.assertEqual(ungated(self.text, needle, "masterBookEnabled"), [])

    def test_edit_and_add_buttons_require_editor(self):
        start = self.text.index('<cfloop array="#primaryDefs#"')
        loop = self.text[start:self.text.index("<cfif masterIsLinked AND NOT masterIsSynced>", start)]
        cut = loop.find("<cfelseif primaryEditEnabled>")
        self.assertGreater(cut, 0, "edit/add buttons are not behind primaryEditEnabled")
        self.assertNotIn("primary-edit", loop[:cut])
        self.assertIn("book-field__add", loop[cut:])

    def test_readonly_mode_skips_blank_rows(self):
        self.assertIn("<cfif NOT primaryEditEnabled AND NOT masterIsLinked AND NOT len(pf.value)><cfcontinue></cfif>",
                      self.text)

    def test_ordinary_edit_modals_unchanged(self):
        for hook in ("/include/remoteUpdateName.cfm", "/include/remoteupdatec.cfm",
                     "/include/remoteUpdateTag.cfm", "/include/remoteUpdateSUID.cfm"):
            with self.subTest(hook=hook):
                self.assertIn(hook, self.text)
                self.assertEqual(ungated(self.text, hook, "masterBookEnabled"), live_hits(self.text, hook))

    def test_dev_flag_still_host_based(self):
        self.assertIn('<cfset masterBookEnabled = ( ListFirst(cgi.server_name, ".") NEQ "app" )>', self.text)


@unittest.skipIf(os.environ.get("TAO_TEST_GIT_REV") or not os.path.exists(os.path.join(REPO, PROD)),
                 "prod variant not present (gitignored)")
class ProdVariant(unittest.TestCase):
    def setUp(self):
        self.prod = src(PROD)
        self.dev = src(DEV)

    def test_book_flag_hard_false(self):
        # Only hard-false assignments: the prod gate itself, plus the 2026-10-29 Book-switch
        # override (which can only turn the Book off, never on).
        assigns = re.findall(r"<cfset masterBookEnabled\s*=[^>]*>", self.prod)
        self.assertEqual(assigns, ["<cfset masterBookEnabled = false>"] * 2)
        self.assertIn("<cfif NOT request.bookFeatureEnabled><cfset masterBookEnabled = false></cfif>", self.prod)

    def test_no_book_endpoint_reachable_with_flag_false(self):
        for needle, flag in (("/ajax/contact/updateprimary.cfm", "primaryEditEnabled"),
                             ("/ajax/master/", "masterBookEnabled"),
                             ("master_link_preview.cfm", "masterBookEnabled")):
            with self.subTest(needle=needle):
                self.assertEqual(ungated(self.prod, needle, flag), [])

    def test_differs_from_dev_only_in_banner_and_flag(self):
        changed = []
        for line in difflib.unified_diff(self.dev.split("\n"), self.prod.split("\n"), lineterm="", n=0):
            if line.startswith(("---", "+++", "@@")):
                continue
            changed.append(line)
        allowed_dev = {
            '      Host test is the house pattern (cf include/import-auditions.cfm:296); prod hostname is "app".',
            "      Remove this gate as part of the WO-8 prod promotion, not before. --->",
            '<cfset masterBookEnabled = ( ListFirst(cgi.server_name, ".") NEQ "app" )>',
        }
        removed = [l[1:] for l in changed if l.startswith("-")]
        self.assertTrue(set(removed) <= allowed_dev, "unexpected dev lines dropped: %r" % (set(removed) - allowed_dev))
        banner = re.search(r"<!--- =+\s+PRODUCTION VARIANT.*?=+ --->", self.prod, re.S).group(0)
        gate = re.search(r"      PROD VARIANT: hard false.*?<cfset masterBookEnabled = false>", self.prod, re.S).group(0)
        allowed_prod = set(banner.split("\n")) | set(gate.split("\n"))
        added = [l[1:] for l in changed if l.startswith("+")]
        self.assertTrue(set(added) <= allowed_prod, "unexpected prod-only lines: %r" % (set(added) - allowed_prod))


if __name__ == "__main__":
    unittest.main()
