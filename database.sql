-- Asiatech Career Connect (ACC) Database Schema
-- This SQL file can be imported into phpMyAdmin

CREATE DATABASE IF NOT EXISTS acc_database;
USE acc_database;

-- Users table (OJT students and alumni)
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('user') DEFAULT 'user',
    is_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    reset_token VARCHAR(255),
    reset_token_expires DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Coordinators table
CREATE TABLE coordinators (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('coordinator') DEFAULT 'coordinator',
    is_verified BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    reset_token VARCHAR(255),
    reset_token_expires DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Business owners/companies table
CREATE TABLE companies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('company') DEFAULT 'company',
    is_verified BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    invited_by_coordinator_id INT,
    verification_token VARCHAR(255),
    reset_token VARCHAR(255),
    reset_token_expires DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (invited_by_coordinator_id) REFERENCES coordinators(id)
);

-- Admins table
CREATE TABLE admins (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin') DEFAULT 'admin',
    is_verified BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    reset_token VARCHAR(255),
    reset_token_expires DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- User profiles table
CREATE TABLE user_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    student_type ENUM('ojt', 'alumni') NOT NULL,
    contact_number VARCHAR(20),
    age INT,
    birthdate DATE,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say'),
    profile_photo VARCHAR(255),
    profile_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Coordinator profiles table
CREATE TABLE coordinator_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coordinator_id INT UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    designated_course VARCHAR(100),
    contact_number VARCHAR(20),
    age INT,
    birthdate DATE,
    gender ENUM('male', 'female', 'other'),
    profile_photo VARCHAR(255),
    is_profile_complete BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (coordinator_id) REFERENCES coordinators(id) ON DELETE CASCADE
);

-- Company profiles table
CREATE TABLE company_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT UNIQUE NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    business_summary TEXT,
    key_requirements TEXT,
    company_logo VARCHAR(255),
    profile_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- Admin profiles table (enhanced for complete admin profiles)
CREATE TABLE admin_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    contact_number VARCHAR(20),
    age INT,
    birthdate DATE,
    gender ENUM('male', 'female', 'other'),
    position VARCHAR(100),
    department VARCHAR(100),
    profile_photo_url TEXT,
    is_profile_complete BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE CASCADE
);

-- Courses table (predefined courses)
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(150) NOT NULL,
    course_type ENUM('associate', 'bachelor') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User courses junction table (many-to-many relationship)
CREATE TABLE user_courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    graduation_status ENUM('current', 'graduated') DEFAULT 'current',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_course (user_id, course_id)
);

-- Resumes table
CREATE TABLE resumes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    template_id VARCHAR(50) NOT NULL DEFAULT 'classic-with-photo',
    status ENUM('draft', 'completed') DEFAULT 'draft',
    
    -- Resume Content (JSON fields)
    personal_info JSON,
    professional_summary TEXT,
    work_experience JSON,
    education JSON,
    skills JSON,
    websites_social_links JSON,
    custom_sections JSON,
    extracurricular_activities JSON,
    hobbies TEXT,
    `references` JSON,
    languages JSON,
    
    -- Formatting Options
    font_family ENUM('times-new-roman', 'arial', 'roboto') DEFAULT 'times-new-roman',
    paper_size ENUM('a4', 'us-letter') DEFAULT 'a4',
    
    -- Metadata
    is_primary BOOLEAN DEFAULT FALSE,
    download_count INT DEFAULT 0,
    last_downloaded TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_resumes (user_id, status),
    INDEX idx_template (template_id)
);

-- Comprehensive Job Management System

-- Job Categories by Course
CREATE TABLE job_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_course_name (course_name)
);

