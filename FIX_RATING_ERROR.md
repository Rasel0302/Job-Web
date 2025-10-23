# Fix Rating Submission Error

## The Problem
The rating submission is failing because the `applicant_ratings` table doesn't exist in your database yet.

## Solution: Run the Database Migration

### Option 1: Simple SQL (Recommended for Quick Fix)

1. Open **phpMyAdmin**: http://localhost/phpmyadmin
2. Select your database (`acc4_db`)
3. Click the **SQL** tab
4. Copy and paste this code:

```sql
CREATE TABLE IF NOT EXISTS `applicant_ratings` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `application_id` INT NOT NULL,
    `rated_by_type` ENUM('coordinator', 'company') NOT NULL,
    `rated_by_id` INT NOT NULL,
    `rating` DECIMAL(2,1) NOT NULL,
    `comment` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY `unique_rating` (`application_id`, `rated_by_type`, `rated_by_id`),
    INDEX `idx_application` (`application_id`),
    INDEX `idx_rated_by` (`rated_by_type`, `rated_by_id`),
    CONSTRAINT `fk_applicant_ratings_application` 
        FOREIGN KEY (`application_id`) 
        REFERENCES `job_applications` (`id`) 
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `job_applications` 
ADD COLUMN `average_rating` DECIMAL(3,2) NULL DEFAULT NULL,
ADD COLUMN `rating_count` INT DEFAULT 0;

ALTER TABLE `job_applications` 
ADD INDEX `idx_average_rating` (`average_rating` DESC);
```

5. Click **Go**
6. You should see "Query executed successfully"

### Option 2: Use the SQL File

1. Open **phpMyAdmin**
2. Select your database (`acc4_db`)
3. Click **Import** tab
4. Click **Choose File**
5. Select `create_ratings_table.sql` from your project folder
6. Click **Go**

### Option 3: Safe Version (Can run multiple times)

Use the file `setup_ratings_safe.sql` - this version checks if things exist before creating them, so it's safe to run multiple times.

## After Running the Migration

1. **Refresh your application** (F5 or Ctrl+R)
2. **Try rating again** - it should work now!

## What This Creates

- **`applicant_ratings` table**: Stores all ratings
- **Rating columns in `job_applications`**: 
  - `average_rating` - Average of all ratings (0-5.00)
  - `rating_count` - How many ratings received

## Test It Works

### As Company:
1. Go to job applications
2. Click "View Details" on an applicant
3. Scroll to "Rate Applicant" section
4. Click stars to rate (1-5)
5. Add optional comment
6. Click "Submit Rating"
7. ✅ Should see "Rating submitted successfully"

### As Coordinator:
1. Go to your job's applications
2. Click "View Details"
3. Rate applicant
4. ✅ Should work!

### As User:
1. Go to Dashboard
2. ✅ Should see your rating in the stats card
3. Go to Profile
4. ✅ Should see all ratings with who rated you

## Troubleshooting

### Error: "Table already exists"
- This is OK! It means the table was already created
- You can ignore this error

### Error: "Column already exists"  
- This is OK! The columns were already added
- You can ignore this error

### Error: "Duplicate key name"
- This is OK! The index already exists
- You can ignore this error

### Still getting errors when rating?
Check:
1. Is the backend server running? (`npm run dev` in `server` folder)
2. Is the frontend running? (`npm start` in root folder)
3. Check browser console (F12) for error messages
4. Check backend terminal for error logs

## Files Created

- `create_ratings_table.sql` - Simple version
- `setup_ratings_safe.sql` - Safe version (can run multiple times)
- `migration_applicant_ratings.sql` - Original migration
- `FIX_RATING_ERROR.md` - This file

Once everything works, you can delete these SQL files!


