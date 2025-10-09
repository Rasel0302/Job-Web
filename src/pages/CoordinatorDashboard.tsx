import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { api } from '../services/api';
import { toast } from 'react-hot-toast';
import { 
  BriefcaseIcon,
  PlusIcon,
  UserGroupIcon,
  ChartBarIcon,
  ClockIcon,
  CheckCircleIcon,
  XCircleIcon,
  EyeIcon,
  DocumentTextIcon,
  AcademicCapIcon,
  UserPlusIcon
} from '@heroicons/react/24/outline';

interface JobStats {
  total: number;
  active: number;
  applications: number;
  pending: number;
}

interface RecentJob {
  id: number;
  title: string;
  category: string;
  application_count: number;
  status: string;
  created_at: string;
}

interface RecentApplication {
  id: number;
  job_title: string;
  applicant_name: string;
  status: string;
  created_at: string;
  ats_score: number;
}

export const CoordinatorDashboard: React.FC = () => {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [jobStats, setJobStats] = useState<JobStats>({
    total: 0,
    active: 0,
    applications: 0,
    pending: 0
  });
  const [recentJobs, setRecentJobs] = useState<RecentJob[]>([]);
  const [recentApplications, setRecentApplications] = useState<RecentApplication[]>([]);
  const [coordinatorName, setCoordinatorName] = useState<string>('');

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      
      // Fetch coordinator profile info
      const profileResponse = await api.get('/coordinator/profile');
      const profile = profileResponse.data;
      setCoordinatorName(`${profile.first_name || ''} ${profile.last_name || ''}`.trim());

      // Fetch job statistics
      const statsResponse = await api.get(`/jobs?createdBy=coordinator:${user?.id}&limit=1000`);
      const jobs = statsResponse.data.jobs || [];
      
      const stats = {
        total: jobs.length,
        active: jobs.filter((job: any) => job.status === 'active').length,
        applications: jobs.reduce((sum: number, job: any) => sum + (job.application_count || 0), 0),
        pending: 0 // Will be calculated from applications
      };

      // Get recent jobs (last 5)
      const recentJobsData = jobs.slice(0, 5).map((job: any) => ({
        id: job.id,
        title: job.title,
        category: job.category,
        application_count: job.application_count || 0,
        status: job.status,
        created_at: job.created_at
      }));

      setJobStats(stats);
      setRecentJobs(recentJobsData);

      // Fetch recent applications across all jobs
      if (jobs.length > 0) {
        // Get applications for all coordinator jobs
        const applicationPromises = jobs.slice(0, 3).map((job: any) => 
          api.get(`/jobs/${job.id}/applications?limit=5`)
        );
        
        const applicationResponses = await Promise.all(applicationPromises);
        const allApplications: RecentApplication[] = [];
        
        applicationResponses.forEach((response, index) => {
          const applications = response.data.applications || [];
          applications.forEach((app: any) => {
            allApplications.push({
              id: app.id,
              job_title: jobs[index].title,
              applicant_name: `${app.first_name} ${app.last_name}`,
              status: app.status,
              created_at: app.created_at,
              ats_score: app.overall_score || 0
            });
          });
        });

        // Sort by date and take the 5 most recent
        allApplications.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
        setRecentApplications(allApplications.slice(0, 5));

        // Update pending applications count
        const pendingCount = allApplications.filter(app => app.status === 'pending').length;
        setJobStats(prev => ({ ...prev, pending: pendingCount }));
      }

    } catch (error: any) {
      console.error('Failed to fetch dashboard data:', error);
      toast.error('Failed to load dashboard data');
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadge = (status: string) => {
    const statusConfig = {
      pending: { color: 'bg-yellow-100 text-yellow-800', icon: ClockIcon },
      under_review: { color: 'bg-blue-100 text-blue-800', icon: EyeIcon },
      qualified: { color: 'bg-green-100 text-green-800', icon: CheckCircleIcon },
      rejected: { color: 'bg-red-100 text-red-800', icon: XCircleIcon },
      hired: { color: 'bg-purple-100 text-purple-800', icon: CheckCircleIcon }
    };

    const config = statusConfig[status as keyof typeof statusConfig] || statusConfig.pending;
    const Icon = config.icon;

    return (
      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${config.color}`}>
        <Icon className="h-3 w-3 mr-1" />
        {status.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}
      </span>
    );
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="bg-white shadow rounded-lg p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading dashboard...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        {/* Welcome Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">
            Welcome back, {coordinatorName || 'Coordinator'}! 👋
          </h1>
          <p className="mt-2 text-gray-600">
            Manage your job postings, review applications, and connect students with opportunities.
          </p>
        </div>

        {/* Quick Actions */}
        <div className="mb-8">
          <div className="bg-gradient-to-r from-blue-500 to-blue-600 rounded-lg p-6 text-white">
            <h2 className="text-xl font-semibold mb-4">Quick Actions</h2>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <Link
                to="/coordinator/jobs/create"
                className="bg-white bg-opacity-20 rounded-lg p-4 hover:bg-opacity-30 transition-colors"
              >
                <div className="flex items-center">
                  <PlusIcon className="h-6 w-6 mr-3" />
                  <span className="font-medium">Post New Job</span>
                </div>
              </Link>
              <Link
                to="/coordinator/jobs"
                className="bg-white bg-opacity-20 rounded-lg p-4 hover:bg-opacity-30 transition-colors"
              >
                <div className="flex items-center">
                  <BriefcaseIcon className="h-6 w-6 mr-3" />
                  <span className="font-medium">Manage Jobs</span>
                </div>
              </Link>
              <Link
                to="/coordinator/jobs"
                className="bg-white bg-opacity-20 rounded-lg p-4 hover:bg-opacity-30 transition-colors"
              >
                <div className="flex items-center">
                  <UserGroupIcon className="h-6 w-6 mr-3" />
                  <span className="font-medium">Review Applications</span>
                </div>
              </Link>
              <Link
                to="/coordinator/invite-company"
                className="bg-white bg-opacity-20 rounded-lg p-4 hover:bg-opacity-30 transition-colors"
              >
                <div className="flex items-center">
                  <UserPlusIcon className="h-6 w-6 mr-3" />
                  <span className="font-medium">Invite Companies</span>
                </div>
              </Link>
            </div>
          </div>
        </div>

        {/* Statistics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <BriefcaseIcon className="h-8 w-8 text-blue-600" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Total Jobs</p>
                <p className="text-2xl font-bold text-gray-900">{jobStats.total}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <CheckCircleIcon className="h-8 w-8 text-green-600" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Active Jobs</p>
                <p className="text-2xl font-bold text-gray-900">{jobStats.active}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <UserGroupIcon className="h-8 w-8 text-purple-600" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Total Applications</p>
                <p className="text-2xl font-bold text-gray-900">{jobStats.applications}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <ClockIcon className="h-8 w-8 text-orange-600" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Pending Review</p>
                <p className="text-2xl font-bold text-gray-900">{jobStats.pending}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Recent Jobs and Applications */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Recent Jobs */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200">
            <div className="p-6 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-medium text-gray-900">Recent Job Postings</h3>
                <Link
                  to="/coordinator/jobs"
                  className="text-sm text-blue-600 hover:text-blue-500"
                >
                  View all
                </Link>
              </div>
            </div>
            <div className="p-6">
              {recentJobs.length === 0 ? (
                <div className="text-center py-8">
                  <BriefcaseIcon className="mx-auto h-12 w-12 text-gray-400" />
                  <h3 className="mt-2 text-sm font-medium text-gray-900">No jobs posted yet</h3>
                  <p className="mt-1 text-sm text-gray-500">Get started by posting your first job.</p>
                  <div className="mt-6">
                    <Link
                      to="/coordinator/jobs/create"
                      className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                    >
                      <PlusIcon className="h-4 w-4 mr-2" />
                      Post Job
                    </Link>
                  </div>
                </div>
              ) : (
                <div className="space-y-4">
                  {recentJobs.map((job) => (
                    <div key={job.id} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="text-sm font-medium text-gray-900">{job.title}</h4>
                        <span className="text-xs text-gray-500">
                          {new Date(job.created_at).toLocaleDateString()}
                        </span>
                      </div>
                      <p className="text-xs text-gray-600 mb-2">{job.category}</p>
                      <div className="flex items-center justify-between">
                        <span className="text-xs text-gray-500">
                          {job.application_count} applications
                        </span>
                        <Link
                          to={`/jobs/${job.id}`}
                          className="text-xs text-blue-600 hover:text-blue-500"
                        >
                          View details
                        </Link>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Recent Applications */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200">
            <div className="p-6 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-medium text-gray-900">Recent Applications</h3>
                <Link
                  to="/coordinator/jobs"
                  className="text-sm text-blue-600 hover:text-blue-500"
                >
                  View all
                </Link>
              </div>
            </div>
            <div className="p-6">
              {recentApplications.length === 0 ? (
                <div className="text-center py-8">
                  <DocumentTextIcon className="mx-auto h-12 w-12 text-gray-400" />
                  <h3 className="mt-2 text-sm font-medium text-gray-900">No applications yet</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    Applications will appear here once students start applying to your jobs.
                  </p>
                </div>
              ) : (
                <div className="space-y-4">
                  {recentApplications.map((application) => (
                    <div key={application.id} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="text-sm font-medium text-gray-900">
                          {application.applicant_name}
                        </h4>
                        <span className="text-xs text-gray-500">
                          {new Date(application.created_at).toLocaleDateString()}
                        </span>
                      </div>
                      <p className="text-xs text-gray-600 mb-2">{application.job_title}</p>
                      <div className="flex items-center justify-between">
                        {getStatusBadge(application.status)}
                        {application.ats_score > 0 && (
                          <span className="text-xs text-green-600">
                            ATS Score: {application.ats_score}%
                          </span>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

