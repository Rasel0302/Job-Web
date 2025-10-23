import express from 'express';
import { asyncHandler } from '../middleware/errorHandler.js';
import { authenticate, authorize, AuthRequest } from '../middleware/auth.js';
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
    } else {
      cb(new Error('Only PDF, DOC, and DOCX files are allowed'));
    }
  }
});

// Add error handling for multer
const uploadMiddleware = (req: any, res: any, next: any) => {
  upload.single('resumeFile')(req, res, (err: any) => {
    if (err instanceof multer.MulterError) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({ message: 'File too large. Maximum size is 10MB.' });
      }
      return res.status(400).json({ message: `Upload error: ${err.message}` });
    } else if (err) {
      return res.status(400).json({ message: err.message });
    }
    next();
  });
};

// Get job categories by course
router.get('/categories/:course', asyncHandler(async (req, res) => {
  const { course } = req.params;
  const connection = getConnection();
  
  const [categories] = await connection.execute(
    'SELECT category_name FROM job_categories WHERE course_name = ? ORDER BY category_name ASC',
    [course]
  );
  
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
  const groupedCategories: { [key: string]: string[] } = {};
  (categories as any[]).forEach(row => {
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
router.post('/', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req: AuthRequest, res) => {
  const {
    title,
    location,
    category,
    workType,
    workArrangement,
    currency,
    minSalary,
    maxSalary,
    description,
    summary,
    videoUrl,
    companyName,
    applicationDeadline,
    positionsAvailable,
    experienceLevel,
    targetStudentType,
    coordinatorName,
    businessOwnerName,
    screeningQuestions,
    filterPreScreening
  } = req.body;

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
      experienceLevel || 'entry-level', targetStudentType || 'both', req.user!.role, req.user!.id, coordinatorName || null,
      businessOwnerName || null, filterPreScreening || false
    ]);

    const jobId = (jobResult as any).insertId;

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

  } catch (error) {
    await connection.rollback();
    throw error;
  }
}));

// Get all jobs with filtering and pagination
router.get('/', asyncHandler(async (req, res) => {
  const { 
    category, 
    workType, 
    location, 
    page = 1, 
    limit = 10,
    search,
    createdBy 
  } = req.query;

  const connection = getConnection();
  
  let query = `
    SELECT 
      j.*,
      CASE 
        WHEN j.created_by_type = 'coordinator' THEN 
          COALESCE(CONCAT(cp.first_name, ' ', cp.last_name), j.coordinator_name, 'Unknown Coordinator')
        WHEN j.created_by_type = 'company' THEN 
          COALESCE(company_p.company_name, j.company_name, j.business_owner_name, 'Unknown Company')
      END as created_by_name,
      COUNT(ja.id) as application_count,
      AVG(jr.rating) as average_rating,
      COUNT(jr.id) as rating_count
    FROM jobs j
    LEFT JOIN coordinator_profiles cp ON j.created_by_type = 'coordinator' AND j.created_by_id = cp.coordinator_id
    LEFT JOIN company_profiles company_p ON j.created_by_type = 'company' AND j.created_by_id = company_p.company_id
    LEFT JOIN job_applications ja ON j.id = ja.job_id
    LEFT JOIN job_ratings jr ON j.id = jr.job_id
    WHERE j.status = 'active' AND j.application_deadline > NOW()
  `;
  
  const queryParams: any[] = [];
  
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
    const [type, id] = (createdBy as string).split(':');
    query += ' AND j.created_by_type = ? AND j.created_by_id = ?';
    queryParams.push(type, parseInt(id));
  }
  
  query += ' GROUP BY j.id ORDER BY j.created_at DESC';
  
  // Add pagination
  const offset = (parseInt(page as string) - 1) * parseInt(limit as string);
  query += ' LIMIT ? OFFSET ?';
  queryParams.push(parseInt(limit as string), offset);
  
  const [jobs] = await connection.execute(query, queryParams);
  
  // Get total count for pagination
  let countQuery = 'SELECT COUNT(DISTINCT j.id) as total FROM jobs j WHERE j.status = "active"';
  const countParams: any[] = [];
  
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
    const [type, id] = (createdBy as string).split(':');
    countQuery += ' AND j.created_by_type = ? AND j.created_by_id = ?';
    countParams.push(type, parseInt(id));
  }
  
  const [countResult] = await connection.execute(countQuery, countParams);
  const total = (countResult as any[])[0].total;
  
  res.json({
    jobs,
    pagination: {
      page: parseInt(page as string),
      limit: parseInt(limit as string),
      total,
      totalPages: Math.ceil(total / parseInt(limit as string))
    }
  });
}));

