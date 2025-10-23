# Applicant Rating System Implementation

## Overview
This document describes the implementation of the applicant rating system for the ACC4 application, including changes to accept/decline functionality for companies and view-only access for coordinators viewing affiliated company jobs.

## Database Migration Required

**IMPORTANT**: Before testing the new features, you must run the database migration.

### Option 1: Using phpMyAdmin
1. Open phpMyAdmin: http://localhost/phpmyadmin
2. Select the `acc4_db` database
3. Go to the SQL tab
4. Copy and paste the contents of `migration_applicant_ratings.sql`
5. Click "Go" to execute

### Option 2: Using MySQL Command Line
```bash
C:\xampp\mysql\bin\mysql.exe -u root acc4_db < migration_applicant_ratings.sql
```

## Changes Implemented

### 1. Database Schema Changes (`migration_applicant_ratings.sql`)

#### New Table: `applicant_ratings`
- Stores ratings and comments for applicants
- Fields:
  - `id` - Primary key
  - `application_id` - Foreign key to job_applications
  - `rated_by_type` - ENUM('coordinator', 'company')
  - `rated_by_id` - ID of the rater
  - `rating` - DECIMAL(2,1) between 1.0 and 5.0
  - `comment` - TEXT (optional)
  - `created_at`, `updated_at` - Timestamps
- Unique constraint: One rating per application per rater

#### Updated Table: `job_applications`
- Added `average_rating` - DECIMAL(3,2) - Average of all ratings
- Added `rating_count` - INT - Number of ratings
- Added index on `average_rating` for filtering

### 2. Backend API Changes

#### New Endpoints - Companies (`server/routes/companies.ts`)
- `POST /companies/applications/:applicationId/decision`
  - Accept or reject applicants directly
  - Body: `{ decision: 'accepted' | 'rejected' }`
  
- `POST /companies/applications/:applicationId/rate`
  - Rate an applicant
  - Body: `{ rating: number (1-5), comment: string (optional) }`

#### Updated Endpoints - Companies
- `GET /companies/jobs/:jobId/applications`
  - Now includes rating information
  - Returns: `company_rating`, `company_rating_comment`, `average_rating`, `rating_count`

#### New Endpoints - Coordinators (`server/routes/jobs.ts`)
- `POST /jobs/applications/:applicationId/rate`
  - Rate an applicant (for own jobs only)
  - Body: `{ rating: number (1-5), comment: string (optional) }`

#### Updated Endpoints - Coordinators
- `GET /jobs/:id/applications`
  - Now includes job ownership info and ratings
  - Returns: `job_created_by_type`, `job_created_by_id`, `user_rating`, `user_rating_comment`
  - Applications sorted by `average_rating DESC, created_at DESC`

### 3. Frontend Components

#### New Component: `ApplicantRating` (`src/components/ApplicantRating.tsx`)
- Interactive star rating (1-5 stars)
- Optional comment field
- Shows average rating and rating count
- Displays user's existing rating with edit capability
- Read-only mode for displaying ratings

#### Updated: Company Applications Page (`src/pages/company/CompanyApplications.tsx`)
**Major Changes:**
- Removed comment functionality (as requested)
- Added Accept/Decline buttons directly in the application details modal
- Integrated rating component
- Added rating filter:
  - All Ratings
  - High Rated (4+ stars)
  - Has Rating
  - Not Rated
  - Low Rated (<3 stars)
- Applications now show average rating in list view
- Modal displays rating section on the right side

**New Features:**
- Companies can accept applicants (status becomes "hired")
- Companies can reject applicants (status becomes "rejected")
- Companies can rate applicants using star system + comments
- Filter applications by rating
- View average ratings across all raters

