-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 09, 2025 at 04:47 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `acc_database`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('admin') DEFAULT 'admin',
  `is_verified` tinyint(1) DEFAULT 0,
  `is_approved` tinyint(1) DEFAULT 0,
  `verification_token` varchar(255) DEFAULT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `email`, `password_hash`, `role`, `is_verified`, `is_approved`, `verification_token`, `reset_token`, `reset_token_expires`, `created_at`, `updated_at`) VALUES
(1, 'admin@acc4.com', '$2a$12$boF748G4jq8HqAauxQO5KOQkp5MUKy2lfDfyVoMNz4GmWaghUOfQu', 'admin', 1, 1, NULL, NULL, NULL, '2025-10-09 06:11:14', '2025-10-09 06:11:14');

-- --------------------------------------------------------

--
-- Table structure for table `admin_profiles`
--

CREATE TABLE `admin_profiles` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `gender` enum('male','female','other') DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `profile_photo_url` text DEFAULT NULL,
  `is_profile_complete` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_profiles`
--

INSERT INTO `admin_profiles` (`id`, `admin_id`, `first_name`, `last_name`, `contact_number`, `age`, `birthdate`, `gender`, `position`, `department`, `profile_photo_url`, `is_profile_complete`, `created_at`, `updated_at`) VALUES
(1, 1, 'System', 'Bootstrap Admin', NULL, NULL, NULL, NULL, 'System Administrator', 'Information Technology', NULL, 1, '2025-10-09 06:11:14', '2025-10-09 06:11:14');

-- --------------------------------------------------------

--
-- Table structure for table `ats_resume_data`
--

CREATE TABLE `ats_resume_data` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `extracted_name` varchar(255) DEFAULT NULL,
  `extracted_email` varchar(255) DEFAULT NULL,
  `extracted_phone` varchar(50) DEFAULT NULL,
  `extracted_address` text DEFAULT NULL,
  `skills` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`skills`)),
  `education` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`education`)),
  `experience` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`experience`)),
  `certifications` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`certifications`)),
  `skill_match_score` decimal(5,2) DEFAULT 0.00,
  `experience_match_score` decimal(5,2) DEFAULT 0.00,
  `education_match_score` decimal(5,2) DEFAULT 0.00,
  `overall_score` decimal(5,2) DEFAULT 0.00,
  `raw_text` text DEFAULT NULL,
  `processing_status` enum('pending','completed','failed') DEFAULT 'pending',
  `processing_error` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `companies`
--

CREATE TABLE `companies` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('company') DEFAULT 'company',
  `is_verified` tinyint(1) DEFAULT 0,
  `is_approved` tinyint(1) DEFAULT 0,
  `invited_by_coordinator_id` int(11) DEFAULT NULL,
  `verification_token` varchar(255) DEFAULT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_invitations`
--

