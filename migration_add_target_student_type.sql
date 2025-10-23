-- Migration: Add target_student_type column to jobs table
-- Date: 2025-10-22
-- Description: Add field to specify which type of students can apply (OJT, graduated, or both)

ALTER TABLE jobs
ADD COLUMN target_student_type ENUM('ojt', 'graduated', 'both') DEFAULT 'both' 
AFTER experience_level;

-- Update existing jobs to have default value
UPDATE jobs 
SET target_student_type = 'both' 
WHERE target_student_type IS NULL;

-- Add index for better performance on filtering
CREATE INDEX idx_target_student_type ON jobs(target_student_type);

