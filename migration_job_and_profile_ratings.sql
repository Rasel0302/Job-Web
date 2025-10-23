-- Migration for Job Posts and Coordinator/Company Rating System

-- 1. Create job ratings table
CREATE TABLE IF NOT EXISTS `job_ratings` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `job_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `rating` DECIMAL(2,1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
  `review` TEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY `unique_job_rating` (`job_id`, `user_id`),
  INDEX `idx_job_id` (`job_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_rating` (`rating` DESC),
  
  CONSTRAINT `fk_job_ratings_job`
    FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_job_ratings_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Create coordinator ratings table (users rating coordinators)
CREATE TABLE IF NOT EXISTS `coordinator_ratings` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `coordinator_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `rating` DECIMAL(2,1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
  `review` TEXT NULL,
  `context` ENUM('job_post', 'team_page') NOT NULL DEFAULT 'job_post',
  `job_id` INT NULL, -- Reference to job if rated from job post
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY `unique_coordinator_rating` (`coordinator_id`, `user_id`),
  INDEX `idx_coordinator_id` (`coordinator_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_rating` (`rating` DESC),
  INDEX `idx_context` (`context`),
  
  CONSTRAINT `fk_coordinator_ratings_coordinator`
    FOREIGN KEY (`coordinator_id`) REFERENCES `coordinators` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_coordinator_ratings_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_coordinator_ratings_job`
    FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Create company ratings table (users rating companies)
CREATE TABLE IF NOT EXISTS `company_ratings` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `company_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `rating` DECIMAL(2,1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
  `review` TEXT NULL,
  `context` ENUM('job_post', 'team_page') NOT NULL DEFAULT 'job_post',
  `job_id` INT NULL, -- Reference to job if rated from job post
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY `unique_company_rating` (`company_id`, `user_id`),
  INDEX `idx_company_id` (`company_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_rating` (`rating` DESC),
  INDEX `idx_context` (`context`),
  
  CONSTRAINT `fk_company_ratings_company`
    FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_company_ratings_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_company_ratings_job`
    FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Add aggregated rating fields to jobs table
ALTER TABLE `jobs` 
ADD COLUMN IF NOT EXISTS `average_rating` DECIMAL(3,2) NULL DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `rating_count` INT DEFAULT 0,
ADD INDEX IF NOT EXISTS `idx_job_average_rating` (`average_rating` DESC);

-- 5. Add aggregated rating fields to coordinator_profiles table
ALTER TABLE `coordinator_profiles`
ADD COLUMN IF NOT EXISTS `average_rating` DECIMAL(3,2) NULL DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `rating_count` INT DEFAULT 0,
ADD INDEX IF NOT EXISTS `idx_coordinator_average_rating` (`average_rating` DESC);

-- 6. Add aggregated rating fields to company_profiles table  
ALTER TABLE `company_profiles`
ADD COLUMN IF NOT EXISTS `average_rating` DECIMAL(3,2) NULL DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `rating_count` INT DEFAULT 0,
ADD INDEX IF NOT EXISTS `idx_company_average_rating` (`average_rating` DESC);

-- Insert some sample data (optional - remove in production)
-- Note: Replace IDs with actual existing IDs from your database

-- Sample job ratings (uncomment and modify IDs as needed)
-- INSERT IGNORE INTO job_ratings (job_id, user_id, rating, review) VALUES
-- (1, 1, 4.5, 'Great job opportunity with good benefits'),
-- (1, 2, 5.0, 'Excellent company culture and growth opportunities'),
-- (2, 1, 3.5, 'Decent position but could offer better compensation');

-- Sample coordinator ratings (uncomment and modify IDs as needed)
-- INSERT IGNORE INTO coordinator_ratings (coordinator_id, user_id, rating, review, context) VALUES
-- (1, 1, 4.0, 'Very helpful and responsive coordinator', 'job_post'),
-- (1, 2, 4.5, 'Professional and supportive throughout the process', 'team_page');

-- Sample company ratings (uncomment and modify IDs as needed)
-- INSERT IGNORE INTO company_ratings (company_id, user_id, rating, review, context) VALUES
-- (1, 1, 4.5, 'Great company to work with, good communication', 'job_post'),
-- (1, 2, 5.0, 'Outstanding company culture and benefits', 'team_page');

-- Update aggregated ratings for jobs (run this after inserting sample data)
UPDATE jobs j SET 
  average_rating = (
    SELECT AVG(jr.rating) 
    FROM job_ratings jr 
    WHERE jr.job_id = j.id
  ),
  rating_count = (
    SELECT COUNT(jr.id) 
    FROM job_ratings jr 
    WHERE jr.job_id = j.id
  );

-- Update aggregated ratings for coordinators
UPDATE coordinator_profiles cp SET 
  average_rating = (
    SELECT AVG(cr.rating) 
    FROM coordinator_ratings cr 
    WHERE cr.coordinator_id = cp.coordinator_id
  ),
  rating_count = (
    SELECT COUNT(cr.id) 
    FROM coordinator_ratings cr 
    WHERE cr.coordinator_id = cp.coordinator_id
  );

-- Update aggregated ratings for companies
UPDATE company_profiles comp_p SET 
  average_rating = (
    SELECT AVG(comp_r.rating) 
    FROM company_ratings comp_r 
    WHERE comp_r.company_id = comp_p.company_id
  ),
  rating_count = (
    SELECT COUNT(comp_r.id) 
    FROM company_ratings comp_r 
    WHERE comp_r.company_id = comp_p.company_id
  );