-- Jobs table (comprehensive)
CREATE TABLE jobs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    work_type ENUM('full-time', 'part-time', 'contract', 'internship') DEFAULT 'internship',
    work_arrangement ENUM('on-site', 'remote', 'hybrid') DEFAULT 'on-site',
    currency VARCHAR(10) DEFAULT 'PHP',
    min_salary DECIMAL(10, 2) NULL,
    max_salary DECIMAL(10, 2) NULL,
    description TEXT NOT NULL,
    summary TEXT NULL,
    video_url VARCHAR(500) NULL,
    company_name VARCHAR(255) NULL,
    application_deadline DATE NULL,
    positions_available INT DEFAULT 1,
    experience_level ENUM('entry-level', 'mid-level', 'senior-level', 'executive') DEFAULT 'entry-level',
    
    -- Creator information
    created_by_type ENUM('coordinator', 'company') NOT NULL,
    created_by_id INT NOT NULL,
    coordinator_name VARCHAR(255) NULL,
    business_owner_name VARCHAR(255) NULL,
    
    -- Status and metadata
    status ENUM('draft', 'active', 'paused', 'closed') DEFAULT 'active',
    is_featured BOOLEAN DEFAULT FALSE,
    filter_pre_screening BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_created_by (created_by_type, created_by_id),
    INDEX idx_status (status),
    INDEX idx_deadline (application_deadline)
);

-- Job screening questions
CREATE TABLE job_screening_questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT NOT NULL,
    question_text TEXT NOT NULL,
    question_type ENUM('salary_range', 'qualifications', 'english_skills', 'customer_service', 'notice_period', 'background_check', 'medical_check', 'public_holidays', 'work_right', 'relocation') NOT NULL,
    options JSON NULL, -- For multiple choice questions
    acceptable_answers JSON NULL, -- Acceptable answers for filtering
    min_salary_range DECIMAL(10, 2) NULL, -- For salary range questions
    max_salary_range DECIMAL(10, 2) NULL, -- For salary range questions
    is_required BOOLEAN DEFAULT FALSE,
    is_filter_criteria BOOLEAN DEFAULT FALSE, -- Whether this question is used for filtering
    order_index INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    INDEX idx_job_id (job_id),
    INDEX idx_order (job_id, order_index)
);

-- Job applications (comprehensive)
CREATE TABLE job_applications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT NOT NULL,
    user_id INT NOT NULL,
    
    -- Contact information
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT NULL,
    
    -- Application details
    position_applying_for VARCHAR(255) NOT NULL,
    resume_type ENUM('uploaded', 'builder_link') NOT NULL,
    resume_file VARCHAR(500) NULL, -- File path for uploaded resume
    resume_builder_link VARCHAR(500) NULL, -- Link to resume builder
    interview_video VARCHAR(500) NULL, -- Optional pre-recorded interview
    
    -- Status and screening
    status ENUM('pending', 'under_review', 'qualified', 'rejected', 'hired') DEFAULT 'pending',
    ats_score DECIMAL(5, 2) NULL, -- ATS matching score
    is_ats_processed BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_application (job_id, user_id), -- One application per user per job
    INDEX idx_job_status (job_id, status),
    INDEX idx_user_id (user_id)
);

-- Job application answers (for screening questions)
CREATE TABLE job_application_answers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    question_id INT NOT NULL,
    answer TEXT NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES job_applications(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES job_screening_questions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_answer (application_id, question_id)
);

-- ATS Resume Data (parsed resume information)
CREATE TABLE ats_resume_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    
    -- Personal information extracted
    extracted_name VARCHAR(255) NULL,
    extracted_email VARCHAR(255) NULL,
    extracted_phone VARCHAR(50) NULL,
    extracted_address TEXT NULL,
    
    -- Skills and experience
    skills JSON NULL, -- Array of extracted skills
    education JSON NULL, -- Array of education entries
    experience JSON NULL, -- Array of work experience
    certifications JSON NULL, -- Array of certifications
    
    -- Matching analysis
    skill_match_score DECIMAL(5, 2) DEFAULT 0,
    experience_match_score DECIMAL(5, 2) DEFAULT 0,
    education_match_score DECIMAL(5, 2) DEFAULT 0,
    overall_score DECIMAL(5, 2) DEFAULT 0,
    
    -- Raw data
    raw_text TEXT NULL, -- Original extracted text
    processing_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    processing_error TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (application_id) REFERENCES job_applications(id) ON DELETE CASCADE,
    UNIQUE KEY unique_ats_data (application_id)
);

