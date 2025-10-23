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
    INDEX `idx_rated_by` (`rated_by_type`, `rated_by_id`),
    CONSTRAINT `fk_applicant_ratings_application` 
        FOREIGN KEY (`application_id`) 
        REFERENCES `job_applications` (`id`) 
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add rating columns to job_applications table
-- Note: If columns already exist, you can ignore the error or comment out these lines
ALTER TABLE `job_applications` 
ADD COLUMN `average_rating` DECIMAL(3,2) NULL DEFAULT NULL AFTER `ats_score`,
ADD COLUMN `rating_count` INT DEFAULT 0 AFTER `average_rating`;

-- Create index for rating filtering
ALTER TABLE `job_applications` 
ADD INDEX `idx_average_rating` (`average_rating` DESC);

