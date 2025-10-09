-- Coordinator Profile System Migration
-- Run this SQL script to update your database for the coordinator profile system

-- Update coordinator_profiles table structure
ALTER TABLE coordinator_profiles 
  CHANGE profile_completed is_profile_complete BOOLEAN DEFAULT FALSE;

-- Make profile fields optional (nullable) since they're filled during profile completion
ALTER TABLE coordinator_profiles 
  MODIFY first_name VARCHAR(50) NULL,
  MODIFY last_name VARCHAR(50) NULL,
  MODIFY designated_course VARCHAR(100) NULL;

-- Update gender enum to match admin system
ALTER TABLE coordinator_profiles 
  MODIFY gender ENUM('male', 'female', 'other');

-- Verify the changes
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'acc_career_connect' 
  AND TABLE_NAME = 'coordinator_profiles'
ORDER BY ORDINAL_POSITION;
