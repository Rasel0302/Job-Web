-- Migration: Coordinator Affiliation System
-- Ensure proper relationship between companies and coordinators via invitation system

USE acc_database;

-- Add coordinator affiliation table to track the relationship more explicitly
CREATE TABLE IF NOT EXISTS company_coordinator_affiliations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    coordinator_id INT NOT NULL,
    invitation_id INT NOT NULL,
    affiliated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (coordinator_id) REFERENCES coordinators(id) ON DELETE CASCADE,
    FOREIGN KEY (invitation_id) REFERENCES company_invitations(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_company_coordinator (company_id, coordinator_id),
    INDEX idx_company_coordinator (company_id, coordinator_id),
    INDEX idx_coordinator_companies (coordinator_id),
    INDEX idx_invitation_affiliation (invitation_id)
);

-- Add company job applications status tracking
CREATE TABLE IF NOT EXISTS company_application_actions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    company_id INT NOT NULL,
    action_type ENUM('comment', 'email_sent', 'interview_scheduled', 'accepted', 'rejected', 'on_hold') NOT NULL,
    action_data JSON NULL COMMENT 'Store additional data like email content, interview details, etc.',
    reason TEXT NULL COMMENT 'Reason for accept/reject/hold actions',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL COMMENT 'Company user who performed the action',
    
    FOREIGN KEY (application_id) REFERENCES job_applications(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES companies(id) ON DELETE CASCADE,
    
    INDEX idx_application_actions (application_id),
    INDEX idx_company_actions (company_id),
    INDEX idx_action_type (action_type)
);

-- Add company application comments
CREATE TABLE IF NOT EXISTS company_application_comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    company_id INT NOT NULL,
    comment TEXT NOT NULL,
    comment_type ENUM('general', 'company_feedback', 'interview_note') DEFAULT 'general',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (application_id) REFERENCES job_applications(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    
    INDEX idx_application_comments (application_id),
    INDEX idx_company_comments (company_id)
);

-- Add company email notifications tracking
CREATE TABLE IF NOT EXISTS company_email_notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    company_id INT NOT NULL,
    recipient_email VARCHAR(255) NOT NULL,
    subject VARCHAR(500) NOT NULL,
    message_content TEXT NOT NULL,
    email_type ENUM('interview_invitation', 'accepted', 'rejected', 'on_hold', 'general') NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
    
    FOREIGN KEY (application_id) REFERENCES job_applications(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    
    INDEX idx_company_emails (company_id),
    INDEX idx_application_emails (application_id),
    INDEX idx_email_status (status)
);

-- Update company_invitations to be used when company registers
-- This will be handled in the backend registration logic
