import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { userAPI } from '../services/api';
import { 
  BriefcaseIcon,
  DocumentTextIcon,
  UserGroupIcon,
  ChartBarIcon,
  PlusIcon,
  EyeIcon
} from '@heroicons/react/24/outline';

export const Dashboard: React.FC = () => {
  const { user } = useAuth();
  const [stats, setStats] = useState({
    applications: 0,
    resumes: 0,
    matches: 0,
    jobs: 0
  });
  const [userName, setUserName] = useState<string>('');

  // Redirect coordinators to their own dashboard
  if (user?.role === 'coordinator') {
    window.location.href = '/coordinator/dashboard';
    return null;
  }

  // Fetch user name for welcome message
  useEffect(() => {
    const fetchUserName = async () => {
      try {
        if (user?.role === 'user') {
          const response = await userAPI.getNavbarInfo();
          const { firstName, lastName } = response.data;
          if (firstName && lastName) {
            setUserName(`${firstName} ${lastName}`);
          } else {
            // Fallback to email prefix if name not available
            setUserName(user?.email.split('@')[0] || '');
          }
        } else {
          // For non-user roles, use email prefix for now
          setUserName(user?.email.split('@')[0] || '');
        }
      } catch (error) {
        console.error('Failed to fetch user name:', error);
        // Fallback to email prefix on error
        setUserName(user?.email.split('@')[0] || '');
      }
    };

    if (user) {
      fetchUserName();
    }
  }, [user]);

  // Mock data - in real app, fetch from API
  useEffect(() => {
    // Simulate API call
    setStats({
      applications: 5,
      resumes: 2,
      matches: 8,
      jobs: 12
    });
  }, []);

  const renderUserDashboard = () => (
    <div className="space-y-8">
      {/* Welcome Message */}
      <div className="bg-gradient-to-r from-primary-600 to-primary-700 rounded-lg p-6 text-white">
        <h2 className="text-2xl font-bold mb-2">
          Welcome back, {userName || user?.email.split('@')[0]}!
        </h2>
        <p className="text-primary-100">Ready to take the next step in your career journey?</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <BriefcaseIcon className="h-8 w-8 text-blue-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Applications</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.applications}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <DocumentTextIcon className="h-8 w-8 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Resumes</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.resumes}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <ChartBarIcon className="h-8 w-8 text-purple-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Job Matches</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.matches}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <UserGroupIcon className="h-8 w-8 text-indigo-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Available Jobs</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.jobs}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Link
          to="/resume-builder"
          className="block bg-white rounded-lg shadow hover:shadow-md transition-shadow p-6"
        >
          <div className="flex items-center">
            <DocumentTextIcon className="h-8 w-8 text-primary-600" />
            <div className="ml-4">
              <h3 className="text-lg font-medium text-gray-900">Build Resume</h3>
              <p className="text-gray-500">Create or update your professional resume</p>
            </div>
          </div>
        </Link>

        <Link
          to="/jobs"
          className="block bg-white rounded-lg shadow hover:shadow-md transition-shadow p-6"
        >
          <div className="flex items-center">
            <BriefcaseIcon className="h-8 w-8 text-blue-600" />
            <div className="ml-4">
              <h3 className="text-lg font-medium text-gray-900">Browse Jobs</h3>
              <p className="text-gray-500">Explore available job opportunities</p>
            </div>
          </div>
        </Link>

        <Link
          to="/profile"
          className="block bg-white rounded-lg shadow hover:shadow-md transition-shadow p-6"
        >
          <div className="flex items-center">
            <UserGroupIcon className="h-8 w-8 text-green-600" />
            <div className="ml-4">
              <h3 className="text-lg font-medium text-gray-900">Update Profile</h3>
              <p className="text-gray-500">Keep your profile information current</p>
            </div>
          </div>
        </Link>
      </div>

      {/* Recent Activity */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Recent Activity</h3>
          <div className="space-y-3">
            <div className="flex items-center text-sm">
              <div className="w-2 h-2 bg-green-400 rounded-full mr-3"></div>
              <span className="text-gray-600">Applied to Software Developer position at Tech Corp</span>
              <span className="ml-auto text-gray-400">2 hours ago</span>
            </div>
            <div className="flex items-center text-sm">
              <div className="w-2 h-2 bg-blue-400 rounded-full mr-3"></div>
              <span className="text-gray-600">Updated resume "Software Developer Resume"</span>
              <span className="ml-auto text-gray-400">1 day ago</span>
            </div>
            <div className="flex items-center text-sm">
              <div className="w-2 h-2 bg-purple-400 rounded-full mr-3"></div>
              <span className="text-gray-600">New job match found: Web Developer</span>
              <span className="ml-auto text-gray-400">2 days ago</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  const renderCompanyDashboard = () => (
    <div className="space-y-8">
      {/* Welcome Message */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-lg p-6 text-white">
        <h2 className="text-2xl font-bold mb-2">Company Dashboard</h2>
        <p className="text-blue-100">Manage your job postings and find the best candidates</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <BriefcaseIcon className="h-8 w-8 text-blue-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Active Jobs</p>
              <p className="text-2xl font-semibold text-gray-900">8</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <UserGroupIcon className="h-8 w-8 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Applications</p>
              <p className="text-2xl font-semibold text-gray-900">42</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <EyeIcon className="h-8 w-8 text-purple-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Job Views</p>
              <p className="text-2xl font-semibold text-gray-900">256</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <ChartBarIcon className="h-8 w-8 text-indigo-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Hired</p>
              <p className="text-2xl font-semibold text-gray-900">12</p>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Quick Actions</h3>
          <div className="space-y-3">
            <button className="w-full flex items-center justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700">
              <PlusIcon className="h-4 w-4 mr-2" />
              Post New Job
            </button>
            <Link
              to="/profile"
              className="w-full flex items-center justify-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
            >
              Update Company Profile
            </Link>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Recent Applications</h3>
          <div className="space-y-3">
            <div className="flex items-center text-sm">
              <div className="w-8 h-8 bg-gray-200 rounded-full mr-3"></div>
              <div>
                <p className="font-medium text-gray-900">John Doe</p>
                <p className="text-gray-500">Applied for Software Developer</p>
              </div>
              <span className="ml-auto text-gray-400">2h</span>
            </div>
            <div className="flex items-center text-sm">
              <div className="w-8 h-8 bg-gray-200 rounded-full mr-3"></div>
              <div>
                <p className="font-medium text-gray-900">Jane Smith</p>
                <p className="text-gray-500">Applied for Marketing Intern</p>
              </div>
              <span className="ml-auto text-gray-400">4h</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  const renderCoordinatorDashboard = () => (
    <div className="space-y-8">
      {/* Welcome Message */}
      <div className="bg-gradient-to-r from-green-600 to-green-700 rounded-lg p-6 text-white">
        <h2 className="text-2xl font-bold mb-2">Coordinator Dashboard</h2>
        <p className="text-green-100">Bridge the gap between students and companies</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <UserGroupIcon className="h-8 w-8 text-blue-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Students</p>
              <p className="text-2xl font-semibold text-gray-900">125</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <BriefcaseIcon className="h-8 w-8 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Partner Companies</p>
              <p className="text-2xl font-semibold text-gray-900">18</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <ChartBarIcon className="h-8 w-8 text-purple-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Placements</p>
              <p className="text-2xl font-semibold text-gray-900">32</p>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Coordinator Actions</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <button className="flex items-center justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700">
            <PlusIcon className="h-4 w-4 mr-2" />
            Invite Company
          </button>
          <Link
            to="/profile"
            className="flex items-center justify-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            Update Profile
          </Link>
        </div>
      </div>
    </div>
  );

  const renderAdminDashboard = () => (
    <div className="space-y-8">
      {/* Welcome Message */}
      <div className="bg-gradient-to-r from-red-600 to-red-700 rounded-lg p-6 text-white">
        <h2 className="text-2xl font-bold mb-2">Admin Dashboard</h2>
        <p className="text-red-100">Manage the platform and oversee all activities</p>
      </div>

      {/* Admin specific content would go here */}
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Admin Controls</h3>
        <p className="text-gray-600">Admin dashboard functionality coming soon...</p>
        <Link
          to="/admin"
          className="mt-4 inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700"
        >
          Go to Admin Panel
        </Link>
      </div>
    </div>
  );

  if (!user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {user.role === 'user' && renderUserDashboard()}
      {user.role === 'company' && renderCompanyDashboard()}
      {user.role === 'coordinator' && renderCoordinatorDashboard()}
      {user.role === 'admin' && renderAdminDashboard()}
    </div>
  );
};
