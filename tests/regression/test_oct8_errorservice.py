"""ErrorService capture repairs: handled capture, root-cause fallback, column clamps."""
import re
import unittest

from _tao import cf_function, head_src, prod_ro, skip_without_db, src

SVC = "services/ErrorService.cfc"
CAUSED_BY = "Caused by: "


def root_cause_from_stack(stack):
    """Python mirror of the CFML fallback: last 'Caused by:' line -> (type, message)."""
    lines = re.findall(r"Caused by: [^\r\n]+", stack or "")
    if not lines:
        return None
    cb = lines[-1][len(CAUSED_BY):].strip()
    sep = cb.find(": ")
    return (cb[:sep], cb[sep + 2:]) if sep >= 0 else (cb, "")


class ErrorServiceStatic(unittest.TestCase):
    def test_handled_capture_is_silent_and_minimal(self):
        body = cf_function(src(SVC), "captureHandled")
        for forbidden in ("sendErrorEmail", "createSupportTicket", "cfmail"):
            self.assertNotIn(forbidden, body)
        self.assertIn('diagnostics.userEmail = ""', body)
        self.assertIn("catch (any e)", body)

    def test_stack_fallback_present_and_new(self):
        needle = 'reMatch("Caused by: [^\\r\\n]+", diag.stackTrace)'
        self.assertIn(needle, src(SVC))
        self.assertNotIn(needle, head_src(SVC))

    def test_cfml_offset_matches_prefix_length(self):
        # CFML mid() is 1-based: start 12 skips the 11 characters of "Caused by: ".
        self.assertEqual(len(CAUSED_BY), 11)
        self.assertIn("mid(cbLines[arrayLen(cbLines)], 12, 4000)", src(SVC))


@skip_without_db
class ErrorServiceProdEvidence(unittest.TestCase):
    def test_clamps_fit_prod_columns(self):
        clamps = {col: int(n) for col, n in
                  re.findall(r"<cfset d\.(\w+)\s*=\s*Left\(d\.\w+, (\d+)\)", src(SVC))}
        colmap = {"errorType": "error_type", "rootCauseType": "root_cause_type", "rootCauseFile": "root_cause_file",
                  "scriptName": "script_name", "httpMethod": "http_method", "httpReferer": "http_referer",
                  "remoteIp": "remote_ip", "userName": "user_name", "userEmail": "user_email",
                  "cfContext": "cf_context", "eventName": "event_name", "environment": "environment",
                  "cfEngine": "cf_engine", "serverName": "server_name"}
        self.assertEqual(set(clamps), set(colmap))
        with prod_ro() as cur:
            cur.execute("SELECT column_name AS c, character_maximum_length AS n FROM information_schema.columns "
                        "WHERE table_schema='actorsbusinessoffice' AND table_name='error_tickets'")
            widths = {r["c"]: r["n"] for r in cur.fetchall()}
        for key, col in colmap.items():
            with self.subTest(column=col):
                self.assertLessEqual(clamps[key], widths[col])

    def test_fallback_recovers_real_cause_from_prod_wrappers(self):
        with prod_ro() as cur:
            cur.execute("SELECT id, stack_trace FROM error_tickets WHERE error_message='Event handler exception.' "
                        "AND stack_trace LIKE %s ORDER BY id DESC LIMIT 25", ("%Caused by:%",))
            rows = cur.fetchall()
        self.assertGreater(len(rows), 0)
        for r in rows:
            with self.subTest(ticket=r["id"]):
                rc = root_cause_from_stack(r["stack_trace"])
                self.assertIsNotNone(rc)
                self.assertNotIn("EventHandlerException", rc[0])


if __name__ == "__main__":
    unittest.main()