// Get job recommendations for user
router.get('/recommendations', authenticate, authorize('user'), asyncHandler(async (req: AuthRequest, res) => {
  try {
    const recommendations = await JobRecommendationService.getRecommendationsForUser(req.user!.id);
    
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
    const jobsWithMatches = (jobs as any[]).map(job => {
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

  } catch (error: any) {
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
          COALESCE(company_p.company_name, j.company_name, j.business_owner_name, 'Unknown Company')
      END as created_by_name,
      COUNT(ja.id) as application_count,
      AVG(jr.rating) as average_rating,
      COUNT(jr.id) as rating_count
    FROM jobs j
    LEFT JOIN coordinator_profiles cp ON j.created_by_type = 'coordinator' AND j.created_by_id = cp.coordinator_id
    LEFT JOIN company_profiles company_p ON j.created_by_type = 'company' AND j.created_by_id = company_p.company_id
    LEFT JOIN job_applications ja ON j.id = ja.job_id
    LEFT JOIN job_ratings jr ON j.id = jr.job_id
    WHERE j.id = ?
    GROUP BY j.id
  `, [id]);

  if ((jobs as any[]).length === 0) {
    return res.status(404).json({ message: 'Job not found' });
  }

  const job = (jobs as any[])[0];

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
router.post('/:id/apply', authenticate, authorize('user'), uploadMiddleware, asyncHandler(async (req: AuthRequest, res) => {
  const { id: jobId } = req.params;
  const {
    firstName,
    lastName,
    email,
    phone,
    address,
    positionApplyingFor,
    resumeType,
    resumeBuilderLink,
    interviewVideo,
    screeningAnswers
  } = req.body;

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
    const [existingApplication] = await connection.execute(
      'SELECT id FROM job_applications WHERE job_id = ? AND user_id = ?',
      [jobId, req.user!.id]
    );

    if ((existingApplication as any[]).length > 0) {
      return res.status(400).json({ message: 'You have already applied to this job' });
    }

    // Insert application
    const [applicationResult] = await connection.execute(`
      INSERT INTO job_applications (
        job_id, user_id, first_name, last_name, email, phone, address,
        position_applying_for, resume_type, resume_file, resume_builder_link, interview_video
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      jobId, req.user!.id, firstName, lastName, email, phone, address || null,
      positionApplyingFor, resumeType, 
      req.file ? req.file.filename : null, 
      resumeBuilderLink || null, 
      interviewVideo || null
    ]);

    const applicationId = (applicationResult as any).insertId;

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

  } catch (error) {
    await connection.rollback();
    throw error;
  }
}));

// Rate a job (users only)
router.post('/:id/rate', authenticate, authorize('user'), asyncHandler(async (req: AuthRequest, res) => {
  const { id: jobId } = req.params;
  const { rating, review } = req.body;

  if (!rating || rating < 1 || rating > 5) {
    return res.status(400).json({ message: 'Rating must be between 1 and 5' });
  }

  const connection = getConnection();

  // Insert or update rating
  await connection.execute(`
    INSERT INTO job_ratings (job_id, user_id, rating, review) 
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE 
    rating = VALUES(rating), 
    review = VALUES(review), 
    updated_at = CURRENT_TIMESTAMP
  `, [jobId, req.user!.id, rating, review || null]);

  // Update aggregated rating in jobs table
  const [ratingStats] = await connection.execute(`
    SELECT AVG(rating) as avg_rating, COUNT(*) as count
    FROM job_ratings
    WHERE job_id = ?
  `, [jobId]);

  const stats = (ratingStats as any[])[0];
  await connection.execute(
    'UPDATE jobs SET average_rating = ?, rating_count = ? WHERE id = ?',
    [stats.avg_rating, stats.count, jobId]
  );

  res.json({ 
    message: 'Job rating submitted successfully',
    average_rating: stats.avg_rating,
    rating_count: stats.count
  });
}));

// Get job ratings (public)
router.get('/:id/ratings', asyncHandler(async (req, res) => {
  const { id: jobId } = req.params;
  const connection = getConnection();

  try {
    // Get all ratings for this job with user details
    const [ratings] = await connection.execute(`
      SELECT 
        jr.id,
        jr.rating,
        jr.review,
        jr.created_at,
        up.first_name,
        up.last_name,
        up.profile_photo
      FROM job_ratings jr
      LEFT JOIN user_profiles up ON jr.user_id = up.user_id
      WHERE jr.job_id = ?
      ORDER BY jr.created_at DESC
    `, [jobId]);

    // Process ratings to include photo URLs
    const processedRatings = (ratings as any[]).map(rating => ({
      ...rating,
      profile_photo: rating.profile_photo ? UploadService.getPhotoUrl(rating.profile_photo) : null
    }));

    res.json({ ratings: processedRatings });
  } catch (error) {
    console.error('Error fetching job ratings:', error);
    res.status(500).json({ 
      message: 'Failed to fetch job ratings',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}));

// Get current user's job rating
router.get('/:id/my-rating', authenticate, authorize('user'), asyncHandler(async (req: AuthRequest, res) => {
  const { id: jobId } = req.params;
  const connection = getConnection();

  const [userRating] = await connection.execute(`
    SELECT rating, review
    FROM job_ratings
    WHERE job_id = ? AND user_id = ?
  `, [jobId, req.user!.id]);

  if ((userRating as any[]).length > 0) {
    res.json((userRating as any[])[0]);
  } else {
    res.json({ rating: null, review: null });
  }
}));

// Get applications for a job (coordinators and companies)
router.get('/:id/applications', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req: AuthRequest, res) => {
  const { id: jobId } = req.params;
  const { status, page = 1, limit = 10 } = req.query;

  const connection = getConnection();

  // Get job info to determine created_by_type
  const [jobInfo] = await connection.execute(
    'SELECT created_by_type, created_by_id FROM jobs WHERE id = ?',
    [jobId]
  );

  if ((jobInfo as any[]).length === 0) {
    return res.status(404).json({ message: 'Job not found' });
  }

  const job = (jobInfo as any[])[0];

  let query = `
    SELECT 
      ja.*,
      up.profile_photo,
      ats.overall_score,
      ats.skill_match_score,
      ats.experience_match_score,
      ats.processing_status as ats_status,
      COUNT(jac.id) as comment_count,
      ar.rating as user_rating,
      ar.comment as user_rating_comment,
      -- Complete user rating profile across all applications
      user_stats.overall_average_rating,
      user_stats.total_ratings,
      user_stats.highest_rating,
      user_stats.lowest_rating,
      user_stats.company_ratings_count,
      user_stats.coordinator_ratings_count
    FROM job_applications ja
    LEFT JOIN user_profiles up ON ja.user_id = up.user_id
    LEFT JOIN ats_resume_data ats ON ja.id = ats.application_id
    LEFT JOIN job_application_comments jac ON ja.id = jac.application_id
    LEFT JOIN applicant_ratings ar ON ja.id = ar.application_id 
      AND ar.rated_by_type = ? 
      AND ar.rated_by_id = ?
    LEFT JOIN (
      SELECT 
        ja_inner.user_id,
        AVG(ar_inner.rating) as overall_average_rating,
        COUNT(ar_inner.id) as total_ratings,
        MAX(ar_inner.rating) as highest_rating,
        MIN(ar_inner.rating) as lowest_rating,
        COUNT(CASE WHEN ar_inner.rated_by_type = 'company' THEN 1 END) as company_ratings_count,
        COUNT(CASE WHEN ar_inner.rated_by_type = 'coordinator' THEN 1 END) as coordinator_ratings_count
      FROM job_applications ja_inner
      LEFT JOIN applicant_ratings ar_inner ON ja_inner.id = ar_inner.application_id
      GROUP BY ja_inner.user_id
    ) user_stats ON ja.user_id = user_stats.user_id
    WHERE ja.job_id = ?
  `;

  const queryParams: any[] = [job.created_by_type, req.user!.id, jobId];

  if (status) {
    query += ' AND ja.status = ?';
    queryParams.push(status);
  }

  query += ' GROUP BY ja.id ORDER BY user_stats.overall_average_rating DESC, ja.created_at DESC';

  // Add pagination
  const offset = (parseInt(page as string) - 1) * parseInt(limit as string);
  query += ' LIMIT ? OFFSET ?';
  queryParams.push(parseInt(limit as string), offset);

  const [applications] = await connection.execute(query, queryParams);

  // Process applications to convert profile_photo paths to URLs and add user rating profile
  const processedApplications = (applications as any[]).map(app => ({
    ...app,
    profile_photo: UploadService.getPhotoUrl(app.profile_photo),
    user_rating_profile: {
      overall_average_rating: app.overall_average_rating,
      total_ratings: app.total_ratings || 0,
      highest_rating: app.highest_rating,
      lowest_rating: app.lowest_rating,
      company_ratings_count: app.company_ratings_count || 0,
      coordinator_ratings_count: app.coordinator_ratings_count || 0
    }
  }));

  // Get total count
  let countQuery = 'SELECT COUNT(*) as total FROM job_applications WHERE job_id = ?';
  const countParams = [jobId];
  
  if (status) {
    countQuery += ' AND status = ?';
    countParams.push(status as string);
  }

  const [countResult] = await connection.execute(countQuery, countParams);
  const total = (countResult as any[])[0].total;

  res.json({
    applications: processedApplications,
    job_created_by_type: job.created_by_type,
    job_created_by_id: job.created_by_id,
    pagination: {
      page: parseInt(page as string),
      limit: parseInt(limit as string),
      total,
      totalPages: Math.ceil(total / parseInt(limit as string))
    }
  });
}));

// Filter applications based on screening questions (coordinators and companies)
router.post('/:id/applications/filter', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req: AuthRequest, res) => {
  const { id: jobId } = req.params;
  const { filterCriteria } = req.body;
  
  const connection = getConnection();

  // Get job details to check if pre-screening filter is enabled
  const [jobs] = await connection.execute(
    'SELECT filter_pre_screening FROM jobs WHERE id = ?',
    [jobId]
  );

  if ((jobs as any[]).length === 0) {
    return res.status(404).json({ message: 'Job not found' });
  }

  const job = (jobs as any[])[0];
  if (!job.filter_pre_screening) {
    return res.status(400).json({ message: 'Pre-screening filter is not enabled for this job' });
  }

  // Get screening questions for this job
  const [questions] = await connection.execute(`
    SELECT id, question_type, acceptable_answers, min_salary_range, max_salary_range
    FROM job_screening_questions 
    WHERE job_id = ? AND is_filter_criteria = true
  `, [jobId]);

  if ((questions as any[]).length === 0) {
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
  const filteredApplications: any[] = [];
  
  for (const app of applications as any[]) {
    let meetsStandards = true;
    
    // Get screening answers for this application
    const [answers] = await connection.execute(`
      SELECT jaa.*, jsq.question_type 
      FROM job_application_answers jaa
      JOIN job_screening_questions jsq ON jaa.question_id = jsq.id
      WHERE jaa.application_id = ?
    `, [app.id]);

    const answerMap = new Map();
    (answers as any[]).forEach((answer: any) => {
      answerMap.set(answer.question_type, answer.answer);
    });

    // Check each filtering criteria
    for (const question of questions as any[]) {
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
      } else {
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
    totalOriginal: (applications as any[]).length
  });
}));

// Update application status (coordinators only)
router.patch('/applications/:applicationId/status', authenticate, authorize('coordinator'), asyncHandler(async (req: AuthRequest, res) => {
  const { applicationId } = req.params;
  const { status } = req.body;

  const validStatuses = ['pending', 'under_review', 'qualified', 'rejected', 'hired'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ message: 'Invalid status' });
  }

  const connection = getConnection();

  await connection.execute(
    'UPDATE job_applications SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
    [status, applicationId]
  );

  res.json({ message: 'Application status updated successfully' });
}));

