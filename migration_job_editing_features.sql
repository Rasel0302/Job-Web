-- Migration script for job editing and application review features
-- Run this script to update your database with the new features

-- Add filter_pre_screening column to jobs table
ALTER TABLE jobs ADD COLUMN filter_pre_screening BOOLEAN DEFAULT FALSE;

-- Add new columns to job_screening_questions table for filtering
ALTER TABLE job_screening_questions 
ADD COLUMN acceptable_answers JSON NULL COMMENT 'Acceptable answers for filtering',
ADD COLUMN min_salary_range DECIMAL(10, 2) NULL COMMENT 'For salary range questions',
ADD COLUMN max_salary_range DECIMAL(10, 2) NULL COMMENT 'For salary range questions',
ADD COLUMN is_filter_criteria BOOLEAN DEFAULT FALSE COMMENT 'Whether this question is used for filtering';

-- Update job creation and editing to support the new fields
-- This will be handled by the application code

-- The following tables are already properly structured:
-- - job_applications (for storing applications)
-- - job_application_answers (for storing screening question answers)  
-- - job_application_comments (for business owner and coordinator comments)

-- Index for better performance on filtering
CREATE INDEX idx_screening_filter ON job_screening_questions(job_id, is_filter_criteria);

SELECT 'Migration completed successfully!' as status;