CREATE TABLE `company_invitations` (
  `id` int(11) NOT NULL,
  `coordinator_id` int(11) NOT NULL,
  `company_email` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `token` varchar(255) NOT NULL,
  `status` enum('pending','used','expired') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `company_invitations`
--

INSERT INTO `company_invitations` (`id`, `coordinator_id`, `company_email`, `message`, `token`, `status`, `created_at`, `expires_at`, `used_at`, `company_id`) VALUES
(1, 1, 'selramarana0302@gmail.com', 'Hi this is Rasel Maraña a coordinator of ACC, we are excited to have you.', 'ef5dfcf318f6ffc36f0dd1ca7e21bb9fab60dfda10d216d67da0119cf81fbc3c', 'pending', '2025-10-09 13:16:48', '2025-10-16 05:16:48', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `company_profiles`
--

CREATE TABLE `company_profiles` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `company_name` varchar(100) NOT NULL,
  `business_summary` text DEFAULT NULL,
  `key_requirements` text DEFAULT NULL,
  `company_logo` varchar(255) DEFAULT NULL,
  `profile_completed` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `coordinators`
--

CREATE TABLE `coordinators` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('coordinator') DEFAULT 'coordinator',
  `is_verified` tinyint(1) DEFAULT 0,
  `is_approved` tinyint(1) DEFAULT 0,
  `verification_token` varchar(255) DEFAULT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `coordinators`
--

INSERT INTO `coordinators` (`id`, `email`, `password_hash`, `role`, `is_verified`, `is_approved`, `verification_token`, `reset_token`, `reset_token_expires`, `created_at`, `updated_at`) VALUES
(1, 'maranarasel19@gmail.com', '$2a$12$iBJc0c3ToAgEtxsGinMz5e87A6uRANekdM3N9SvlSb9u3InnOeU4G', 'coordinator', 1, 1, '3e2b55c06dd2cf88d081354d29a9ca45c3dbe95e63d03a08818f6be32c74111d', NULL, NULL, '2025-10-09 06:12:45', '2025-10-09 09:38:35');

-- --------------------------------------------------------

--
-- Table structure for table `coordinator_profiles`
--

CREATE TABLE `coordinator_profiles` (
  `id` int(11) NOT NULL,
  `coordinator_id` int(11) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `designated_course` varchar(100) DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `gender` enum('male','female','other') DEFAULT NULL,
  `profile_photo` varchar(255) DEFAULT NULL,
  `is_profile_complete` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `coordinator_profiles`
--

INSERT INTO `coordinator_profiles` (`id`, `coordinator_id`, `first_name`, `last_name`, `designated_course`, `contact_number`, `age`, `birthdate`, `gender`, `profile_photo`, `is_profile_complete`, `created_at`, `updated_at`) VALUES
(1, 1, 'Rasel', 'Maraña', 'Bachelor in Science of Information Technology', '09609167874', 21, '2025-03-02', 'male', 'http://localhost:5000/api/uploads/profiles/coordinator_1_1759990398985.webp', 1, '2025-10-09 06:13:38', '2025-10-09 06:13:38');

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `id` int(11) NOT NULL,
  `course_name` varchar(150) NOT NULL,
  `course_type` enum('associate','bachelor') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`id`, `course_name`, `course_type`, `created_at`) VALUES
(1, 'Associate in Hotel and Restaurant Management', 'associate', '2025-10-09 06:11:14'),
(2, 'Associate in Information Technology', 'associate', '2025-10-09 06:11:14'),
(3, 'BS Accountancy', 'bachelor', '2025-10-09 06:11:14'),
(4, 'BS Business Administration Major in Marketing Management', 'bachelor', '2025-10-09 06:11:14'),
(5, 'BS Criminology', 'bachelor', '2025-10-09 06:11:14'),
(6, 'BS Tourism Management', 'bachelor', '2025-10-09 06:11:14'),
(7, 'BS Hospitality Management', 'bachelor', '2025-10-09 06:11:14'),
(8, 'BS Computer Engineering', 'bachelor', '2025-10-09 06:11:14'),
(9, 'BS Computer Science', 'bachelor', '2025-10-09 06:11:14'),
(10, 'BS Information Technology', 'bachelor', '2025-10-09 06:11:14'),
(11, 'BS Information System', 'bachelor', '2025-10-09 06:11:14'),
(12, 'BS Education Major in English', 'bachelor', '2025-10-09 06:11:14'),
(13, 'BS Education Major in Mathematics', 'bachelor', '2025-10-09 06:11:14'),
(14, 'BS Education Major in Social Science', 'bachelor', '2025-10-09 06:11:14');

-- --------------------------------------------------------

--
-- Table structure for table `email_notifications`
--

CREATE TABLE `email_notifications` (
  `id` int(11) NOT NULL,
  `recipient_email` varchar(100) NOT NULL,
  `subject` varchar(200) NOT NULL,
  `body` text NOT NULL,
  `type` enum('otp','invitation','application_status','job_match','general') NOT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_sent` tinyint(1) DEFAULT 0,
  `error_message` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `email_notifications`
--

INSERT INTO `email_notifications` (`id`, `recipient_email`, `subject`, `body`, `type`, `sent_at`, `is_sent`, `error_message`) VALUES
(1, 'maranarasel19@gmail.com', 'Your ACC Verification Code', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }\n          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>ACC Career Connect</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Verification Code</h2>\n            <p>Your verification code for coordinator registration is:</p>\n            <div class=\"otp-box\">\n              <div class=\"otp-code\">399700</div>\n            </div>\n            <p><strong>This code will expire in 10 minutes.</strong></p>\n            <p>If you didn\'t request this code, please ignore this email.</p>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'otp', '2025-10-09 06:12:48', 1, NULL),
(2, 'maranarasel19@gmail.com', 'Welcome to Asiatech Career Connect!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Welcome to ACC!</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Hello maranarasel19!</h2>\n            <p>Welcome to Asiatech Career Connect! We\'re excited to have you join our platform as a coordinator.</p>\n            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>\n            <p>Get started by completing your profile and exploring the available opportunities.</p>\n            <a href=\"http://localhost:5173\" class=\"btn\">Start Exploring</a>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-09 06:13:05', 1, NULL),
(3, 'maranarasel19@gmail.com', '✅ Your coordinator account has been approved!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <title>Account APPROVED</title>\n        <style>\n          body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5; }\n          .container { max-width: 600px; margin: 0 auto; background-color: white; }\n          .header { background-color: #16a34a; color: white; padding: 30px; text-align: center; }\n          .content { padding: 30px; }\n          .status-badge { \n            display: inline-block; \n            padding: 8px 16px; \n            background-color: #16a34a; \n            color: white; \n            border-radius: 20px; \n            font-weight: bold; \n            font-size: 12px; \n            text-transform: uppercase; \n            margin-bottom: 20px;\n          }\n          .button { \n            display: inline-block; \n            padding: 12px 24px; \n            background-color: #3b82f6; \n            color: white; \n            text-decoration: none; \n            border-radius: 5px; \n            margin: 20px 0; \n          }\n          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 14px; }\n          .reason-box { \n            background-color: #fef2f2; \n            border: 1px solid #fecaca; \n            border-radius: 5px; \n            padding: 15px; \n            margin: 20px 0;\n            color: #991b1b;\n          }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Account APPROVED</h1>\n            <p>ACC Career Connect</p>\n          </div>\n          \n          <div class=\"content\">\n            <div class=\"status-badge\">APPROVED</div>\n            \n            <h2>Hello,</h2>\n            \n            <p>Great news! Your coordinator account has been approved and is now active.</p>\n            \n            \n            \n            <p><strong>Account Type:</strong> Coordinator</p>\n            <p><strong>Email:</strong> maranarasel19@gmail.com</p>\n            \n            <h3>What\'s Next?</h3>\n            <p>You can now login to your coordinator account and start using ACC Career Connect.</p>\n            \n            \n              <a href=\"http://localhost:5173/login\" class=\"button\">Login to Your Account</a>\n            \n            \n            <p>If you have any questions, please don\'t hesitate to contact our support team.</p>\n            \n            <p>Best regards,<br>\n            <strong>ACC Career Connect Team</strong></p>\n          </div>\n          \n          <div class=\"footer\">\n            <p>© 2025 ACC Career Connect. All rights reserved.</p>\n            <p>Asiatech College Career Platform</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-09 09:38:39', 1, NULL),
(4, 'selramarana0302@gmail.com', 'Invitation to Join ACC Career Connect Platform - Bachelor in Science of Information Technology', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"UTF-8\">\n        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n        <title>Company Invitation - ACC Career Connect</title>\n        <style>\n          body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }\n          .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }\n          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }\n          .content { padding: 30px; }\n          .message-box { background-color: #f8f9fa; border-left: 4px solid #007bff; padding: 20px; margin: 20px 0; }\n          .coordinator-info { background-color: #e3f2fd; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .button { \n            display: inline-block; \n            padding: 15px 30px; \n            background-color: #007bff; \n            color: white; \n            text-decoration: none; \n            border-radius: 5px; \n            margin: 20px 0; \n            font-weight: bold; \n          }\n          .token-info { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #666; }\n          .expiry-notice { background-color: #f8d7da; border: 1px solid #f1c2c2; padding: 10px; border-radius: 5px; margin: 15px 0; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>🎓 ACC Career Connect</h1>\n            <h2>Company Partnership Invitation</h2>\n          </div>\n          \n          <div class=\"content\">\n            <h3>Dear Company Representative,</h3>\n            \n            <p>You have been invited to join the ACC Career Connect platform as a company partner!</p>\n            \n            <div class=\"coordinator-info\">\n              <h4>📧 Invitation From:</h4>\n              <p><strong>Coordinator:</strong> Rasel Maraña</p>\n              <p><strong>Email:</strong> maranarasel19@gmail.com</p>\n              <p><strong>Course/Department:</strong> Bachelor in Science of Information Technology</p>\n            </div>\n            \n            <div class=\"message-box\">\n              <h4>💌 Personal Message:</h4>\n              <p style=\"font-style: italic; line-height: 1.6;\">\"Hi this is Rasel Maraña a coordinator of ACC, we are excited to have you.\"</p>\n            </div>\n            \n            <h4>🚀 What You Can Do:</h4>\n            <ul style=\"line-height: 1.8;\">\n              <li><strong>Post Job Opportunities:</strong> Share internship, part-time, and full-time positions</li>\n              <li><strong>Access Talented Candidates:</strong> Connect with skilled students and alumni</li>\n              <li><strong>Review Applications:</strong> Manage applications with our comprehensive tools</li>\n              <li><strong>Build Your Team:</strong> Find the right talent for your company</li>\n            </ul>\n            \n            <div class=\"token-info\">\n              <h4>🔑 Your Invitation Details:</h4>\n              <p><strong>Invitation Token:</strong> <code>ef5dfcf318f6ffc36f0dd1ca7e21bb9fab60dfda10d216d67da0119cf81fbc3c</code></p>\n              <p><strong>Invited Email:</strong> selramarana0302@gmail.com</p>\n              <p><em>You\'ll need this token during registration to verify your invitation.</em></p>\n            </div>\n            \n            <div style=\"text-align: center;\">\n              <a href=\"http://localhost:5173/register?token=ef5dfcf318f6ffc36f0dd1ca7e21bb9fab60dfda10d216d67da0119cf81fbc3c\" class=\"button\">🎯 Join ACC Career Connect Now</a>\n            </div>\n            \n            <div class=\"expiry-notice\">\n              <p><strong>⏰ Important:</strong> This invitation expires on <strong>10/16/2025</strong>. Please register before this date.</p>\n            </div>\n            \n            <h4>📋 How to Register:</h4>\n            <ol style=\"line-height: 1.8;\">\n              <li>Click the registration button above</li>\n              <li>Select \"Company/Business Owner\" during registration</li>\n              <li>Use your invitation token: <strong>ef5dfcf318f6ffc36f0dd1ca7e21bb9fab60dfda10d216d67da0119cf81fbc3c</strong></li>\n              <li>Complete your company profile</li>\n              <li>Start posting jobs and finding talent!</li>\n            </ol>\n            \n            <p>If you have any questions or need assistance, please don\'t hesitate to contact the coordinator directly at <a href=\"mailto:maranarasel19@gmail.com\">maranarasel19@gmail.com</a>.</p>\n            \n            <p>We look forward to having you as a partner in connecting students with great career opportunities!</p>\n            \n            <p>Best regards,<br>\n            <strong>ACC Career Connect Team</strong><br>\n            <em>Asiatech College Career Platform</em></p>\n          </div>\n          \n          <div class=\"footer\">\n            <p>© 2025 ACC Career Connect. All rights reserved.</p>\n            <p>This invitation was sent by Rasel Maraña (maranarasel19@gmail.com)</p>\n            <p>If you received this email by mistake, please ignore it.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'invitation', '2025-10-09 13:16:51', 1, NULL),
(5, '1-220471@asiatech.edu.ph', 'Your ACC Verification Code', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }\n          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>ACC Career Connect</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Verification Code</h2>\n            <p>Your verification code for registration is:</p>\n            <div class=\"otp-box\">\n              <div class=\"otp-code\">847272</div>\n            </div>\n            <p><strong>This code will expire in 10 minutes.</strong></p>\n            <p>If you didn\'t request this code, please ignore this email.</p>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'otp', '2025-10-09 13:34:39', 1, NULL),
(6, '1-220471@asiatech.edu.ph', 'Welcome to Asiatech Career Connect!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Welcome to ACC!</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Hello 1-220471!</h2>\n            <p>Welcome to Asiatech Career Connect! We\'re excited to have you join our platform as a user.</p>\n            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>\n            <p>Get started by completing your profile and exploring the available opportunities.</p>\n            <a href=\"http://localhost:5173\" class=\"btn\">Start Exploring</a>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-09 13:35:06', 1, NULL),
(7, '1-220471@asiatech.edu.ph', 'Your ACC Verification Code', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }\n          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>ACC Career Connect</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Verification Code</h2>\n            <p>Your verification code for registration is:</p>\n            <div class=\"otp-box\">\n              <div class=\"otp-code\">928190</div>\n            </div>\n            <p><strong>This code will expire in 10 minutes.</strong></p>\n            <p>If you didn\'t request this code, please ignore this email.</p>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'otp', '2025-10-09 14:25:11', 1, NULL),
(8, '1-220471@asiatech.edu.ph', 'Welcome to Asiatech Career Connect!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Welcome to ACC!</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Hello 1-220471!</h2>\n            <p>Welcome to Asiatech Career Connect! We\'re excited to have you join our platform as a user.</p>\n            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>\n            <p>Get started by completing your profile and exploring the available opportunities.</p>\n            <a href=\"http://localhost:5173\" class=\"btn\">Start Exploring</a>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-09 14:25:52', 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `work_type` enum('full-time','part-time','contract','internship') DEFAULT 'internship',
  `work_arrangement` enum('on-site','remote','hybrid') DEFAULT 'on-site',
  `currency` varchar(10) DEFAULT 'PHP',
  `min_salary` decimal(10,2) DEFAULT NULL,
  `max_salary` decimal(10,2) DEFAULT NULL,
  `description` text NOT NULL,
  `summary` text DEFAULT NULL,
  `video_url` varchar(500) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `application_deadline` date DEFAULT NULL,
  `positions_available` int(11) DEFAULT 1,
  `experience_level` enum('entry-level','mid-level','senior-level','executive') DEFAULT 'entry-level',
  `created_by_type` enum('coordinator','company') NOT NULL,
  `created_by_id` int(11) NOT NULL,
  `coordinator_name` varchar(255) DEFAULT NULL,
  `business_owner_name` varchar(255) DEFAULT NULL,
  `status` enum('draft','active','paused','closed') DEFAULT 'active',
  `is_featured` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `filter_pre_screening` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `title`, `location`, `category`, `work_type`, `work_arrangement`, `currency`, `min_salary`, `max_salary`, `description`, `summary`, `video_url`, `company_name`, `application_deadline`, `positions_available`, `experience_level`, `created_by_type`, `created_by_id`, `coordinator_name`, `business_owner_name`, `status`, `is_featured`, `created_at`, `updated_at`, `filter_pre_screening`) VALUES
(1, 'IT Debugger', 'San Pablo, Ilocos Sur', 'IT Support / Technical Support', 'full-time', 'on-site', 'PHP', 20000.00, 30000.00, 'We are', 'BDO', NULL, NULL, '2025-11-27', 4, 'mid-level', 'coordinator', 1, 'Rasel Maraña', NULL, 'active', 0, '2025-10-09 11:02:26', '2025-10-09 11:02:26', 0);

-- --------------------------------------------------------

--
-- Table structure for table `job_applications`
--

CREATE TABLE `job_applications` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` text DEFAULT NULL,
  `position_applying_for` varchar(255) NOT NULL,
  `resume_type` enum('uploaded','builder_link') NOT NULL,
  `resume_file` varchar(500) DEFAULT NULL,
  `resume_builder_link` varchar(500) DEFAULT NULL,
  `interview_video` varchar(500) DEFAULT NULL,
  `status` enum('pending','under_review','qualified','rejected','hired') DEFAULT 'pending',
  `ats_score` decimal(5,2) DEFAULT NULL,
  `is_ats_processed` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `job_applications`
--

INSERT INTO `job_applications` (`id`, `job_id`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `address`, `position_applying_for`, `resume_type`, `resume_file`, `resume_builder_link`, `interview_video`, `status`, `ats_score`, `is_ats_processed`, `created_at`, `updated_at`) VALUES
(1, 1, 2, 'Rasel', 'Maraña', '1-220471@asiatech.edu.ph', '09609167874', 'Celina Plains, Phase 1, Block 7, Lot 8/ Santa Rosa/ Laguna', 'IT Debugger', 'uploaded', 'resumeFile-1760020666267-122152446.pdf', NULL, NULL, 'pending', NULL, 0, '2025-10-09 14:37:46', '2025-10-09 14:37:46');

-- --------------------------------------------------------

--
-- Table structure for table `job_application_answers`
--

CREATE TABLE `job_application_answers` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `answer` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_application_comments`
--

CREATE TABLE `job_application_comments` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `commenter_id` int(11) NOT NULL,
  `commenter_type` enum('coordinator','company') NOT NULL,
  `comment` text NOT NULL,
  `is_visible_to_coordinator` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_categories`
--

CREATE TABLE `job_categories` (
  `id` int(11) NOT NULL,
  `course_name` varchar(100) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `job_categories`
--

INSERT INTO `job_categories` (`id`, `course_name`, `category_name`, `created_at`) VALUES
(1, 'ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Food & Beverage Services', '2025-10-09 06:11:14'),
(2, 'ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Front Office & Guest Services', '2025-10-09 06:11:14'),
(3, 'ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Housekeeping Management', '2025-10-09 06:11:14'),
(4, 'ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Restaurant Management', '2025-10-09 06:11:14'),
(5, 'ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Event Planning / Banquet Services', '2025-10-09 06:11:14'),
(6, 'ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Hospitality and Tourism', '2025-10-09 06:11:14'),
(7, 'ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Hotel Operations', '2025-10-09 06:11:14'),
(8, 'ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Barista / Bartending', '2025-10-09 06:11:14'),
(9, 'ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Culinary Arts (basic)', '2025-10-09 06:11:14'),
(10, 'ASSOCIATE IN HOTEL AND RESTAURANT MANAGEMENT', 'Customer Service', '2025-10-09 06:11:14'),
(11, 'ASSOCIATE IN INFORMATION TECHNOLOGY', 'IT Support / Helpdesk', '2025-10-09 06:11:14'),
(12, 'ASSOCIATE IN INFORMATION TECHNOLOGY', 'Technical Support', '2025-10-09 06:11:14'),
(13, 'ASSOCIATE IN INFORMATION TECHNOLOGY', 'Computer Technician', '2025-10-09 06:11:14'),
(14, 'ASSOCIATE IN INFORMATION TECHNOLOGY', 'Junior Web Developer', '2025-10-09 06:11:14'),
(15, 'ASSOCIATE IN INFORMATION TECHNOLOGY', 'Software Testing / QA', '2025-10-09 06:11:14'),
(16, 'ASSOCIATE IN INFORMATION TECHNOLOGY', 'Network Support', '2025-10-09 06:11:14'),
(17, 'ASSOCIATE IN INFORMATION TECHNOLOGY', 'Data Entry / Office IT Assistant', '2025-10-09 06:11:14'),
(18, 'ASSOCIATE IN INFORMATION TECHNOLOGY', 'Basic Web Design', '2025-10-09 06:11:14'),
(19, 'ASSOCIATE IN INFORMATION TECHNOLOGY', 'System Administration (Junior)', '2025-10-09 06:11:14'),
(20, 'ASSOCIATE IN INFORMATION TECHNOLOGY', 'IT Sales', '2025-10-09 06:11:14'),
(21, 'BS ACCOUNTANCY', 'Accounting and Finance', '2025-10-09 06:11:14'),
(22, 'BS ACCOUNTANCY', 'Audit and Assurance', '2025-10-09 06:11:14'),
(23, 'BS ACCOUNTANCY', 'Taxation', '2025-10-09 06:11:14'),
(24, 'BS ACCOUNTANCY', 'Bookkeeping', '2025-10-09 06:11:14'),
(25, 'BS ACCOUNTANCY', 'Financial Analysis', '2025-10-09 06:11:14'),
(26, 'BS ACCOUNTANCY', 'Management Accounting', '2025-10-09 06:11:14'),
(27, 'BS ACCOUNTANCY', 'Payroll', '2025-10-09 06:11:14'),
(28, 'BS ACCOUNTANCY', 'Banking and Financial Services', '2025-10-09 06:11:14'),
(29, 'BS ACCOUNTANCY', 'Accounts Payable/Receivable', '2025-10-09 06:11:14'),
(30, 'BS ACCOUNTANCY', 'Corporate Finance', '2025-10-09 06:11:14'),
(31, 'BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Sales and Marketing', '2025-10-09 06:11:14'),
(32, 'BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Digital Marketing', '2025-10-09 06:11:14'),
(33, 'BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Brand Management', '2025-10-09 06:11:14'),
(34, 'BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Advertising and Promotions', '2025-10-09 06:11:14'),
(35, 'BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Market Research', '2025-10-09 06:11:14'),
(36, 'BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Customer Relationship Management (CRM)', '2025-10-09 06:11:14'),
(37, 'BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Public Relations', '2025-10-09 06:11:14'),
(38, 'BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'E-commerce Marketing', '2025-10-09 06:11:14'),
(39, 'BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Retail Management', '2025-10-09 06:11:14'),
(40, 'BS BUSINESS ADMINISTRATION MAJOR IN MARKETING MANAGEMENT', 'Business Development', '2025-10-09 06:11:14'),
(41, 'BS CRIMINOLOGY', 'Law Enforcement', '2025-10-09 06:11:14'),
(42, 'BS CRIMINOLOGY', 'Criminal Investigation', '2025-10-09 06:11:14'),
(43, 'BS CRIMINOLOGY', 'Security Services', '2025-10-09 06:11:14'),
(44, 'BS CRIMINOLOGY', 'Correctional Services', '2025-10-09 06:11:14'),
(45, 'BS CRIMINOLOGY', 'Forensic Science (basic roles)', '2025-10-09 06:11:14'),
(46, 'BS CRIMINOLOGY', 'Intelligence Services', '2025-10-09 06:11:14'),
(47, 'BS CRIMINOLOGY', 'Public Safety', '2025-10-09 06:11:14'),
(48, 'BS CRIMINOLOGY', 'Probation & Parole Services', '2025-10-09 06:11:14'),
(49, 'BS CRIMINOLOGY', 'Crime Prevention and Detection', '2025-10-09 06:11:14'),
(50, 'BS CRIMINOLOGY', 'Legal Support (e.g., paralegal, case assistant)', '2025-10-09 06:11:14'),
(51, 'BS TOURISM MANAGEMENT', 'Travel and Tour Services', '2025-10-09 06:11:14'),
(52, 'BS TOURISM MANAGEMENT', 'Airline and Airport Operations', '2025-10-09 06:11:14'),
(53, 'BS TOURISM MANAGEMENT', 'Event and Conference Planning', '2025-10-09 06:11:14'),
(54, 'BS TOURISM MANAGEMENT', 'Cruise Line Services', '2025-10-09 06:11:14'),
(55, 'BS TOURISM MANAGEMENT', 'Tourism Development and Planning', '2025-10-09 06:11:14'),
(56, 'BS TOURISM MANAGEMENT', 'Tour Guiding', '2025-10-09 06:11:14'),
(57, 'BS TOURISM MANAGEMENT', 'Travel Consultancy', '2025-10-09 06:11:14'),
(58, 'BS TOURISM MANAGEMENT', 'Destination Marketing', '2025-10-09 06:11:14'),
(59, 'BS TOURISM MANAGEMENT', 'Customer Service (Travel Industry)', '2025-10-09 06:11:14'),
(60, 'BS TOURISM MANAGEMENT', 'Leisure and Recreation Services', '2025-10-09 06:11:14'),
(61, 'BS HOSPITALITY MANAGEMENT', 'Hotel and Resort Management', '2025-10-09 06:11:14'),
(62, 'BS HOSPITALITY MANAGEMENT', 'Food & Beverage Management', '2025-10-09 06:11:14'),
(63, 'BS HOSPITALITY MANAGEMENT', 'Front Office and Concierge Services', '2025-10-09 06:11:14'),
(64, 'BS HOSPITALITY MANAGEMENT', 'Hospitality Sales and Marketing', '2025-10-09 06:11:14'),
(65, 'BS HOSPITALITY MANAGEMENT', 'Event and Convention Services', '2025-10-09 06:11:14'),
(66, 'BS HOSPITALITY MANAGEMENT', 'Casino and Gaming Operations', '2025-10-09 06:11:14'),
(67, 'BS HOSPITALITY MANAGEMENT', 'Housekeeping Operations', '2025-10-09 06:11:14'),
(68, 'BS HOSPITALITY MANAGEMENT', 'Lodging and Accommodation Services', '2025-10-09 06:11:14'),
(69, 'BS HOSPITALITY MANAGEMENT', 'Guest Relations', '2025-10-09 06:11:14'),
(70, 'BS HOSPITALITY MANAGEMENT', 'Travel and Leisure', '2025-10-09 06:11:14'),
(71, 'BS COMPUTER ENGINEERING', 'Hardware Engineering', '2025-10-09 06:11:14'),
(72, 'BS COMPUTER ENGINEERING', 'Embedded Systems', '2025-10-09 06:11:14'),
(73, 'BS COMPUTER ENGINEERING', 'Network and Systems Engineering', '2025-10-09 06:11:14'),
(74, 'BS COMPUTER ENGINEERING', 'Robotics and Automation', '2025-10-09 06:11:14'),
(75, 'BS COMPUTER ENGINEERING', 'Software Development', '2025-10-09 06:11:14'),
(76, 'BS COMPUTER ENGINEERING', 'Systems Architecture', '2025-10-09 06:11:14'),
(77, 'BS COMPUTER ENGINEERING', 'IT Infrastructure', '2025-10-09 06:11:14'),
(78, 'BS COMPUTER ENGINEERING', 'Cybersecurity (technical roles)', '2025-10-09 06:11:14'),
(79, 'BS COMPUTER ENGINEERING', 'Firmware Development', '2025-10-09 06:11:14'),
(80, 'BS COMPUTER ENGINEERING', 'Technical Project Management', '2025-10-09 06:11:14'),
(81, 'BS COMPUTER SCIENCE', 'Software Development / Programming', '2025-10-09 06:11:14'),
(82, 'BS COMPUTER SCIENCE', 'Data Structures and Algorithms', '2025-10-09 06:11:14'),
(83, 'BS COMPUTER SCIENCE', 'Artificial Intelligence / Machine Learning', '2025-10-09 06:11:14'),
(84, 'BS COMPUTER SCIENCE', 'Cybersecurity', '2025-10-09 06:11:14'),
(85, 'BS COMPUTER SCIENCE', 'Game Development', '2025-10-09 06:11:14'),
(86, 'BS COMPUTER SCIENCE', 'Systems Development', '2025-10-09 06:11:14'),
(87, 'BS COMPUTER SCIENCE', 'Web and Mobile App Development', '2025-10-09 06:11:14'),
(88, 'BS COMPUTER SCIENCE', 'Data Analytics / Data Science', '2025-10-09 06:11:14'),
(89, 'BS COMPUTER SCIENCE', 'DevOps / System Integration', '2025-10-09 06:11:14'),
(90, 'BS COMPUTER SCIENCE', 'Research & Development (Tech)', '2025-10-09 06:11:14'),
(91, 'BS INFORMATION TECHNOLOGY', 'IT Support / Technical Support', '2025-10-09 06:11:14'),
(92, 'BS INFORMATION TECHNOLOGY', 'Systems Administration', '2025-10-09 06:11:14'),
(93, 'BS INFORMATION TECHNOLOGY', 'Network Administration', '2025-10-09 06:11:14'),
(94, 'BS INFORMATION TECHNOLOGY', 'Web Development', '2025-10-09 06:11:14'),
(95, 'BS INFORMATION TECHNOLOGY', 'Database Administration', '2025-10-09 06:11:14'),
(96, 'BS INFORMATION TECHNOLOGY', 'Software Development', '2025-10-09 06:11:14'),
(97, 'BS INFORMATION TECHNOLOGY', 'Information Security', '2025-10-09 06:11:14'),
(98, 'BS INFORMATION TECHNOLOGY', 'Cloud Computing', '2025-10-09 06:11:14'),
(99, 'BS INFORMATION TECHNOLOGY', 'IT Project Management', '2025-10-09 06:11:14'),
(100, 'BS INFORMATION TECHNOLOGY', 'IT Consulting', '2025-10-09 06:11:14'),
(101, 'BS INFORMATION SYSTEMS', 'Business Analysis', '2025-10-09 06:11:14'),
(102, 'BS INFORMATION SYSTEMS', 'IT Project Coordination', '2025-10-09 06:11:14'),
(103, 'BS INFORMATION SYSTEMS', 'ERP / SAP Implementation', '2025-10-09 06:11:14'),
(104, 'BS INFORMATION SYSTEMS', 'Systems Analysis and Design', '2025-10-09 06:11:14'),
(105, 'BS INFORMATION SYSTEMS', 'Software Documentation and Testing', '2025-10-09 06:11:14'),
(106, 'BS INFORMATION SYSTEMS', 'Database Management', '2025-10-09 06:11:14'),
(107, 'BS INFORMATION SYSTEMS', 'Information Management', '2025-10-09 06:11:14'),
(108, 'BS INFORMATION SYSTEMS', 'IT Auditing', '2025-10-09 06:11:14'),
(109, 'BS INFORMATION SYSTEMS', 'Techno-functional Consulting', '2025-10-09 06:11:14'),
(110, 'BS INFORMATION SYSTEMS', 'Business Intelligence', '2025-10-09 06:11:14'),
(111, 'BS EDUCATION MAJOR IN ENGLISH', 'English Language Teaching', '2025-10-09 06:11:14'),
(112, 'BS EDUCATION MAJOR IN ENGLISH', 'ESL / EFL Instructor', '2025-10-09 06:11:14'),
(113, 'BS EDUCATION MAJOR IN ENGLISH', 'Content Writing / Editing', '2025-10-09 06:11:14'),
(114, 'BS EDUCATION MAJOR IN ENGLISH', 'Curriculum Development', '2025-10-09 06:11:14'),
(115, 'BS EDUCATION MAJOR IN ENGLISH', 'Academic Support Services', '2025-10-09 06:11:14'),
(116, 'BS EDUCATION MAJOR IN ENGLISH', 'Communication and Soft Skills Training', '2025-10-09 06:11:14'),
(117, 'BS EDUCATION MAJOR IN ENGLISH', 'Online Tutoring', '2025-10-09 06:11:14'),
(118, 'BS EDUCATION MAJOR IN ENGLISH', 'Publishing / Educational Materials Development', '2025-10-09 06:11:14'),
(119, 'BS EDUCATION MAJOR IN ENGLISH', 'Public Speaking & Speech Training', '2025-10-09 06:11:14'),
(120, 'BS EDUCATION MAJOR IN ENGLISH', 'Customer Support (English-intensive)', '2025-10-09 06:11:14'),
(121, 'BS EDUCATION MAJOR IN MATHEMATICS', 'Math Instruction / Teaching', '2025-10-09 06:11:14'),
(122, 'BS EDUCATION MAJOR IN MATHEMATICS', 'Statistics and Data Analysis', '2025-10-09 06:11:14'),
(123, 'BS EDUCATION MAJOR IN MATHEMATICS', 'Educational Content Development (Math)', '2025-10-09 06:11:14'),
(124, 'BS EDUCATION MAJOR IN MATHEMATICS', 'Research and Development', '2025-10-09 06:11:14'),
(125, 'BS EDUCATION MAJOR IN MATHEMATICS', 'Test and Assessment Creation', '2025-10-09 06:11:14'),
(126, 'BS EDUCATION MAJOR IN MATHEMATICS', 'Analytics Support Roles', '2025-10-09 06:11:14'),
(127, 'BS EDUCATION MAJOR IN MATHEMATICS', 'Tutoring (Online or Offline)', '2025-10-09 06:11:14'),
(128, 'BS EDUCATION MAJOR IN MATHEMATICS', 'Math Curriculum Development', '2025-10-09 06:11:14'),
(129, 'BS EDUCATION MAJOR IN MATHEMATICS', 'Insurance Underwriting (technical roles)', '2025-10-09 06:11:14'),
(130, 'BS EDUCATION MAJOR IN MATHEMATICS', 'Entry-Level Data Science', '2025-10-09 06:11:14'),
(131, 'BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Social Studies Teaching', '2025-10-09 06:11:14'),
(132, 'BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Research and Policy Analysis', '2025-10-09 06:11:14'),
(133, 'BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Government and NGO Roles', '2025-10-09 06:11:14'),
(134, 'BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Community Development', '2025-10-09 06:11:14'),
(135, 'BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Civic Education and Outreach', '2025-10-09 06:11:14'),
(136, 'BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Journalism / Public Affairs', '2025-10-09 06:11:14'),
(137, 'BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Public Relations', '2025-10-09 06:11:14'),
(138, 'BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Educational Content Creation', '2025-10-09 06:11:14'),
(139, 'BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'Historical / Cultural Work (Museums, Archives)', '2025-10-09 06:11:14'),
(140, 'BS EDUCATION MAJOR IN SOCIAL SCIENCE', 'HR and Organizational Development (with training)', '2025-10-09 06:11:14');

-- --------------------------------------------------------

--
-- Table structure for table `job_matches`
--

CREATE TABLE `job_matches` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `resume_id` int(11) NOT NULL,
  `match_score` decimal(5,2) NOT NULL,
  `match_reasons` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`match_reasons`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_ratings`
--

CREATE TABLE `job_ratings` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` int(11) NOT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `review` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_screening_questions`
--

CREATE TABLE `job_screening_questions` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `question_text` text NOT NULL,
  `question_type` enum('salary_range','qualifications','english_skills','customer_service','notice_period','background_check','medical_check','public_holidays','work_right','relocation') NOT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `is_required` tinyint(1) DEFAULT 0,
  `order_index` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `acceptable_answers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Acceptable answers for filtering' CHECK (json_valid(`acceptable_answers`)),
  `min_salary_range` decimal(10,2) DEFAULT NULL COMMENT 'For salary range questions',
  `max_salary_range` decimal(10,2) DEFAULT NULL COMMENT 'For salary range questions',
  `is_filter_criteria` tinyint(1) DEFAULT 0 COMMENT 'Whether this question is used for filtering'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `job_screening_questions`
--

INSERT INTO `job_screening_questions` (`id`, `job_id`, `question_text`, `question_type`, `options`, `is_required`, `order_index`, `created_at`, `acceptable_answers`, `min_salary_range`, `max_salary_range`, `is_filter_criteria`) VALUES
(1, 1, 'What\'s your expected monthly basic salary range?', 'salary_range', NULL, 0, 0, '2025-10-09 11:02:26', NULL, NULL, NULL, 0),
(2, 1, 'Which of the following types of qualifications do you have?', 'qualifications', '[\"High School Diploma\",\"National Certificate 1\",\"National Certificate 2\",\"National Certificate 3\",\"National Certificate 4\",\"Diploma\",\"Bachelor Degree\",\"Post Graduate Diploma\",\"Master Degree\",\"Doctoral Degree\"]', 0, 1, '2025-10-09 11:02:26', NULL, NULL, NULL, 0),
(3, 1, 'How would you rate your English language skills?', 'english_skills', '[\"Speaks proficiently in a professional setting\",\"Writes proficiently in a professional setting\",\"Limited proficiency\"]', 0, 2, '2025-10-09 11:02:26', NULL, NULL, NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `otp_verifications`
--

CREATE TABLE `otp_verifications` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `otp_code` varchar(6) NOT NULL,
  `purpose` enum('registration','login','password_reset') NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_used` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `otp_verifications`
--

INSERT INTO `otp_verifications` (`id`, `email`, `otp_code`, `purpose`, `expires_at`, `is_used`, `created_at`) VALUES
(1, 'maranarasel19@gmail.com', '399700', 'registration', '2025-10-09 06:13:03', 1, '2025-10-09 06:12:45'),
(2, '1-220471@asiatech.edu.ph', '847272', 'registration', '2025-10-09 13:35:04', 1, '2025-10-09 13:34:37'),
(3, '1-220471@asiatech.edu.ph', '928190', 'registration', '2025-10-09 14:25:49', 1, '2025-10-09 14:25:09');

-- --------------------------------------------------------

--
-- Table structure for table `resumes`
--

CREATE TABLE `resumes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `template_id` varchar(50) NOT NULL DEFAULT 'classic-with-photo',
  `status` enum('draft','completed') DEFAULT 'draft',
  `personal_info` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`personal_info`)),
  `professional_summary` text DEFAULT NULL,
  `work_experience` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`work_experience`)),
  `education` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`education`)),
  `skills` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`skills`)),
  `websites_social_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`websites_social_links`)),
  `custom_sections` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`custom_sections`)),
  `extracurricular_activities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`extracurricular_activities`)),
  `hobbies` text DEFAULT NULL,
  `references` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`references`)),
  `languages` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`languages`)),
  `font_family` enum('times-new-roman','arial','roboto') DEFAULT 'times-new-roman',
  `paper_size` enum('a4','us-letter') DEFAULT 'a4',
  `is_primary` tinyint(1) DEFAULT 0,
  `download_count` int(11) DEFAULT 0,
  `last_downloaded` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `resumes`
