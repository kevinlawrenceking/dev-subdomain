-- P11: Add IANA timezone identifier for browser auto-detection
-- Enables matching Intl.DateTimeFormat().resolvedOptions().timeZone to DB records
ALTER TABLE timezones ADD COLUMN tz_iana VARCHAR(100) NULL AFTER tzname;

-- Populate US timezones (verify exact tzname values match before running)
UPDATE timezones SET tz_iana = 'America/New_York'    WHERE tzname = 'Eastern Standard Time';
UPDATE timezones SET tz_iana = 'America/Chicago'     WHERE tzname = 'Central Standard Time';
UPDATE timezones SET tz_iana = 'America/Denver'      WHERE tzname = 'Mountain Standard Time';
UPDATE timezones SET tz_iana = 'America/Phoenix'     WHERE tzname = 'US Mountain Standard Time';
UPDATE timezones SET tz_iana = 'America/Los_Angeles' WHERE tzname = 'Pacific Standard Time';
UPDATE timezones SET tz_iana = 'America/Anchorage'   WHERE tzname = 'Alaskan Standard Time';
UPDATE timezones SET tz_iana = 'America/Anchorage'   WHERE tzname = 'Alaska Standard Time';
UPDATE timezones SET tz_iana = 'Pacific/Honolulu'    WHERE tzname = 'Hawaiian Standard Time';

-- Common international mappings
UPDATE timezones SET tz_iana = 'Europe/London'       WHERE tzname = 'GMT Standard Time';
UPDATE timezones SET tz_iana = 'Europe/Paris'        WHERE tzname = 'Romance Standard Time';
UPDATE timezones SET tz_iana = 'Europe/Berlin'       WHERE tzname = 'W. Europe Standard Time';
UPDATE timezones SET tz_iana = 'Asia/Tokyo'          WHERE tzname = 'Tokyo Standard Time';
UPDATE timezones SET tz_iana = 'Australia/Sydney'    WHERE tzname = 'AUS Eastern Standard Time';
UPDATE timezones SET tz_iana = 'Asia/Kolkata'        WHERE tzname = 'India Standard Time';
UPDATE timezones SET tz_iana = 'Asia/Shanghai'       WHERE tzname = 'China Standard Time';
