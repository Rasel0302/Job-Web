import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { api } from '../services/api';
import { toast } from 'react-hot-toast';
import {
  UserIcon,
  EnvelopeIcon,
  PhoneIcon,
  DocumentTextIcon,
  ChatBubbleLeftRightIcon,
  CheckIcon,
  XMarkIcon,
  EyeIcon,
  FunnelIcon,
  ArrowLeftIcon,
  CalendarIcon,
  LinkIcon
} from '@heroicons/react/24/outline';

interface JobApplication {
  id: number;
  job_id: number;
  user_id: number;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  address: string;
  position_applying_for: string;
  resume_type: 'uploaded' | 'builder_link';
  resume_file: string;
  resume_builder_link: string;
  interview_video: string;
  status: 'pending' | 'under_review' | 'qualified' | 'rejected' | 'hired';
  created_at: string;
  updated_at: string;
  profile_photo: string;
  overall_score: number;
  skill_match_score: number;
  experience_match_score: number;
  comment_count: number;
  screening_answers: ScreeningAnswer[];
}

interface ScreeningAnswer {
  id: number;
  question_id: number;
  question_text: string;
  question_type: string;
  answer: string;
  options: string[] | null;
}

interface Comment {
  id: number;
  application_id: number;
  commenter_id: number;
  commenter_type: 'coordinator' | 'company';
  commenter_name: string;
  comment: string;
  created_at: string;
}

interface JobDetails {
  id: number;
  title: string;
  company_name: string;
  created_by_type: string;
  created_by_id: number;
  filter_pre_screening: boolean;
}

