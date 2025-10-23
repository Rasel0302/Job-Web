import express from 'express';
import { asyncHandler } from '../middleware/errorHandler.js';
import { authenticate, authorize } from '../middleware/auth.js';
import { getConnection } from '../config/database.js';
import { uploadSingle } from '../middleware/upload.js';
import { UploadService } from '../services/uploadService.js';
const router = express.Router();
// Get user profile
router.get('/profile', authenticate, asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [userProfile] = await connection.execute(`
    SELECT 
      u.id,
      u.email,
      u.role,
      up.first_name,
      up.last_name,
      up.student_type,
      up.contact_number,
      up.age,
      up.birthdate,
      up.gender,
      up.profile_photo,
      up.profile_completed
    FROM users u
    LEFT JOIN user_profiles up ON u.id = up.user_id
    WHERE u.id = ?
  `, [req.user.id]);
    if (userProfile.length === 0) {
        return res.status(404).json({ message: 'User not found' });
    }
    const user = userProfile[0];
    // Get user courses
    const [courses] = await connection.execute(`
    SELECT 
      c.id,
      c.course_name,
      c.course_type,
      uc.graduation_status
    FROM user_courses uc
    JOIN courses c ON uc.course_id = c.id
    WHERE uc.user_id = ?
  `, [req.user.id]);
    res.json({
        ...user,
        profile_photo_url: UploadService.getPhotoUrl(user.profile_photo),
        courses: courses
    });
}));
// Upload profile photo
router.post('/upload-photo', authenticate, authorize('user'), uploadSingle, asyncHandler(async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'No image file provided' });
    }
    const connection = getConnection();
    try {
        // Process and save the photo
        const photoPath = await UploadService.processAndSaveProfilePhoto(req.file.buffer, req.user.id, 'user');
        // Get existing profile photo to delete old one
        const [existingProfile] = await connection.execute('SELECT profile_photo FROM user_profiles WHERE user_id = ?', [req.user.id]);
        // Delete old photo if exists
        if (existingProfile.length > 0 && existingProfile[0].profile_photo) {
            await UploadService.deleteProfilePhoto(existingProfile[0].profile_photo);
        }
        // Update or create profile with new photo
        const [checkProfile] = await connection.execute('SELECT id FROM user_profiles WHERE user_id = ?', [req.user.id]);
        if (checkProfile.length > 0) {
            // Update existing profile
            await connection.execute('UPDATE user_profiles SET profile_photo = ?, updated_at = NOW() WHERE user_id = ?', [photoPath, req.user.id]);
        }
        else {
            // Create minimal profile with photo
            await connection.execute('INSERT INTO user_profiles (user_id, profile_photo, first_name, last_name, student_type) VALUES (?, ?, "", "", "ojt")', [req.user.id, photoPath]);
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
// Complete user profile
router.post('/complete-profile', authenticate, authorize('user'), asyncHandler(async (req, res) => {
    const { firstName, lastName, studentType, contactNumber, age, birthdate, gender, courseIds } = req.body;
    if (!firstName || !lastName || !studentType || !courseIds || courseIds.length === 0) {
        return res.status(400).json({ message: 'Required fields are missing' });
    }
    const connection = getConnection();
    // Check if profile already exists
    const [existingProfile] = await connection.execute('SELECT id, profile_photo FROM user_profiles WHERE user_id = ?', [req.user.id]);
    const existingPhotoPath = existingProfile.length > 0 ? existingProfile[0].profile_photo : null;
    if (existingProfile.length > 0) {
        // Update existing profile (preserve existing photo)
        await connection.execute(`
      UPDATE user_profiles 
      SET first_name = ?, last_name = ?, student_type = ?, contact_number = ?, 
          age = ?, birthdate = ?, gender = ?, profile_completed = TRUE, updated_at = NOW()
      WHERE user_id = ?
    `, [firstName, lastName, studentType, contactNumber, age, birthdate, gender, req.user.id]);
    }
    else {
        // Create new profile
        await connection.execute(`
      INSERT INTO user_profiles (user_id, first_name, last_name, student_type, contact_number, age, birthdate, gender, profile_completed)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE)
    `, [req.user.id, firstName, lastName, studentType, contactNumber, age, birthdate, gender]);
    }
    // Clear existing courses
    await connection.execute('DELETE FROM user_courses WHERE user_id = ?', [req.user.id]);
    // Add new courses
    for (const courseId of courseIds) {
        await connection.execute('INSERT INTO user_courses (user_id, course_id, graduation_status) VALUES (?, ?, ?)', [req.user.id, courseId, studentType === 'alumni' ? 'graduated' : 'current']);
    }
    res.json({ message: 'Profile completed successfully' });
}));
// Get all courses
router.get('/courses', asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [courses] = await connection.execute('SELECT id, course_name, course_type FROM courses ORDER BY course_type, course_name');
    res.json(courses);
}));
// Debug endpoint removed after fixing coordinator photo display
// Get navbar info (name and photo)
router.get('/navbar-info', authenticate, asyncHandler(async (req, res) => {
    const connection = getConnection();
    let userInfo;
    switch (req.user.role) {
        case 'user':
            const [userProfile] = await connection.execute(`
        SELECT first_name, last_name, profile_photo FROM user_profiles WHERE user_id = ?
      `, [req.user.id]);
            userInfo = userProfile[0];
            break;
        case 'coordinator':
            const [coordProfile] = await connection.execute(`
        SELECT first_name, last_name, profile_photo FROM coordinator_profiles WHERE coordinator_id = ?
      `, [req.user.id]);
            userInfo = coordProfile[0];
            break;
        case 'company':
            const [companyProfile] = await connection.execute(`
        SELECT company_name as first_name, '' as last_name, profile_photo FROM company_profiles WHERE company_id = ?
      `, [req.user.id]);
            userInfo = companyProfile[0];
            break;
        case 'admin':
            const [adminProfile] = await connection.execute(`
        SELECT first_name, last_name, profile_photo_url as profile_photo FROM admin_profiles WHERE admin_id = ?
      `, [req.user.id]);
            userInfo = adminProfile[0];
            break;
    }
    // Process profile photo URL
    let profilePhotoUrl = null;
    if (userInfo?.profile_photo) {
        // All profile photos (user, coordinator, company, admin) need to be processed with UploadService
        profilePhotoUrl = UploadService.getPhotoUrl(userInfo.profile_photo);
    }
    res.json({
        firstName: userInfo?.first_name || '',
        lastName: userInfo?.last_name || '',
        profilePhotoUrl: profilePhotoUrl,
        email: req.user.email,
        role: req.user.role
    });
}));
// Update user profile
router.put('/profile', authenticate, authorize('user'), asyncHandler(async (req, res) => {
    const { firstName, lastName, studentType, contactNumber, age, birthdate, gender, courseIds } = req.body;
    const connection = getConnection();
    // Update profile (preserve existing photo)
    await connection.execute(`
    UPDATE user_profiles 
    SET first_name = ?, last_name = ?, student_type = ?, contact_number = ?, 
        age = ?, birthdate = ?, gender = ?, updated_at = NOW()
    WHERE user_id = ?
  `, [firstName, lastName, studentType, contactNumber, age, birthdate, gender, req.user.id]);
    // Update courses if provided
    if (courseIds && courseIds.length > 0) {
        await connection.execute('DELETE FROM user_courses WHERE user_id = ?', [req.user.id]);
        for (const courseId of courseIds) {
            await connection.execute('INSERT INTO user_courses (user_id, course_id, graduation_status) VALUES (?, ?, ?)', [req.user.id, courseId, studentType === 'alumni' ? 'graduated' : 'current']);
        }
    }
    res.json({ message: 'Profile updated successfully' });
}));
// Get approved coordinators (public endpoint)
router.get('/coordinators/approved', asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [coordinators] = await connection.execute(`
    SELECT 
      c.id,
      cp.first_name,
      cp.last_name,
      cp.designated_course,
      cp.profile_photo
    FROM coordinators c
    INNER JOIN coordinator_profiles cp ON c.id = cp.coordinator_id
    WHERE c.is_verified = TRUE 
      AND c.is_approved = TRUE 
      AND cp.is_profile_complete = TRUE
      AND cp.first_name IS NOT NULL 
      AND cp.last_name IS NOT NULL
      AND cp.designated_course IS NOT NULL
    ORDER BY cp.first_name ASC, cp.last_name ASC
  `);
    // Process profile photo URLs
    const processedCoordinators = coordinators.map(coord => ({
        ...coord,
        profile_photo: UploadService.getPhotoUrl(coord.profile_photo)
    }));
    res.json(processedCoordinators);
}));
// Get approved companies/business owners (public endpoint)
router.get('/companies/approved', asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [companies] = await connection.execute(`
    SELECT 
      c.id,
      cp.company_name,
      cp.profile_type,
      cp.first_name,
      cp.last_name,
      cp.business_summary,
      cp.profile_photo
    FROM companies c
    INNER JOIN company_profiles cp ON c.id = cp.company_id
    WHERE c.is_verified = TRUE 
      AND c.is_approved = TRUE 
      AND cp.profile_completed = TRUE
      AND cp.company_name IS NOT NULL
      AND cp.business_summary IS NOT NULL
    ORDER BY cp.company_name ASC
  `);
    // Process profile photo URLs
    const processedCompanies = companies.map(company => ({
        ...company,
        profile_photo: UploadService.getPhotoUrl(company.profile_photo)
    }));
    res.json(processedCompanies);
}));
export default router;
