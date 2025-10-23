import express from 'express';
import { asyncHandler } from '../middleware/errorHandler.js';
import { authenticate, authorize } from '../middleware/auth.js';
import { getConnection } from '../config/database.js';
import { JobRecommendationService } from '../services/jobRecommendationService.js';
import { UploadService } from '../services/uploadService.js';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const router = express.Router();
// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = path.join(__dirname, '../../uploads/resumes/');
        console.log('Upload destination:', uploadDir);
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const filename = file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname);
        console.log('Generated filename:', filename);
        cb(null, filename);
    }
});
const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['.pdf', '.doc', '.docx'];
        const ext = path.extname(file.originalname).toLowerCase();
        if (allowedTypes.includes(ext)) {
            cb(null, true);
        }
        else {
            cb(new Error('Only PDF, DOC, and DOCX files are allowed'));
        }
    }
});
// Add error handling for multer
const uploadMiddleware = (req, res, next) => {
    upload.single('resumeFile')(req, res, (err) => {
        if (err instanceof multer.MulterError) {
            if (err.code === 'LIMIT_FILE_SIZE') {
                return res.status(400).json({ message: 'File too large. Maximum size is 10MB.' });
            }
            return res.status(400).json({ message: `Upload error: ${err.message}` });
        }
        else if (err) {
            return res.status(400).json({ message: err.message });
        }
        next();
    });
};
// Get job categories by course
router.get('/categories/:course', asyncHandler(async (req, res) => {
    const { course } = req.params;
    const connection = getConnection();
    const [categories] = await connection.execute('SELECT category_name FROM job_categories WHERE course_name = ? ORDER BY category_name ASC', [course]);
    res.json(categories);
}));
// Get all job categories grouped by course
router.get('/categories', asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [categories] = await connection.execute(`
    SELECT course_name, category_name
    FROM job_categories 
    ORDER BY course_name ASC, category_name ASC
  `);
    // Group categories by course in JavaScript
    const groupedCategories = {};
    categories.forEach(row => {
        if (!groupedCategories[row.course_name]) {
            groupedCategories[row.course_name] = [];
        }
        groupedCategories[row.course_name].push(row.category_name);
    });
    // Convert to array format expected by frontend
    const result = Object.keys(groupedCategories).map(courseName => ({
        course_name: courseName,
        categories: groupedCategories[courseName]
    }));
    res.json(result);
}));
// Create a new job (coordinators and companies)
router.post('/', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req, res) => {
    const { title, location, category, workType, workArrangement, currency, minSalary, maxSalary, description, summary, videoUrl, companyName, applicationDeadline, positionsAvailable, experienceLevel, targetStudentType, coordinatorName, businessOwnerName, screeningQuestions, filterPreScreening } = req.body;
    if (!title || !location || !category || !description) {
        return res.status(400).json({ message: 'Title, location, category, and description are required' });
    }
    const connection = getConnection();
    try {
        await connection.beginTransaction();
        // Insert job
        const [jobResult] = await connection.execute(`
      INSERT INTO jobs (
        title, location, category, work_type, work_arrangement, 
        currency, min_salary, max_salary, description, summary, 
        video_url, company_name, application_deadline, positions_available, 
        experience_level, target_student_type, created_by_type, created_by_id, coordinator_name, 
        business_owner_name, filter_pre_screening
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
            title, location, category, workType || 'internship', workArrangement || 'on-site',
            currency || 'PHP', minSalary || null, maxSalary || null, description, summary || null,
            videoUrl || null, companyName || null, applicationDeadline || null, positionsAvailable || 1,
            experienceLevel || 'entry-level', targetStudentType || 'both', req.user.role, req.user.id, coordinatorName || null,
            businessOwnerName || null, filterPreScreening || false
        ]);
        const jobId = jobResult.insertId;
        // Insert screening questions if provided
        if (screeningQuestions && Array.isArray(screeningQuestions)) {
            for (let i = 0; i < screeningQuestions.length; i++) {
                const question = screeningQuestions[i];
                await connection.execute(`
          INSERT INTO job_screening_questions (
            job_id, question_text, question_type, options, is_required, order_index
          ) VALUES (?, ?, ?, ?, ?, ?)
        `, [
                    jobId,
                    question.questionText,
                    question.questionType,
                    question.options ? JSON.stringify(question.options) : null,
                    question.isRequired || false,
                    i
                ]);
            }
        }
        await connection.commit();
        res.status(201).json({
            message: 'Job created successfully',
            jobId: jobId
        });
    }
    catch (error) {
        await connection.rollback();
        throw error;
    }
}));
// Get all jobs with filtering and pagination
router.get('/', asyncHandler(async (req, res) => {
    const { category, workType, location, page = 1, limit = 10, search, createdBy } = req.query;
    const connection = getConnection();
    let query = `
    SELECT 
      j.*,
      CASE 
        WHEN j.created_by_type = 'coordinator' THEN 
          COALESCE(CONCAT(cp.first_name, ' ', cp.last_name), j.coordinator_name, 'Unknown Coordinator')
        WHEN j.created_by_type = 'company' THEN 
          COALESCE(j.company_name, j.business_owner_name, 'Unknown Company')
      END as created_by_name,
      COUNT(ja.id) as application_count,
      AVG(jr.rating) as average_rating,
      COUNT(jr.id) as rating_count
    FROM jobs j
    LEFT JOIN coordinator_profiles cp ON j.created_by_type = 'coordinator' AND j.created_by_id = cp.coordinator_id
    LEFT JOIN job_applications ja ON j.id = ja.job_id
    LEFT JOIN job_ratings jr ON j.id = jr.job_id
    WHERE j.status = 'active'
  `;
    const queryParams = [];
    if (category) {
        query += ' AND j.category = ?';
        queryParams.push(category);
    }
    if (workType) {
        query += ' AND j.work_type = ?';
        queryParams.push(workType);
    }
    if (location) {
        query += ' AND j.location LIKE ?';
        queryParams.push(`%${location}%`);
    }
    if (search) {
        query += ' AND (j.title LIKE ? OR j.description LIKE ?)';
        queryParams.push(`%${search}%`, `%${search}%`);
    }
    if (createdBy) {
        const [type, id] = createdBy.split(':');
        query += ' AND j.created_by_type = ? AND j.created_by_id = ?';
        queryParams.push(type, parseInt(id));
    }
    query += ' GROUP BY j.id ORDER BY j.created_at DESC';
    // Add pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    query += ' LIMIT ? OFFSET ?';
    queryParams.push(parseInt(limit), offset);
    const [jobs] = await connection.execute(query, queryParams);
    // Get total count for pagination
    let countQuery = 'SELECT COUNT(DISTINCT j.id) as total FROM jobs j WHERE j.status = "active"';
    const countParams = [];
    if (category) {
        countQuery += ' AND j.category = ?';
        countParams.push(category);
    }
    if (workType) {
        countQuery += ' AND j.work_type = ?';
        countParams.push(workType);
    }
    if (location) {
        countQuery += ' AND j.location LIKE ?';
        countParams.push(`%${location}%`);
    }
    if (search) {
        countQuery += ' AND (j.title LIKE ? OR j.description LIKE ?)';
        countParams.push(`%${search}%`, `%${search}%`);
    }
    if (createdBy) {
        const [type, id] = createdBy.split(':');
        countQuery += ' AND j.created_by_type = ? AND j.created_by_id = ?';
        countParams.push(type, parseInt(id));
    }
    const [countResult] = await connection.execute(countQuery, countParams);
    const total = countResult[0].total;
    res.json({
        jobs,
        pagination: {
            page: parseInt(page),
            limit: parseInt(limit),
            total,
            totalPages: Math.ceil(total / parseInt(limit))
        }
    });
}));
// Get job recommendations for user
router.get('/recommendations', authenticate, authorize('user'), asyncHandler(async (req, res) => {
    try {
        const recommendations = await JobRecommendationService.getRecommendationsForUser(req.user.id);
        if (recommendations.length === 0) {
            return res.json({
                message: 'Complete your profile and build your resume to get personalized job recommendations',
                jobs: []
            });
        }
        // Get job details for recommended jobs
        const jobIds = recommendations.map(r => r.jobId);
        const connection = getConnection();
        const [jobs] = await connection.execute(`
      SELECT 
        j.*,
        COALESCE(CONCAT(cp.first_name, ' ', cp.last_name), j.coordinator_name, 'Unknown Coordinator') as created_by_name,
        COUNT(ja.id) as application_count,
        AVG(jr.rating) as average_rating,
        COUNT(jr.id) as rating_count
      FROM jobs j
      LEFT JOIN coordinator_profiles cp ON j.created_by_type = 'coordinator' AND j.created_by_id = cp.coordinator_id
      LEFT JOIN job_applications ja ON j.id = ja.job_id
      LEFT JOIN job_ratings jr ON j.id = jr.job_id
      WHERE j.id IN (${jobIds.map(() => '?').join(',')})
      GROUP BY j.id
    `, jobIds);
        // Add match information to jobs
        const jobsWithMatches = jobs.map(job => {
            const matchInfo = recommendations.find(r => r.jobId === job.id);
            return {
                ...job,
                matchScore: matchInfo?.matchScore || 0,
                matchReasons: matchInfo?.matchReasons || []
            };
        });
        // Sort by match score
        jobsWithMatches.sort((a, b) => b.matchScore - a.matchScore);
        res.json({
            message: 'Personalized job recommendations based on your profile',
            jobs: jobsWithMatches
        });
    }
    catch (error) {
        console.error('Error getting job recommendations:', error);
        res.status(500).json({ message: 'Failed to get job recommendations' });
    }
}));
// Get single job with details
router.get('/:id', asyncHandler(async (req, res) => {
    const { id } = req.params;
    const connection = getConnection();
    const [jobs] = await connection.execute(`
    SELECT 
      j.*,
      CASE 
        WHEN j.created_by_type = 'coordinator' THEN 
          COALESCE(CONCAT(cp.first_name, ' ', cp.last_name), j.coordinator_name, 'Unknown Coordinator')
        WHEN j.created_by_type = 'company' THEN 
          COALESCE(j.company_name, j.business_owner_name, 'Unknown Company')
      END as created_by_name,
      COUNT(ja.id) as application_count,
      AVG(jr.rating) as average_rating,
      COUNT(jr.id) as rating_count
    FROM jobs j
    LEFT JOIN coordinator_profiles cp ON j.created_by_type = 'coordinator' AND j.created_by_id = cp.coordinator_id
    LEFT JOIN job_applications ja ON j.id = ja.job_id
    LEFT JOIN job_ratings jr ON j.id = jr.job_id
    WHERE j.id = ?
    GROUP BY j.id
  `, [id]);
    if (jobs.length === 0) {
        return res.status(404).json({ message: 'Job not found' });
    }
    const job = jobs[0];
    // Get screening questions
    const [questions] = await connection.execute(`
    SELECT * FROM job_screening_questions 
    WHERE job_id = ? 
    ORDER BY order_index ASC
  `, [id]);
    // Get recent ratings/reviews
    const [ratings] = await connection.execute(`
    SELECT 
      jr.*,
      up.first_name,
      up.last_name
    FROM job_ratings jr
    LEFT JOIN user_profiles up ON jr.user_id = up.user_id
    WHERE jr.job_id = ?
    ORDER BY jr.created_at DESC
    LIMIT 5
  `, [id]);
    res.json({
        ...job,
        screeningQuestions: questions,
        recentRatings: ratings
    });
}));
// Apply to a job
router.post('/:id/apply', authenticate, authorize('user'), uploadMiddleware, asyncHandler(async (req, res) => {
    const { id: jobId } = req.params;
    const { firstName, lastName, email, phone, address, positionApplyingFor, resumeType, resumeBuilderLink, interviewVideo, screeningAnswers } = req.body;
    if (!firstName || !lastName || !email || !phone || !positionApplyingFor || !resumeType) {
        return res.status(400).json({ message: 'Required fields are missing' });
    }
    if (resumeType === 'uploaded' && !req.file) {
        return res.status(400).json({ message: 'Resume file is required when using uploaded type' });
    }
    // Log file upload details for debugging
    if (req.file) {
        console.log('File uploaded successfully:', {
            filename: req.file.filename,
            originalname: req.file.originalname,
            path: req.file.path,
            size: req.file.size
        });
        // Verify file actually exists on filesystem
        const fs = await import('fs');
        if (!fs.existsSync(req.file.path)) {
            console.error('File was not saved to filesystem:', req.file.path);
            return res.status(500).json({ message: 'File upload failed - file not saved properly' });
        }
    }
    if (resumeType === 'builder_link' && !resumeBuilderLink) {
        return res.status(400).json({ message: 'Resume builder link is required when using builder link type' });
    }
    const connection = getConnection();
    try {
        await connection.beginTransaction();
        // Check if user already applied to this job
        const [existingApplication] = await connection.execute('SELECT id FROM job_applications WHERE job_id = ? AND user_id = ?', [jobId, req.user.id]);
        if (existingApplication.length > 0) {
            return res.status(400).json({ message: 'You have already applied to this job' });
        }
        // Insert application
        const [applicationResult] = await connection.execute(`
      INSERT INTO job_applications (
        job_id, user_id, first_name, last_name, email, phone, address,
        position_applying_for, resume_type, resume_file, resume_builder_link, interview_video
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
            jobId, req.user.id, firstName, lastName, email, phone, address || null,
            positionApplyingFor, resumeType,
            req.file ? req.file.filename : null,
            resumeBuilderLink || null,
            interviewVideo || null
        ]);
        const applicationId = applicationResult.insertId;
        // Insert screening question answers if provided
        if (screeningAnswers && typeof screeningAnswers === 'object') {
            for (const [questionId, answer] of Object.entries(screeningAnswers)) {
                await connection.execute(`
          INSERT INTO job_application_answers (application_id, question_id, answer)
          VALUES (?, ?, ?)
        `, [applicationId, questionId, answer]);
            }
        }
        await connection.commit();
        res.status(201).json({
            message: 'Application submitted successfully',
            applicationId: applicationId
        });
    }
    catch (error) {
        await connection.rollback();
        throw error;
    }
}));
// Rate a job (users only)
router.post('/:id/rate', authenticate, authorize('user'), asyncHandler(async (req, res) => {
    const { id: jobId } = req.params;
    const { rating, review } = req.body;
    if (!rating || rating < 1 || rating > 5) {
        return res.status(400).json({ message: 'Rating must be between 1 and 5' });
    }
    const connection = getConnection();
    await connection.execute(`
    INSERT INTO job_ratings (job_id, user_id, rating, review) 
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE 
    rating = VALUES(rating), 
    review = VALUES(review), 
    updated_at = CURRENT_TIMESTAMP
  `, [jobId, req.user.id, rating, review || null]);
    res.json({ message: 'Rating submitted successfully' });
}));
// Get applications for a job (coordinators and companies)
router.get('/:id/applications', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req, res) => {
    const { id: jobId } = req.params;
    const { status, page = 1, limit = 10 } = req.query;
    const connection = getConnection();
    let query = `
    SELECT 
      ja.*,
      up.profile_photo,
      ats.overall_score,
      ats.skill_match_score,
      ats.experience_match_score,
      ats.processing_status as ats_status,
      COUNT(jac.id) as comment_count
    FROM job_applications ja
    LEFT JOIN user_profiles up ON ja.user_id = up.user_id
    LEFT JOIN ats_resume_data ats ON ja.id = ats.application_id
    LEFT JOIN job_application_comments jac ON ja.id = jac.application_id
    WHERE ja.job_id = ?
  `;
    const queryParams = [jobId];
    if (status) {
        query += ' AND ja.status = ?';
        queryParams.push(status);
    }
    query += ' GROUP BY ja.id ORDER BY ja.created_at DESC';
    // Add pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    query += ' LIMIT ? OFFSET ?';
    queryParams.push(parseInt(limit), offset);
    const [applications] = await connection.execute(query, queryParams);
    // Process applications to convert profile_photo paths to URLs
    const processedApplications = applications.map(app => ({
        ...app,
        profile_photo: UploadService.getPhotoUrl(app.profile_photo)
    }));
    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM job_applications WHERE job_id = ?';
    const countParams = [jobId];
    if (status) {
        countQuery += ' AND status = ?';
        countParams.push(status);
    }
    const [countResult] = await connection.execute(countQuery, countParams);
    const total = countResult[0].total;
    res.json({
        applications: processedApplications,
        pagination: {
            page: parseInt(page),
            limit: parseInt(limit),
            total,
            totalPages: Math.ceil(total / parseInt(limit))
        }
    });
}));
// Filter applications based on screening questions (coordinators and companies)
router.post('/:id/applications/filter', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req, res) => {
    const { id: jobId } = req.params;
    const { filterCriteria } = req.body;
    const connection = getConnection();
    // Get job details to check if pre-screening filter is enabled
    const [jobs] = await connection.execute('SELECT filter_pre_screening FROM jobs WHERE id = ?', [jobId]);
    if (jobs.length === 0) {
        return res.status(404).json({ message: 'Job not found' });
    }
    const job = jobs[0];
    if (!job.filter_pre_screening) {
        return res.status(400).json({ message: 'Pre-screening filter is not enabled for this job' });
    }
    // Get screening questions for this job
    const [questions] = await connection.execute(`
    SELECT id, question_type, acceptable_answers, min_salary_range, max_salary_range
    FROM job_screening_questions 
    WHERE job_id = ? AND is_filter_criteria = true
  `, [jobId]);
    if (questions.length === 0) {
        return res.status(400).json({ message: 'No filtering criteria set for this job' });
    }
    // Get all applications with their screening answers
    const [applications] = await connection.execute(`
    SELECT 
      ja.*,
      up.profile_photo,
      ats.overall_score,
      ats.skill_match_score,
      ats.experience_match_score,
      COUNT(jac.id) as comment_count
    FROM job_applications ja
    LEFT JOIN user_profiles up ON ja.user_id = up.user_id
    LEFT JOIN ats_resume_data ats ON ja.id = ats.application_id
    LEFT JOIN job_application_comments jac ON ja.id = jac.application_id
    WHERE ja.job_id = ?
    GROUP BY ja.id
    ORDER BY ja.created_at DESC
  `, [jobId]);
    // Filter applications based on screening questions
    const filteredApplications = [];
    for (const app of applications) {
        let meetsStandards = true;
        // Get screening answers for this application
        const [answers] = await connection.execute(`
      SELECT jaa.*, jsq.question_type 
      FROM job_application_answers jaa
      JOIN job_screening_questions jsq ON jaa.question_id = jsq.id
      WHERE jaa.application_id = ?
    `, [app.id]);
        const answerMap = new Map();
        answers.forEach((answer) => {
            answerMap.set(answer.question_type, answer.answer);
        });
        // Check each filtering criteria
        for (const question of questions) {
            const userAnswer = answerMap.get(question.question_type);
            if (!userAnswer) {
                meetsStandards = false;
                break;
            }
            // Check based on question type
            if (question.question_type === 'salary_range') {
                // For salary range, check if user's expected salary is within acceptable range
                const userSalary = parseFloat(userAnswer);
                if (isNaN(userSalary)) {
                    meetsStandards = false;
                    break;
                }
                if (question.min_salary_range && userSalary < question.min_salary_range) {
                    meetsStandards = false;
                    break;
                }
                if (question.max_salary_range && userSalary > question.max_salary_range) {
                    meetsStandards = false;
                    break;
                }
            }
            else {
                // For other questions, check if answer is in acceptable_answers
                if (question.acceptable_answers) {
                    const acceptableAnswers = JSON.parse(question.acceptable_answers);
                    if (!acceptableAnswers.includes(userAnswer)) {
                        meetsStandards = false;
                        break;
                    }
                }
            }
        }
        if (meetsStandards) {
            filteredApplications.push({
                ...app,
                profile_photo: UploadService.getPhotoUrl(app.profile_photo)
            });
        }
    }
    res.json({
        applications: filteredApplications,
        totalFiltered: filteredApplications.length,
        totalOriginal: applications.length
    });
}));
// Update application status (coordinators only)
router.patch('/applications/:applicationId/status', authenticate, authorize('coordinator'), asyncHandler(async (req, res) => {
    const { applicationId } = req.params;
    const { status } = req.body;
    const validStatuses = ['pending', 'under_review', 'qualified', 'rejected', 'hired'];
    if (!validStatuses.includes(status)) {
        return res.status(400).json({ message: 'Invalid status' });
    }
    const connection = getConnection();
    await connection.execute('UPDATE job_applications SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', [status, applicationId]);
    res.json({ message: 'Application status updated successfully' });
}));
// Add comment to application
router.post('/applications/:applicationId/comments', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req, res) => {
    const { applicationId } = req.params;
    const { comment } = req.body;
    if (!comment) {
        return res.status(400).json({ message: 'Comment is required' });
    }
    const connection = getConnection();
    await connection.execute(`
    INSERT INTO job_application_comments (
      application_id, commenter_id, commenter_type, comment
    ) VALUES (?, ?, ?, ?)
  `, [applicationId, req.user.id, req.user.role, comment]);
    res.json({ message: 'Comment added successfully' });
}));
// Get application details with screening answers (coordinators and companies)
router.get('/applications/:applicationId/details', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req, res) => {
    const { applicationId } = req.params;
    const connection = getConnection();
    // Get application details
    const [applications] = await connection.execute(`
    SELECT ja.*, up.profile_photo
    FROM job_applications ja
    LEFT JOIN user_profiles up ON ja.user_id = up.user_id
    WHERE ja.id = ?
  `, [applicationId]);
    if (applications.length === 0) {
        return res.status(404).json({ message: 'Application not found' });
    }
    const application = applications[0];
    // Get screening question answers
    const [answers] = await connection.execute(`
    SELECT 
      jaa.*,
      jsq.question_text,
      jsq.question_type,
      jsq.options
    FROM job_application_answers jaa
    LEFT JOIN job_screening_questions jsq ON jaa.question_id = jsq.id
    WHERE jaa.application_id = ?
    ORDER BY jsq.order_index
  `, [applicationId]);
    res.json({
        ...application,
        profile_photo: UploadService.getPhotoUrl(application.profile_photo),
        screening_answers: answers
    });
}));
// Get comments for application (coordinators and companies can see all comments)
router.get('/applications/:applicationId/comments', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req, res) => {
    const { applicationId } = req.params;
    const connection = getConnection();
    const [comments] = await connection.execute(`
    SELECT 
      jac.*,
      CASE 
        WHEN jac.commenter_type = 'coordinator' THEN 
          CONCAT(cp.first_name, ' ', cp.last_name)
        WHEN jac.commenter_type = 'company' THEN 
          COALESCE(comp.company_name, 'Unknown Company')
      END as commenter_name
    FROM job_application_comments jac
    LEFT JOIN coordinator_profiles cp ON jac.commenter_type = 'coordinator' AND jac.commenter_id = cp.coordinator_id
    LEFT JOIN company_profiles comp ON jac.commenter_type = 'company' AND jac.commenter_id = comp.company_id
    WHERE jac.application_id = ?
    ORDER BY jac.created_at DESC
  `, [applicationId]);
    res.json(comments);
}));
// Update job (coordinators and companies - only their own jobs)
router.put('/:id', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req, res) => {
    const { id } = req.params;
    const { title, location, category, workType, workArrangement, currency, minSalary, maxSalary, description, summary, videoUrl, companyName, applicationDeadline, positionsAvailable, experienceLevel, targetStudentType, coordinatorName, businessOwnerName, screeningQuestions, status } = req.body;
    if (!title || !location || !category || !description) {
        return res.status(400).json({ message: 'Title, location, category, and description are required' });
    }
    const connection = getConnection();
    try {
        await connection.beginTransaction();
        // Check if user owns this job
        const [existingJob] = await connection.execute('SELECT created_by_type, created_by_id FROM jobs WHERE id = ?', [id]);
        if (existingJob.length === 0) {
            return res.status(404).json({ message: 'Job not found' });
        }
        const job = existingJob[0];
        if (job.created_by_type !== req.user.role || job.created_by_id !== req.user.id) {
            return res.status(403).json({ message: 'You can only edit jobs you created' });
        }
        // Update job
        await connection.execute(`
      UPDATE jobs SET 
        title = ?, location = ?, category = ?, work_type = ?, work_arrangement = ?, 
        currency = ?, min_salary = ?, max_salary = ?, description = ?, summary = ?, 
        video_url = ?, company_name = ?, application_deadline = ?, positions_available = ?, 
        experience_level = ?, target_student_type = ?, coordinator_name = ?, business_owner_name = ?, status = ?,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `, [
            title, location, category, workType || 'internship', workArrangement || 'on-site',
            currency || 'PHP', minSalary || null, maxSalary || null, description, summary || null,
            videoUrl || null, companyName || null, applicationDeadline || null, positionsAvailable || 1,
            experienceLevel || 'entry-level', targetStudentType || 'both', coordinatorName || null, businessOwnerName || null,
            status || 'active', id
        ]);
        // Delete existing screening questions
        await connection.execute('DELETE FROM job_screening_questions WHERE job_id = ?', [id]);
        // Insert updated screening questions if provided
        if (screeningQuestions && Array.isArray(screeningQuestions)) {
            for (let i = 0; i < screeningQuestions.length; i++) {
                const question = screeningQuestions[i];
                await connection.execute(`
          INSERT INTO job_screening_questions (
            job_id, question_text, question_type, options, is_required, order_index
          ) VALUES (?, ?, ?, ?, ?, ?)
        `, [
                    id,
                    question.questionText,
                    question.questionType,
                    question.options ? JSON.stringify(question.options) : null,
                    question.isRequired || false,
                    i
                ]);
            }
        }
        await connection.commit();
        res.json({
            message: 'Job updated successfully',
            jobId: id
        });
    }
    catch (error) {
        await connection.rollback();
        throw error;
    }
}));
// Delete job (coordinators and companies - only their own jobs)
router.delete('/:id', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req, res) => {
    const { id } = req.params;
    const connection = getConnection();
    try {
        await connection.beginTransaction();
        // Check if user owns this job
        const [existingJob] = await connection.execute('SELECT created_by_type, created_by_id FROM jobs WHERE id = ?', [id]);
        if (existingJob.length === 0) {
            return res.status(404).json({ message: 'Job not found' });
        }
        const job = existingJob[0];
        if (job.created_by_type !== req.user.role || job.created_by_id !== req.user.id) {
            return res.status(403).json({ message: 'You can only delete jobs you created' });
        }
        // Delete job (cascade will handle related tables)
        await connection.execute('DELETE FROM jobs WHERE id = ?', [id]);
        await connection.commit();
        res.json({ message: 'Job deleted successfully' });
    }
    catch (error) {
        await connection.rollback();
        throw error;
    }
}));
export default router;