-- Business owner comments on applications (only coordinators can see)
CREATE TABLE job_application_comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    commenter_id INT NOT NULL,
    commenter_type ENUM('coordinator', 'company') NOT NULL,
    comment TEXT NOT NULL,
    is_visible_to_coordinator BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (application_id) REFERENCES job_applications(id) ON DELETE CASCADE,
    INDEX idx_application_id (application_id),
    INDEX idx_commenter (commenter_type, commenter_id)
);

-- Job ratings and reviews by users
CREATE TABLE job_ratings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_rating (job_id, user_id), -- One rating per user per job
    INDEX idx_job_id (job_id),
    INDEX idx_rating (rating)
);

-- AI job matching scores table
CREATE TABLE job_matches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    job_id INT NOT NULL,
    resume_id INT NOT NULL,
    match_score DECIMAL(5,2) NOT NULL, -- Score out of 100
    match_reasons JSON, -- Detailed reasons for the match
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (resume_id) REFERENCES resumes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_job_resume_match (user_id, job_id, resume_id)
);

-- Email notifications table
CREATE TABLE email_notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    recipient_email VARCHAR(100) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    type ENUM('otp', 'invitation', 'application_status', 'job_match', 'general') NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_sent BOOLEAN DEFAULT FALSE,
    error_message TEXT
);

-- OTP verification table
CREATE TABLE otp_verifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    purpose ENUM('registration', 'login', 'password_reset') NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert predefined courses
INSERT INTO courses (course_name, course_type) VALUES
('Associate in Hotel and Restaurant Management', 'associate'),
('Associate in Information Technology', 'associate'),
('BS Accountancy', 'bachelor'),
('BS Business Administration Major in Marketing Management', 'bachelor'),
('BS Criminology', 'bachelor'),
('BS Tourism Management', 'bachelor'),
('BS Hospitality Management', 'bachelor'),
('BS Computer Engineering', 'bachelor'),
('BS Computer Science', 'bachelor'),
('BS Information Technology', 'bachelor'),
('BS Information System', 'bachelor'),
('BS Education Major in English', 'bachelor'),
('BS Education Major in Mathematics', 'bachelor'),
('BS Education Major in Social Science', 'bachelor');

-- Insert comprehensive job categories by course
INSERT INTO job_categories (course_name, category_name) VALUES
-- ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT
('ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Food & Beverage Services'),
('ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Front Office & Guest Services'),
('ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Housekeeping Management'),
('ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Restaurant Management'),
('ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Event Planning / Banquet Services'),
('ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Hospitality and Tourism'),
('ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Hotel Operations'),
('ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Barista / Bartending'),
('ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Culinary Arts (basic)'),
('ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Customer Service'),

-- ASSOCIATE IN INFORMATION TECHNOLOGY
('ASSOCIATE IN INFORMATION TECHNOLOGY', 'IT Support / Helpdesk'),
('ASSOCIATE IN INFORMATION TECHNOLOGY', 'Technical Support'),
('ASSOCIATE IN INFORMATION TECHNOLOGY', 'Computer Technician'),
('ASSOCIATE IN INFORMATION TECHNOLOGY', 'Junior Web Developer'),
('ASSOCIATE IN INFORMATION TECHNOLOGY', 'Software Testing / QA'),
('ASSOCIATE IN INFORMATION TECHNOLOGY', 'Network Support'),
('ASSOCIATE IN INFORMATION TECHNOLOGY', 'Data Entry / Office IT Assistant'),
('ASSOCIATE IN INFORMATION TECHNOLOGY', 'Basic Web Design'),
('ASSOCIATE IN INFORMATION TECHNOLOGY', 'System Administration (Junior)'),
('ASSOCIATE IN INFORMATION TECHNOLOGY', 'IT Sales'),

