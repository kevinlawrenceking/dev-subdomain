-- P1_ticket_notifications.sql
-- TAO: Ticket Notification Emails -- Schema Migration

ALTER TABLE tickets
  ADD COLUMN developerResponse    TEXT     NULL AFTER ticketdetails,
  ADD COLUMN resolvedEmailSentAt  DATETIME NULL AFTER developerResponse,
  ADD COLUMN ackEmailSentAt       DATETIME NULL AFTER resolvedEmailSentAt;

-- Rollback:
-- ALTER TABLE tickets
--   DROP COLUMN developerResponse,
--   DROP COLUMN resolvedEmailSentAt,
--   DROP COLUMN ackEmailSentAt;
