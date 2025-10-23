-- Migration: Applicant Rating System
-- This migration adds a rating system for applicants

-- Create applicant_ratings table
CREATE TABLE IF NOT EXISTS applicant_ratings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    rated_by_type ENUM('coordinator', 'company') NOT NULL,
    rated_by_id INT NOT NULL,
    rating DECIMAL(2,1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    comment TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (application_id) REFERENCES job_applications(id) ON DELETE CASCADE,
    UNIQUE KEY unique_rating (application_id, rated_by_type, rated_by_id),
    INDEX idx_application (application_id),
    INDEX idx_rated_by (rated_by_type, rated_by_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add average_rating column to job_applications table
ALTER TABLE job_applications 
ADD COLUMN average_rating DECIMAL(3,2) NULL DEFAULT NULL AFTER ats_score,
ADD COLUMN rating_count INT DEFAULT 0 AFTER average_rating;

-- Create index for rating filtering
CREATE INDEX idx_average_rating ON job_applications(average_rating DESC);