export const ReviewApplications: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const navigate = useNavigate();
  
  const [job, setJob] = useState<JobDetails | null>(null);
  const [applications, setApplications] = useState<JobApplication[]>([]);
  const [filteredApplications, setFilteredApplications] = useState<JobApplication[]>([]);
  const [selectedApplication, setSelectedApplication] = useState<JobApplication | null>(null);
  const [comments, setComments] = useState<Comment[]>([]);
  const [newComment, setNewComment] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [preScreeningFilter, setPreScreeningFilter] = useState<boolean>(false);
  const [showApplicationDetails, setShowApplicationDetails] = useState(false);

  useEffect(() => {
    if (id) {
      fetchJobDetails();
      fetchApplications();
    }
  }, [id]);

  useEffect(() => {
    const applyFilters = async () => {
      await filterApplications();
    };
    applyFilters();
  }, [applications, statusFilter, preScreeningFilter]);

  const fetchJobDetails = async () => {
    try {
      const response = await api.get(`/jobs/${id}`);
      setJob(response.data);
    } catch (error) {
      console.error('Failed to fetch job details:', error);
      toast.error('Failed to load job details');
    }
  };

  const fetchApplications = async () => {
    try {
      setLoading(true);
      const response = await api.get(`/jobs/${id}/applications`);
      setApplications(response.data.applications || []);
    } catch (error: any) {
      console.error('Failed to fetch applications:', error);
      toast.error('Failed to load applications');
    } finally {
      setLoading(false);
    }
  };

  const fetchApplicationDetails = async (applicationId: number) => {
    try {
      const response = await api.get(`/jobs/applications/${applicationId}/details`);
      setSelectedApplication(response.data);
      fetchComments(applicationId);
      setShowApplicationDetails(true);
    } catch (error) {
      console.error('Failed to fetch application details:', error);
      toast.error('Failed to load application details');
    }
  };

  const fetchComments = async (applicationId: number) => {
    try {
      const response = await api.get(`/jobs/applications/${applicationId}/comments`);
      setComments(response.data);
    } catch (error) {
      console.error('Failed to fetch comments:', error);
    }
  };

  const filterApplications = async () => {
    let filtered = [...applications];

    // Status filter
    if (statusFilter !== 'all') {
      filtered = filtered.filter(app => app.status === statusFilter);
    }

    // Pre-screening filter
    if (preScreeningFilter && job?.filter_pre_screening) {
      try {
        const response = await api.post(`/jobs/${id}/applications/filter`, {
          filterCriteria: {} // Can be extended with specific criteria
        });
        
        // Use the filtered applications from the backend
        const filteredByScreening = response.data.applications;
        const filteredIds = new Set(filteredByScreening.map((app: any) => app.id));
        
        filtered = filtered.filter(app => filteredIds.has(app.id));
        
        toast.success(`Filtered ${filteredByScreening.length} applications that meet pre-screening standards`);
      } catch (error: any) {
        console.error('Failed to apply pre-screening filter:', error);
        toast.error(error.response?.data?.message || 'Failed to apply pre-screening filter');
        // Continue with unfiltered results
      }
    }

    setFilteredApplications(filtered);
  };

  const updateApplicationStatus = async (applicationId: number, status: string) => {
    if (user?.role !== 'coordinator') {
      toast.error('Only coordinators can update application status');
      return;
    }

    try {
      setSubmitting(true);
      await api.patch(`/jobs/applications/${applicationId}/status`, { status });
      toast.success('Application status updated successfully');
      fetchApplications();
      if (selectedApplication?.id === applicationId) {
        setSelectedApplication(prev => prev ? { ...prev, status: status as any } : null);
      }
    } catch (error: any) {
      console.error('Failed to update application status:', error);
      toast.error(error.response?.data?.message || 'Failed to update status');
    } finally {
      setSubmitting(false);
    }
  };

  const addComment = async () => {
    if (!newComment.trim() || !selectedApplication) return;

    try {
      setSubmitting(true);
      await api.post(`/jobs/applications/${selectedApplication.id}/comments`, {
        comment: newComment
      });
      setNewComment('');
      fetchComments(selectedApplication.id);
      toast.success('Comment added successfully');
    } catch (error: any) {
      console.error('Failed to add comment:', error);
      toast.error(error.response?.data?.message || 'Failed to add comment');
    } finally {
      setSubmitting(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800';
      case 'under_review': return 'bg-blue-100 text-blue-800';
      case 'qualified': return 'bg-green-100 text-green-800';
      case 'rejected': return 'bg-red-100 text-red-800';
      case 'hired': return 'bg-purple-100 text-purple-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow p-8 text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading applications...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <button
              onClick={() => navigate(`/jobs/${id}`)}
              className="flex items-center text-sm text-gray-500 hover:text-gray-700 mb-2"
            >
              <ArrowLeftIcon className="h-4 w-4 mr-1" />
              Back to Job Details
            </button>
            <h1 className="text-3xl font-bold text-gray-900">Review Applications</h1>
            {job && (
              <p className="mt-2 text-gray-600">
                {job.title} • {applications.length} applications
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow mb-6 p-6">
        <div className="flex items-center space-x-6">
          <div className="flex items-center">
            <FunnelIcon className="h-5 w-5 text-gray-400 mr-2" />
            <span className="text-sm font-medium text-gray-700">Filters:</span>
          </div>
          
          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">Status</label>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="text-sm border border-gray-300 rounded-md px-3 py-1"
            >
              <option value="all">All Status</option>
              <option value="pending">Pending</option>
              <option value="under_review">Under Review</option>
              <option value="qualified">Qualified</option>
              <option value="rejected">Rejected</option>
              <option value="hired">Hired</option>
            </select>
          </div>

          {job?.filter_pre_screening && (
            <div>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={preScreeningFilter}
                  onChange={(e) => setPreScreeningFilter(e.target.checked)}
                  className="rounded border-gray-300 text-blue-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50"
                />
                <span className="ml-2 text-sm text-gray-700">Filter by pre-screening standards</span>
              </label>
            </div>
          )}
        </div>
      </div>

      {/* Applications List */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-medium text-gray-900">
            Applications ({filteredApplications.length})
          </h2>
        </div>

        {filteredApplications.length === 0 ? (
          <div className="p-8 text-center">
            <UserIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500">No applications found with the selected filters.</p>
          </div>
        ) : (
          <div className="divide-y divide-gray-200">
            {filteredApplications.map((application) => (
              <div key={application.id} className="p-6">
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-4">
                    <div className="flex-shrink-0">
                      {application.profile_photo ? (
                        <img
                          className="h-12 w-12 rounded-full object-cover"
                          src={application.profile_photo}
                          alt={`${application.first_name} ${application.last_name}`}
                        />
                      ) : (
                        <div className="h-12 w-12 rounded-full bg-gray-300 flex items-center justify-center">
                          <UserIcon className="h-6 w-6 text-gray-600" />
                        </div>
                      )}
                    </div>
                    
                    <div className="flex-1">
                      <div className="flex items-center space-x-3">
                        <h3 className="text-lg font-medium text-gray-900">
                          {application.first_name} {application.last_name}
                        </h3>
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(application.status)}`}>
                          {application.status.replace('_', ' ')}
                        </span>
                      </div>
                      
                      <div className="mt-1 flex items-center space-x-4 text-sm text-gray-500">
                        <span className="flex items-center">
                          <EnvelopeIcon className="h-4 w-4 mr-1" />
                          {application.email}
                        </span>
                        <span className="flex items-center">
                          <PhoneIcon className="h-4 w-4 mr-1" />
                          {application.phone}
                        </span>
                        <span className="flex items-center">
                          <CalendarIcon className="h-4 w-4 mr-1" />
                          Applied {formatDate(application.created_at)}
                        </span>
                      </div>
                      
                      <div className="mt-2 flex items-center space-x-4 text-sm">
                        <span className="text-gray-600">Position: {application.position_applying_for}</span>
                        {application.overall_score > 0 && (
                          <span className="text-blue-600">ATS Score: {application.overall_score}%</span>
                        )}
                        {application.comment_count > 0 && (
                          <span className="flex items-center text-gray-600">
                            <ChatBubbleLeftRightIcon className="h-4 w-4 mr-1" />
                            {application.comment_count} comments
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center space-x-3">
                    <button
                      onClick={() => fetchApplicationDetails(application.id)}
                      className="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                    >
                      <EyeIcon className="h-4 w-4 mr-2" />
                      View Details
                    </button>

                    {user?.role === 'coordinator' && (
                      <div className="flex space-x-2">
                        {application.status !== 'qualified' && application.status !== 'hired' && (
                          <button
                            onClick={() => updateApplicationStatus(application.id, 'qualified')}
                            disabled={submitting}
                            className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50"
                          >
                            <CheckIcon className="h-4 w-4 mr-1" />
                            Accept
                          </button>
                        )}
                        
                        {application.status !== 'rejected' && (
                          <button
                            onClick={() => updateApplicationStatus(application.id, 'rejected')}
                            disabled={submitting}
                            className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50"
                          >
                            <XMarkIcon className="h-4 w-4 mr-1" />
                            Reject
                          </button>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Application Details Modal */}
      {showApplicationDetails && selectedApplication && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-8 mx-auto p-5 border max-w-4xl shadow-lg rounded-md bg-white mb-8">
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-xl font-semibold text-gray-900">
                Application Details - {selectedApplication.first_name} {selectedApplication.last_name}
              </h3>
              <button
                onClick={() => setShowApplicationDetails(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <XMarkIcon className="h-6 w-6" />
              </button>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Application Information */}
              <div className="space-y-6">
                <div>
                  <h4 className="text-lg font-medium text-gray-900 mb-4">Personal Information</h4>
                  <div className="space-y-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Full Name</label>
                      <p className="mt-1 text-sm text-gray-900">{selectedApplication.first_name} {selectedApplication.last_name}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Email</label>
                      <p className="mt-1 text-sm text-gray-900">{selectedApplication.email}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Phone</label>
                      <p className="mt-1 text-sm text-gray-900">{selectedApplication.phone}</p>
                    </div>
                    {selectedApplication.address && (
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Address</label>
                        <p className="mt-1 text-sm text-gray-900">{selectedApplication.address}</p>
                      </div>
                    )}
                  </div>
                </div>

                <div>
                  <h4 className="text-lg font-medium text-gray-900 mb-4">Application Details</h4>
                  <div className="space-y-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Position Applying For</label>
                      <p className="mt-1 text-sm text-gray-900">{selectedApplication.position_applying_for}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">Resume</label>
                      <div className="mt-1">
                        {selectedApplication.resume_type === 'uploaded' && selectedApplication.resume_file ? (
                          <a
                            href={`/uploads/resumes/${selectedApplication.resume_file}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="inline-flex items-center text-sm text-blue-600 hover:text-blue-800"
                          >
                            <DocumentTextIcon className="h-4 w-4 mr-1" />
                            View Resume File
                          </a>
                        ) : selectedApplication.resume_builder_link ? (
                          <a
                            href={selectedApplication.resume_builder_link}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="inline-flex items-center text-sm text-blue-600 hover:text-blue-800"
                          >
                            <LinkIcon className="h-4 w-4 mr-1" />
                            View Resume Builder
                          </a>
                        ) : (
                          <p className="text-sm text-gray-500">No resume provided</p>
                        )}
                      </div>
                    </div>
                    {selectedApplication.interview_video && (
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Interview Video</label>
                        <a
                          href={selectedApplication.interview_video}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="mt-1 inline-flex items-center text-sm text-blue-600 hover:text-blue-800"
                        >
                          <LinkIcon className="h-4 w-4 mr-1" />
                          Watch Interview Video
                        </a>
                      </div>
                    )}
                  </div>
                </div>

                {/* Screening Questions */}
                {selectedApplication.screening_answers && selectedApplication.screening_answers.length > 0 && (
                  <div>
                    <h4 className="text-lg font-medium text-gray-900 mb-4">Screening Questions</h4>
                    <div className="space-y-4">
                      {selectedApplication.screening_answers.map((answer, index) => (
                        <div key={answer.id} className="border border-gray-200 rounded-lg p-4">
                          <h5 className="font-medium text-gray-900 mb-2">{answer.question_text}</h5>
                          <p className="text-sm text-gray-700">{answer.answer}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* Comments Section */}
              <div className="space-y-6">
                <div>
                  <h4 className="text-lg font-medium text-gray-900 mb-4">Comments</h4>
                  
                  {/* Add Comment */}
                  <div className="mb-6">
                    <textarea
                      value={newComment}
                      onChange={(e) => setNewComment(e.target.value)}
                      placeholder={
                        user?.role === 'coordinator' 
                          ? "Add a comment about this applicant..." 
                          : user?.role === 'company'
                          ? "Add your thoughts about this applicant (e.g., 'I need this person')..."
                          : "You don't have permission to comment"
                      }
                      disabled={!user || (user.role !== 'coordinator' && user.role !== 'company')}
                      rows={3}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed"
                    />
                    {(user?.role === 'coordinator' || user?.role === 'company') && (
                      <button
                        onClick={addComment}
                        disabled={submitting || !newComment.trim()}
                        className="mt-2 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
                      >
                        {submitting ? 'Adding...' : 'Add Comment'}
                      </button>
                    )}
                  </div>

                  {/* Comments List */}
                  <div className="space-y-4 max-h-96 overflow-y-auto">
                    {comments.length === 0 ? (
                      <p className="text-sm text-gray-500 text-center py-4">No comments yet</p>
                    ) : (
                      comments.map((comment) => (
                        <div key={comment.id} className="bg-gray-50 rounded-lg p-4">
                          <div className="flex items-center justify-between mb-2">
                            <span className="text-sm font-medium text-gray-900">
                              {comment.commenter_name}
                              <span className={`ml-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ${
                                comment.commenter_type === 'coordinator' 
                                  ? 'bg-blue-100 text-blue-800' 
                                  : 'bg-purple-100 text-purple-800'
                              }`}>
                                {comment.commenter_type === 'coordinator' ? 'Coordinator' : 'Business Owner'}
                              </span>
                            </span>
                            <span className="text-xs text-gray-500">{formatDate(comment.created_at)}</span>
                          </div>
                          <p className="text-sm text-gray-700">{comment.comment}</p>
                        </div>
                      ))
                    )}
                  </div>
                </div>

                {/* Status Actions for Coordinators */}
                {user?.role === 'coordinator' && (
                  <div>
                    <h4 className="text-lg font-medium text-gray-900 mb-4">Update Status</h4>
                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <span className="text-sm text-gray-700">Current Status:</span>
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(selectedApplication.status)}`}>
                          {selectedApplication.status.replace('_', ' ')}
                        </span>
                      </div>
                      
                      <div className="flex space-x-3">
                        <button
                          onClick={() => updateApplicationStatus(selectedApplication.id, 'under_review')}
                          disabled={submitting}
                          className="flex-1 px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
                        >
                          Under Review
                        </button>
                        <button
                          onClick={() => updateApplicationStatus(selectedApplication.id, 'qualified')}
                          disabled={submitting}
                          className="flex-1 px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50"
                        >
                          Accept
                        </button>
                        <button
                          onClick={() => updateApplicationStatus(selectedApplication.id, 'rejected')}
                          disabled={submitting}
                          className="flex-1 px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50"
                        >
                          Reject
                        </button>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
