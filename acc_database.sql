-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 29, 2025 at 05:47 PM
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
-- Table structure for table `applicant_ratings`
--

CREATE TABLE `applicant_ratings` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `rated_by_type` enum('coordinator','company') NOT NULL,
  `rated_by_id` int(11) NOT NULL,
  `rating` decimal(2,1) NOT NULL CHECK (`rating` >= 1.0 and `rating` <= 5.0),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `application_actions`
--

CREATE TABLE `application_actions` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `action_type` enum('accepted','rejected','hired','interview_scheduled') NOT NULL,
  `action_by_type` enum('coordinator','company') NOT NULL,
  `action_by_id` int(11) NOT NULL,
  `action_by_name` varchar(255) NOT NULL,
  `reason` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `email_sent` tinyint(1) DEFAULT 0,
  `auto_delete_date` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `application_actions`
--

INSERT INTO `application_actions` (`id`, `application_id`, `action_type`, `action_by_type`, `action_by_id`, `action_by_name`, `reason`, `notes`, `email_sent`, `auto_delete_date`, `created_at`) VALUES
(9, 3, 'accepted', 'company', 3, 'Company Corporation', NULL, 'Bring envelope of your requirements', 1, NULL, '2025-10-28 15:53:19'),
(10, 3, 'hired', 'company', 3, 'Company Corporation', NULL, 'Congratulations, you start on Wednesday 9:00 am, same location meet up.', 1, NULL, '2025-10-28 15:55:34');

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

--
-- Dumping data for table `companies`
--

INSERT INTO `companies` (`id`, `email`, `password_hash`, `role`, `is_verified`, `is_approved`, `invited_by_coordinator_id`, `verification_token`, `reset_token`, `reset_token_expires`, `created_at`, `updated_at`) VALUES
(3, 'raselmadrideomarana@gmail.com', '$2a$12$Id/iO03ooynaCyyWbicxpO0.5Q3pct7agdE.EnLN/yRBSlg8wyZ6.', 'company', 1, 1, 1, '141aefe008115c6290fdf6b13c05db7c929f53bc59a05149e2e0a957b9cdcb24', NULL, NULL, '2025-10-22 03:33:02', '2025-10-22 03:49:38'),
(4, 'd.i.g.oschris.ti.a.n.n@gmail.com', '$2a$12$C.HKCcA.miCxZilvQGuwDOUd85R6EthPRqoxv9CGyUYPZBm9Q8n8.', 'company', 1, 1, 2, '5c65c3ea81d4735df7361f1b29aa44cc6ae72b7f7cdfaff7293e2fe0bd2c3026', NULL, NULL, '2025-10-23 16:43:24', '2025-10-23 16:44:16');

-- --------------------------------------------------------

--
-- Table structure for table `company_application_actions`
--

CREATE TABLE `company_application_actions` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `action_type` enum('comment','email_sent','interview_scheduled','accepted','rejected','on_hold') NOT NULL,
  `action_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Store additional data like email content, interview details, etc.' CHECK (json_valid(`action_data`)),
  `reason` text DEFAULT NULL COMMENT 'Reason for accept/reject/hold actions',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL COMMENT 'Company user who performed the action'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_application_comments`
--

CREATE TABLE `company_application_comments` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `comment` text NOT NULL,
  `comment_type` enum('general','company_feedback','interview_note') DEFAULT 'general',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_coordinator_affiliations`
--

CREATE TABLE `company_coordinator_affiliations` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `coordinator_id` int(11) NOT NULL,
  `invitation_id` int(11) NOT NULL,
  `affiliated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `company_coordinator_affiliations`
--

INSERT INTO `company_coordinator_affiliations` (`id`, `company_id`, `coordinator_id`, `invitation_id`, `affiliated_at`, `status`, `created_at`, `updated_at`) VALUES
(2, 3, 1, 5, '2025-10-22 03:33:02', 'active', '2025-10-22 03:33:02', '2025-10-22 03:33:02'),
(3, 4, 2, 6, '2025-10-23 16:43:24', 'active', '2025-10-23 16:43:24', '2025-10-23 16:43:24');

-- --------------------------------------------------------

--
-- Table structure for table `company_email_notifications`
--

CREATE TABLE `company_email_notifications` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `recipient_email` varchar(255) NOT NULL,
  `subject` varchar(500) NOT NULL,
  `message_content` text NOT NULL,
  `email_type` enum('interview_invitation','accepted','rejected','on_hold','general') NOT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('pending','sent','failed') DEFAULT 'pending'
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
(1, 1, 'selramarana0302@gmail.com', 'Hi this is Rasel Maraña a coordinator of ACC, we are excited to have you.', 'ef5dfcf318f6ffc36f0dd1ca7e21bb9fab60dfda10d216d67da0119cf81fbc3c', 'expired', '2025-10-09 13:16:48', '2025-10-16 05:16:48', NULL, NULL),
(2, 1, 'raselmadrideomarana@gmail.com', 'Hello, we are welcoming you to join our website to hire your own employees and this is fresh graduates.', '340c19cc03178029ec25aa7b7066f7820bf0f6dc62780dd669ddc7f017f66391', 'pending', '2025-10-21 13:41:20', '2025-10-28 05:41:20', NULL, NULL),
(3, 1, 'raselmadrideomarana@gmail.com', 'Hi, we are inviting to our website', '47505911', 'used', '2025-10-21 13:53:04', '2025-10-28 05:53:04', '2025-10-21 13:55:55', NULL),
(4, 1, 'raselmadrideomarana@gmail.com', 'Hiiii!', '32823011', 'used', '2025-10-22 03:21:32', '2025-10-28 19:21:32', '2025-10-22 03:23:40', NULL),
(5, 1, 'raselmadrideomarana@gmail.com', 'Hiiii!', '29324691', 'used', '2025-10-22 03:31:18', '2025-10-28 19:31:18', '2025-10-22 03:33:02', 3),
(6, 2, 'd.i.g.oschris.ti.a.n.n@gmail.com', 'Hi We are inviting you', '23958277', 'used', '2025-10-23 16:40:00', '2025-10-30 08:40:00', '2025-10-23 16:43:24', 4);

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
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `first_name` varchar(50) DEFAULT NULL COMMENT 'Business owner first name (optional)',
  `last_name` varchar(50) DEFAULT NULL COMMENT 'Business owner last name (optional)',
  `contact_number` varchar(20) DEFAULT NULL COMMENT 'Contact phone number',
  `company_address` text DEFAULT NULL COMMENT 'Company/business address (optional)',
  `profile_type` enum('company','business_owner') DEFAULT 'company' COMMENT 'Type: company or business owner',
  `profile_photo` varchar(255) DEFAULT NULL COMMENT 'Business owner photo or company logo path',
  `average_rating` decimal(3,2) DEFAULT NULL,
  `rating_count` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `company_profiles`
--

