"""Contacts import v3: a real Excel workbook that cfspreadsheet cannot read fails the job
with a save-as-CSV message; it is never read as CSV text and never reported as parsed.

Static checks on ajax/importv3/parse.cfm. Set TAO_TEST_GIT_REV=<rev> to run them against a
committed revision; they are expected to FAIL on c7bdde78.
"""
import os
import re
import subprocess
import unittest

from _tao import cf_function, REPO, src, strip_cf_comments

PARSE = "ajax/importv3/parse.cfm"


def read(rel):
    rev = os.environ.get("TAO_TEST_GIT_REV")
    if rev:
        return subprocess.run(["git", "show", "%s:%s" % (rev, rel)], cwd=REPO, check=True,
                              capture_output=True, text=True, encoding="utf-8").stdout
    return src(rel)


class ExcelBranch(unittest.TestCase):
    def setUp(self):
        self.text = strip_cf_comments(read(PARSE).replace("\r\n", "\n"))
        start = self.text.index('<cfelseif variables.job.file_type eq "xls" or variables.job.file_type eq "xlsx">')
        end = self.text.index('<cfelseif variables.job.file_type eq "vcf">')
        self.branch = self.text[start:end]

    def test_workbook_never_falls_back_to_csv(self):
        throw = self.branch.find('<cfthrow type="TAO.Import.ExcelUnreadable"')
        fallback = self.branch.find('fileRead(variables.filePath, "utf-8")')
        self.assertGreater(throw, 0, "no ExcelUnreadable throw in the Excel branch")
        self.assertGreater(fallback, throw, "CSV fallback is reachable before the workbook guard")
        guard = self.branch[:throw]
        self.assertIn('<cfif NOT variables.excelParsed AND NOT variables.nativeParsed AND variables.fileSignature neq "text">', guard)
        self.assertIn("importFileSignature(variables.filePath)", guard)

    def test_native_reader_only_for_zip_and_before_unreadable_throw(self):
        text = src("ajax/importv3/parse.cfm")
        call = text.index("readXlsxNative(variables.filePath)")
        zip_gate = text.rindex('<cfif NOT variables.excelParsed AND variables.fileSignature eq "zip">', 0, call)
        throw = text.index('<cfthrow type="TAO.Import.ExcelUnreadable"')
        self.assertLess(zip_gate, call)
        self.assertLess(call, throw)
        self.assertIn('<cfelseif NOT variables.nativeParsed>', text)

    def test_native_reader_avoids_commons_compress(self):
        body = cf_function(src("ajax/importv3/parse.cfm"), "readXlsxNative")
        self.assertIn('"java.util.zip.ZipFile"', body)
        self.assertNotIn("commons.compress", body)
        self.assertIn("DOCTYPE", cf_function(src("ajax/importv3/parse.cfm"), "xlsxEntryXml"))

    def test_signature_detects_zip_and_ole(self):
        fn = re.search(r'<cffunction name="importFileSignature".*?</cffunction>', self.text, re.S).group(0)
        self.assertIn('"504B0304"', fn)
        self.assertIn('"D0CF11E0"', fn)
        self.assertIn('<cfreturn "unknown">', fn, "unreadable file must not default to text")

    def test_linkage_error_caught_narrowly(self):
        self.assertIn('<cfcatch type="java.lang.LinkageError">', self.branch)
        for broad in ("java.lang.Throwable", 'type="java.lang.Error"'):
            with self.subTest(broad=broad):
                self.assertNotIn(broad, self.text)

    def test_xlsx_linkage_probed_before_read(self):
        self.assertIn("excelZipReaderStatus()", self.branch)
        self.assertLess(self.branch.index("excelZipReaderStatus()"), self.branch.index("<cfspreadsheet"))
        fn = re.search(r'<cffunction name="excelZipReaderStatus".*?</cffunction>', self.text, re.S).group(0)
        self.assertIn('"getNextEntry"', fn)
        self.assertIn('"org.apache.commons.compress.archivers.zip.ZipArchiveEntry"', fn)

    def test_unreadable_handler_fails_job_with_user_message(self):
        m = re.search(r'<cfcatch type="TAO.Import.ExcelUnreadable">(.*?)</cfcatch>\s*<cfcatch type="any">',
                      self.text, re.S)
        self.assertIsNotNone(m, "ExcelUnreadable handler missing or not ahead of the generic catch")
        handler = m.group(1)
        self.assertRegex(handler, r'setJobStatus\([^)]*"failed"')
        self.assertIn('variables.response.code = "PARSE_FAILED"', handler)
        self.assertIn("variables.response.message = cfcatch.message", handler)
        self.assertNotIn("success", handler)
        self.assertIn('captureHandled(cfcatch, "importv3-parse-excel")', handler)
        self.assertIn("<cfabort>", handler)

    def test_user_message_says_save_as_csv(self):
        msg = re.search(r'<cfthrow type="TAO.Import.ExcelUnreadable"\s+message="([^"]+)"', self.branch).group(1)
        self.assertIn("save it as CSV", msg)


if __name__ == "__main__":
    unittest.main()
