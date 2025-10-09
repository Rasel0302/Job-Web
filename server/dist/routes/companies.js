import express from 'express';
import { asyncHandler } from '../middleware/errorHandler.js';
import { authenticate, authorize } from '../middleware/auth.js';
import { getConnection } from '../config/database.js';
const router = express.Router();
// Get company profile
router.get('/profile', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [companyProfile] = await connection.execute(`
    SELECT 
      c.id,
      c.email,
      c.role,
      cp.company_name,
      cp.business_summary,
      cp.key_requirements,
      cp.profile_completed
    FROM companies c
    LEFT JOIN company_profiles cp ON c.id = cp.company_id
    WHERE c.id = ?
  `, [req.user.id]);
    if (companyProfile.length === 0) {
        return res.status(404).json({ message: 'Company not found' });
    }
    res.json(companyProfile[0]);
}));
// Complete company profile
router.post('/complete-profile', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const { companyName, businessSummary, keyRequirements } = req.body;
    if (!companyName) {
        return res.status(400).json({ message: 'Company name is required' });
    }
    const connection = getConnection();
    // Check if profile already exists
    const [existingProfile] = await connection.execute('SELECT id FROM company_profiles WHERE company_id = ?', [req.user.id]);
    if (existingProfile.length > 0) {
        // Update existing profile
        await connection.execute(`
      UPDATE company_profiles 
      SET company_name = ?, business_summary = ?, key_requirements = ?, profile_completed = TRUE, updated_at = NOW()
      WHERE company_id = ?
    `, [companyName, businessSummary, keyRequirements, req.user.id]);
    }
    else {
        // Create new profile
        await connection.execute(`
      INSERT INTO company_profiles (company_id, company_name, business_summary, key_requirements, profile_completed)
      VALUES (?, ?, ?, ?, TRUE)
    `, [req.user.id, companyName, businessSummary, keyRequirements]);
    }
    res.json({ message: 'Company profile completed successfully' });
}));
// Update company profile
router.put('/profile', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const { companyName, businessSummary, keyRequirements } = req.body;
    const connection = getConnection();
    await connection.execute(`
    UPDATE company_profiles 
    SET company_name = ?, business_summary = ?, key_requirements = ?, updated_at = NOW()
    WHERE company_id = ?
  `, [companyName, businessSummary, keyRequirements, req.user.id]);
    res.json({ message: 'Company profile updated successfully' });
}));
// Get all companies (for public viewing)
router.get('/', asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [companies] = await connection.execute(`
    SELECT 
      c.id,
      cp.company_name,
      cp.business_summary,
      cp.key_requirements,
      COUNT(j.id) as job_count
    FROM companies c
    JOIN company_profiles cp ON c.id = cp.company_id
    LEFT JOIN jobs j ON c.id = j.company_id AND j.is_active = TRUE
    WHERE c.is_verified = TRUE AND c.is_approved = TRUE AND cp.profile_completed = TRUE
    GROUP BY c.id, cp.company_name, cp.business_summary, cp.key_requirements
    ORDER BY cp.company_name
  `);
    res.json(companies);
}));
// Get specific company
router.get('/:id', asyncHandler(async (req, res) => {
    const { id } = req.params;
    const connection = getConnection();
    const [company] = await connection.execute(`
    SELECT 
      c.id,
      cp.company_name,
      cp.business_summary,
      cp.key_requirements
    FROM companies c
    JOIN company_profiles cp ON c.id = cp.company_id
    WHERE c.id = ? AND c.is_verified = TRUE AND c.is_approved = TRUE AND cp.profile_completed = TRUE
  `, [id]);
    if (company.length === 0) {
        return res.status(404).json({ message: 'Company not found' });
    }
    // Get company jobs
    const [jobs] = await connection.execute(`
    SELECT 
      j.id,
      j.title,
      j.description,
      j.work_type,
      j.experience_level,
      j.location,
      CASE 
        WHEN j.min_salary IS NOT NULL AND j.max_salary IS NOT NULL 
        THEN CONCAT(j.currency, ' ', j.min_salary, ' - ', j.max_salary)
        WHEN j.min_salary IS NOT NULL 
        THEN CONCAT(j.currency, ' ', j.min_salary, '+')
        ELSE 'Negotiable'
      END as salary_range,
      j.category as category_name
    FROM jobs j
    WHERE j.created_by_type = 'company' AND j.created_by_id = ? AND j.status = 'active'
    ORDER BY j.created_at DESC
  `, [id]);
    res.json({
        ...company[0],
        jobs: jobs
    });
}));
export default router;
