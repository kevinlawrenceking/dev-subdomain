-- ROLLBACK: P3_0 — Remove [NEW] payment plans added by this migration
DELETE FROM paymentplans
WHERE planName LIKE '%[NEW]%'
  AND BasePaymentPlanId IN (95048,95181,95803,95804,95805,95806,95807,95808,95809,95810,95811,95812,95813,96343,97435);
