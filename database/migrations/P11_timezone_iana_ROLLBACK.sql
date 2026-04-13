-- P11 Rollback: Remove IANA timezone column
ALTER TABLE timezones DROP COLUMN tz_iana;
