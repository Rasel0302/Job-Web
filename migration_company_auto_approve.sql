-- Migration: Auto-approve all companies
-- Companies with valid invitations should be automatically approved

-- Update all existing companies to be approved
UPDATE companies 
SET is_approved = TRUE 
WHERE is_approved = FALSE OR is_approved IS NULL;

-- Verify the update
SELECT 
    id, 
    email, 
    is_approved, 
    is_verified,
    created_at 
FROM companies;