--

INSERT INTO `resumes` (`id`, `user_id`, `title`, `template_id`, `status`, `personal_info`, `professional_summary`, `work_experience`, `education`, `skills`, `websites_social_links`, `custom_sections`, `extracurricular_activities`, `hobbies`, `references`, `languages`, `font_family`, `paper_size`, `is_primary`, `download_count`, `last_downloaded`, `created_at`, `updated_at`) VALUES
(2, 2, 'BSIT', 'modern-with-photo', 'completed', '{\"firstName\":\"Rasel\",\"lastName\":\"Maraña\",\"email\":\"1-220471@asiatech.edu.ph\",\"phone\":\"09609167874\",\"address\":\"Celina Plains Phase 1, Block 7, Lot 8\",\"cityState\":\"Santa Rosa, Laguna\",\"country\":\"Philippines\",\"jobTitle\":\"Full Stack Developer\",\"profilePhotoUrl\":\"http://localhost:5000/api/uploads/profiles/user_2_1760020136229.webp\"}', '', '[{\"id\":1760020239485,\"jobTitle\":\"Jollibee Crew\",\"company\":\"Gen One\",\"startDate\":\"2023\",\"endDate\":\"2024\",\"currentlyWorking\":false,\"city\":\"\",\"description\":\"I am a riceman for 11 months\"}]', '[{\"id\":1760020272437,\"school\":\"Asia Technological School of Science and Arts\",\"degree\":\"BSIT\",\"startDate\":\"2022\",\"endDate\":\"2025\",\"currentlyStudying\":false,\"city\":\"Dila, Dila\",\"description\":\"I have a valedictorian degree here.\"}]', '[{\"id\":1760020333254,\"name\":\"Javascript\",\"level\":\"Expert\"},{\"id\":1760020342997,\"name\":\"PHP\",\"level\":\"Expert\"},{\"id\":1760020348317,\"name\":\"CSS\",\"level\":\"Expert\"}]', '[{\"id\":1760020358957,\"label\":\"Portfolio\",\"url\":\"http://raselm.site\"}]', '[]', '[]', '', '[]', '[]', 'times-new-roman', 'a4', 0, 2, '2025-10-09 14:35:18', '2025-10-09 14:28:17', '2025-10-09 14:35:35');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('user') DEFAULT 'user',
  `is_verified` tinyint(1) DEFAULT 0,
  `verification_token` varchar(255) DEFAULT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `role`, `is_verified`, `verification_token`, `reset_token`, `reset_token_expires`, `created_at`, `updated_at`) VALUES
