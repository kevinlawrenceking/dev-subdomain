-- Create auditionsimport_error table for tracking validation errors during audition imports
-- Author: Kevin King
-- Date: 2025-07-26

CREATE TABLE IF NOT EXISTS `auditionsimport_error` (
    `id` INT(11) NOT NULL,
    `error_msg` VARCHAR(500) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
