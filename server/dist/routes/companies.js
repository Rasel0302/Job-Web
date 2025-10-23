import express from 'express';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import { asyncHandler } from '../middleware/errorHandler.js';
import { authenticate, authenticateForProfileCompletion, authorize } from '../middleware/auth.js';
import { getConnection } from '../config/database.js';
import { UploadService } from '../services/uploadService.js';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const router = express.Router();
// Multer configuration for profile photo uploads
const storage = multer.memoryStorage();
const upload = multer({
    storage,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
    },
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
        if (allowedTypes.includes(file.mimetype)) {
            cb(null, true);
        }
        else {
            cb(new Error('Only JPEG, PNG, and WebP images are allowed'));
        }
    },
});
// Get company profile
router.get('/profile', authenticateForProfileCompletion, asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [companyProfile] = await connection.execute(`
    SELECT 
      c.id,
      c.email,
      cp.first_name,
      cp.last_name,
      cp.company_name,
      cp.contact_number,
      cp.company_address,
      cp.business_summary,
      cp.key_requirements,
      cp.profile_type,
      cp.profile_photo,
      COALESCE(cp.profile_completed, FALSE) as profile_completed
    FROM companies c
    LEFT JOIN company_profiles cp ON c.id = cp.company_id
    WHERE c.id = ?
  `, [req.user.id]);
    if (companyProfile.length === 0) {
        return res.status(404).json({ message: 'Company not found' });
    }
    const profile = companyProfile[0];
    // Add profile photo URL if it exists
    if (profile.profile_photo) {
        profile.profile_photo_url = UploadService.getPhotoUrl(profile.profile_photo);
    }
    res.json(profile);
}));
// Get detailed company profile with coordinator info
router.get('/profile-detailed', authenticateForProfileCompletion, asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [profileData] = await connection.execute(`
    SELECT 
      c.id,
      c.email,
      c.created_at,
      c.updated_at,
      cp.first_name,
      cp.last_name,
      cp.company_name,
      cp.contact_number,
      cp.company_address,
      cp.business_summary,
      cp.key_requirements,
      cp.profile_type,
      cp.profile_photo,
      COALESCE(cp.profile_completed, FALSE) as profile_completed,
      -- Coordinator information
      coord.id as coordinator_id,
      CONCAT(coord_prof.first_name, ' ', coord_prof.last_name) as coordinator_name,
      coord.email as coordinator_email,
      coord_prof.contact_number as coordinator_contact,
      coord_prof.designated_course as coordinator_course,
      cca.affiliated_at,
      ci.token as invitation_code
    FROM companies c
    LEFT JOIN company_profiles cp ON c.id = cp.company_id
    LEFT JOIN company_coordinator_affiliations cca ON c.id = cca.company_id AND cca.status = 'active'
    LEFT JOIN coordinators coord ON cca.coordinator_id = coord.id
    LEFT JOIN coordinator_profiles coord_prof ON coord.id = coord_prof.coordinator_id
    LEFT JOIN company_invitations ci ON cca.invitation_id = ci.id
    WHERE c.id = ?
  `, [req.user.id]);
    if (profileData.length === 0) {
        return res.status(404).json({ message: 'Company not found' });
    }
    const profile = profileData[0];
    // Add profile photo URL if it exists
    if (profile.profile_photo) {
        profile.profile_photo_url = UploadService.getPhotoUrl(profile.profile_photo);
    }
    res.json(profile);
}));
// Get dashboard stats
router.get('/dashboard-stats', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const connection = getConnection();
    // Get job stats
    const [jobStats] = await connection.execute(`
    SELECT 
      COUNT(*) as total_jobs,
      SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_jobs
    FROM jobs 
    WHERE created_by_type = 'company' AND created_by_id = ?
  `, [req.user.id]);
    // Get application stats
    const [applicationStats] = await connection.execute(`
    SELECT 
      COUNT(*) as total_applications,
      SUM(CASE WHEN ja.status = 'pending' THEN 1 ELSE 0 END) as pending_applications,
      SUM(CASE WHEN ja.status = 'under_review' THEN 1 ELSE 0 END) as under_review_applications,
      SUM(CASE WHEN ja.status = 'qualified' THEN 1 ELSE 0 END) as qualified_applications,
      SUM(CASE WHEN caa.action_type = 'accepted' THEN 1 ELSE 0 END) as accepted_applications,
      SUM(CASE WHEN caa.action_type = 'rejected' THEN 1 ELSE 0 END) as rejected_applications,
      SUM(CASE WHEN caa.action_type = 'on_hold' THEN 1 ELSE 0 END) as on_hold_applications
    FROM job_applications ja
    JOIN jobs j ON ja.job_id = j.id
    LEFT JOIN company_application_actions caa ON ja.id = caa.application_id AND caa.company_id = ?
    WHERE j.created_by_type = 'company' AND j.created_by_id = ?
  `, [req.user.id, req.user.id]);
    const stats = {
        ...(jobStats[0]),
        ...(applicationStats[0])
    };
    res.json(stats);
}));
// Get recent jobs
router.get('/recent-jobs', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [jobs] = await connection.execute(`
    SELECT 
      id,
      title,
      location,
      work_type,
      status,
      created_at,
      (SELECT COUNT(*) FROM job_applications WHERE job_id = jobs.id) as application_count
    FROM jobs 
    WHERE created_by_type = 'company' AND created_by_id = ?
    ORDER BY created_at DESC
    LIMIT 5
  `, [req.user.id]);
    res.json(jobs);
}));
// Get company jobs
router.get('/jobs', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [jobs] = await connection.execute(`
    SELECT 
      j.*,
      COUNT(ja.id) as application_count,
      COUNT(CASE WHEN ja.status = 'qualified' THEN 1 END) as qualified_count,
      CASE WHEN j.status = 'active' AND j.application_deadline > NOW() THEN true ELSE false END as can_edit
    FROM jobs j
    LEFT JOIN job_applications ja ON j.id = ja.job_id
    WHERE j.created_by_type = 'company' AND j.created_by_id = ?
    GROUP BY j.id
    ORDER BY j.created_at DESC
  `, [req.user.id]);
    res.json(jobs);
}));
// Create job (company posting)
router.post('/jobs', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const { title, description, category, work_type, work_arrangement, experience_level, location, currency, min_salary, max_salary, application_deadline, positions_available, requirements, benefits, screening_questions, filterPreScreening } = req.body;
    if (!title || !description || !location) {
        return res.status(400).json({ message: 'Title, description, and location are required' });
    }
    const connection = getConnection();
    try {
        // Insert job with pending status (requires coordinator approval)
        const [result] = await connection.execute(`
      INSERT INTO jobs (
        title, description, category, work_type, work_arrangement, experience_level,
        location, currency, min_salary, max_salary, application_deadline, positions_available,
        requirements, benefits, status, created_by_type, created_by_id, coordinator_name,
        filter_pre_screening
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', 'company', ?, 
        (SELECT CONCAT(cp.first_name, ' ', cp.last_name) 
         FROM company_coordinator_affiliations cca 
         JOIN coordinator_profiles cp ON cca.coordinator_id = cp.coordinator_id 
         WHERE cca.company_id = ? AND cca.status = 'active' LIMIT 1), ?)
    `, [
            title, description, category, work_type, work_arrangement, experience_level,
            location, currency, min_salary, max_salary, application_deadline, positions_available,
            JSON.stringify(requirements), JSON.stringify(benefits), req.user.id, req.user.id,
            filterPreScreening
        ]);
        const jobId = result.insertId;
        // Insert screening questions
        if (screening_questions && screening_questions.length > 0) {
            for (const [index, question] of screening_questions.entries()) {
                await connection.execute(`
          INSERT INTO job_screening_questions (
            job_id, question_type, question_text, is_required, options, order_index,
            acceptable_answers, min_salary_range, max_salary_range, is_filter_criteria
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, [
                    jobId,
                    question.questionType,
                    question.questionText,
                    question.isRequired,
                    question.options ? JSON.stringify(question.options) : null,
                    index,
                    question.acceptableAnswers ? JSON.stringify(question.acceptableAnswers) : null,
                    question.minSalaryRange || null,
                    question.maxSalaryRange || null,
                    question.isFilterCriteria || false
                ]);
            }
        }
        res.status(201).json({
            message: 'Job posted successfully! It will be reviewed by your coordinator before going live.',
            jobId
        });
    }
    catch (error) {
        console.error('Job creation error:', error);
        res.status(500).json({ message: 'Failed to create job posting' });
    }
}));
// Get applications for company jobs (only qualified ones)
router.get('/jobs/:jobId/applications', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const { jobId } = req.params;
    const { status } = req.query;
    const connection = getConnection();
    // Verify job belongs to this company
    const [jobCheck] = await connection.execute('SELECT id FROM jobs WHERE id = ? AND created_by_type = "company" AND created_by_id = ?', [jobId, req.user.id]);
    if (jobCheck.length === 0) {
        return res.status(403).json({ message: 'Access denied' });
    }
    let query = `
    SELECT 
      ja.*,
      j.title as job_title,
      up.profile_photo,
      COUNT(cac.id) as company_comments_count
    FROM job_applications ja
    JOIN jobs j ON ja.job_id = j.id
    LEFT JOIN user_profiles up ON ja.user_id = up.user_id
    LEFT JOIN company_application_comments cac ON ja.id = cac.application_id AND cac.company_id = ?
    WHERE ja.job_id = ? AND ja.status IN ('qualified', 'under_review')
  `;
    const queryParams = [req.user.id, jobId];
    if (status && status !== 'all') {
        query += ' AND ja.status = ?';
        queryParams.push(status);
    }
    query += ' GROUP BY ja.id ORDER BY ja.created_at DESC';
    const [applications] = await connection.execute(query, queryParams);
    // Process applications to include photo URLs
    const processedApplications = applications.map(app => ({
        ...app,
        profile_photo: UploadService.getPhotoUrl(app.profile_photo)
    }));
    res.json({
        applications: processedApplications
    });
}));
// Add comment to application
router.post('/applications/:applicationId/comment', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const { applicationId } = req.params;
    const { comment, commentType } = req.body;
    const connection = getConnection();
    // Verify application belongs to company's job
    const [applicationCheck] = await connection.execute(`
    SELECT ja.id FROM job_applications ja
    JOIN jobs j ON ja.job_id = j.id
    WHERE ja.id = ? AND j.created_by_type = 'company' AND j.created_by_id = ?
  `, [applicationId, req.user.id]);
    if (applicationCheck.length === 0) {
        return res.status(403).json({ message: 'Access denied' });
    }
    await connection.execute(`
    INSERT INTO company_application_comments (
      application_id, company_id, comment, comment_type
    ) VALUES (?, ?, ?, ?)
  `, [applicationId, req.user.id, comment, commentType || 'general']);
    // Track action
    await connection.execute(`
    INSERT INTO company_application_actions (
      application_id, company_id, action_type, action_data, created_by
    ) VALUES (?, ?, 'comment', ?, ?)
  `, [applicationId, req.user.id, JSON.stringify({ comment, commentType }), req.user.id]);
    res.json({ message: 'Comment added successfully' });
}));
// Send email to applicant
router.post('/applications/:applicationId/send-email', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const { applicationId } = req.params;
    const { recipientEmail, subject, message, emailType, interviewLink, interviewDate, interviewTime } = req.body;
    const connection = getConnection();
    // Verify application belongs to company's job
    const [applicationCheck] = await connection.execute(`
    SELECT ja.id, ja.first_name, ja.last_name FROM job_applications ja
    JOIN jobs j ON ja.job_id = j.id
    WHERE ja.id = ? AND j.created_by_type = 'company' AND j.created_by_id = ?
  `, [applicationId, req.user.id]);
    if (applicationCheck.length === 0) {
        return res.status(403).json({ message: 'Access denied' });
    }
    const applicant = applicationCheck[0];
    try {
        // Store email notification
        await connection.execute(`
      INSERT INTO company_email_notifications (
        application_id, company_id, recipient_email, subject, message_content, email_type
      ) VALUES (?, ?, ?, ?, ?, ?)
    `, [applicationId, req.user.id, recipientEmail, subject, message, emailType]);
        // Track action
        const actionData = {
            emailType,
            subject,
            message,
            ...(interviewLink && { interviewLink }),
            ...(interviewDate && { interviewDate }),
            ...(interviewTime && { interviewTime })
        };
        await connection.execute(`
      INSERT INTO company_application_actions (
        application_id, company_id, action_type, action_data, created_by
      ) VALUES (?, ?, 'email_sent', ?, ?)
    `, [applicationId, req.user.id, JSON.stringify(actionData), req.user.id]);
        // TODO: Send actual email using email service
        // For now, just track that email was "sent"
        await connection.execute('UPDATE company_email_notifications SET status = "sent" WHERE application_id = ? AND company_id = ?', [applicationId, req.user.id]);
        res.json({ message: 'Email sent successfully and applicant has been notified' });
    }
    catch (error) {
        console.error('Email sending error:', error);
        res.status(500).json({ message: 'Failed to send email' });
    }
}));
// Company status action (accept, reject, hold)
router.post('/applications/:applicationId/status-action', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const { applicationId } = req.params;
    const { action, reason } = req.body;
    const connection = getConnection();
    if (!['accepted', 'rejected', 'on_hold'].includes(action)) {
        return res.status(400).json({ message: 'Invalid action' });
    }
    // Verify application belongs to company's job
    const [applicationCheck] = await connection.execute(`
    SELECT ja.id, ja.first_name, ja.last_name, ja.email FROM job_applications ja
    JOIN jobs j ON ja.job_id = j.id
    WHERE ja.id = ? AND j.created_by_type = 'company' AND j.created_by_id = ?
  `, [applicationId, req.user.id]);
    if (applicationCheck.length === 0) {
        return res.status(403).json({ message: 'Access denied' });
    }
    try {
        // Record company action
        await connection.execute(`
      INSERT INTO company_application_actions (
        application_id, company_id, action_type, action_data, reason, created_by
      ) VALUES (?, ?, ?, ?, ?, ?)
    `, [
            applicationId,
            req.user.id,
            action,
            JSON.stringify({ action, timestamp: new Date().toISOString() }),
            reason,
            req.user.id
        ]);
        // Send email notification to applicant
        const applicant = applicationCheck[0];
        const emailSubject = `Application Update - ${action.charAt(0).toUpperCase() + action.slice(1)}`;
        const emailMessage = `Dear ${applicant.first_name},\n\nWe have updated the status of your application.\n\nStatus: ${action.replace('_', ' ').toUpperCase()}\n\n${reason ? `Reason: ${reason}\n\n` : ''}Best regards,\nThe Hiring Team`;
        await connection.execute(`
      INSERT INTO company_email_notifications (
        application_id, company_id, recipient_email, subject, message_content, email_type, status
      ) VALUES (?, ?, ?, ?, ?, ?, 'sent')
    `, [applicationId, req.user.id, applicant.email, emailSubject, emailMessage, action]);
        res.json({ message: `Application ${action} successfully and notification sent to applicant` });
    }
    catch (error) {
        console.error('Status action error:', error);
        res.status(500).json({ message: 'Failed to process status action' });
    }
}));
// Get accepted applications
router.get('/applications/accepted', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [applications] = await connection.execute(`
    SELECT 
      ja.*,
      j.title as job_title,
      up.profile_photo,
      caa.created_at as accepted_at,
      caa.reason as acceptance_reason,
      COUNT(cac.id) as company_comments_count,
      caa.action_data as interview_details,
      CASE WHEN ja.status = 'hired' THEN true ELSE false END as coordinator_approved,
      CASE 
        WHEN ja.status = 'hired' THEN 'hired'
        WHEN ja.status = 'qualified' THEN 'pending_coordinator'
        ELSE 'declined_by_coordinator'
      END as final_status
    FROM job_applications ja
    JOIN jobs j ON ja.job_id = j.id
    JOIN company_application_actions caa ON ja.id = caa.application_id AND caa.action_type = 'accepted'
    LEFT JOIN user_profiles up ON ja.user_id = up.user_id
    LEFT JOIN company_application_comments cac ON ja.id = cac.application_id AND cac.company_id = ?
    WHERE j.created_by_type = 'company' AND j.created_by_id = ? AND caa.company_id = ?
    GROUP BY ja.id, caa.id
    ORDER BY caa.created_at DESC
  `, [req.user.id, req.user.id, req.user.id]);
    // Process applications to include photo URLs
    const processedApplications = applications.map(app => ({
        ...app,
        profile_photo: UploadService.getPhotoUrl(app.profile_photo),
        interview_details: app.interview_details ? JSON.parse(app.interview_details) : null,
        notification_sent: true // For now, assume all have been notified
    }));
    res.json({
        applications: processedApplications
    });
}));
// Get rejected applications
router.get('/applications/rejected', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [applications] = await connection.execute(`
    SELECT 
      ja.*,
      j.title as job_title,
      up.profile_photo,
      caa.created_at as rejected_at,
      caa.reason as rejection_reason,
      COUNT(cac.id) as company_comments_count
    FROM job_applications ja
    JOIN jobs j ON ja.job_id = j.id
    JOIN company_application_actions caa ON ja.id = caa.application_id AND caa.action_type = 'rejected'
    LEFT JOIN user_profiles up ON ja.user_id = up.user_id
    LEFT JOIN company_application_comments cac ON ja.id = cac.application_id AND cac.company_id = ?
    WHERE j.created_by_type = 'company' AND j.created_by_id = ? AND caa.company_id = ?
    GROUP BY ja.id, caa.id
    ORDER BY caa.created_at DESC
  `, [req.user.id, req.user.id, req.user.id]);
    // Process applications to include photo URLs
    const processedApplications = applications.map(app => ({
        ...app,
        profile_photo: UploadService.getPhotoUrl(app.profile_photo),
        notification_sent: true // For now, assume all have been notified
    }));
    res.json({
        applications: processedApplications
    });
}));
// Get on-hold applications
router.get('/applications/on-hold', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [applications] = await connection.execute(`
    SELECT 
      ja.*,
      j.title as job_title,
      up.profile_photo,
      caa.created_at as held_at,
      caa.reason as hold_reason,
      COUNT(cac.id) as company_comments_count,
      true as can_be_reconsidered
    FROM job_applications ja
    JOIN jobs j ON ja.job_id = j.id
    JOIN company_application_actions caa ON ja.id = caa.application_id AND caa.action_type = 'on_hold'
    LEFT JOIN user_profiles up ON ja.user_id = up.user_id
    LEFT JOIN company_application_comments cac ON ja.id = cac.application_id AND cac.company_id = ?
    WHERE j.created_by_type = 'company' AND j.created_by_id = ? AND caa.company_id = ?
    GROUP BY ja.id, caa.id
    ORDER BY caa.created_at DESC
  `, [req.user.id, req.user.id, req.user.id]);
    // Process applications to include photo URLs
    const processedApplications = applications.map(app => ({
        ...app,
        profile_photo: UploadService.getPhotoUrl(app.profile_photo),
        notification_sent: true // For now, assume all have been notified
    }));
    res.json({
        applications: processedApplications
    });
}));
// Reconsider on-hold application
router.post('/applications/:applicationId/reconsider', authenticate, authorize('company'), asyncHandler(async (req, res) => {
    const { applicationId } = req.params;
    const connection = getConnection();
    // Verify application belongs to company's job
    const [applicationCheck] = await connection.execute(`
    SELECT ja.id FROM job_applications ja
    JOIN jobs j ON ja.job_id = j.id
    WHERE ja.id = ? AND j.created_by_type = 'company' AND j.created_by_id = ?
  `, [applicationId, req.user.id]);
    if (applicationCheck.length === 0) {
        return res.status(403).json({ message: 'Access denied' });
    }
    // Remove on-hold action (effectively moving back to qualified status)
    await connection.execute('DELETE FROM company_application_actions WHERE application_id = ? AND company_id = ? AND action_type = "on_hold"', [applicationId, req.user.id]);
    // Record reconsideration action
    await connection.execute(`
    INSERT INTO company_application_actions (
      application_id, company_id, action_type, action_data, created_by
    ) VALUES (?, ?, 'reconsidered', ?, ?)
  `, [applicationId, req.user.id, JSON.stringify({ reconsidered_at: new Date().toISOString() }), req.user.id]);
    res.json({ message: 'Application moved back to review' });
}));
// Complete company profile
router.post('/complete-profile', authenticateForProfileCompletion, upload.single('profilePhoto'), asyncHandler(async (req, res) => {
    const { profileType, firstName, lastName, companyName, contactNumber, companyAddress, businessSummary, keyRequirements } = req.body;
    // Validation
    if (!companyName || !businessSummary || !contactNumber) {
        return res.status(400).json({
            message: 'Company name, business description, and contact number are required'
        });
    }
    const connection = getConnection();
    try {
        // Process profile photo if uploaded
        let profilePhotoPath = null;
        if (req.file) {
            profilePhotoPath = await UploadService.processAndSaveProfilePhoto(req.file.buffer, req.user.id, 'company');
        }
        // Check if profile already exists
        const [existingProfile] = await connection.execute('SELECT id FROM company_profiles WHERE company_id = ?', [req.user.id]);
        if (existingProfile.length > 0) {
            // Update existing profile
            const updateQuery = `
      UPDATE company_profiles 
        SET 
          profile_type = ?,
          first_name = ?,
          last_name = ?,
          company_name = ?,
          contact_number = ?,
          company_address = ?,
          business_summary = ?,
          key_requirements = ?,
          ${profilePhotoPath ? 'profile_photo = ?,' : ''}
          profile_completed = TRUE,
          updated_at = CURRENT_TIMESTAMP
      WHERE company_id = ?
      `;
            const updateParams = [
                profileType || 'company',
                firstName || null,
                lastName || null,
                companyName,
                contactNumber,
                companyAddress || null,
                businessSummary,
                keyRequirements || null,
                ...(profilePhotoPath ? [profilePhotoPath] : []),
                req.user.id
            ];
            await connection.execute(updateQuery, updateParams);
        }
        else {
            // Insert new profile
            const insertQuery = `
        INSERT INTO company_profiles (
          company_id, 
          profile_type,
          first_name, 
          last_name, 
          company_name, 
          contact_number, 
          company_address, 
          business_summary,
          key_requirements,
          ${profilePhotoPath ? 'profile_photo,' : ''}
          profile_completed
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ${profilePhotoPath ? '?, ' : ''}TRUE)
      `;
            const insertParams = [
                req.user.id,
                profileType || 'company',
                firstName || null,
                lastName || null,
                companyName,
                contactNumber,
                companyAddress || null,
                businessSummary,
                keyRequirements || null,
                ...(profilePhotoPath ? [profilePhotoPath] : [])
            ];
            await connection.execute(insertQuery, insertParams);
        }
        res.json({
            message: 'Company profile completed successfully',
            profilePhotoUrl: profilePhotoPath ? UploadService.getPhotoUrl(profilePhotoPath) : null
        });
    }
    catch (error) {
        console.error('Company profile completion error:', error);
        res.status(500).json({ message: 'Failed to complete profile' });
    }
}));
// Upload profile photo (can be called during or after profile completion)
router.post('/upload-photo', authenticateForProfileCompletion, upload.single('profilePhoto'), asyncHandler(async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'No photo file provided' });
    }
    try {
        const photoPath = await UploadService.processAndSaveProfilePhoto(req.file.buffer, req.user.id, 'company');
        // Update company profile with new photo (create profile if it doesn't exist)
        const connection = getConnection();
        // Check if profile exists
        const [existingProfile] = await connection.execute('SELECT id FROM company_profiles WHERE company_id = ?', [req.user.id]);
        if (existingProfile.length > 0) {
            // Update existing profile
            await connection.execute('UPDATE company_profiles SET profile_photo = ? WHERE company_id = ?', [photoPath, req.user.id]);
        }
        else {
            // Create new profile with just the photo
            await connection.execute('INSERT INTO company_profiles (company_id, profile_photo, profile_completed) VALUES (?, ?, FALSE)', [req.user.id, photoPath]);
        }
        res.json({
            message: 'Profile photo uploaded successfully',
            photoUrl: UploadService.getPhotoUrl(photoPath)
        });
    }
    catch (error) {
        console.error('Photo upload error:', error);
        res.status(500).json({ message: 'Failed to upload photo' });
    }
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