(2, '1-220471@asiatech.edu.ph', '$2a$12$VmPCIUGEjf62seT0XvF42ODetu.2Lr9HYqOprxr7JsZMvkF3SGHHC', 'user', 1, '12fce09c7fcd6e5c114e1e8b6b20446e35d469de10505a64a82856e23d396ed2', NULL, NULL, '2025-10-09 14:25:09', '2025-10-09 14:25:49');

-- --------------------------------------------------------

--
-- Table structure for table `user_courses`
--

CREATE TABLE `user_courses` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `graduation_status` enum('current','graduated') DEFAULT 'current',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_courses`
--

INSERT INTO `user_courses` (`id`, `user_id`, `course_id`, `graduation_status`, `created_at`) VALUES
(2, 2, 10, 'current', '2025-10-09 14:27:16');

-- --------------------------------------------------------

--
-- Table structure for table `user_profiles`
--

CREATE TABLE `user_profiles` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `student_type` enum('ojt','alumni') NOT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `gender` enum('male','female','other','prefer_not_to_say') DEFAULT NULL,
  `profile_photo` varchar(255) DEFAULT NULL,
  `profile_completed` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_profiles`
--

INSERT INTO `user_profiles` (`id`, `user_id`, `first_name`, `last_name`, `student_type`, `contact_number`, `age`, `birthdate`, `gender`, `profile_photo`, `profile_completed`, `created_at`, `updated_at`) VALUES
(2, 2, 'Rasel', 'Maraña', 'ojt', '09609167874', 21, '2004-03-02', 'male', 'uploads/profiles/user_2_1760020136229.webp', 1, '2025-10-09 14:26:27', '2025-10-09 14:28:56');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_admins_email` (`email`);

--
-- Indexes for table `admin_profiles`
--
ALTER TABLE `admin_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admin_id` (`admin_id`);

--
-- Indexes for table `ats_resume_data`
--
ALTER TABLE `ats_resume_data`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_ats_data` (`application_id`),
  ADD KEY `idx_ats_resume_data_app_id` (`application_id`);

