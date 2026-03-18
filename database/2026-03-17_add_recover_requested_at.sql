-- Add token expiration timestamp for password recovery
-- Run against: actorsbusinessoffice (prod) or new_development (dev)
--
-- Rollback:
--   ALTER TABLE taousers_tbl DROP COLUMN recover_requested_at;

ALTER TABLE taousers_tbl
    ADD COLUMN recover_requested_at DATETIME DEFAULT NULL
    COMMENT 'When recovery token was generated; tokens expire after 1 hour';