INSERT INTO `company_profiles` (`id`, `company_id`, `company_name`, `business_summary`, `key_requirements`, `company_logo`, `profile_completed`, `created_at`, `updated_at`, `first_name`, `last_name`, `contact_number`, `company_address`, `profile_type`, `profile_photo`, `average_rating`, `rating_count`) VALUES
(1, 3, 'Company Corporation', 'We are a newbie company designed to integrate web and coding', NULL, NULL, 1, '2025-10-22 03:40:48', '2025-10-26 09:21:51', NULL, NULL, '09609167874', 'Hawaiin Street, Sampaloc, Manila', 'company', 'uploads/profiles/company_3_1761104448321.webp', 5.00, 1),
(2, 4, 'Samsung Corporation', 'We are famous for creating gadgets and digital devices for your everyday use.', NULL, NULL, 1, '2025-10-23 16:45:14', '2025-10-26 09:21:51', NULL, NULL, '09609167874', 'Romania, Russia', 'company', 'uploads/profiles/company_4_1761237914806.webp', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `company_ratings`
--

CREATE TABLE `company_ratings` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` decimal(2,1) NOT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `review` text DEFAULT NULL,
  `context` enum('job_post','team_page') NOT NULL DEFAULT 'job_post',
  `job_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `company_ratings`
--

INSERT INTO `company_ratings` (`id`, `company_id`, `user_id`, `rating`, `review`, `context`, `job_id`, `created_at`, `updated_at`) VALUES
(1, 3, 2, 5.0, 'great', 'team_page', NULL, '2025-10-23 06:48:58', '2025-10-23 06:48:58');

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
(1, 'maranarasel19@gmail.com', '$2a$12$iBJc0c3ToAgEtxsGinMz5e87A6uRANekdM3N9SvlSb9u3InnOeU4G', 'coordinator', 1, 1, '3e2b55c06dd2cf88d081354d29a9ca45c3dbe95e63d03a08818f6be32c74111d', NULL, NULL, '2025-10-09 06:12:45', '2025-10-09 09:38:35'),
(2, 'te.rrymco.r.w.i.n.64@gmail.com', '$2a$12$UvexNeEVzlq3iMYQuV4JceEkKvrfE9YlS60loGWo4cnE9uUmJFVZq', 'coordinator', 1, 1, 'be71c9327dd4d4e6bb653952a103709fff9ac86e4503c278607fc1c13a5dc9a4', NULL, NULL, '2025-10-23 16:02:46', '2025-10-23 16:18:46');

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
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `average_rating` decimal(3,2) DEFAULT NULL,
  `rating_count` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `coordinator_profiles`
--

INSERT INTO `coordinator_profiles` (`id`, `coordinator_id`, `first_name`, `last_name`, `designated_course`, `contact_number`, `age`, `birthdate`, `gender`, `profile_photo`, `is_profile_complete`, `created_at`, `updated_at`, `average_rating`, `rating_count`) VALUES
(1, 1, 'Rasel', 'Maraña', 'Bachelor in Science of Information Technology', '09609167874', 21, '2025-03-02', 'male', 'uploads/profiles/coordinator_1_1759990398985.webp', 1, '2025-10-09 06:13:38', '2025-10-26 09:21:46', 5.00, 1),
(2, 2, 'Rozaida ', 'Tuazon', 'Bachelor in Science of Computer Science', '09609167874', 30, '1990-07-24', 'female', 'uploads/profiles/coordinator_2_1761236117917.webp', 1, '2025-10-23 16:16:09', '2025-10-26 09:21:46', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `coordinator_ratings`
--

CREATE TABLE `coordinator_ratings` (
  `id` int(11) NOT NULL,
  `coordinator_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` decimal(2,1) NOT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `review` text DEFAULT NULL,
  `context` enum('job_post','team_page') NOT NULL DEFAULT 'job_post',
  `job_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `coordinator_ratings`
--

INSERT INTO `coordinator_ratings` (`id`, `coordinator_id`, `user_id`, `rating`, `review`, `context`, `job_id`, `created_at`, `updated_at`) VALUES
(1, 1, 2, 5.0, 'great', 'team_page', NULL, '2025-10-23 06:41:20', '2025-10-23 06:41:20');

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
(8, '1-220471@asiatech.edu.ph', 'Welcome to Asiatech Career Connect!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Welcome to ACC!</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Hello 1-220471!</h2>\n            <p>Welcome to Asiatech Career Connect! We\'re excited to have you join our platform as a user.</p>\n            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>\n            <p>Get started by completing your profile and exploring the available opportunities.</p>\n            <a href=\"http://localhost:5173\" class=\"btn\">Start Exploring</a>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-09 14:25:52', 1, NULL),
(9, 'raselmadrideomarana@gmail.com', 'Invitation to Join ACC Career Connect Platform - Bachelor in Science of Information Technology', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"UTF-8\">\n        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n        <title>Company Invitation - ACC Career Connect</title>\n        <style>\n          body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }\n          .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }\n          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }\n          .content { padding: 30px; }\n          .message-box { background-color: #f8f9fa; border-left: 4px solid #007bff; padding: 20px; margin: 20px 0; }\n          .coordinator-info { background-color: #e3f2fd; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .button { \n            display: inline-block; \n            padding: 15px 30px; \n            background-color: #007bff; \n            color: white; \n            text-decoration: none; \n            border-radius: 5px; \n            margin: 20px 0; \n            font-weight: bold; \n          }\n          .token-info { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #666; }\n          .expiry-notice { background-color: #f8d7da; border: 1px solid #f1c2c2; padding: 10px; border-radius: 5px; margin: 15px 0; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>🎓 ACC Career Connect</h1>\n            <h2>Company Partnership Invitation</h2>\n          </div>\n          \n          <div class=\"content\">\n            <h3>Dear Company Representative,</h3>\n            \n            <p>You have been invited to join the ACC Career Connect platform as a company partner!</p>\n            \n            <div class=\"coordinator-info\">\n              <h4>📧 Invitation From:</h4>\n              <p><strong>Coordinator:</strong> Rasel Maraña</p>\n              <p><strong>Email:</strong> maranarasel19@gmail.com</p>\n              <p><strong>Course/Department:</strong> Bachelor in Science of Information Technology</p>\n            </div>\n            \n            <div class=\"message-box\">\n              <h4>💌 Personal Message:</h4>\n              <p style=\"font-style: italic; line-height: 1.6;\">\"Hello, we are welcoming you to join our website to hire your own employees and this is fresh graduates.\"</p>\n            </div>\n            \n            <h4>🚀 What You Can Do:</h4>\n            <ul style=\"line-height: 1.8;\">\n              <li><strong>Post Job Opportunities:</strong> Share internship, part-time, and full-time positions</li>\n              <li><strong>Access Talented Candidates:</strong> Connect with skilled students and alumni</li>\n              <li><strong>Review Applications:</strong> Manage applications with our comprehensive tools</li>\n              <li><strong>Build Your Team:</strong> Find the right talent for your company</li>\n            </ul>\n            \n            <div class=\"token-info\">\n              <h4>🔑 Your Invitation Details:</h4>\n              <p><strong>Invitation Token:</strong> <code>340c19cc03178029ec25aa7b7066f7820bf0f6dc62780dd669ddc7f017f66391</code></p>\n              <p><strong>Invited Email:</strong> raselmadrideomarana@gmail.com</p>\n              <p><em>You\'ll need this token during registration to verify your invitation.</em></p>\n            </div>\n            \n            <div style=\"text-align: center;\">\n              <a href=\"http://localhost:5173/register?token=340c19cc03178029ec25aa7b7066f7820bf0f6dc62780dd669ddc7f017f66391\" class=\"button\">🎯 Join ACC Career Connect Now</a>\n            </div>\n            \n            <div class=\"expiry-notice\">\n              <p><strong>⏰ Important:</strong> This invitation expires on <strong>10/28/2025</strong>. Please register before this date.</p>\n            </div>\n            \n            <h4>📋 How to Register:</h4>\n            <ol style=\"line-height: 1.8;\">\n              <li>Click the registration button above</li>\n              <li>Select \"Company/Business Owner\" during registration</li>\n              <li>Use your invitation token: <strong>340c19cc03178029ec25aa7b7066f7820bf0f6dc62780dd669ddc7f017f66391</strong></li>\n              <li>Complete your company profile</li>\n              <li>Start posting jobs and finding talent!</li>\n            </ol>\n            \n            <p>If you have any questions or need assistance, please don\'t hesitate to contact the coordinator directly at <a href=\"mailto:maranarasel19@gmail.com\">maranarasel19@gmail.com</a>.</p>\n            \n            <p>We look forward to having you as a partner in connecting students with great career opportunities!</p>\n            \n            <p>Best regards,<br>\n            <strong>ACC Career Connect Team</strong><br>\n            <em>Asiatech College Career Platform</em></p>\n          </div>\n          \n          <div class=\"footer\">\n            <p>© 2025 ACC Career Connect. All rights reserved.</p>\n            <p>This invitation was sent by Rasel Maraña (maranarasel19@gmail.com)</p>\n            <p>If you received this email by mistake, please ignore it.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'invitation', '2025-10-21 13:41:23', 1, NULL),
(10, 'raselmadrideomarana@gmail.com', 'Invitation to Join ACC Career Connect Platform - Bachelor in Science of Information Technology', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"UTF-8\">\n        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n        <title>Company Invitation - ACC Career Connect</title>\n        <style>\n          body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }\n          .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }\n          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }\n          .content { padding: 30px; }\n          .message-box { background-color: #f8f9fa; border-left: 4px solid #007bff; padding: 20px; margin: 20px 0; }\n          .coordinator-info { background-color: #e3f2fd; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .button { \n            display: inline-block; \n            padding: 15px 30px; \n            background-color: #007bff; \n            color: white; \n            text-decoration: none; \n            border-radius: 5px; \n            margin: 20px 0; \n            font-weight: bold; \n          }\n          .code-info { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #666; }\n          .expiry-notice { background-color: #f8d7da; border: 1px solid #f1c2c2; padding: 10px; border-radius: 5px; margin: 15px 0; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>🎓 ACC Career Connect</h1>\n            <h2>Company Partnership Invitation</h2>\n          </div>\n          \n          <div class=\"content\">\n            <h3>Dear Company Representative,</h3>\n            \n            <p>You have been invited to join the ACC Career Connect platform as a company partner!</p>\n            \n            <div class=\"coordinator-info\">\n              <h4>📧 Invitation From:</h4>\n              <p><strong>Coordinator:</strong> Rasel Maraña</p>\n              <p><strong>Email:</strong> maranarasel19@gmail.com</p>\n              <p><strong>Course/Department:</strong> Bachelor in Science of Information Technology</p>\n            </div>\n            \n            <div class=\"message-box\">\n              <h4>💌 Personal Message:</h4>\n              <p style=\"font-style: italic; line-height: 1.6;\">\"Hi, we are inviting to our website\"</p>\n            </div>\n            \n            <h4>🚀 What You Can Do:</h4>\n            <ul style=\"line-height: 1.8;\">\n              <li><strong>Post Job Opportunities:</strong> Share internship, part-time, and full-time positions</li>\n              <li><strong>Access Talented Candidates:</strong> Connect with skilled students and alumni</li>\n              <li><strong>Review Applications:</strong> Manage applications with our comprehensive tools</li>\n              <li><strong>Build Your Team:</strong> Find the right talent for your company</li>\n            </ul>\n            \n            <div class=\"code-info\">\n              <h4>🔑 Your Invitation Details:</h4>\n              <p><strong>Invitation Code:</strong> <code>47505911</code></p>\n              <p><strong>Invited Email:</strong> raselmadrideomarana@gmail.com</p>\n              <p><em>You\'ll need this code during registration to verify your invitation.</em></p>\n            </div>\n            \n            <div style=\"text-align: center;\">\n              <a href=\"http://localhost:5173/register?token=47505911\" class=\"button\">🎯 Join ACC Career Connect Now</a>\n            </div>\n            \n            <div class=\"expiry-notice\">\n              <p><strong>⏰ Important:</strong> This invitation expires on <strong>10/28/2025</strong>. Please register before this date.</p>\n            </div>\n            \n            <h4>📋 How to Register:</h4>\n            <ol style=\"line-height: 1.8;\">\n              <li>Click the registration button above</li>\n              <li>Select \"Company/Business Owner\" during registration</li>\n              <li>Use your invitation code: <strong>47505911</strong></li>\n              <li>Complete your company profile</li>\n              <li>Start posting jobs and finding talent!</li>\n            </ol>\n            \n            <p>If you have any questions or need assistance, please don\'t hesitate to contact the coordinator directly at <a href=\"mailto:maranarasel19@gmail.com\">maranarasel19@gmail.com</a>.</p>\n            \n            <p>We look forward to having you as a partner in connecting students with great career opportunities!</p>\n            \n            <p>Best regards,<br>\n            <strong>ACC Career Connect Team</strong><br>\n            <em>Asiatech College Career Platform</em></p>\n          </div>\n          \n          <div class=\"footer\">\n            <p>© 2025 ACC Career Connect. All rights reserved.</p>\n            <p>This invitation was sent by Rasel Maraña (maranarasel19@gmail.com)</p>\n            <p>If you received this email by mistake, please ignore it.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'invitation', '2025-10-21 13:53:07', 1, NULL),
(11, 'raselmadrideomarana@gmail.com', 'Your ACC Verification Code', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }\n          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>ACC Career Connect</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Verification Code</h2>\n            <p>Your verification code for company registration is:</p>\n            <div class=\"otp-box\">\n              <div class=\"otp-code\">592974</div>\n            </div>\n            <p><strong>This code will expire in 10 minutes.</strong></p>\n            <p>If you didn\'t request this code, please ignore this email.</p>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'otp', '2025-10-21 13:55:57', 1, NULL),
(12, 'raselmadrideomarana@gmail.com', 'Welcome to Asiatech Career Connect!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Welcome to ACC!</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Hello raselmadrideomarana!</h2>\n            <p>Welcome to Asiatech Career Connect! We\'re excited to have you join our platform as a company.</p>\n            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>\n            <p>Get started by completing your profile and exploring the available opportunities.</p>\n            <a href=\"http://localhost:5173\" class=\"btn\">Start Exploring</a>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-21 13:56:14', 1, NULL),
(13, 'raselmadrideomarana@gmail.com', 'Invitation to Join ACC Career Connect Platform - Bachelor in Science of Information Technology', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"UTF-8\">\n        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n        <title>Company Invitation - ACC Career Connect</title>\n        <style>\n          body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }\n          .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }\n          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }\n          .content { padding: 30px; }\n          .message-box { background-color: #f8f9fa; border-left: 4px solid #007bff; padding: 20px; margin: 20px 0; }\n          .coordinator-info { background-color: #e3f2fd; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .button { \n            display: inline-block; \n            padding: 15px 30px; \n            background-color: #007bff; \n            color: white; \n            text-decoration: none; \n            border-radius: 5px; \n            margin: 20px 0; \n            font-weight: bold; \n          }\n          .code-info { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #666; }\n          .expiry-notice { background-color: #f8d7da; border: 1px solid #f1c2c2; padding: 10px; border-radius: 5px; margin: 15px 0; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>🎓 ACC Career Connect</h1>\n            <h2>Company Partnership Invitation</h2>\n          </div>\n          \n          <div class=\"content\">\n            <h3>Dear Company Representative,</h3>\n            \n            <p>You have been invited to join the ACC Career Connect platform as a company partner!</p>\n            \n            <div class=\"coordinator-info\">\n              <h4>📧 Invitation From:</h4>\n              <p><strong>Coordinator:</strong> Rasel Maraña</p>\n              <p><strong>Email:</strong> maranarasel19@gmail.com</p>\n              <p><strong>Course/Department:</strong> Bachelor in Science of Information Technology</p>\n            </div>\n            \n            <div class=\"message-box\">\n              <h4>💌 Personal Message:</h4>\n              <p style=\"font-style: italic; line-height: 1.6;\">\"Hiiii!\"</p>\n            </div>\n            \n            <h4>🚀 What You Can Do:</h4>\n            <ul style=\"line-height: 1.8;\">\n              <li><strong>Post Job Opportunities:</strong> Share internship, part-time, and full-time positions</li>\n              <li><strong>Access Talented Candidates:</strong> Connect with skilled students and alumni</li>\n              <li><strong>Review Applications:</strong> Manage applications with our comprehensive tools</li>\n              <li><strong>Build Your Team:</strong> Find the right talent for your company</li>\n            </ul>\n            \n            <div class=\"code-info\">\n              <h4>🔑 Your Invitation Details:</h4>\n              <p><strong>Invitation Code:</strong> <code>32823011</code></p>\n              <p><strong>Invited Email:</strong> raselmadrideomarana@gmail.com</p>\n              <p><em>You\'ll need this code during registration to verify your invitation.</em></p>\n            </div>\n            \n            <div style=\"text-align: center;\">\n              <a href=\"http://localhost:5173/register?token=32823011\" class=\"button\">🎯 Join ACC Career Connect Now</a>\n            </div>\n            \n            <div class=\"expiry-notice\">\n              <p><strong>⏰ Important:</strong> This invitation expires on <strong>10/29/2025</strong>. Please register before this date.</p>\n            </div>\n            \n            <h4>📋 How to Register:</h4>\n            <ol style=\"line-height: 1.8;\">\n              <li>Click the registration button above</li>\n              <li>Select \"Company/Business Owner\" during registration</li>\n              <li>Use your invitation code: <strong>32823011</strong></li>\n              <li>Complete your company profile</li>\n              <li>Start posting jobs and finding talent!</li>\n            </ol>\n            \n            <p>If you have any questions or need assistance, please don\'t hesitate to contact the coordinator directly at <a href=\"mailto:maranarasel19@gmail.com\">maranarasel19@gmail.com</a>.</p>\n            \n            <p>We look forward to having you as a partner in connecting students with great career opportunities!</p>\n            \n            <p>Best regards,<br>\n            <strong>ACC Career Connect Team</strong><br>\n            <em>Asiatech College Career Platform</em></p>\n          </div>\n          \n          <div class=\"footer\">\n            <p>© 2025 ACC Career Connect. All rights reserved.</p>\n            <p>This invitation was sent by Rasel Maraña (maranarasel19@gmail.com)</p>\n            <p>If you received this email by mistake, please ignore it.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'invitation', '2025-10-22 03:21:35', 1, NULL),
(14, 'raselmadrideomarana@gmail.com', 'Your ACC Verification Code', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }\n          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>ACC Career Connect</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Verification Code</h2>\n            <p>Your verification code for company registration is:</p>\n            <div class=\"otp-box\">\n              <div class=\"otp-code\">426397</div>\n            </div>\n            <p><strong>This code will expire in 10 minutes.</strong></p>\n            <p>If you didn\'t request this code, please ignore this email.</p>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'otp', '2025-10-22 03:23:42', 1, NULL),
(15, 'raselmadrideomarana@gmail.com', 'Welcome to Asiatech Career Connect!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Welcome to ACC!</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Hello raselmadrideomarana!</h2>\n            <p>Welcome to Asiatech Career Connect! We\'re excited to have you join our platform as a company.</p>\n            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>\n            <p>Get started by completing your profile and exploring the available opportunities.</p>\n            <a href=\"http://localhost:5173\" class=\"btn\">Start Exploring</a>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-22 03:24:06', 1, NULL),
(16, 'raselmadrideomarana@gmail.com', 'Invitation to Join ACC Career Connect Platform - Bachelor in Science of Information Technology', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"UTF-8\">\n        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n        <title>Company Invitation - ACC Career Connect</title>\n        <style>\n          body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }\n          .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }\n          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }\n          .content { padding: 30px; }\n          .message-box { background-color: #f8f9fa; border-left: 4px solid #007bff; padding: 20px; margin: 20px 0; }\n          .coordinator-info { background-color: #e3f2fd; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .button { \n            display: inline-block; \n            padding: 15px 30px; \n            background-color: #007bff; \n            color: white; \n            text-decoration: none; \n            border-radius: 5px; \n            margin: 20px 0; \n            font-weight: bold; \n          }\n          .code-info { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #666; }\n          .expiry-notice { background-color: #f8d7da; border: 1px solid #f1c2c2; padding: 10px; border-radius: 5px; margin: 15px 0; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>🎓 ACC Career Connect</h1>\n            <h2>Company Partnership Invitation</h2>\n          </div>\n          \n          <div class=\"content\">\n            <h3>Dear Company Representative,</h3>\n            \n            <p>You have been invited to join the ACC Career Connect platform as a company partner!</p>\n            \n            <div class=\"coordinator-info\">\n              <h4>📧 Invitation From:</h4>\n              <p><strong>Coordinator:</strong> Rasel Maraña</p>\n              <p><strong>Email:</strong> maranarasel19@gmail.com</p>\n              <p><strong>Course/Department:</strong> Bachelor in Science of Information Technology</p>\n            </div>\n            \n            <div class=\"message-box\">\n              <h4>💌 Personal Message:</h4>\n              <p style=\"font-style: italic; line-height: 1.6;\">\"Hiiii!\"</p>\n            </div>\n            \n            <h4>🚀 What You Can Do:</h4>\n            <ul style=\"line-height: 1.8;\">\n              <li><strong>Post Job Opportunities:</strong> Share internship, part-time, and full-time positions</li>\n              <li><strong>Access Talented Candidates:</strong> Connect with skilled students and alumni</li>\n              <li><strong>Review Applications:</strong> Manage applications with our comprehensive tools</li>\n              <li><strong>Build Your Team:</strong> Find the right talent for your company</li>\n            </ul>\n            \n            <div class=\"code-info\">\n              <h4>🔑 Your Invitation Details:</h4>\n              <p><strong>Invitation Code:</strong> <code>29324691</code></p>\n              <p><strong>Invited Email:</strong> raselmadrideomarana@gmail.com</p>\n              <p><em>You\'ll need this code during registration to verify your invitation.</em></p>\n            </div>\n            \n            <div style=\"text-align: center;\">\n              <a href=\"http://localhost:5173/register?token=29324691\" class=\"button\">🎯 Join ACC Career Connect Now</a>\n            </div>\n            \n            <div class=\"expiry-notice\">\n              <p><strong>⏰ Important:</strong> This invitation expires on <strong>10/29/2025</strong>. Please register before this date.</p>\n            </div>\n            \n            <h4>📋 How to Register:</h4>\n            <ol style=\"line-height: 1.8;\">\n              <li>Click the registration button above</li>\n              <li>Select \"Company/Business Owner\" during registration</li>\n              <li>Use your invitation code: <strong>29324691</strong></li>\n              <li>Complete your company profile</li>\n              <li>Start posting jobs and finding talent!</li>\n            </ol>\n            \n            <p>If you have any questions or need assistance, please don\'t hesitate to contact the coordinator directly at <a href=\"mailto:maranarasel19@gmail.com\">maranarasel19@gmail.com</a>.</p>\n            \n            <p>We look forward to having you as a partner in connecting students with great career opportunities!</p>\n            \n            <p>Best regards,<br>\n            <strong>ACC Career Connect Team</strong><br>\n            <em>Asiatech College Career Platform</em></p>\n          </div>\n          \n          <div class=\"footer\">\n            <p>© 2025 ACC Career Connect. All rights reserved.</p>\n            <p>This invitation was sent by Rasel Maraña (maranarasel19@gmail.com)</p>\n            <p>If you received this email by mistake, please ignore it.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'invitation', '2025-10-22 03:31:21', 1, NULL);
INSERT INTO `email_notifications` (`id`, `recipient_email`, `subject`, `body`, `type`, `sent_at`, `is_sent`, `error_message`) VALUES
(17, 'raselmadrideomarana@gmail.com', 'Your ACC Verification Code', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }\n          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>ACC Career Connect</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Verification Code</h2>\n            <p>Your verification code for company registration is:</p>\n            <div class=\"otp-box\">\n              <div class=\"otp-code\">254955</div>\n            </div>\n            <p><strong>This code will expire in 10 minutes.</strong></p>\n            <p>If you didn\'t request this code, please ignore this email.</p>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'otp', '2025-10-22 03:33:04', 1, NULL),
(18, 'raselmadrideomarana@gmail.com', 'Welcome to Asiatech Career Connect!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Welcome to ACC!</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Hello raselmadrideomarana!</h2>\n            <p>Welcome to Asiatech Career Connect! We\'re excited to have you join our platform as a company.</p>\n            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>\n            <p>Get started by completing your profile and exploring the available opportunities.</p>\n            <a href=\"http://localhost:5173\" class=\"btn\">Start Exploring</a>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-22 03:33:18', 1, NULL),
(19, '1-220443@asiatech.edu.ph', 'Your ACC Verification Code', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }\n          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>ACC Career Connect</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Verification Code</h2>\n            <p>Your verification code for registration is:</p>\n            <div class=\"otp-box\">\n              <div class=\"otp-code\">292712</div>\n            </div>\n            <p><strong>This code will expire in 10 minutes.</strong></p>\n            <p>If you didn\'t request this code, please ignore this email.</p>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'otp', '2025-10-23 14:59:30', 1, NULL),
(20, '1-220443@asiatech.edu.ph', 'Welcome to Asiatech Career Connect!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Welcome to ACC!</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Hello 1-220443!</h2>\n            <p>Welcome to Asiatech Career Connect! We\'re excited to have you join our platform as a user.</p>\n            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>\n            <p>Get started by completing your profile and exploring the available opportunities.</p>\n            <a href=\"http://localhost:5173\" class=\"btn\">Start Exploring</a>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-23 15:01:27', 1, NULL),
(21, 'te.rrymco.r.w.i.n.64@gmail.com', 'Your ACC Verification Code', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }\n          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>ACC Career Connect</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Verification Code</h2>\n            <p>Your verification code for coordinator registration is:</p>\n            <div class=\"otp-box\">\n              <div class=\"otp-code\">200743</div>\n            </div>\n            <p><strong>This code will expire in 10 minutes.</strong></p>\n            <p>If you didn\'t request this code, please ignore this email.</p>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'otp', '2025-10-23 16:02:49', 1, NULL),
(22, 'te.rrymco.r.w.i.n.64@gmail.com', 'Welcome to Asiatech Career Connect!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Welcome to ACC!</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Hello te.rrymco.r.w.i.n.64!</h2>\n            <p>Welcome to Asiatech Career Connect! We\'re excited to have you join our platform as a coordinator.</p>\n            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>\n            <p>Get started by completing your profile and exploring the available opportunities.</p>\n            <a href=\"http://localhost:5173\" class=\"btn\">Start Exploring</a>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-23 16:03:28', 1, NULL),
(23, 'te.rrymco.r.w.i.n.64@gmail.com', '✅ Your coordinator account has been approved!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <title>Account APPROVED</title>\n        <style>\n          body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5; }\n          .container { max-width: 600px; margin: 0 auto; background-color: white; }\n          .header { background-color: #16a34a; color: white; padding: 30px; text-align: center; }\n          .content { padding: 30px; }\n          .status-badge { \n            display: inline-block; \n            padding: 8px 16px; \n            background-color: #16a34a; \n            color: white; \n            border-radius: 20px; \n            font-weight: bold; \n            font-size: 12px; \n            text-transform: uppercase; \n            margin-bottom: 20px;\n          }\n          .button { \n            display: inline-block; \n            padding: 12px 24px; \n            background-color: #3b82f6; \n            color: white; \n            text-decoration: none; \n            border-radius: 5px; \n            margin: 20px 0; \n          }\n          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 14px; }\n          .reason-box { \n            background-color: #fef2f2; \n            border: 1px solid #fecaca; \n            border-radius: 5px; \n            padding: 15px; \n            margin: 20px 0;\n            color: #991b1b;\n          }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Account APPROVED</h1>\n            <p>ACC Career Connect</p>\n          </div>\n          \n          <div class=\"content\">\n            <div class=\"status-badge\">APPROVED</div>\n            \n            <h2>Hello,</h2>\n            \n            <p>Great news! Your coordinator account has been approved and is now active.</p>\n            \n            \n            \n            <p><strong>Account Type:</strong> Coordinator</p>\n            <p><strong>Email:</strong> te.rrymco.r.w.i.n.64@gmail.com</p>\n            \n            <h3>What\'s Next?</h3>\n            <p>You can now login to your coordinator account and start using ACC Career Connect.</p>\n            \n            \n              <a href=\"http://localhost:5173/login\" class=\"button\">Login to Your Account</a>\n            \n            \n            <p>If you have any questions, please don\'t hesitate to contact our support team.</p>\n            \n            <p>Best regards,<br>\n            <strong>ACC Career Connect Team</strong></p>\n          </div>\n          \n          <div class=\"footer\">\n            <p>© 2025 ACC Career Connect. All rights reserved.</p>\n            <p>Asiatech College Career Platform</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-23 16:18:48', 1, NULL),
(24, 'd.i.g.oschris.ti.a.n.n@gmail.com', 'Invitation to Join ACC Career Connect Platform - Bachelor in Science of Computer Science', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"UTF-8\">\n        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n        <title>Company Invitation - ACC Career Connect</title>\n        <style>\n          body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }\n          .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }\n          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }\n          .content { padding: 30px; }\n          .message-box { background-color: #f8f9fa; border-left: 4px solid #007bff; padding: 20px; margin: 20px 0; }\n          .coordinator-info { background-color: #e3f2fd; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .button { \n            display: inline-block; \n            padding: 15px 30px; \n            background-color: #007bff; \n            color: white; \n            text-decoration: none; \n            border-radius: 5px; \n            margin: 20px 0; \n            font-weight: bold; \n          }\n          .code-info { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 15px 0; }\n          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #666; }\n          .expiry-notice { background-color: #f8d7da; border: 1px solid #f1c2c2; padding: 10px; border-radius: 5px; margin: 15px 0; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>🎓 ACC Career Connect</h1>\n            <h2>Company Partnership Invitation</h2>\n          </div>\n          \n          <div class=\"content\">\n            <h3>Dear Company Representative,</h3>\n            \n            <p>You have been invited to join the ACC Career Connect platform as a company partner!</p>\n            \n            <div class=\"coordinator-info\">\n              <h4>📧 Invitation From:</h4>\n              <p><strong>Coordinator:</strong> Rozaida  Tuazon</p>\n              <p><strong>Email:</strong> te.rrymco.r.w.i.n.64@gmail.com</p>\n              <p><strong>Course/Department:</strong> Bachelor in Science of Computer Science</p>\n            </div>\n            \n            <div class=\"message-box\">\n              <h4>💌 Personal Message:</h4>\n              <p style=\"font-style: italic; line-height: 1.6;\">\"Hi We are inviting you\"</p>\n            </div>\n            \n            <h4>🚀 What You Can Do:</h4>\n            <ul style=\"line-height: 1.8;\">\n              <li><strong>Post Job Opportunities:</strong> Share internship, part-time, and full-time positions</li>\n              <li><strong>Access Talented Candidates:</strong> Connect with skilled students and alumni</li>\n              <li><strong>Review Applications:</strong> Manage applications with our comprehensive tools</li>\n              <li><strong>Build Your Team:</strong> Find the right talent for your company</li>\n            </ul>\n            \n            <div class=\"code-info\">\n              <h4>🔑 Your Invitation Details:</h4>\n              <p><strong>Invitation Code:</strong> <code>23958277</code></p>\n              <p><strong>Invited Email:</strong> d.i.g.oschris.ti.a.n.n@gmail.com</p>\n              <p><em>You\'ll need this code during registration to verify your invitation.</em></p>\n            </div>\n            \n            <div style=\"text-align: center;\">\n              <a href=\"http://localhost:5173/register?token=23958277\" class=\"button\">🎯 Join ACC Career Connect Now</a>\n            </div>\n            \n            <div class=\"expiry-notice\">\n              <p><strong>⏰ Important:</strong> This invitation expires on <strong>10/31/2025</strong>. Please register before this date.</p>\n            </div>\n            \n            <h4>📋 How to Register:</h4>\n            <ol style=\"line-height: 1.8;\">\n              <li>Click the registration button above</li>\n              <li>Select \"Company/Business Owner\" during registration</li>\n              <li>Use your invitation code: <strong>23958277</strong></li>\n              <li>Complete your company profile</li>\n              <li>Start posting jobs and finding talent!</li>\n            </ol>\n            \n            <p>If you have any questions or need assistance, please don\'t hesitate to contact the coordinator directly at <a href=\"mailto:te.rrymco.r.w.i.n.64@gmail.com\">te.rrymco.r.w.i.n.64@gmail.com</a>.</p>\n            \n            <p>We look forward to having you as a partner in connecting students with great career opportunities!</p>\n            \n            <p>Best regards,<br>\n            <strong>ACC Career Connect Team</strong><br>\n            <em>Asiatech College Career Platform</em></p>\n          </div>\n          \n          <div class=\"footer\">\n            <p>© 2025 ACC Career Connect. All rights reserved.</p>\n            <p>This invitation was sent by Rozaida  Tuazon (te.rrymco.r.w.i.n.64@gmail.com)</p>\n            <p>If you received this email by mistake, please ignore it.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'invitation', '2025-10-23 16:40:04', 1, NULL),
(25, 'd.i.g.oschris.ti.a.n.n@gmail.com', 'Your ACC Verification Code', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }\n          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>ACC Career Connect</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Verification Code</h2>\n            <p>Your verification code for company registration is:</p>\n            <div class=\"otp-box\">\n              <div class=\"otp-code\">399571</div>\n            </div>\n            <p><strong>This code will expire in 10 minutes.</strong></p>\n            <p>If you didn\'t request this code, please ignore this email.</p>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'otp', '2025-10-23 16:43:29', 1, NULL),
(26, 'd.i.g.oschris.ti.a.n.n@gmail.com', 'Welcome to Asiatech Career Connect!', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>Welcome to ACC!</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Hello d.i.g.oschris.ti.a.n.n!</h2>\n            <p>Welcome to Asiatech Career Connect! We\'re excited to have you join our platform as a company.</p>\n            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>\n            <p>Get started by completing your profile and exploring the available opportunities.</p>\n            <a href=\"http://localhost:5173\" class=\"btn\">Start Exploring</a>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'general', '2025-10-23 16:44:22', 1, NULL),
(27, '1-220043@asiatech.edu.ph', 'Your ACC Verification Code', '\n      <!DOCTYPE html>\n      <html>\n      <head>\n        <meta charset=\"utf-8\">\n        <style>\n          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }\n          .container { max-width: 600px; margin: 0 auto; padding: 20px; }\n          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }\n          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }\n          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }\n          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }\n          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }\n        </style>\n      </head>\n      <body>\n        <div class=\"container\">\n          <div class=\"header\">\n            <h1>ACC Career Connect</h1>\n            <p>Asiatech Career Connect</p>\n          </div>\n          <div class=\"content\">\n            <h2>Verification Code</h2>\n            <p>Your verification code for registration is:</p>\n            <div class=\"otp-box\">\n              <div class=\"otp-code\">175582</div>\n            </div>\n            <p><strong>This code will expire in 10 minutes.</strong></p>\n            <p>If you didn\'t request this code, please ignore this email.</p>\n          </div>\n          <div class=\"footer\">\n            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>\n          </div>\n        </div>\n      </body>\n      </html>\n    ', 'otp', '2025-10-23 17:17:05', 1, NULL),
(28, '1-220471@asiatech.edu.ph', 'Congratulations! Your Application Has Been Accepted - Interview Scheduled', '<h2>Congratulations, Rasel Maraña!</h2><p>We are pleased to inform you that your application for <strong>Web Developer Intern</strong> at <strong>Company Corporation</strong> has been accepted.</p><h3>Interview Details:</h3><ul><li><strong>Date & Time:</strong> 11/5/2025, 10:00:00 AM</li><li><strong>Mode:</strong> onsite</li><li><strong>Location/Link:</strong> Celina Plains, Phase 2</li></ul><h4>Additional Notes:</h4><p>Bring envelope of your requirements</p><p>We look forward to meeting you!</p><p>Best regards,<br>Company Corporation</p>', '', '2025-10-28 15:53:22', 1, NULL),
(29, '1-220471@asiatech.edu.ph', 'Congratulations! You Have Been Hired - Web Developer Intern', '<h2>Congratulations, Rasel Maraña!</h2><p>We are excited to inform you that you have been selected for the position of <strong>Web Developer Intern</strong> at <strong>Company Corporation</strong>.</p><h4>Next Steps:</h4><p>Congratulations, you start on Wednesday 9:00 am, same location meet up.</p><p>Welcome to the team!</p><p>Best regards,<br>Company Corporation</p>', '', '2025-10-28 15:55:37', 1, NULL),
(30, '1-220026@asiatech.edu.ph', 'Your OTP Code for registration', '\n        <h2>Email Verification</h2>\n        <p>Your OTP code for registration is:</p>\n        <div style=\"background: #f3f4f6; padding: 20px; text-align: center; margin: 20px 0;\">\n          <h1 style=\"color: #16a34a; font-size: 32px; letter-spacing: 8px; margin: 0;\">131584</h1>\n        </div>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you didn\'t request this, please ignore this email.</p>\n      ', '', '2025-10-29 05:55:36', 1, NULL),
(31, '1-220026@asiatech.edu.ph', 'Welcome to Asiatech Career Center!', '\n        <h2>Welcome to Asiatech Career Center, 1-220026!</h2>\n        <p>Your user account has been successfully created.</p>\n        <p>You can now log in and start exploring opportunities.</p>\n        <p>Best regards,<br>Asiatech Career Center Team</p>\n      ', '', '2025-10-29 05:57:01', 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `email_templates`
--

CREATE TABLE `email_templates` (
  `id` int(11) NOT NULL,
  `template_name` varchar(100) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `body_html` text NOT NULL,
  `body_text` text NOT NULL,
  `variables` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`variables`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `email_templates`
--

INSERT INTO `email_templates` (`id`, `template_name`, `subject`, `body_html`, `body_text`, `variables`, `created_at`, `updated_at`) VALUES
(1, 'application_accepted', 'Congratulations! Your Application Has Been Accepted - Interview Scheduled', '<h2>Congratulations, {applicant_name}!</h2><p>We are pleased to inform you that your application for <strong>{job_title}</strong> at <strong>{company_name}</strong> has been accepted.</p><h3>Interview Details:</h3><ul><li><strong>Date & Time:</strong> {interview_date}</li><li><strong>Mode:</strong> {interview_mode}</li><li><strong>Location/Link:</strong> {interview_location_link}</li></ul>{notes_section}<p>We look forward to meeting you!</p><p>Best regards,<br>{company_name}</p>', 'Congratulations {applicant_name}! Your application for {job_title} at {company_name} has been accepted. Interview scheduled for {interview_date} - {interview_mode}. Location/Link: {interview_location_link}. {notes_text}', NULL, '2025-10-27 11:39:23', '2025-10-27 11:39:23'),
(2, 'application_rejected', 'Application Status Update - {job_title}', '<h2>Thank you for your interest, {applicant_name}</h2><p>We regret to inform you that your application for <strong>{job_title}</strong> at <strong>{company_name}</strong> has not been selected to move forward.</p>{reason_section}<p>We encourage you to apply for future opportunities that match your skills and experience.</p><p>Best regards,<br>{company_name}</p>', 'Thank you for your interest {applicant_name}. Your application for {job_title} at {company_name} has not been selected. {reason_text}', NULL, '2025-10-27 11:39:36', '2025-10-27 11:39:36'),
(3, 'applicant_hired', 'Congratulations! You Have Been Hired - {job_title}', '<h2>Congratulations, {applicant_name}!</h2><p>We are excited to inform you that you have been selected for the position of <strong>{job_title}</strong> at <strong>{company_name}</strong>.</p>{details_section}<p>Welcome to the team!</p><p>Best regards,<br>{company_name}</p>', 'Congratulations {applicant_name}! You have been hired for {job_title} at {company_name}. {details_text}', NULL, '2025-10-27 11:39:36', '2025-10-27 11:39:36'),
(4, 'interview_reminder_1week', 'Interview Reminder - {job_title} in 1 Week', '<h2>Interview Reminder</h2><p>Hello {applicant_name},</p><p>This is a friendly reminder that you have an interview scheduled for <strong>{job_title}</strong> at <strong>{company_name}</strong> in one week.</p><p><strong>Interview Details:</strong><br>Date & Time: {interview_date}<br>Mode: {interview_mode}<br>Location/Link: {interview_location_link}</p>', 'Interview Reminder: {job_title} at {company_name} in 1 week. Date: {interview_date}, Mode: {interview_mode}', NULL, '2025-10-27 11:39:47', '2025-10-27 11:39:47'),
(5, 'interview_reminder_1day', 'Interview Tomorrow - {job_title}', '<h2>Interview Tomorrow!</h2><p>Hello {applicant_name},</p><p>Your interview for <strong>{job_title}</strong> at <strong>{company_name}</strong> is scheduled for tomorrow.</p><p><strong>Interview Details:</strong><br>Date & Time: {interview_date}<br>Mode: {interview_mode}<br>Location/Link: {interview_location_link}</p>', 'Interview Tomorrow: {job_title} at {company_name}. Date: {interview_date}, Mode: {interview_mode}', NULL, '2025-10-27 11:39:47', '2025-10-27 11:39:47'),
(6, 'interview_reminder_1hour', 'Interview in 1 Hour - {job_title}', '<h2>Interview Starting Soon!</h2><p>Hello {applicant_name},</p><p>Your interview for <strong>{job_title}</strong> at <strong>{company_name}</strong> starts in 1 hour.</p><p><strong>Interview Details:</strong><br>Date & Time: {interview_date}<br>Mode: {interview_mode}<br>Location/Link: {interview_location_link}</p>', 'Interview in 1 hour: {job_title} at {company_name}. Date: {interview_date}, Mode: {interview_mode}', NULL, '2025-10-27 11:39:47', '2025-10-27 11:39:47'),
(7, 'post_interview_rejected', 'Interview Follow-up - {job_title}', '<h2>Thank you for interviewing with us, {applicant_name}</h2><p>We appreciate the time you took to interview for the <strong>{job_title}</strong> position at <strong>{company_name}</strong>.</p><p>After careful consideration, we have decided to move forward with another candidate.</p>{feedback_section}<p>We wish you the best in your job search.</p><p>Best regards,<br>{company_name}</p>', 'Thank you for interviewing {applicant_name}. We have decided to move forward with another candidate for {job_title} at {company_name}. {feedback_text}', NULL, '2025-10-27 11:39:58', '2025-10-27 11:39:58');

-- --------------------------------------------------------

--
-- Table structure for table `interviews`
--

CREATE TABLE `interviews` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `scheduled_by_type` enum('coordinator','company') NOT NULL,
  `scheduled_by_id` int(11) NOT NULL,
  `interview_date` datetime NOT NULL,
  `interview_mode` enum('onsite','online') NOT NULL,
  `interview_location` varchar(500) DEFAULT NULL,
  `interview_link` varchar(500) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `status` enum('scheduled','completed','cancelled','no_show') DEFAULT 'scheduled',
  `reminder_1week_sent` tinyint(1) DEFAULT 0,
  `reminder_1day_sent` tinyint(1) DEFAULT 0,
  `reminder_1hour_sent` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `interviews`
--

INSERT INTO `interviews` (`id`, `application_id`, `job_id`, `user_id`, `scheduled_by_type`, `scheduled_by_id`, `interview_date`, `interview_mode`, `interview_location`, `interview_link`, `notes`, `status`, `reminder_1week_sent`, `reminder_1day_sent`, `reminder_1hour_sent`, `created_at`, `updated_at`) VALUES
(8, 3, 2, 2, 'company', 3, '2025-11-05 10:00:00', 'onsite', 'Celina Plains, Phase 2', NULL, 'Bring envelope of your requirements', 'completed', 0, 0, 0, '2025-10-28 15:53:19', '2025-10-28 15:54:40');

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
  `application_limit` int(11) DEFAULT NULL COMMENT 'Maximum number of applications allowed for this job. NULL means no limit.',
  `experience_level` enum('entry-level','mid-level','senior-level','executive') DEFAULT 'entry-level',
  `target_student_type` enum('ojt','graduated','both') DEFAULT 'both',
  `created_by_type` enum('coordinator','company') NOT NULL,
  `created_by_id` int(11) NOT NULL,
  `coordinator_name` varchar(255) DEFAULT NULL,
  `business_owner_name` varchar(255) DEFAULT NULL,
  `status` enum('draft','active','paused','closed') DEFAULT 'active',
  `is_featured` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `filter_pre_screening` tinyint(1) DEFAULT 0,
  `average_rating` decimal(3,2) DEFAULT NULL,
  `rating_count` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `title`, `location`, `category`, `work_type`, `work_arrangement`, `currency`, `min_salary`, `max_salary`, `description`, `summary`, `video_url`, `company_name`, `application_deadline`, `positions_available`, `application_limit`, `experience_level`, `target_student_type`, `created_by_type`, `created_by_id`, `coordinator_name`, `business_owner_name`, `status`, `is_featured`, `created_at`, `updated_at`, `filter_pre_screening`, `average_rating`, `rating_count`) VALUES
(1, 'IT Debugger', 'San Pablo, Ilocos Sur', 'IT Support / Technical Support', 'full-time', 'on-site', 'PHP', 20000.00, 30000.00, 'We are', 'BDO', NULL, NULL, '2025-11-27', 4, 50, 'mid-level', 'both', 'coordinator', 1, 'Rasel Maraña', NULL, 'active', 0, '2025-10-09 11:02:26', '2025-10-26 07:26:15', 0, NULL, 0),
(2, 'Web Developer Intern', 'Quezon City, Metro Manila', 'Web and Mobile App Development', 'internship', 'on-site', 'PHP', 15000.00, 25000.00, 'We are looking for a motivated Web Developer Intern to join our team. You will work on developing and maintaining web applications using modern technologies. This is a great opportunity to gain hands-on experience in web development and learn from experienced developers.\n\nResponsibilities:\n- Develop and maintain web applications\n- Write clean, maintainable code\n- Collaborate with team members\n- Participate in code reviews\n- Learn new technologies and best practices\n\nRequirements:\n- Currently pursuing BS Computer Science or related field\n- Basic knowledge of HTML, CSS, and JavaScript\n- Familiarity with React or Vue.js is a plus\n- Good communication skills\n- Eager to learn and grow', 'Join our team as a Web Developer Intern and gain hands-on experience with modern web technologies including React, Node.js, and TypeScript.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', NULL, '2025-12-31', 1, NULL, 'entry-level', 'ojt', 'company', 3, NULL, NULL, 'active', 0, '2025-10-22 04:25:18', '2025-10-23 08:12:19', 0, 5.00, 1),
(3, 'AI debugger', 'Roseville, Cabuyao, Laguna', 'Artificial Intelligence / Machine Learning', 'full-time', 'on-site', 'PHP', 10000.00, 50000.00, 'We are in need of a professional AI debugger here in Asiatech.', 'We are offering experience and a chance to join Google Company if you prove to us this job.', NULL, NULL, '2026-01-22', 5, NULL, 'entry-level', 'both', 'coordinator', 2, 'Rozaida Tuazon', NULL, 'active', 0, '2025-10-23 16:29:24', '2025-10-23 16:29:24', 0, NULL, 0),
(4, 'Android debugger', 'Samsung building 21th street, BGC, Makati, Metro Manila', 'Software Development / Programming', 'part-time', 'remote', 'PHP', 40000.00, 79998.00, 'Hello, We are hiring applicants all over the world for our next samsung phone.', 'We are giving you the opportunity to work with us in your early age, which is what we need.', NULL, NULL, '2026-01-27', 4, NULL, 'entry-level', 'both', 'company', 4, NULL, NULL, 'active', 0, '2025-10-23 16:52:51', '2025-10-23 16:52:51', 0, NULL, 0),
(5, 'Website Developer', 'BGC, Makati, Metro Manila', 'Web Development', 'full-time', 'remote', 'PHP', 10000.00, 20000.00, 'This is my personal business, and I am creating a team dedicated and capable of creating system websites.', 'I am creating a website devs company', NULL, NULL, '2026-03-29', 4, 50, 'entry-level', 'both', 'coordinator', 1, NULL, NULL, 'active', 0, '2025-10-29 09:13:31', '2025-10-29 09:13:31', 0, NULL, 0);

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
  `status` enum('pending','under_review','qualified','rejected','accepted','interview_scheduled','interview_completed','pending_review','hired') NOT NULL DEFAULT 'pending',
  `ats_score` decimal(5,2) DEFAULT NULL,
  `average_rating` decimal(3,2) DEFAULT NULL,
  `rating_count` int(11) DEFAULT 0,
  `is_ats_processed` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `scheduled_interview_date` datetime DEFAULT NULL,
  `interview_id` int(11) DEFAULT NULL,
  `auto_delete_date` datetime DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `job_applications`
--

INSERT INTO `job_applications` (`id`, `job_id`, `user_id`, `first_name`, `last_name`, `email`, `phone`, `address`, `position_applying_for`, `resume_type`, `resume_file`, `resume_builder_link`, `interview_video`, `status`, `ats_score`, `average_rating`, `rating_count`, `is_ats_processed`, `created_at`, `updated_at`, `scheduled_interview_date`, `interview_id`, `auto_delete_date`, `rejection_reason`) VALUES
(3, 2, 2, 'Rasel', 'Maraña', '1-220471@asiatech.edu.ph', '09609167874', 'Celina Plains, Phase 1, Block 7, Lot 8', 'Web Developer Intern', 'uploaded', 'resumeFile-1761666393956-477148012.pdf', NULL, NULL, 'hired', NULL, NULL, 0, 0, '2025-10-28 15:46:33', '2025-10-28 15:55:34', '2025-11-05 10:00:00', 8, NULL, NULL),
(6, 4, 5, 'James', 'Malibago', '1-220026@asiatech.edu.ph', '09383541664', '123 Main Street', 'Android debugger', 'uploaded', 'resumeFile-1761718302759-554815473.pdf', NULL, NULL, 'pending', NULL, NULL, 0, 0, '2025-10-29 06:11:42', '2025-10-29 06:11:42', NULL, NULL, NULL, NULL),
(7, 1, 2, 'Rasel', 'Maraña', '1-220471@asiatech.edu.ph', '09609167874', 'Celina Plains Phase 1, Block 7, Lot 8', 'IT Debugger', 'uploaded', 'resumeFile-1761723308000-36768764.pdf', NULL, NULL, 'pending', NULL, NULL, 0, 0, '2025-10-29 07:35:08', '2025-10-29 07:35:08', NULL, NULL, NULL, NULL);

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

--
-- Dumping data for table `job_ratings`
--

INSERT INTO `job_ratings` (`id`, `job_id`, `user_id`, `rating`, `review`, `created_at`, `updated_at`) VALUES
(1, 2, 2, 5, 'good', '2025-10-23 08:12:19', '2025-10-23 08:12:19');

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
(6, 2, 'How would you rate your English language skills?', 'english_skills', '[\"Speaks proficiently in a professional setting\",\"Writes proficiently in a professional setting\",\"Limited proficiency\"]', 0, 0, '2025-10-22 05:53:56', NULL, NULL, NULL, 0),
(7, 2, 'Are you willing to undergo a pre-employment background check?', 'background_check', '[\"Yes\",\"No\"]', 0, 1, '2025-10-22 05:53:56', NULL, NULL, NULL, 0),
(8, 3, 'Which of the following types of qualifications do you have?', 'qualifications', '[\"High School Diploma\",\"National Certificate 1\",\"National Certificate 2\",\"National Certificate 3\",\"National Certificate 4\",\"Diploma\",\"Bachelor Degree\",\"Post Graduate Diploma\",\"Master Degree\",\"Doctoral Degree\"]', 0, 0, '2025-10-23 16:29:24', NULL, NULL, NULL, 0),
(9, 3, 'How would you rate your English language skills?', 'english_skills', '[\"Speaks proficiently in a professional setting\",\"Writes proficiently in a professional setting\",\"Limited proficiency\"]', 0, 1, '2025-10-23 16:29:24', NULL, NULL, NULL, 0),
(10, 3, 'Do you have customer service experience?', 'customer_service', '[\"Yes\",\"No\"]', 0, 2, '2025-10-23 16:29:24', NULL, NULL, NULL, 0),
(11, 4, 'Which of the following types of qualifications do you have?', 'qualifications', '[\"High School Diploma\",\"National Certificate 1\",\"National Certificate 2\",\"National Certificate 3\",\"National Certificate 4\",\"Diploma\",\"Bachelor Degree\",\"Post Graduate Diploma\",\"Master Degree\",\"Doctoral Degree\"]', 0, 0, '2025-10-23 16:52:51', NULL, NULL, NULL, 0),
(12, 4, 'How would you rate your English language skills?', 'english_skills', '[\"Speaks proficiently in a professional setting\",\"Writes proficiently in a professional setting\",\"Limited proficiency\"]', 0, 1, '2025-10-23 16:52:51', NULL, NULL, NULL, 0),
(13, 4, 'Do you have customer service experience?', 'customer_service', '[\"Yes\",\"No\"]', 0, 2, '2025-10-23 16:52:51', NULL, NULL, NULL, 0),
(14, 4, 'How much notice are you required to give your current employer?', 'notice_period', '[\"None, I\'m ready to go now\",\"Less than 2 weeks\",\"1 month\",\"2 months\",\"3 months\",\"More than 3 months\"]', 0, 3, '2025-10-23 16:52:51', NULL, NULL, NULL, 0),
(15, 1, 'What\'s your expected monthly basic salary range?', 'salary_range', NULL, 0, 0, '2025-10-26 07:26:15', NULL, NULL, NULL, 0),
(16, 1, 'Which of the following types of qualifications do you have?', 'qualifications', '[\"High School Diploma\",\"National Certificate 1\",\"National Certificate 2\",\"National Certificate 3\",\"National Certificate 4\",\"Diploma\",\"Bachelor Degree\",\"Post Graduate Diploma\",\"Master Degree\",\"Doctoral Degree\"]', 0, 1, '2025-10-26 07:26:15', NULL, NULL, NULL, 0),
(17, 1, 'How would you rate your English language skills?', 'english_skills', '[\"Speaks proficiently in a professional setting\",\"Writes proficiently in a professional setting\",\"Limited proficiency\"]', 0, 2, '2025-10-26 07:26:15', NULL, NULL, NULL, 0),
(18, 5, 'What\'s your expected monthly basic salary range?', 'salary_range', NULL, 1, 0, '2025-10-29 09:13:31', NULL, NULL, NULL, 0),
(19, 5, 'Which of the following types of qualifications do you have?', 'qualifications', '[\"High School Diploma\",\"National Certificate 1\",\"National Certificate 2\",\"National Certificate 3\",\"National Certificate 4\",\"Diploma\",\"Bachelor Degree\",\"Post Graduate Diploma\",\"Master Degree\",\"Doctoral Degree\"]', 0, 1, '2025-10-29 09:13:31', NULL, NULL, NULL, 0),
(20, 5, 'How would you rate your English language skills?', 'english_skills', '[\"Speaks proficiently in a professional setting\",\"Writes proficiently in a professional setting\",\"Limited proficiency\"]', 0, 2, '2025-10-29 09:13:31', NULL, NULL, NULL, 0),
(21, 5, 'Do you have customer service experience?', 'customer_service', '[\"Yes\",\"No\"]', 0, 3, '2025-10-29 09:13:31', NULL, NULL, NULL, 0);

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
(11, '1-220026@asiatech.edu.ph', '131584', 'registration', '2025-10-29 05:56:59', 1, '2025-10-29 05:55:33');

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
(6, 3, 'Android Software', 'classic-with-photo', 'completed', '{\"firstName\":\"Andrew\",\"lastName\":\"Mindoro\",\"email\":\"1-220443@asiatech.edu.ph\",\"phone\":\"09609167874\",\"address\":\"Olympia Phase 2, Barangay Labas\",\"cityState\":\"Santa Rosa/ Laguna\",\"country\":\"Philippines\",\"jobTitle\":\"Android Debugger\",\"profilePhotoUrl\":\"http://localhost:5000/api/uploads/profiles/user_3_1761238580177.webp\"}', '', '[{\"id\":1761238745616,\"jobTitle\":\"Landers Staff\",\"company\":\"Jomel Trinidad\",\"startDate\":\"11/2024\",\"endDate\":\"12/2024\",\"currentlyWorking\":false,\"city\":\"Nuvalli, Tagaytay, Cavite\",\"description\":\"I work there for 1 month as a stock clerk\"}]', '[]', '[]', '[]', '[]', '[]', '', '[]', '[]', 'times-new-roman', 'a4', 0, 1, '2025-10-23 17:00:51', '2025-10-23 16:55:29', '2025-10-23 17:01:44'),
(9, 2, 'BSIT', 'classic-with-photo', 'completed', '{\"firstName\":\"Rasel\",\"lastName\":\"Maraña\",\"email\":\"1-220471@asiatech.edu.ph\",\"phone\":\"09609167874\",\"address\":\"Celina Plains, Phase 1, Block 7, Lot 8\",\"cityState\":\"Santa Rosa/ Laguna\",\"country\":\"Philippines\",\"jobTitle\":\"Full stack web developer\",\"profilePhotoUrl\":\"http://localhost:5000/api/uploads/profiles/user_2_1761471632411.webp\"}', '', '[{\"id\":1761471727066,\"jobTitle\":\"Full stack developer\",\"company\":\"Socia\",\"startDate\":\"03/2025\",\"endDate\":\"04/2025\",\"currentlyWorking\":false,\"city\":\"BGC, Makati, Metro Manila\",\"description\":\"I have a certificate with a big company\"}]', '[{\"id\":1761471791986,\"school\":\"Asia Technological School of Science and Arts\",\"degree\":\"Bachelor in Science of Information Technology\",\"startDate\":\"03/2022\",\"endDate\":\"03/2026\",\"currentlyStudying\":false,\"city\":\"Dila, Dila, Santa Rosa Laguna\",\"description\":\"I have a college degree\"}]', '[{\"id\":1761471988699,\"name\":\"JavaScript\",\"level\":\"Experienced\"},{\"id\":1761472060492,\"name\":\"PHP\",\"level\":\"Expert\"},{\"id\":1761472066643,\"name\":\"CSS\",\"level\":\"Expert\"},{\"id\":1761472072716,\"name\":\"React\",\"level\":\"Expert\"}]', '[{\"id\":1761472123444,\"label\":\"Portfolio\",\"url\":\"http://raselm.site\"}]', '[]', '[]', '', '[]', '[]', 'times-new-roman', 'a4', 1, 3, '2025-10-28 14:51:50', '2025-10-26 09:40:18', '2025-10-28 14:51:50'),
(10, 5, 'Malibago', 'classic-ats', 'completed', '{\"firstName\":\"James\",\"lastName\":\"Malibago\",\"email\":\"1-220026@asiatech.edu.ph\",\"phone\":\"09383541664\",\"address\":\"123 Main Street\",\"cityState\":\"Santa Rosa\",\"country\":\"Philippines\",\"jobTitle\":\"Tech Support\"}', '', '[{\"id\":1761717661984,\"jobTitle\":\"Reliever\",\"company\":\"One Green Arrow\",\"startDate\":\"01/2025\",\"endDate\":\"10/2025\",\"currentlyWorking\":false,\"city\":\"Santa Rosa\",\"description\":\"I\'m Broke\"}]', '[{\"id\":1761717790240,\"school\":\"Asiatech\",\"degree\":\"BS Information Technology\",\"startDate\":\"09/2022\",\"endDate\":\"06/2026\",\"currentlyStudying\":false,\"city\":\"Santa Rosa\",\"description\":\"Nakakamatay\"}]', '[{\"id\":1761717896944,\"name\":\"Excel, Microsoft Word, Programming, Design\",\"level\":\"Beginner\"}]', '[]', '[]', '[]', '', '[]', '[{\"id\":1761718173984,\"language\":\"English and Tagalog\",\"level\":\"Fluent\"}]', 'times-new-roman', 'a4', 0, 1, '2025-10-29 06:10:09', '2025-10-29 05:59:32', '2025-10-29 06:10:34');

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
(2, '1-220471@asiatech.edu.ph', '$2a$12$VmPCIUGEjf62seT0XvF42ODetu.2Lr9HYqOprxr7JsZMvkF3SGHHC', 'user', 1, '12fce09c7fcd6e5c114e1e8b6b20446e35d469de10505a64a82856e23d396ed2', NULL, NULL, '2025-10-09 14:25:09', '2025-10-09 14:25:49'),
(3, '1-220443@asiatech.edu.ph', '$2a$12$O37NdMD5Ar9Tl.jVZ0qQa.IhvX4Bt9dYQCXYeTDQ6aXF/gTl29L1.', 'user', 1, '539c30cef99b6ed84045552a18cf8d02e37dae46267fd52712e3870928aa5981', NULL, NULL, '2025-10-23 14:59:26', '2025-10-23 15:01:24'),
(4, '1-220043@asiatech.edu.ph', '$2a$12$9JhbPLhgahxM4u7hxrdeaugTKVz4zudWU53EC50WthmYpomU/Y7Se', 'user', 0, 'a6fb11100c14f64fa30d1033a403d3baf936a7f0cea04c71537386e67ad01e6c', NULL, NULL, '2025-10-23 17:17:02', '2025-10-23 17:17:02'),
(5, '1-220026@asiatech.edu.ph', '$2a$12$8ntikZY/sJK2HAju8tdiruEMJgOiIShfJnH3EMgO.aEhSkyNIOLty', 'user', 1, '36bf0d0e638e438cb413e3dcc79bdf32972ba39edcf9ab27d7d33597846ae129', NULL, NULL, '2025-10-29 05:55:33', '2025-10-29 05:56:59');

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
(2, 2, 10, 'current', '2025-10-09 14:27:16'),
(3, 3, 4, 'current', '2025-10-23 15:06:38'),
(4, 5, 10, 'current', '2025-10-29 05:58:10');

-- --------------------------------------------------------

--
-- Table structure for table `user_employment_status`
--

CREATE TABLE `user_employment_status` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `employer_type` enum('coordinator','company') NOT NULL,
  `employer_id` int(11) NOT NULL,
  `employer_name` varchar(255) NOT NULL,
  `job_title` varchar(255) NOT NULL,
  `hired_date` datetime NOT NULL,
  `employment_status` enum('active','contract_ended') DEFAULT 'active',
  `contract_end_date` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_employment_status`
--

INSERT INTO `user_employment_status` (`id`, `user_id`, `application_id`, `job_id`, `employer_type`, `employer_id`, `employer_name`, `job_title`, `hired_date`, `employment_status`, `contract_end_date`, `created_at`, `updated_at`) VALUES
(2, 2, 3, 2, 'company', 3, 'Company Corporation', 'Web Developer Intern', '2025-10-28 23:55:34', 'active', NULL, '2025-10-28 15:55:34', '2025-10-28 15:55:34');

-- --------------------------------------------------------

--
-- Table structure for table `user_notifications`
--

CREATE TABLE `user_notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('interview_reminder','application_status','system') NOT NULL,
  `related_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NOT NULL DEFAULT (current_timestamp() + interval 7 day)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_notifications`
--

INSERT INTO `user_notifications` (`id`, `user_id`, `title`, `message`, `type`, `related_id`, `is_read`, `created_at`, `expires_at`) VALUES
(12, 2, 'Interview Completed', 'Your interview for Web Developer Intern has been completed. The employer will contact you soon with their decision.', 'application_status', 8, 1, '2025-10-28 15:54:40', '2025-11-04 07:54:40'),
(13, 2, 'Congratulations! You\'ve been hired!', 'You have been hired for the position of Web Developer Intern at Company Corporation', 'application_status', 29, 1, '2025-10-28 15:55:37', '2025-11-04 07:55:37');

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
(2, 2, 'Rasel', 'Maraña', 'ojt', '09609167874', 21, '2004-03-02', 'male', 'uploads/profiles/user_2_1761471632411.webp', 1, '2025-10-09 14:26:27', '2025-10-26 09:40:32'),
(3, 3, 'Andrew', 'Mindoro', 'ojt', '09609167874', 19, '2003-10-29', 'male', NULL, 1, '2025-10-23 15:04:34', '2025-10-26 09:11:32'),
(4, 5, 'James', 'Malibago', 'ojt', '09383541664', 23, '2002-03-16', 'male', NULL, 1, '2025-10-29 05:58:10', '2025-10-29 05:58:10');

-- --------------------------------------------------------

--
-- Table structure for table `user_rating_archive`
--

CREATE TABLE `user_rating_archive` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rated_by_type` enum('coordinator','company') NOT NULL,
  `rated_by_id` int(11) NOT NULL,
  `rating` decimal(2,1) NOT NULL,
  `comment` text DEFAULT NULL,
  `original_application_id` int(11) DEFAULT NULL,
  `job_title` varchar(255) DEFAULT NULL,
  `archived_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

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
-- Indexes for table `applicant_ratings`
--
ALTER TABLE `applicant_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_rating` (`application_id`,`rated_by_type`,`rated_by_id`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_rated_by` (`rated_by_type`,`rated_by_id`);

--
-- Indexes for table `application_actions`
--
ALTER TABLE `application_actions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_auto_delete` (`auto_delete_date`),
  ADD KEY `idx_action_type` (`action_type`);

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
-- Indexes for table `company_application_actions`
--
ALTER TABLE `company_application_actions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_application_actions` (`application_id`),
  ADD KEY `idx_company_actions` (`company_id`),
  ADD KEY `idx_action_type` (`action_type`);

--
-- Indexes for table `company_application_comments`
--
ALTER TABLE `company_application_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_application_comments` (`application_id`),
  ADD KEY `idx_company_comments` (`company_id`);

--
-- Indexes for table `company_coordinator_affiliations`
--
ALTER TABLE `company_coordinator_affiliations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_company_coordinator` (`company_id`,`coordinator_id`),
  ADD KEY `idx_company_coordinator` (`company_id`,`coordinator_id`),
  ADD KEY `idx_coordinator_companies` (`coordinator_id`),
  ADD KEY `idx_invitation_affiliation` (`invitation_id`);

--
-- Indexes for table `company_email_notifications`
--
ALTER TABLE `company_email_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_company_emails` (`company_id`),
  ADD KEY `idx_application_emails` (`application_id`),
  ADD KEY `idx_email_status` (`status`);

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
  ADD UNIQUE KEY `company_id` (`company_id`),
  ADD KEY `idx_company_profiles_type` (`profile_type`),
  ADD KEY `idx_company_profiles_completed` (`profile_completed`),
  ADD KEY `idx_company_average_rating` (`average_rating`);

--
-- Indexes for table `company_ratings`
--
ALTER TABLE `company_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_company_rating` (`company_id`,`user_id`),
  ADD KEY `idx_company_id` (`company_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_rating` (`rating`),
  ADD KEY `idx_context` (`context`),
  ADD KEY `fk_company_ratings_job` (`job_id`);

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
  ADD UNIQUE KEY `coordinator_id` (`coordinator_id`),
  ADD KEY `idx_coordinator_average_rating` (`average_rating`);

--
-- Indexes for table `coordinator_ratings`
--
ALTER TABLE `coordinator_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_coordinator_rating` (`coordinator_id`,`user_id`),
  ADD KEY `idx_coordinator_id` (`coordinator_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_rating` (`rating`),
  ADD KEY `idx_context` (`context`),
  ADD KEY `fk_coordinator_ratings_job` (`job_id`);

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
-- Indexes for table `email_templates`
--
ALTER TABLE `email_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `template_name` (`template_name`);

--
-- Indexes for table `interviews`
--
ALTER TABLE `interviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_id` (`job_id`),
  ADD KEY `idx_interview_date` (`interview_date`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_user` (`user_id`);

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
  ADD KEY `idx_jobs_deadline` (`application_deadline`),
  ADD KEY `idx_target_student_type` (`target_student_type`),
  ADD KEY `idx_job_average_rating` (`average_rating`),
  ADD KEY `idx_application_limit` (`application_limit`);

--
-- Indexes for table `job_applications`
--
ALTER TABLE `job_applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_application` (`job_id`,`user_id`),
  ADD KEY `idx_job_status` (`job_id`,`status`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_job_applications_job_status` (`job_id`,`status`),
  ADD KEY `idx_job_applications_user_id` (`user_id`),
  ADD KEY `idx_average_rating` (`average_rating`),
  ADD KEY `idx_auto_delete` (`auto_delete_date`),
  ADD KEY `idx_interview` (`interview_id`);

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
-- Indexes for table `user_employment_status`
--
ALTER TABLE `user_employment_status`
  ADD PRIMARY KEY (`id`),
  ADD KEY `application_id` (`application_id`),
  ADD KEY `job_id` (`job_id`),
  ADD KEY `idx_user_status` (`user_id`,`employment_status`),
  ADD KEY `idx_employer` (`employer_type`,`employer_id`);

--
-- Indexes for table `user_notifications`
--
ALTER TABLE `user_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_unread` (`user_id`,`is_read`),
  ADD KEY `idx_expires` (`expires_at`);

--
-- Indexes for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `user_rating_archive`
--
ALTER TABLE `user_rating_archive`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_rated_by` (`rated_by_type`,`rated_by_id`),
  ADD KEY `idx_archived_date` (`archived_date`);

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
-- AUTO_INCREMENT for table `applicant_ratings`
--
ALTER TABLE `applicant_ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `application_actions`
--
ALTER TABLE `application_actions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `ats_resume_data`
--
ALTER TABLE `ats_resume_data`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `companies`
--
ALTER TABLE `companies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `company_application_actions`
--
ALTER TABLE `company_application_actions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `company_application_comments`
--
ALTER TABLE `company_application_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company_coordinator_affiliations`
--
ALTER TABLE `company_coordinator_affiliations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `company_email_notifications`
--
ALTER TABLE `company_email_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company_invitations`
--
ALTER TABLE `company_invitations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `company_profiles`
--
ALTER TABLE `company_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `company_ratings`
--
ALTER TABLE `company_ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `coordinators`
--
ALTER TABLE `coordinators`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `coordinator_profiles`
--
ALTER TABLE `coordinator_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `coordinator_ratings`
--
ALTER TABLE `coordinator_ratings`
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `email_templates`
--
ALTER TABLE `email_templates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `interviews`
--
ALTER TABLE `interviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `job_applications`
--
ALTER TABLE `job_applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `job_screening_questions`
--
ALTER TABLE `job_screening_questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `otp_verifications`
--
ALTER TABLE `otp_verifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `resumes`
--
ALTER TABLE `resumes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_courses`
--
ALTER TABLE `user_courses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_employment_status`
--
ALTER TABLE `user_employment_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user_notifications`
--
ALTER TABLE `user_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_rating_archive`
--
ALTER TABLE `user_rating_archive`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin_profiles`
--
ALTER TABLE `admin_profiles`
  ADD CONSTRAINT `admin_profiles_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `applicant_ratings`
--
ALTER TABLE `applicant_ratings`
  ADD CONSTRAINT `applicant_ratings_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `application_actions`
--
ALTER TABLE `application_actions`
  ADD CONSTRAINT `application_actions_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE;

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
-- Constraints for table `company_application_actions`
--
ALTER TABLE `company_application_actions`
  ADD CONSTRAINT `company_application_actions_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `company_application_actions_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `company_application_actions_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `companies` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `company_application_comments`
--
ALTER TABLE `company_application_comments`
  ADD CONSTRAINT `company_application_comments_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `company_application_comments_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `company_coordinator_affiliations`
--
ALTER TABLE `company_coordinator_affiliations`
  ADD CONSTRAINT `company_coordinator_affiliations_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `company_coordinator_affiliations_ibfk_2` FOREIGN KEY (`coordinator_id`) REFERENCES `coordinators` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `company_coordinator_affiliations_ibfk_3` FOREIGN KEY (`invitation_id`) REFERENCES `company_invitations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `company_email_notifications`
--
ALTER TABLE `company_email_notifications`
  ADD CONSTRAINT `company_email_notifications_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `company_email_notifications_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;

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
-- Constraints for table `company_ratings`
--
ALTER TABLE `company_ratings`
  ADD CONSTRAINT `fk_company_ratings_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_company_ratings_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_company_ratings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `coordinator_profiles`
--
ALTER TABLE `coordinator_profiles`
  ADD CONSTRAINT `coordinator_profiles_ibfk_1` FOREIGN KEY (`coordinator_id`) REFERENCES `coordinators` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `coordinator_ratings`
--
ALTER TABLE `coordinator_ratings`
  ADD CONSTRAINT `fk_coordinator_ratings_coordinator` FOREIGN KEY (`coordinator_id`) REFERENCES `coordinators` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_coordinator_ratings_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_coordinator_ratings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `interviews`
--
ALTER TABLE `interviews`
  ADD CONSTRAINT `interviews_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `interviews_ibfk_2` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `interviews_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

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
-- Constraints for table `user_employment_status`
--
ALTER TABLE `user_employment_status`
  ADD CONSTRAINT `user_employment_status_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_employment_status_ibfk_2` FOREIGN KEY (`application_id`) REFERENCES `job_applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_employment_status_ibfk_3` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_notifications`
--
ALTER TABLE `user_notifications`
  ADD CONSTRAINT `user_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `user_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
