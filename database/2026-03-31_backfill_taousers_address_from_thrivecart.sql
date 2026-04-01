-- Backfill taousers address fields from thrivecart billing data
-- Only updates fields that are currently NULL or empty string
-- Only pulls from thrivecart records that have non-empty billing data
-- Safe to run multiple times (idempotent)

-- Preview: see which rows would be affected
SELECT
    u.userid,
    u.userFirstName,
    u.userLastName,
    u.add1       AS current_add1,
    u.city       AS current_city,
    u.defState   AS current_state,
    u.zip        AS current_zip,
    u.defCountry AS current_country,
    t.BillingAddress,
    t.BillingCity,
    t.BillingState,
    t.BillingZip,
    t.BillingCountry
FROM taousers u
INNER JOIN thrivecart t ON t.id = u.customerid
WHERE
    -- thrivecart has at least one billing field with data
    (COALESCE(NULLIF(t.BillingAddress, ''), NULLIF(t.BillingCity, ''), NULLIF(t.BillingZip, '')) IS NOT NULL)
    -- user has at least one empty/null address field that could be filled
    AND (
        (u.add1 IS NULL OR u.add1 = '')
        OR (u.city IS NULL OR u.city = '')
        OR (u.defState IS NULL OR u.defState = '')
        OR (u.zip IS NULL OR u.zip = '')
        OR (u.defCountry IS NULL OR u.defCountry = '')
    );

-- Execute: backfill only null/empty fields, leave existing values untouched
UPDATE taousers_tbl u
INNER JOIN thrivecart t ON t.id = u.customerid
SET
    u.add1       = CASE WHEN (u.add1 IS NULL OR u.add1 = '')
                        AND t.BillingAddress IS NOT NULL AND t.BillingAddress != ''
                        THEN t.BillingAddress ELSE u.add1 END,
    u.city       = CASE WHEN (u.city IS NULL OR u.city = '')
                        AND t.BillingCity IS NOT NULL AND t.BillingCity != ''
                        THEN t.BillingCity ELSE u.city END,
    u.defState   = CASE WHEN (u.defState IS NULL OR u.defState = '')
                        AND t.BillingState IS NOT NULL AND t.BillingState != ''
                        THEN t.BillingState ELSE u.defState END,
    u.zip        = CASE WHEN (u.zip IS NULL OR u.zip = '')
                        AND t.BillingZip IS NOT NULL AND t.BillingZip != ''
                        THEN t.BillingZip ELSE u.zip END,
    u.defCountry = CASE WHEN (u.defCountry IS NULL OR u.defCountry = '')
                        AND t.BillingCountry IS NOT NULL AND t.BillingCountry != ''
                        THEN t.BillingCountry ELSE u.defCountry END
WHERE
    u.IsDeleted = 0
    AND (COALESCE(NULLIF(t.BillingAddress, ''), NULLIF(t.BillingCity, ''), NULLIF(t.BillingZip, '')) IS NOT NULL)
    AND (
        (u.add1 IS NULL OR u.add1 = '')
        OR (u.city IS NULL OR u.city = '')
        OR (u.defState IS NULL OR u.defState = '')
        OR (u.zip IS NULL OR u.zip = '')
        OR (u.defCountry IS NULL OR u.defCountry = '')
    );

-- Rollback: set fields back to NULL where they were just backfilled
-- (only needed if something went wrong - run manually)
-- UPDATE taousers_tbl u
-- INNER JOIN thrivecart t ON t.id = u.customerid
-- SET u.add1 = NULL, u.city = NULL, u.defState = NULL, u.zip = NULL, u.defCountry = NULL
-- WHERE u.IsDeleted = 0
--   AND u.add1 = t.BillingAddress
--   AND u.city = t.BillingCity;
