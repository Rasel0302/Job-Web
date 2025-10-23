-- Migration: Enhanced Company Profile Fields
-- Add additional fields needed for company/business owner profile completion

USE acc_database;

-- Add new columns to company_profiles table
ALTER TABLE company_profiles 
ADD COLUMN first_name VARCHAR(50) NULL COMMENT 'Business owner first name (optional)',
ADD COLUMN last_name VARCHAR(50) NULL COMMENT 'Business owner last name (optional)',
ADD COLUMN contact_number VARCHAR(20) NULL COMMENT 'Contact phone number',
ADD COLUMN company_address TEXT NULL COMMENT 'Company/business address (optional)',
ADD COLUMN profile_type ENUM('company', 'business_owner') DEFAULT 'company' COMMENT 'Type: company or business owner',
ADD COLUMN profile_photo VARCHAR(255) NULL COMMENT 'Business owner photo or company logo path';

-- Update existing records to set profile_photo from company_logo if exists
UPDATE company_profiles 
SET profile_photo = company_logo 
WHERE company_logo IS NOT NULL AND company_logo != '';

-- Add index for better performance
CREATE INDEX idx_company_profiles_type ON company_profiles(profile_type);
CREATE INDEX idx_company_profiles_completed ON company_profiles(profile_completed);