--
-- Indexes for table `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `invited_by_coordinator_id` (`invited_by_coordinator_id`),
  ADD KEY `idx_companies_email` (`email`);

--
-- Indexes for table `company_invitations`
--
ALTER TABLE `company_invitations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `idx_coordinator_id` (`coordinator_id`),
  ADD KEY `idx_company_email` (`company_email`),
  ADD KEY `idx_token` (`token`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_expires_at` (`expires_at`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `idx_status_expires_at` (`status`,`expires_at`);

--
-- Indexes for table `company_profiles`
--
ALTER TABLE `company_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `company_id` (`company_id`);

--
-- Indexes for table `coordinators`
--
ALTER TABLE `coordinators`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_coordinators_email` (`email`);

--
-- Indexes for table `coordinator_profiles`
--
ALTER TABLE `coordinator_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `coordinator_id` (`coordinator_id`);

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `email_notifications`
--
ALTER TABLE `email_notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_created_by` (`created_by_type`,`created_by_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_deadline` (`application_deadline`),
  ADD KEY `idx_jobs_category` (`category`),
  ADD KEY `idx_jobs_created_by` (`created_by_type`,`created_by_id`),
  ADD KEY `idx_jobs_status` (`status`),
  ADD KEY `idx_jobs_deadline` (`application_deadline`);

--
-- Indexes for table `job_applications`
--
ALTER TABLE `job_applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_application` (`job_id`,`user_id`),
  ADD KEY `idx_job_status` (`job_id`,`status`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_job_applications_job_status` (`job_id`,`status`),
  ADD KEY `idx_job_applications_user_id` (`user_id`);

--
-- Indexes for table `job_application_answers`
--
ALTER TABLE `job_application_answers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_answer` (`application_id`,`question_id`),
  ADD KEY `idx_job_application_answers_app_id` (`application_id`),
  ADD KEY `idx_job_application_answers_question_id` (`question_id`);

--
-- Indexes for table `job_application_comments`
--
ALTER TABLE `job_application_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_application_id` (`application_id`),
  ADD KEY `idx_commenter` (`commenter_type`,`commenter_id`),
  ADD KEY `idx_job_application_comments_app_id` (`application_id`),
  ADD KEY `idx_job_application_comments_commenter` (`commenter_type`,`commenter_id`);

--
-- Indexes for table `job_categories`
--
ALTER TABLE `job_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_course_name` (`course_name`),
  ADD KEY `idx_job_categories_course` (`course_name`);

--
-- Indexes for table `job_matches`
--
ALTER TABLE `job_matches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_job_resume_match` (`user_id`,`job_id`,`resume_id`),
  ADD KEY `resume_id` (`resume_id`),
  ADD KEY `idx_job_matches_user_id` (`user_id`),
  ADD KEY `idx_job_matches_job_id` (`job_id`),
  ADD KEY `idx_job_matches_score` (`match_score`);

--
-- Indexes for table `job_ratings`
--
ALTER TABLE `job_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_rating` (`job_id`,`user_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_job_id` (`job_id`),
  ADD KEY `idx_rating` (`rating`),
  ADD KEY `idx_job_ratings_job_id` (`job_id`),
  ADD KEY `idx_job_ratings_rating` (`rating`);

--
-- Indexes for table `job_screening_questions`
--
ALTER TABLE `job_screening_questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_job_id` (`job_id`),
  ADD KEY `idx_order` (`job_id`,`order_index`),
  ADD KEY `idx_job_screening_questions_job_id` (`job_id`),
  ADD KEY `idx_job_screening_questions_order` (`job_id`,`order_index`),
  ADD KEY `idx_screening_filter` (`job_id`,`is_filter_criteria`);

--
-- Indexes for table `otp_verifications`
--
ALTER TABLE `otp_verifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_otp_email_purpose` (`email`,`purpose`),
  ADD KEY `idx_otp_expires` (`expires_at`);

--
-- Indexes for table `resumes`
--
ALTER TABLE `resumes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_resumes` (`user_id`,`status`),
  ADD KEY `idx_template` (`template_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_users_email` (`email`),
  ADD KEY `idx_users_verification_token` (`verification_token`);

--
-- Indexes for table `user_courses`
--
ALTER TABLE `user_courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_course` (`user_id`,`course_id`),
  ADD KEY `course_id` (`course_id`);

--
-- Indexes for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `admin_profiles`
--
ALTER TABLE `admin_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `ats_resume_data`
--
ALTER TABLE `ats_resume_data`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `companies`
--
ALTER TABLE `companies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company_invitations`
--
ALTER TABLE `company_invitations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `company_profiles`
--
ALTER TABLE `company_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `coordinators`
--
ALTER TABLE `coordinators`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `coordinator_profiles`
--
ALTER TABLE `coordinator_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `email_notifications`
--
ALTER TABLE `email_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `job_applications`
--
ALTER TABLE `job_applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `job_application_answers`
--
ALTER TABLE `job_application_answers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `job_application_comments`
--
ALTER TABLE `job_application_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `job_categories`
--
ALTER TABLE `job_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=141;

--
-- AUTO_INCREMENT for table `job_matches`
--
ALTER TABLE `job_matches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `job_ratings`
--
ALTER TABLE `job_ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `job_screening_questions`
--
ALTER TABLE `job_screening_questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `otp_verifications`
--
ALTER TABLE `otp_verifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `resumes`
--
ALTER TABLE `resumes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user_courses`
--
ALTER TABLE `user_courses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin_profiles`
--
ALTER TABLE `admin_profiles`
  ADD CONSTRAINT `admin_profiles_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `ats_resume_data`
--
ALTER TABLE `ats_resume_data`
  ADD CONSTRAINT `ats_resume_data_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `companies`
--
ALTER TABLE `companies`
  ADD CONSTRAINT `companies_ibfk_1` FOREIGN KEY (`invited_by_coordinator_id`) REFERENCES `coordinators` (`id`);

--
-- Constraints for table `company_invitations`
--
ALTER TABLE `company_invitations`
  ADD CONSTRAINT `company_invitations_ibfk_1` FOREIGN KEY (`coordinator_id`) REFERENCES `coordinators` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `company_invitations_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `company_profiles`
--
ALTER TABLE `company_profiles`
  ADD CONSTRAINT `company_profiles_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `coordinator_profiles`
--
ALTER TABLE `coordinator_profiles`
  ADD CONSTRAINT `coordinator_profiles_ibfk_1` FOREIGN KEY (`coordinator_id`) REFERENCES `coordinators` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `job_applications`
--
ALTER TABLE `job_applications`
  ADD CONSTRAINT `job_applications_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `job_applications_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `job_application_answers`
--
ALTER TABLE `job_application_answers`
  ADD CONSTRAINT `job_application_answers_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `job_application_answers_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `job_screening_questions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `job_application_comments`
--
ALTER TABLE `job_application_comments`
  ADD CONSTRAINT `job_application_comments_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `job_matches`
--
ALTER TABLE `job_matches`
  ADD CONSTRAINT `job_matches_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `job_matches_ibfk_2` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `job_matches_ibfk_3` FOREIGN KEY (`resume_id`) REFERENCES `resumes` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `job_ratings`
--
ALTER TABLE `job_ratings`
  ADD CONSTRAINT `job_ratings_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `job_ratings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `job_screening_questions`
--
ALTER TABLE `job_screening_questions`
  ADD CONSTRAINT `job_screening_questions_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `resumes`
--
ALTER TABLE `resumes`
  ADD CONSTRAINT `resumes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_courses`
--
ALTER TABLE `user_courses`
  ADD CONSTRAINT `user_courses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_courses_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `user_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