#### Updated: Coordinator Applications Page (`src/pages/ReviewApplications.tsx`)
**Major Changes:**
- Detects job ownership (coordinator's own job vs affiliated company job)
- View-only mode for company jobs:
  - Can VIEW all application details
  - Can RATE applicants (view only, cannot change)
  - CANNOT accept/reject applications
  - Shows purple badge "View Only - Company Job"
- Full control for own jobs:
  - Can accept/reject applications
  - Can rate applicants
  - Shows blue badge "Your Job - Full Access"
- Added rating filter (same as company page)
- Integrated rating component

**Access Control:**
- Coordinators can only modify status for their own job postings
- Coordinators can only rate applicants for their own job postings
- Affiliated company jobs are read-only with rating capability

### 4. User Experience Improvements

#### Rating System
- **Star Display**: Visual 1-5 star rating system
- **Hover Effect**: Stars highlight on hover for better UX
- **Average Rating Display**: Shows overall average from all raters
- **Rating Count**: Shows how many people have rated
- **Comments**: Optional text feedback with each rating
- **Edit Capability**: Users can update their ratings

#### Filtering
- **By Status**: pending, under_review, qualified, rejected, hired
- **By Rating**: 
  - High Rated (4+ stars)
  - Has Rating (any rating)
  - Not Rated (no ratings yet)
  - Low Rated (<3 stars)
- **Pre-screening** (if enabled for job)

#### Application List
- Shows average rating directly in list view
- Star icon with numeric rating
- Rating count in parentheses
- Sorted by highest rated first (when ratings exist)

## Testing Instructions

### Test as Company

1. **Login as a company**
   - Navigate to company dashboard
   - Go to "Jobs" → View job → "Applications"

2. **Test Rating System**
   - Click "View Details" on any application
   - Find "Rate Applicant" section on the right
   - Click stars to rate (1-5)
   - Add optional comment
   - Click "Submit Rating"
   - Verify average rating updates
   - Click "Edit Rating" to modify

3. **Test Accept/Decline**
   - In application details modal
   - Click "Accept Applicant" (green button)
   - Confirm the action
   - Verify status changes to "Hired"
   - Try "Reject Applicant" (red button)
   - Verify status changes to "Rejected"

4. **Test Filtering**
   - Use rating filter dropdown
   - Select "High Rated (4+ stars)"
   - Verify only highly rated applicants show
   - Try other filter options

### Test as Coordinator

1. **Login as coordinator** (maranarasel19@gmail.com / Hideonbush!1)
   - Navigate to "Manage Jobs"
   - Note which jobs are "Your Job" vs "Company Job"

2. **Test Own Job Applications**
   - Click on a "Your Job" job
   - Click "View Applications" icon
   - Verify you see "Your Job - Full Access" badge
   - Click "View Details" on an application
   - Test Accept/Reject buttons (should work)
   - Test rating system (should work)

3. **Test Company Job Applications (View-Only)**
   - Go back to "Manage Jobs"
   - Find a "Company Job" (purple badge)
   - Click "View Applications" icon
   - Verify you see "View Only - Company Job" badge
   - Click "View Details" on an application
   - Verify Accept/Reject buttons are NOT shown
   - Verify you CAN see rating section (view only)
   - Note: You can view all details but cannot modify status

4. **Test Rating & Filtering**
   - Rate applicants on your own jobs
   - Use rating filter
   - Verify sorting by rating works

## Key Business Rules

1. **Companies**:
   - ✅ Can accept/decline applicants directly
   - ✅ Can rate applicants
   - ✅ Can filter by ratings
   - ❌ No comment system (removed)

2. **Coordinators - Own Jobs**:
   - ✅ Full access to accept/reject
   - ✅ Can rate applicants
   - ✅ Can filter by ratings
   - ✅ Status management

3. **Coordinators - Company Jobs**:
   - ✅ Can VIEW all application details
   - ✅ Can VIEW ratings (read-only)
   - ❌ CANNOT accept/reject
   - ❌ CANNOT rate applicants
   - ❌ CANNOT change status

4. **Rating System**:
   - Range: 1.0 to 5.0 stars
   - One rating per application per user
   - Can update existing ratings
   - Average calculated across all raters
   - Optional comments with each rating

## Files Modified

### Backend
- `server/routes/companies.ts` - Added decision and rating endpoints
- `server/routes/jobs.ts` - Added coordinator rating endpoint, updated queries

### Frontend
- `src/components/ApplicantRating.tsx` - NEW rating component
- `src/pages/company/CompanyApplications.tsx` - Complete rewrite
- `src/pages/ReviewApplications.tsx` - Complete rewrite with access control

### Database
- `migration_applicant_ratings.sql` - NEW migration file

## Cleanup

After successfully running the migration and testing, you can delete:
- `migration_applicant_ratings.sql`
- `RATING_SYSTEM_IMPLEMENTATION.md` (this file)


