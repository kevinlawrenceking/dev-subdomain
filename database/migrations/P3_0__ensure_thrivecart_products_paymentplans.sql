-- ============================================================================
-- P3_0: Ensure all ThriveCart payment plans exist in the paymentplans table
-- DATE: 2026-04-03
-- AUTHOR: Kevin King
--
-- These IDs are ThriveCart product_id values = BasePaymentPlanID.
-- Uses INSERT IGNORE: skips if ID already exists, only adds missing.
-- [NEW] tag in name identifies rows added by this migration.
-- ============================================================================

INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95048, 'The Actor''s Office ($17/month after free trial) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95181, 'The Actor''s Office ($169/year after free trial) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95803, 'The Actor''s Office ($17/month no trial) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95804, 'The Actor''s Office ($169/year no trial) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95805, 'The Actor''s Office ($8/month) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95806, 'The Actor''s Office ($79.20/year) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95807, 'The Actor''s Office ($10/month) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95808, 'The Actor''s Office ($84.50/year) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95809, 'The Actor''s Office ($99/year no trial) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95810, 'The Actor''s Office ($12/month) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95811, 'The Actor''s Office ($119/year) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95812, 'The Actor''s Office ($12.75/month) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (95813, 'The Actor''s Office | Auditions Module Add-On ($45/year) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (96343, 'The Actor''s Office ($17/month one month free) [NEW]');
INSERT IGNORE INTO paymentplans (BasePaymentPlanId, planName) VALUES (97435, 'The Actor''s Office (Extended Free Trial) [NEW]');

-- VERIFY: Show only newly inserted rows
SELECT BasePaymentPlanId, planName
FROM paymentplans
WHERE planName LIKE '%[NEW]%'
ORDER BY BasePaymentPlanId;