// Add comment to application
router.post('/applications/:applicationId/comments', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req: AuthRequest, res) => {
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
  `, [applicationId, req.user!.id, req.user!.role, comment]);

  res.json({ message: 'Comment added successfully' });
}));

// Get application details with screening answers (coordinators and companies)
router.get('/applications/:applicationId/details', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req: AuthRequest, res) => {
  const { applicationId } = req.params;
  const connection = getConnection();

  // Get application details
  const [applications] = await connection.execute(`
    SELECT ja.*, up.profile_photo
    FROM job_applications ja
    LEFT JOIN user_profiles up ON ja.user_id = up.user_id
    WHERE ja.id = ?
  `, [applicationId]);

  if ((applications as any[]).length === 0) {
    return res.status(404).json({ message: 'Application not found' });
  }

  const application = (applications as any[])[0];

  // Get the current user's rating
  let userRating = null;
  let userRatingComment = null;
  if (req.user!.role === 'company') {
    const [companyRating] = await connection.execute(`
      SELECT rating, comment
      FROM applicant_ratings
      WHERE application_id = ? AND rated_by_type = 'company' AND rated_by_id = ?
    `, [applicationId, req.user!.id]);

    if ((companyRating as any[]).length > 0) {
      userRating = (companyRating as any[])[0].rating;
      userRatingComment = (companyRating as any[])[0].comment;
    }
  } else if (req.user!.role === 'coordinator') {
    const [coordinatorRating] = await connection.execute(`
      SELECT rating, comment
      FROM applicant_ratings
      WHERE application_id = ? AND rated_by_type = 'coordinator' AND rated_by_id = ?
    `, [applicationId, req.user!.id]);

    if ((coordinatorRating as any[]).length > 0) {
      userRating = (coordinatorRating as any[])[0].rating;
      userRatingComment = (coordinatorRating as any[])[0].comment;
    }
  }

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

  // Get ALL ratings for this USER across all their applications (complete profile)
  const [ratings] = await connection.execute(`
    SELECT 
      ar.id,
      ar.rating,
      ar.comment,
      ar.created_at,
      ar.rated_by_type,
      ar.rated_by_id,
      j.title as job_title,
      CASE 
        WHEN ar.rated_by_type = 'coordinator' THEN 
          CONCAT(cp.first_name, ' ', cp.last_name)
        WHEN ar.rated_by_type = 'company' THEN 
          comp_p.company_name
      END as rater_name,
      CASE 
        WHEN ar.rated_by_type = 'coordinator' THEN cp.profile_photo
        WHEN ar.rated_by_type = 'company' THEN comp_p.profile_photo
      END as rater_photo
    FROM applicant_ratings ar
    LEFT JOIN job_applications ja ON ar.application_id = ja.id
    LEFT JOIN jobs j ON ja.job_id = j.id
    LEFT JOIN coordinator_profiles cp ON ar.rated_by_type = 'coordinator' AND ar.rated_by_id = cp.coordinator_id
    LEFT JOIN company_profiles comp_p ON ar.rated_by_type = 'company' AND ar.rated_by_id = comp_p.company_id
    WHERE ja.user_id = ?
    ORDER BY ar.rating DESC, ar.created_at DESC
  `, [application.user_id]);

  // Calculate the user's overall rating statistics
  const [userRatingStats] = await connection.execute(`
    SELECT 
      AVG(ar.rating) as overall_average_rating,
      COUNT(ar.id) as total_ratings,
      MAX(ar.rating) as highest_rating,
      MIN(ar.rating) as lowest_rating,
      COUNT(CASE WHEN ar.rated_by_type = 'company' THEN 1 END) as company_ratings_count,
      COUNT(CASE WHEN ar.rated_by_type = 'coordinator' THEN 1 END) as coordinator_ratings_count
    FROM applicant_ratings ar
    LEFT JOIN job_applications ja ON ar.application_id = ja.id
    WHERE ja.user_id = ?
  `, [application.user_id]);

  const userStats = (userRatingStats as any[])[0] || {
    overall_average_rating: null,
    total_ratings: 0,
    highest_rating: null,
    lowest_rating: null,
    company_ratings_count: 0,
    coordinator_ratings_count: 0
  };

  // Process ratings to include photo URLs
  const processedRatings = (ratings as any[]).map(rating => ({
    ...rating,
    rater_photo: UploadService.getPhotoUrl(rating.rater_photo)
  }));

  res.json({
    ...application,
    profile_photo: UploadService.getPhotoUrl(application.profile_photo),
    screening_answers: answers,
    all_ratings: processedRatings,
    // Add user's own rating for companies and coordinators (for this specific application)
    company_rating: req.user!.role === 'company' ? userRating : null,
    company_rating_comment: req.user!.role === 'company' ? userRatingComment : null,
    user_rating: req.user!.role === 'coordinator' ? userRating : null,
    user_rating_comment: req.user!.role === 'coordinator' ? userRatingComment : null,
    // Add complete user rating profile from all applications
    user_rating_profile: {
      overall_average_rating: userStats.overall_average_rating,
      total_ratings: userStats.total_ratings,
      highest_rating: userStats.highest_rating,
      lowest_rating: userStats.lowest_rating,
      company_ratings_count: userStats.company_ratings_count,
      coordinator_ratings_count: userStats.coordinator_ratings_count
    }
  });
}));

// Get comments for application (coordinators and companies can see all comments)
router.get('/applications/:applicationId/comments', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req: AuthRequest, res) => {
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
router.put('/:id', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req: AuthRequest, res) => {
  const { id } = req.params;
  const {
    title,
    location,
    category,
    workType,
    workArrangement,
    currency,
    minSalary,
    maxSalary,
    description,
    summary,
    videoUrl,
    companyName,
    applicationDeadline,
    positionsAvailable,
    experienceLevel,
    targetStudentType,
    coordinatorName,
    businessOwnerName,
    screeningQuestions,
    status
  } = req.body;

  if (!title || !location || !category || !description) {
    return res.status(400).json({ message: 'Title, location, category, and description are required' });
  }

  const connection = getConnection();
  
  try {
    await connection.beginTransaction();

    // Check if user owns this job
    const [existingJob] = await connection.execute(
      'SELECT created_by_type, created_by_id FROM jobs WHERE id = ?',
      [id]
    );

    if ((existingJob as any[]).length === 0) {
      return res.status(404).json({ message: 'Job not found' });
    }

    const job = (existingJob as any[])[0];
    if (job.created_by_type !== req.user!.role || job.created_by_id !== req.user!.id) {
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

  } catch (error) {
    await connection.rollback();
    throw error;
  }
}));

// Delete job (coordinators and companies - only their own jobs)
router.delete('/:id', authenticate, authorize('coordinator', 'company'), asyncHandler(async (req: AuthRequest, res) => {
  const { id } = req.params;
  const connection = getConnection();

  try {
    await connection.beginTransaction();

    // Check if user owns this job
    const [existingJob] = await connection.execute(
      'SELECT created_by_type, created_by_id FROM jobs WHERE id = ?',
      [id]
    );

    if ((existingJob as any[]).length === 0) {
      return res.status(404).json({ message: 'Job not found' });
    }

    const job = (existingJob as any[])[0];
    if (job.created_by_type !== req.user!.role || job.created_by_id !== req.user!.id) {
      return res.status(403).json({ message: 'You can only delete jobs you created' });
    }

    // Delete job (cascade will handle related tables)
    await connection.execute('DELETE FROM jobs WHERE id = ?', [id]);

    await connection.commit();

    res.json({ message: 'Job deleted successfully' });

  } catch (error) {
    await connection.rollback();
    throw error;
  }
}));

// Rate Applicant (for coordinators)
router.post('/applications/:applicationId/rate', authenticate, authorize('coordinator'), asyncHandler(async (req: AuthRequest, res) => {
  const { applicationId } = req.params;
  const { rating, comment } = req.body;
  const connection = getConnection();

  if (!rating || rating < 1 || rating > 5) {
    return res.status(400).json({ message: 'Rating must be between 1 and 5' });
  }

  // Verify application belongs to coordinator's job
  const [applicationCheck] = await connection.execute(`
    SELECT ja.id FROM job_applications ja
    JOIN jobs j ON ja.job_id = j.id
    WHERE ja.id = ? AND j.created_by_type = 'coordinator' AND j.created_by_id = ?
  `, [applicationId, req.user!.id]);

  if ((applicationCheck as any[]).length === 0) {
    return res.status(403).json({ message: 'Access denied' });
  }

  // Insert or update rating
  await connection.execute(`
    INSERT INTO applicant_ratings (application_id, rated_by_type, rated_by_id, rating, comment)
    VALUES (?, 'coordinator', ?, ?, ?)
    ON DUPLICATE KEY UPDATE rating = VALUES(rating), comment = VALUES(comment), updated_at = NOW()
  `, [applicationId, req.user!.id, rating, comment || null]);

  // Update average rating in job_applications
  const [ratingStats] = await connection.execute(`
    SELECT AVG(rating) as avg_rating, COUNT(*) as count
    FROM applicant_ratings
    WHERE application_id = ?
  `, [applicationId]);

  const stats = (ratingStats as any[])[0];
  await connection.execute(
    'UPDATE job_applications SET average_rating = ?, rating_count = ? WHERE id = ?',
    [stats.avg_rating, stats.count, applicationId]
  );

  res.json({ 
    message: 'Rating submitted successfully',
    average_rating: stats.avg_rating,
    rating_count: stats.count
  });
}));

export default router;