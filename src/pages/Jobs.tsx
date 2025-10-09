import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { api } from '../services/api';
import { toast } from 'react-hot-toast';
import { 
  BriefcaseIcon, 
  MapPinIcon, 
  ClockIcon, 
  CurrencyDollarIcon,
  BuildingOfficeIcon,
  AcademicCapIcon,
  UserGroupIcon,
  StarIcon
} from '@heroicons/react/24/outline';

interface Job {
  id: number;
  title: string;
  location: string;
  category: string;
  work_type: string;
  work_arrangement: string;
  currency: string;
  min_salary: number;
  max_salary: number;
  description: string;
  summary: string;
  company_name: string;
  coordinator_name: string;
  business_owner_name: string;
  created_by_name: string;
  application_count: number;
  average_rating: number;
  rating_count: number;
  created_at: string;
  application_deadline: string;
  positions_available: number;
  experience_level: string;
  matchScore?: number;
  matchReasons?: string[];
}

export const Jobs: React.FC = () => {
  const { user } = useAuth();
  const [jobs, setJobs] = useState<Job[]>([]);
  const [recommendedJobs, setRecommendedJobs] = useState<Job[]>([]);
  const [loading, setLoading] = useState(true);
  const [recommendationsLoading, setRecommendationsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState({
    category: '',
    workType: '',
    location: '',
    search: ''
  });

  useEffect(() => {
    fetchJobs();
    if (user?.role === 'user') {
      fetchRecommendations();
    }
  }, [filters, user]);

  const fetchRecommendations = async () => {
    try {
      setRecommendationsLoading(true);
      const response = await api.get('/jobs/recommendations');
      setRecommendedJobs(response.data.jobs || []);
    } catch (err: any) {
      console.error('Error fetching recommendations:', err);
      // Don't show error for recommendations, just silently fail
    } finally {
      setRecommendationsLoading(false);
    }
  };

  const fetchJobs = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      
      if (filters.category) params.append('category', filters.category);
      if (filters.workType) params.append('workType', filters.workType);
      if (filters.location) params.append('location', filters.location);
      if (filters.search) params.append('search', filters.search);
      
      const response = await api.get(`/jobs?${params.toString()}`);
      setJobs(response.data.jobs || []);
    } catch (err: any) {
      setError('Failed to load jobs');
      toast.error('Failed to load jobs');
      console.error('Error fetching jobs:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleFilterChange = (field: string, value: string) => {
    setFilters(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const formatSalary = (job: Job) => {
    if (!job.min_salary && !job.max_salary) return 'Salary not specified';
    
    const currency = job.currency || 'PHP';
    if (job.min_salary && job.max_salary) {
      return `${currency} ${job.min_salary?.toLocaleString()} - ${job.max_salary?.toLocaleString()}`;
    } else if (job.min_salary) {
      return `${currency} ${job.min_salary?.toLocaleString()}+`;
    } else {
      return `Up to ${currency} ${job.max_salary?.toLocaleString()}`;
    }
  };

  const getTimeAgo = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60));
    
    if (diffInHours < 24) {
      return `${diffInHours} hours ago`;
    } else {
      const diffInDays = Math.floor(diffInHours / 24);
      return `${diffInDays} days ago`;
    }
  };

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow p-8 text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading job opportunities...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Job Opportunities</h1>
        <p className="mt-2 text-gray-600">
          Discover exciting career opportunities tailored for ACC students and alumni.
        </p>
      </div>

      {/* Recommended Jobs for logged-in users */}
      {user?.role === 'user' && (
        <div className="mb-8">
          <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg p-6 border border-blue-200">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-xl font-semibold text-gray-900 flex items-center">
                  <StarIcon className="h-5 w-5 text-yellow-500 mr-2" />
                  Recommended for You
                </h2>
                <p className="text-sm text-gray-600 mt-1">
                  Jobs that match your skills, courses, and experience
                </p>
              </div>
              {!recommendationsLoading && recommendedJobs.length > 0 && (
                <button 
                  onClick={fetchRecommendations}
                  className="text-sm text-blue-600 hover:text-blue-800"
                >
                  Refresh Recommendations
                </button>
              )}
            </div>

            {recommendationsLoading ? (
              <div className="flex items-center justify-center py-8">
                <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                <span className="ml-3 text-sm text-gray-600">Finding your perfect matches...</span>
              </div>
            ) : recommendedJobs.length > 0 ? (
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                {recommendedJobs.slice(0, 4).map((job) => (
                  <div key={job.id} className="bg-white rounded-lg border border-blue-200 p-4 hover:shadow-md transition-shadow">
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex-1">
                        <h3 className="font-medium text-gray-900 mb-1">{job.title}</h3>
                        <p className="text-sm text-gray-600">{job.created_by_name} • {job.location}</p>
                      </div>
                      <div className="ml-3">
                        <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                          {job.matchScore}% Match
                        </span>
                      </div>
                    </div>
                    
                    {job.matchReasons && job.matchReasons.length > 0 && (
                      <div className="mb-3">
                        <p className="text-xs text-blue-600 font-medium mb-1">Why this matches you:</p>
                        <ul className="text-xs text-gray-600 space-y-1">
                          {job.matchReasons.slice(0, 2).map((reason, index) => (
                            <li key={index} className="flex items-start">
                              <span className="text-blue-500 mr-1">•</span>
                              {reason}
                            </li>
                          ))}
                        </ul>
                      </div>
                    )}

                    <div className="flex space-x-2">
                      <Link
                        to={`/jobs/${job.id}`}
                        className="flex-1 text-center px-3 py-2 text-xs border border-blue-300 text-blue-700 rounded hover:bg-blue-50 transition-colors"
                      >
                        View Details
                      </Link>
                      <Link
                        to={`/jobs/${job.id}/apply`}
                        className="flex-1 text-center px-3 py-2 text-xs bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
                      >
                        Apply Now
                      </Link>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-6">
                <StarIcon className="h-12 w-12 text-gray-400 mx-auto mb-3" />
                <h3 className="text-sm font-medium text-gray-900 mb-1">No Personalized Recommendations Yet</h3>
                <p className="text-xs text-gray-600 mb-4">
                  Complete your profile and build your resume to get job recommendations tailored just for you!
                </p>
                <div className="space-x-2">
                  <Link
                    to="/complete-profile"
                    className="inline-block px-3 py-2 text-xs bg-blue-600 text-white rounded hover:bg-blue-700"
                  >
                    Complete Profile
                  </Link>
                  <Link
                    to="/resume-builder"
                    className="inline-block px-3 py-2 text-xs border border-blue-300 text-blue-700 rounded hover:bg-blue-50"
                  >
                    Build Resume
                  </Link>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Search Jobs
            </label>
            <input
              type="text"
              value={filters.search}
              onChange={(e) => handleFilterChange('search', e.target.value)}
              placeholder="Search by title or description"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Work Type
            </label>
            <select 
              value={filters.workType}
              onChange={(e) => handleFilterChange('workType', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">All Types</option>
              <option value="full-time">Full Time</option>
              <option value="part-time">Part Time</option>
              <option value="contract">Contract</option>
              <option value="internship">Internship</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Category
            </label>
            <input
              type="text"
              value={filters.category}
              onChange={(e) => handleFilterChange('category', e.target.value)}
              placeholder="e.g., IT Support, Accounting"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Location
            </label>
            <input
              type="text"
              value={filters.location}
              onChange={(e) => handleFilterChange('location', e.target.value)}
              placeholder="e.g., Manila, Quezon City"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 text-center">
          <BriefcaseIcon className="h-8 w-8 text-blue-600 mx-auto mb-2" />
          <div className="text-2xl font-bold text-gray-900">{jobs.length}</div>
          <div className="text-sm text-gray-600">Active Job Openings</div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 text-center">
          <UserGroupIcon className="h-8 w-8 text-green-600 mx-auto mb-2" />
          <div className="text-2xl font-bold text-gray-900">
            {jobs.reduce((sum, job) => sum + (job.application_count || 0), 0)}
          </div>
          <div className="text-sm text-gray-600">Total Applications</div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 text-center">
          <BuildingOfficeIcon className="h-8 w-8 text-purple-600 mx-auto mb-2" />
          <div className="text-2xl font-bold text-gray-900">
            {new Set(jobs.map(job => job.created_by_name)).size}
          </div>
          <div className="text-sm text-gray-600">Hiring Partners</div>
        </div>
      </div>

      {/* Job Listings */}
      {error ? (
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <p className="text-red-600">{error}</p>
          <button 
            onClick={fetchJobs}
            className="mt-4 px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700"
          >
            Try Again
          </button>
        </div>
      ) : jobs.length === 0 ? (
        <div className="bg-gray-50 border border-gray-200 rounded-lg p-12 text-center">
          <BriefcaseIcon className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No Jobs Found</h3>
          <p className="text-gray-600 mb-4">
            There are no job opportunities matching your current filters.
          </p>
          <button 
            onClick={() => setFilters({ category: '', workType: '', location: '', search: '' })}
            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
          >
            Clear Filters
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-6">
          {jobs.map((job) => (
            <div key={job.id} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div className="flex-1">
                  <div className="flex items-start justify-between mb-2">
                    <h3 className="text-xl font-semibold text-gray-900 mb-1">
                      {job.title}
                    </h3>
                    <div className="flex items-center space-x-2">
                      {job.average_rating > 0 && (
                        <div className="flex items-center">
                          <StarIcon className="h-4 w-4 text-yellow-400 fill-current" />
                          <span className="text-sm text-gray-600 ml-1">
                            {job.average_rating.toFixed(1)} ({job.rating_count})
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                  
                  <div className="flex flex-wrap gap-4 text-sm text-gray-600 mb-3">
                    <span className="flex items-center">
                      <BuildingOfficeIcon className="h-4 w-4 mr-1" />
                      {job.created_by_name}
                    </span>
                    <span className="flex items-center">
                      <MapPinIcon className="h-4 w-4 mr-1" />
                      {job.location}
                    </span>
                    <span className="flex items-center">
                      <BriefcaseIcon className="h-4 w-4 mr-1" />
                      {job.work_type?.charAt(0).toUpperCase() + job.work_type?.slice(1)} • {job.work_arrangement?.charAt(0).toUpperCase() + job.work_arrangement?.slice(1)}
                    </span>
                    <span className="flex items-center">
                      <ClockIcon className="h-4 w-4 mr-1" />
                      {getTimeAgo(job.created_at)}
                    </span>
                  </div>

                  <div className="flex flex-wrap gap-2 mb-4">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      <AcademicCapIcon className="h-3 w-3 mr-1" />
                      {job.category}
                    </span>
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      <CurrencyDollarIcon className="h-3 w-3 mr-1" />
                      {formatSalary(job)}
                    </span>
                    {job.experience_level && (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                        {job.experience_level.charAt(0).toUpperCase() + job.experience_level.slice(1)}
                      </span>
                    )}
                  </div>

                  <p className="text-gray-700 text-sm leading-relaxed mb-4 line-clamp-3">
                    {job.summary || job.description}
                  </p>

                  <div className="flex items-center justify-between text-sm">
                    <div className="flex items-center space-x-4 text-gray-500">
                      <span>{job.application_count || 0} applications</span>
                      <span>{job.positions_available} positions</span>
                      {job.application_deadline && (
                        <span className="text-orange-600">
                          Deadline: {new Date(job.application_deadline).toLocaleDateString()}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex space-x-3">
                <Link
                  to={`/jobs/${job.id}`}
                  className="flex-1 text-center px-4 py-2 border border-blue-300 text-blue-700 rounded-lg hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
                >
                  View Details
                </Link>
                <Link
                  to={`/jobs/${job.id}/apply`}
                  className="flex-1 text-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
                >
                  Apply Now
                </Link>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* CTA Section */}
      <div className="mt-12 bg-gradient-to-r from-blue-600 to-blue-700 rounded-lg p-8 text-center text-white">
        <h2 className="text-2xl font-bold mb-4">Ready to Start Your Career?</h2>
        <p className="text-blue-100 mb-6 max-w-2xl mx-auto">
          Join thousands of ACC students and alumni who have found their dream jobs through our platform.
          Create your profile and start applying today!
        </p>
        <div className="space-x-4">
          <Link
            to="/complete-profile"
            className="bg-white text-blue-600 px-6 py-3 rounded-lg font-medium hover:bg-blue-50 transition-colors inline-block"
          >
            Complete Your Profile
          </Link>
          <Link
            to="/resume-builder"
            className="border-2 border-white text-white px-6 py-3 rounded-lg font-medium hover:bg-white hover:text-blue-600 transition-colors inline-block"
          >
            Build Your Resume
          </Link>
        </div>
      </div>
    </div>
  );
};