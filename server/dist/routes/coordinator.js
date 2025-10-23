import express from 'express';
import { asyncHandler } from '../middleware/errorHandler.js';
import { authenticate, authenticateForProfileCompletion, authorize } from '../middleware/auth.js';
import { getConnection } from '../config/database.js';
import { emailService } from '../services/emailService.js';
const router = express.Router();
// Get coordinator profile
router.get('/profile', authenticateForProfileCompletion, asyncHandler(async (req, res) => {
    const connection = getConnection();
    const [coordinatorProfile] = await connection.execute(`
    SELECT 
      c.id,
      c.email,
      cp.first_name,
      cp.last_name,
      cp.contact_number,
      cp.age,
      cp.birthdate,
      cp.gender,
      cp.designated_course,
      cp.profile_photo,
      COALESCE(cp.is_profile_complete, FALSE) as is_profile_complete
    FROM coordinators c
    LEFT JOIN coordinator_profiles cp ON c.id = cp.coordinator_id
    WHERE c.id = ?
  `, [req.user.id]);
    if (coordinatorProfile.length === 0) {
        return res.status(404).json({ message: 'Coordinator not found' });
    }
    res.json(coordinatorProfile[0]);
}));
// Complete coordinator profile (used during registration)
router.post('/complete-profile', authenticateForProfileCompletion, asyncHandler(async (req, res) => {
    const { firstName, lastName, contactNumber, age, birthdate, gender, designatedCourse, profilePhotoUrl } = req.body;
    if (!firstName || !lastName || !contactNumber || !age || !birthdate || !gender || !designatedCourse || !profilePhotoUrl) {
        return res.status(400).json({ message: 'All required fields must be provided' });
    }
    const connection = getConnection();
    // Check if profile already exists
    const [existingProfile] = await connection.execute('SELECT id FROM coordinator_profiles WHERE coordinator_id = ?', [req.user.id]);
    if (existingProfile.length > 0) {
        // Update existing profile
        await connection.execute(`UPDATE coordinator_profiles SET 
        first_name = ?, last_name = ?, contact_number = ?, age = ?, birthdate = ?, 
        gender = ?, designated_course = ?, profile_photo = ?, 
        is_profile_complete = TRUE, updated_at = NOW() 
       WHERE coordinator_id = ?`, [firstName, lastName, contactNumber, age, birthdate, gender, designatedCourse, profilePhotoUrl, req.user.id]);
    }
    else {
        // Create new profile
        await connection.execute(`INSERT INTO coordinator_profiles 
        (coordinator_id, first_name, last_name, contact_number, age, birthdate, gender, designated_course, profile_photo, is_profile_complete) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE)`, [req.user.id, firstName, lastName, contactNumber, age, birthdate, gender, designatedCourse, profilePhotoUrl]);
    }
    res.json({
        message: 'Profile completed successfully! Your account is now pending admin approval.',
        profileComplete: true
    });
}));
// Update coordinator profile (for editing later)
router.put('/profile', authenticate, authorize('coordinator'), asyncHandler(async (req, res) => {
    const { firstName, lastName, contactNumber, age, birthdate, gender, designatedCourse, profilePhotoUrl } = req.body;
    const connection = getConnection();
    // Check if profile exists
    const [existingProfile] = await connection.execute('SELECT id FROM coordinator_profiles WHERE coordinator_id = ?', [req.user.id]);
    if (existingProfile.length > 0) {
        // Update existing profile
        if (profilePhotoUrl) {
            // Update with photo URL
            await connection.execute(`UPDATE coordinator_profiles SET 
          first_name = ?, last_name = ?, contact_number = ?, age = ?, birthdate = ?, 
          gender = ?, designated_course = ?, profile_photo = ?, updated_at = NOW() 
         WHERE coordinator_id = ?`, [firstName, lastName, contactNumber, age, birthdate, gender, designatedCourse, profilePhotoUrl, req.user.id]);
        }
        else {
            // Update without changing photo URL
            await connection.execute(`UPDATE coordinator_profiles SET 
          first_name = ?, last_name = ?, contact_number = ?, age = ?, birthdate = ?, 
          gender = ?, designated_course = ?, updated_at = NOW() 
         WHERE coordinator_id = ?`, [firstName, lastName, contactNumber, age, birthdate, gender, designatedCourse, req.user.id]);
        }
    }
    else {
        // Create new profile
        await connection.execute(`INSERT INTO coordinator_profiles 
        (coordinator_id, first_name, last_name, contact_number, age, birthdate, gender, designated_course, profile_photo, is_profile_complete) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE)`, [req.user.id, firstName, lastName, contactNumber, age, birthdate, gender, designatedCourse, profilePhotoUrl]);
    }
    res.json({ message: 'Coordinator profile updated successfully' });
}));
// Send company invitation
router.post('/invite-company', authenticate, authorize('coordinator'), asyncHandler(async (req, res) => {
    const { email, message } = req.body;
    if (!email || !message) {
        return res.status(400).json({ message: 'Email and message are required' });
    }
    const connection = getConnection();
    // Check if this email is already registered as a company
    const [existingCompanies] = await connection.execute('SELECT id FROM companies WHERE email = ?', [email]);
    if (existingCompanies.length > 0) {
        return res.status(400).json({ message: 'This email is already registered as a company' });
    }
    // Generate unique 8-digit invitation code
    const token = Math.floor(10000000 + Math.random() * 90000000).toString();
    // Set expiration to 7 days from now
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);
    // Insert invitation
    await connection.execute(`INSERT INTO company_invitations (coordinator_id, company_email, message, token, expires_at)
     VALUES (?, ?, ?, ?, ?)`, [req.user.id, email, message, token, expiresAt]);
    // Get coordinator info for the email
    const [coordinatorInfo] = await connection.execute(`
    SELECT 
      c.email,
      cp.first_name,
      cp.last_name,
      cp.designated_course
    FROM coordinators c
    LEFT JOIN coordinator_profiles cp ON c.id = cp.coordinator_id
    WHERE c.id = ?
  `, [req.user.id]);
    const coordinator = coordinatorInfo[0];
    const coordinatorName = coordinator ? `${coordinator.first_name || ''} ${coordinator.last_name || ''}`.trim() : 'Coordinator';
    // Send invitation email
    try {
        await emailService.sendCompanyInvitation({
            recipientEmail: email,
            recipientName: 'Company Representative',
            coordinatorName,
            coordinatorEmail: coordinator?.email || '',
            course: coordinator?.designated_course || '',
            message,
            invitationToken: token,
            expirationDate: expiresAt
        });
        res.json({
            message: 'Invitation sent successfully',
            token: token.substring(0, 8) + '...' // Return partial token for reference
        });
    }
    catch (emailError) {
        console.error('Failed to send invitation email:', emailError);
        // Delete the invitation since email failed
        await connection.execute('DELETE FROM company_invitations WHERE token = ?', [token]);
        res.status(500).json({ message: 'Failed to send invitation email. Please try again.' });
    }
}));
// Get invitation history for coordinator
router.get('/invitations', authenticate, authorize('coordinator'), asyncHandler(async (req, res) => {
    const connection = getConnection();
    // Update expired invitations
    await connection.execute('UPDATE company_invitations SET status = "expired" WHERE status = "pending" AND expires_at <= NOW()');
    const [invitations] = await connection.execute(`
    SELECT 
      ci.id,
      ci.company_email as email,
      ci.message,
      ci.token,
      ci.status,
      ci.created_at,
      ci.used_at,
      ci.expires_at
    FROM company_invitations ci
    WHERE ci.coordinator_id = ?
    ORDER BY ci.created_at DESC
  `, [req.user.id]);
    res.json(invitations);
}));
// Validate invitation token (used during company registration)
router.get('/validate-invitation/:token', asyncHandler(async (req, res) => {
    const { token } = req.params;
    const connection = getConnection();
    // Update expired invitations first
    await connection.execute('UPDATE company_invitations SET status = "expired" WHERE status = "pending" AND expires_at <= NOW()');
    const [invitations] = await connection.execute(`
    SELECT 
      ci.id,
      ci.coordinator_id,
      ci.company_email,
      ci.message,
      ci.status,
      ci.expires_at,
      c.email as coordinator_email,
      cp.first_name as coordinator_first_name,
      cp.last_name as coordinator_last_name,
      cp.designated_course
    FROM company_invitations ci
    LEFT JOIN coordinators c ON ci.coordinator_id = c.id
    LEFT JOIN coordinator_profiles cp ON c.id = cp.coordinator_id
    WHERE ci.token = ?
  `, [token]);
    if (invitations.length === 0) {
        return res.status(404).json({ message: 'Invalid invitation token' });
    }
    const invitation = invitations[0];
    if (invitation.status !== 'pending') {
        return res.status(400).json({
            message: invitation.status === 'used' ? 'This invitation has already been used' : 'This invitation has expired'
        });
    }
    const coordinatorName = `${invitation.coordinator_first_name || ''} ${invitation.coordinator_last_name || ''}`.trim();
    res.json({
        valid: true,
        companyEmail: invitation.company_email,
        coordinatorName: coordinatorName || 'Coordinator',
        coordinatorEmail: invitation.coordinator_email,
        course: invitation.designated_course,
        message: invitation.message
    });
}));
// Mark invitation as used (called after successful company registration)
router.post('/use-invitation/:token', asyncHandler(async (req, res) => {
    const { token } = req.params;
    const { companyId } = req.body;
    const connection = getConnection();
    const [result] = await connection.execute('UPDATE company_invitations SET status = "used", used_at = NOW(), company_id = ? WHERE token = ? AND status = "pending"', [companyId, token]);
    if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'Invalid or already used invitation token' });
    }
    res.json({ message: 'Invitation marked as used successfully' });
}));
export default router;
