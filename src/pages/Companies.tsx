import React, { useState, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import { api } from '../services/api';
import { 
  UserCircleIcon, 
  AcademicCapIcon, 
  BuildingOfficeIcon,
  UsersIcon,
  BookOpenIcon
} from '@heroicons/react/24/outline';

interface Coordinator {
  id: number;
  first_name: string;
  last_name: string;
  designated_course: string;
  profile_photo?: string;
}

export const Companies: React.FC = () => {
  const [coordinators, setCoordinators] = useState<Coordinator[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchCoordinators();
  }, []);

  const fetchCoordinators = async () => {
    try {
      setLoading(true);
      const response = await api.get('/users/coordinators/approved');
      setCoordinators(response.data);
    } catch (err: any) {
      setError('Failed to load coordinators');
      toast.error('Failed to load coordinators');
      console.error('Error fetching coordinators:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Our Team</h1>
        <p className="mt-2 text-gray-600">
          Meet our coordinators and business partners who make OJT placements possible.
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 text-center">
          <AcademicCapIcon className="h-8 w-8 text-blue-600 mx-auto mb-2" />
          <div className="text-2xl font-bold text-gray-900">{coordinators.length}</div>
          <div className="text-sm text-gray-600">Active Coordinators</div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 text-center">
          <BuildingOfficeIcon className="h-8 w-8 text-green-600 mx-auto mb-2" />
          <div className="text-2xl font-bold text-gray-900">-</div>
          <div className="text-sm text-gray-600">Business Partners</div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 text-center">
          <UsersIcon className="h-8 w-8 text-purple-600 mx-auto mb-2" />
          <div className="text-2xl font-bold text-gray-900">500+</div>
          <div className="text-sm text-gray-600">Students Placed</div>
        </div>
      </div>

      {/* Coordinators Section */}
      <div className="mb-16">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900 flex items-center">
            <AcademicCapIcon className="h-6 w-6 mr-2 text-blue-600" />
            Course Coordinators
          </h2>
          <p className="mt-2 text-gray-600">
            Our dedicated coordinators who guide students through their OJT journey and connect them with opportunities.
          </p>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[1, 2, 3, 4, 5, 6].map(i => (
              <div key={i} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
                <div className="animate-pulse">
                  <div className="w-20 h-20 bg-gray-200 rounded-full mx-auto mb-4"></div>
                  <div className="h-4 bg-gray-200 rounded w-3/4 mx-auto mb-2"></div>
                  <div className="h-3 bg-gray-200 rounded w-full mx-auto"></div>
                </div>
              </div>
            ))}
          </div>
        ) : error ? (
          <div className="text-center py-12 bg-red-50 rounded-lg border border-red-200">
            <div className="text-red-600">
              <AcademicCapIcon className="h-12 w-12 mx-auto mb-4" />
              <p className="text-lg font-medium">{error}</p>
              <button 
                onClick={fetchCoordinators}
                className="mt-4 px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500"
              >
                Try Again
              </button>
            </div>
          </div>
        ) : coordinators.length === 0 ? (
          <div className="text-center py-12 bg-gray-50 rounded-lg border border-gray-200">
            <AcademicCapIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No Coordinators Available</h3>
            <p className="text-gray-600">
              There are currently no active coordinators to display.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {coordinators.map((coordinator) => (
              <div key={coordinator.id} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow">
                {/* Profile Photo */}
                <div className="text-center mb-4">
                  {coordinator.profile_photo ? (
                    <img
                      src={coordinator.profile_photo}
                      alt={`${coordinator.first_name} ${coordinator.last_name}`}
                      className="w-20 h-20 rounded-full object-cover mx-auto ring-2 ring-blue-100"
                    />
                  ) : (
                    <div className="w-20 h-20 rounded-full bg-blue-100 flex items-center justify-center mx-auto">
                      <UserCircleIcon className="h-12 w-12 text-blue-600" />
                    </div>
                  )}
                </div>

                {/* Name */}
                <div className="text-center mb-3">
                  <h3 className="text-lg font-semibold text-gray-900">
                    {coordinator.first_name} {coordinator.last_name}
                  </h3>
                </div>

                {/* Designated Course */}
                <div className="text-center">
                  <div className="inline-flex items-center px-3 py-1 rounded-full text-sm bg-blue-50 text-blue-700 border border-blue-200">
                    <BookOpenIcon className="h-4 w-4 mr-1.5" />
                    <span className="font-medium">{coordinator.designated_course}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Business Owners Section */}
      <div className="mb-12">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900 flex items-center">
            <BuildingOfficeIcon className="h-6 w-6 mr-2 text-green-600" />
            Business Partners
          </h2>
          <p className="mt-2 text-gray-600">
            Companies and organizations that provide valuable OJT opportunities for our students.
          </p>
        </div>

        {/* Placeholder for Business Owners */}
        <div className="bg-gray-50 rounded-lg border-2 border-dashed border-gray-300 p-12 text-center">
          <BuildingOfficeIcon className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <h3 className="text-xl font-medium text-gray-900 mb-2">Coming Soon</h3>
          <p className="text-gray-600 mb-6">
            Our business partner directory is currently under development. 
            <br />
            Check back soon to see the companies offering OJT opportunities.
          </p>
          <div className="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
            <BuildingOfficeIcon className="h-4 w-4 mr-2" />
            Business Partner Features Coming Soon
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-lg p-8 text-center text-white">
        <h2 className="text-2xl font-bold mb-4">Join Our Network</h2>
        <p className="text-blue-100 mb-6 max-w-2xl mx-auto">
          Whether you're a student looking for guidance or a company seeking talented interns, 
          our coordinators are here to help make the perfect match.
        </p>
        <div className="space-x-4">
          <button className="bg-white text-blue-600 px-6 py-3 rounded-lg font-medium hover:bg-blue-50 transition-colors">
            Contact a Coordinator
          </button>
          <button className="border-2 border-white text-white px-6 py-3 rounded-lg font-medium hover:bg-white hover:text-blue-600 transition-colors">
            Learn More
          </button>
        </div>
      </div>
    </div>
  );
};