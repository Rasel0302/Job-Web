-- Migration for Company Invitation System
-- This migration adds the necessary table to support coordinator invitations to companies

-- Create company_invitations table
CREATE TABLE IF NOT EXISTS company_invitations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Coordinator who sent the invitation
    coordinator_id INT NOT NULL,
    
    -- Company email and details
    company_email VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Invitation token (unique, used for registration)
    token VARCHAR(255) NOT NULL UNIQUE,
    
    -- Status tracking
    status ENUM('pending', 'used', 'expired') DEFAULT 'pending',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    used_at TIMESTAMP NULL,
    
    -- Company ID if they register (nullable until used)
    company_id INT NULL,
    
    -- Indexes
    INDEX idx_coordinator_id (coordinator_id),
    INDEX idx_company_email (company_email),
    INDEX idx_token (token),
    INDEX idx_status (status),
    INDEX idx_expires_at (expires_at),
    
    -- Foreign key constraints
    FOREIGN KEY (coordinator_id) REFERENCES coordinators(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL
);

-- Add index for efficient cleanup of expired invitations
CREATE INDEX idx_status_expires_at ON company_invitations(status, expires_at);