-- BS ACCOUNTANCY
('BS ACCOUNTANCY', 'Accounting and Finance'),
('BS ACCOUNTANCY', 'Audit and Assurance'),
('BS ACCOUNTANCY', 'Taxation'),
('BS ACCOUNTANCY', 'Bookkeeping'),
('BS ACCOUNTANCY', 'Financial Analysis'),
('BS ACCOUNTANCY', 'Management Accounting'),
('BS ACCOUNTANCY', 'Payroll'),
('BS ACCOUNTANCY', 'Banking and Financial Services'),
('BS ACCOUNTANCY', 'Accounts Payable/Receivable'),
('BS ACCOUNTANCY', 'Corporate Finance'),

-- BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT
('BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Sales and Marketing'),
('BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Digital Marketing'),
('BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Brand Management'),
('BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Advertising and Promotions'),
('BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Market Research'),
('BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Customer Relationship Management (CRM)'),
('BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Public Relations'),
('BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'E-commerce Marketing'),
('BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Retail Management'),
('BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Business Development'),

-- BS CRIMINOLOGY
('BS CRIMINOLOGY', 'Law Enforcement'),
('BS CRIMINOLOGY', 'Criminal Investigation'),
('BS CRIMINOLOGY', 'Security Services'),
('BS CRIMINOLOGY', 'Correctional Services'),
('BS CRIMINOLOGY', 'Forensic Science (basic roles)'),
('BS CRIMINOLOGY', 'Intelligence Services'),
('BS CRIMINOLOGY', 'Public Safety'),
('BS CRIMINOLOGY', 'Probation & Parole Services'),
('BS CRIMINOLOGY', 'Crime Prevention and Detection'),
('BS CRIMINOLOGY', 'Legal Support (e.g., paralegal, case assistant)'),

-- BS TOURISM MANAGEMENT
('BS TOURISM MANAGEMENT', 'Travel and Tour Services'),
('BS TOURISM MANAGEMENT', 'Airline and Airport Operations'),
('BS TOURISM MANAGEMENT', 'Event and Conference Planning'),
('BS TOURISM MANAGEMENT', 'Cruise Line Services'),
('BS TOURISM MANAGEMENT', 'Tourism Development and Planning'),
('BS TOURISM MANAGEMENT', 'Tour Guiding'),
('BS TOURISM MANAGEMENT', 'Travel Consultancy'),
('BS TOURISM MANAGEMENT', 'Destination Marketing'),
('BS TOURISM MANAGEMENT', 'Customer Service (Travel Industry)'),
('BS TOURISM MANAGEMENT', 'Leisure and Recreation Services'),

-- BS HOSPITALITY MANAGEMENT
('BS HOSPITALITY MANAGEMENT', 'Hotel and Resort Management'),
('BS HOSPITALITY MANAGEMENT', 'Food & Beverage Management'),
('BS HOSPITALITY MANAGEMENT', 'Front Office and Concierge Services'),
('BS HOSPITALITY MANAGEMENT', 'Hospitality Sales and Marketing'),
('BS HOSPITALITY MANAGEMENT', 'Event and Convention Services'),
('BS HOSPITALITY MANAGEMENT', 'Casino and Gaming Operations'),
('BS HOSPITALITY MANAGEMENT', 'Housekeeping Operations'),
('BS HOSPITALITY MANAGEMENT', 'Lodging and Accommodation Services'),
('BS HOSPITALITY MANAGEMENT', 'Guest Relations'),
('BS HOSPITALITY MANAGEMENT', 'Travel and Leisure'),

-- BS COMPUTER ENGINEERING
('BS COMPUTER ENGINEERING', 'Hardware Engineering'),
('BS COMPUTER ENGINEERING', 'Embedded Systems'),
('BS COMPUTER ENGINEERING', 'Network and Systems Engineering'),
('BS COMPUTER ENGINEERING', 'Robotics and Automation'),
('BS COMPUTER ENGINEERING', 'Software Development'),
('BS COMPUTER ENGINEERING', 'Systems Architecture'),
('BS COMPUTER ENGINEERING', 'IT Infrastructure'),
('BS COMPUTER ENGINEERING', 'Cybersecurity (technical roles)'),
('BS COMPUTER ENGINEERING', 'Firmware Development'),
('BS COMPUTER ENGINEERING', 'Technical Project Management'),

-- BS COMPUTER SCIENCE
('BS COMPUTER SCIENCE', 'Software Development / Programming'),
('BS COMPUTER SCIENCE', 'Data Structures and Algorithms'),
('BS COMPUTER SCIENCE', 'Artificial Intelligence / Machine Learning'),
('BS COMPUTER SCIENCE', 'Cybersecurity'),
('BS COMPUTER SCIENCE', 'Game Development'),
('BS COMPUTER SCIENCE', 'Systems Development'),
('BS COMPUTER SCIENCE', 'Web and Mobile App Development'),
('BS COMPUTER SCIENCE', 'Data Analytics / Data Science'),
('BS COMPUTER SCIENCE', 'DevOps / System Integration'),
('BS COMPUTER SCIENCE', 'Research & Development (Tech)'),

-- BS INFORMATION TECHNOLOGY
('BS INFORMATION TECHNOLOGY', 'IT Support / Technical Support'),
('BS INFORMATION TECHNOLOGY', 'Systems Administration'),
('BS INFORMATION TECHNOLOGY', 'Network Administration'),
('BS INFORMATION TECHNOLOGY', 'Web Development'),
('BS INFORMATION TECHNOLOGY', 'Database Administration'),
('BS INFORMATION TECHNOLOGY', 'Software Development'),
('BS INFORMATION TECHNOLOGY', 'Information Security'),
('BS INFORMATION TECHNOLOGY', 'Cloud Computing'),
('BS INFORMATION TECHNOLOGY', 'IT Project Management'),
('BS INFORMATION TECHNOLOGY', 'IT Consulting'),

-- BS INFORMATION SYSTEMS
('BS INFORMATION SYSTEMS', 'Business Analysis'),
('BS INFORMATION SYSTEMS', 'IT Project Coordination'),
('BS INFORMATION SYSTEMS', 'ERP / SAP Implementation'),
('BS INFORMATION SYSTEMS', 'Systems Analysis and Design'),
('BS INFORMATION SYSTEMS', 'Software Documentation and Testing'),
('BS INFORMATION SYSTEMS', 'Database Management'),
('BS INFORMATION SYSTEMS', 'Information Management'),
('BS INFORMATION SYSTEMS', 'IT Auditing'),
('BS INFORMATION SYSTEMS', 'Techno-functional Consulting'),
('BS INFORMATION SYSTEMS', 'Business Intelligence'),

-- BS EDUCATION MAJOR IN ENGLISH
('BS EDUCATION MAJOR IN ENGLISH', 'English Language Teaching'),
('BS EDUCATION MAJOR IN ENGLISH', 'ESL / EFL Instructor'),
('BS EDUCATION MAJOR IN ENGLISH', 'Content Writing / Editing'),
('BS EDUCATION MAJOR IN ENGLISH', 'Curriculum Development'),
('BS EDUCATION MAJOR IN ENGLISH', 'Academic Support Services'),
('BS EDUCATION MAJOR IN ENGLISH', 'Communication and Soft Skills Training'),
('BS EDUCATION MAJOR IN ENGLISH', 'Online Tutoring'),
('BS EDUCATION MAJOR IN ENGLISH', 'Publishing / Educational Materials Development'),
('BS EDUCATION MAJOR IN ENGLISH', 'Public Speaking & Speech Training'),
('BS EDUCATION MAJOR IN ENGLISH', 'Customer Support (English-intensive)'),

-- BS EDUCATION MAJOR IN MATHEMATICS
('BS EDUCATION MAJOR IN MATHEMATICS', 'Math Instruction / Teaching'),
('BS EDUCATION MAJOR IN MATHEMATICS', 'Statistics and Data Analysis'),
('BS EDUCATION MAJOR IN MATHEMATICS', 'Educational Content Development (Math)'),
('BS EDUCATION MAJOR IN MATHEMATICS', 'Research and Development'),
('BS EDUCATION MAJOR IN MATHEMATICS', 'Test and Assessment Creation'),
('BS EDUCATION MAJOR IN MATHEMATICS', 'Analytics Support Roles'),
('BS EDUCATION MAJOR IN MATHEMATICS', 'Tutoring (Online or Offline)'),
('BS EDUCATION MAJOR IN MATHEMATICS', 'Math Curriculum Development'),
('BS EDUCATION MAJOR IN MATHEMATICS', 'Insurance Underwriting (technical roles)'),
('BS EDUCATION MAJOR IN MATHEMATICS', 'Entry-Level Data Science'),

-- BS EDUCATION MAJOR IN SOCIAL SCIENCE
('BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Social Studies Teaching'),
('BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Research and Policy Analysis'),
('BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Government and NGO Roles'),
('BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Community Development'),
('BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Civic Education and Outreach'),
('BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Journalism / Public Affairs'),
('BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Public Relations'),
('BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Educational Content Creation'),
('BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Historical / Cultural Work (Museums, Archives)'),
('BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'HR and Organizational Development (with training)');

-- Create first admin account (can be deleted by other admins for security)
-- This is a bootstrap account to get started - should be replaced with personal accounts
-- Default credentials: admin@acc4.com / AdminACC123!@#
INSERT INTO admins (email, password_hash, is_verified, is_approved) VALUES
('admin@acc4.com', '$2a$12$boF748G4jq8HqAauxQO5KOQkp5MUKy2lfDfyVoMNz4GmWaghUOfQu', TRUE, TRUE);

INSERT INTO admin_profiles (admin_id, first_name, last_name, position, department, is_profile_complete) VALUES
(1, 'System', 'Bootstrap Admin', 'System Administrator', 'Information Technology', TRUE);

-- Indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_verification_token ON users(verification_token);
CREATE INDEX idx_coordinators_email ON coordinators(email);
CREATE INDEX idx_companies_email ON companies(email);
CREATE INDEX idx_admins_email ON admins(email);

-- Job Management System Indexes
CREATE INDEX idx_job_categories_course ON job_categories(course_name);
CREATE INDEX idx_jobs_category ON jobs(category);
CREATE INDEX idx_jobs_created_by ON jobs(created_by_type, created_by_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_deadline ON jobs(application_deadline);
CREATE INDEX idx_job_screening_questions_job_id ON job_screening_questions(job_id);
CREATE INDEX idx_job_screening_questions_order ON job_screening_questions(job_id, order_index);
CREATE INDEX idx_job_applications_job_status ON job_applications(job_id, status);
CREATE INDEX idx_job_applications_user_id ON job_applications(user_id);
CREATE INDEX idx_job_application_answers_app_id ON job_application_answers(application_id);
CREATE INDEX idx_job_application_answers_question_id ON job_application_answers(question_id);
CREATE INDEX idx_ats_resume_data_app_id ON ats_resume_data(application_id);
CREATE INDEX idx_job_application_comments_app_id ON job_application_comments(application_id);
CREATE INDEX idx_job_application_comments_commenter ON job_application_comments(commenter_type, commenter_id);
CREATE INDEX idx_job_ratings_job_id ON job_ratings(job_id);
CREATE INDEX idx_job_ratings_rating ON job_ratings(rating);

-- Legacy indexes (keeping for existing functionality)
CREATE INDEX idx_job_matches_user_id ON job_matches(user_id);
CREATE INDEX idx_job_matches_job_id ON job_matches(job_id);
CREATE INDEX idx_job_matches_score ON job_matches(match_score);
CREATE INDEX idx_otp_email_purpose ON otp_verifications(email, purpose);
CREATE INDEX idx_otp_expires ON otp_verifications(expires_at);
