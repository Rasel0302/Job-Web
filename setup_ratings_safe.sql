-- Safe SQL to create ratings system
-- This can be run multiple times without causing errors

-- Drop existing table if you want to start fresh (OPTIONAL - comment out if you want to keep existing data)
-- DROP TABLE IF EXISTS `applicant_ratings`;

-- Create applicant_ratings table
CREATE TABLE IF NOT EXISTS `applicant_ratings` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `application_id` INT NOT NULL,
    `rated_by_type` ENUM('coordinator', 'company') NOT NULL,
    `rated_by_id` INT NOT NULL,
    `rating` DECIMAL(2,1) NOT NULL,
    `comment` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY `unique_rating` (`application_id`, `rated_by_type`, `rated_by_id`),
    INDEX `idx_application` (`application_id`),
    INDEX `idx_rated_by` (`rated_by_type`, `rated_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add foreign key if it doesn't exist
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
    WHERE CONSTRAINT_SCHEMA = DATABASE() 
    AND TABLE_NAME = 'applicant_ratings' 
    AND CONSTRAINT_NAME = 'fk_applicant_ratings_application');

SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `applicant_ratings` ADD CONSTRAINT `fk_applicant_ratings_application` 
     FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE',
    'SELECT "Foreign key already exists" AS info');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add average_rating column if it doesn't exist
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() 
    AND TABLE_NAME = 'job_applications' 
    AND COLUMN_NAME = 'average_rating');

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `job_applications` ADD COLUMN `average_rating` DECIMAL(3,2) NULL DEFAULT NULL',
    'SELECT "average_rating column already exists" AS info');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add rating_count column if it doesn't exist
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() 
    AND TABLE_NAME = 'job_applications' 
    AND COLUMN_NAME = 'rating_count');

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `job_applications` ADD COLUMN `rating_count` INT DEFAULT 0',
    'SELECT "rating_count column already exists" AS info');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add index if it doesn't exist
SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS 
    WHERE TABLE_SCHEMA = DATABASE() 
    AND TABLE_NAME = 'job_applications' 
    AND INDEX_NAME = 'idx_average_rating');

SET @sql = IF(@idx_exists = 0,
    'ALTER TABLE `job_applications` ADD INDEX `idx_average_rating` (`average_rating` DESC)',
    'SELECT "idx_average_rating index already exists" AS info');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Verify everything was created
SELECT 'Setup complete! Checking tables...' AS status;

SELECT 
    'applicant_ratings' AS table_name,
    COUNT(*) AS column_count 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'applicant_ratings';

SELECT 
    'job_applications rating columns' AS info,
    COUNT(*) AS count 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'job_applications' 
AND COLUMN_NAME IN ('average_rating', 'rating_count');


