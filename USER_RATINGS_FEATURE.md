# User Ratings Visibility Feature

## Overview
Users can now see all ratings they've received from companies and coordinators in their dashboard and profile page. This provides transparency and valuable feedback for job seekers.

## Features Implemented

### 1. Backend API - `/users/my-ratings`
**Endpoint**: `GET /users/my-ratings`
**Authorization**: User role only
**Returns**:
```json
{
  "ratings": [
    {
      "id": 1,
      "rating": 4.5,
      "comment": "Great candidate with excellent skills",
      "created_at": "2024-01-15",
      "rated_by_type": "company",
      "rated_by_id": 5,
      "job_id": 10,
      "job_title": "Software Developer",
      "rater_name": "Tech Corp Inc",
      "rater_photo": "http://..."
    }
  ],
  "statistics": {
    "total_ratings": 5,
    "average_rating": 4.2,
    "highest_rating": 5.0,
    "lowest_rating": 3.5,
    "company_ratings_count": 3,
    "coordinator_ratings_count": 2
  }
}
```

### 2. Dashboard Display

#### New Stats Card
- **My Rating** card shows average rating prominently
- Displays as "X.X / 5.0" with star icon
- Golden gradient background for visibility
- Shows "No ratings yet" if no ratings exist

#### Recent Ratings Section
Located below "Recent Activity", this section includes:

**Rating Summary Panel:**
- Average Rating (large display with star)
- Total Ratings count
- Rating breakdown (companies vs coordinators)
- Rating range (highest to lowest)

**Recent Feedback List (5 most recent):**
- Rater's photo and name
- Rater type (Company/Coordinator badge)
- Job title associated with the rating
- Star rating (1-5 visual stars)
- Numeric rating display
- Comment/feedback (if provided)
- Date received

### 3. Profile Page Display

#### Comprehensive Ratings Section
Located after "Academic Information", this section shows:

**For Users with No Ratings:**
- Large star icon
- Encouraging message
- Call-to-action to apply to more jobs

**For Users with Ratings:**

**Rating Summary Dashboard:**
- **Average Rating**: Large display with star icon and numeric value
- **Total Ratings**: Count from all reviewers
- **Best Rating**: Highest rating received (green highlight)
- **Ratings From**: Breakdown of company vs coordinator ratings

**All Feedback List (Complete History):**
Each rating card displays:
- Rater's profile photo (or placeholder)
- Rater's name
- Type badge (purple for companies, blue for coordinators)
- Job title context
- 5-star visual rating
- Numeric rating (X.X / 5.0)
- Full comment/feedback in styled box
- Date received (formatted as "Month Day, Year")
- Hover effects for better UX

### 4. Data Included

**For Each Rating:**
- ⭐ Star rating (1.0 - 5.0)
- 💬 Comment/feedback (optional)
- 👤 Who rated them (company name or coordinator name)
- 📷 Rater's profile photo
- 🏢 Job context (which job the rating is for)
- 📅 When they received it
- 🏷️ Type badge (Company or Coordinator)

**Statistics:**
- 📊 Average rating across all raters
- 🔢 Total number of ratings
- 🏆 Highest rating received
- 📉 Lowest rating received
- 🏢 Count from companies
- 👥 Count from coordinators

## User Benefits

1. **Transparency**: Users can see how they're perceived by employers
2. **Feedback**: Constructive comments help users improve
3. **Motivation**: Positive ratings encourage continued efforts
4. **Profile Building**: Good ratings enhance their reputation
5. **Context**: Users know which jobs generated which feedback
6. **Attribution**: Clear visibility of who provided the feedback

## Visual Design

### Color Scheme
- **Yellow/Orange**: Rating displays and highlights
- **Purple**: Company-related elements
- **Blue**: Coordinator-related elements
- **Green**: Best/highest ratings
- **Gray**: Neutral elements

### Components
- Gradient backgrounds for emphasis
- Star icons (solid for ratings, outline for placeholders)
- Badges for categorization
- Rounded corners for modern look
- Hover effects for interactivity
- Responsive grid layouts

## Technical Implementation

### Frontend Files Modified
- `src/pages/Dashboard.tsx` - Added ratings summary and recent ratings
- `src/pages/Profile.tsx` - Added comprehensive ratings section
- `src/services/api.ts` - Added `getMyRatings()` method

### Backend Files Modified
- `server/routes/users.ts` - Added `/my-ratings` endpoint

### Key SQL Query
Joins multiple tables to get:
- Rating data from `applicant_ratings`
- Job information from `jobs`
- Application context from `job_applications`
- Rater details from `coordinator_profiles` or `company_profiles`
- Profile photos properly processed

## Testing

### As a User:
1. **Login** as a user/student
2. **Dashboard** - See rating summary card and recent ratings section
3. **Profile** - View complete ratings history with all details
4. **Verify**:
   - Ratings from both companies and coordinators appear
   - Photos display correctly
   - Comments show properly
   - Dates are formatted correctly
   - Statistics are accurate

### Sample User Flow:
1. User applies to jobs
2. Company/Coordinator rates the application
3. User sees new rating in dashboard (top 5 recent)
4. User views all ratings in profile page
5. User reads feedback to improve future applications

## Privacy & Security

- ✅ Only users can see their own ratings
- ✅ Endpoint protected with authentication and authorization
- ✅ Profile photos properly secured via UploadService
- ✅ No sensitive data exposed
- ✅ Clear attribution (users know who rated them)

## Future Enhancements (Optional)

- [ ] Export ratings as PDF
- [ ] Filter ratings by company/coordinator
- [ ] Sort by date, rating, or job
- [ ] Email notifications for new ratings
- [ ] Respond to feedback (optional)
- [ ] Rating trends over time (chart)

## Notes

- Ratings are **read-only** for users (they cannot modify them)
- All ratings are preserved in history
- Average is calculated automatically
- System handles missing photos gracefully
- Empty comments are handled (not displayed)
- Responsive design works on all devices

---

**Implementation Complete!** Users can now see their accumulated ratings and who rated them in both their dashboard and profile pages.


