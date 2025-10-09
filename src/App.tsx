import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider } from './contexts/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { Layout } from './components/Layout';

// Pages
import { Home } from './pages/Home';
import { Login } from './pages/auth/Login';
import { Register } from './pages/auth/Register';
import { AdminRegister } from './pages/auth/AdminRegister';
import { AdminCompleteProfile } from './pages/AdminCompleteProfile';
import { AdminPendingApproval } from './pages/AdminPendingApproval';
import { CoordinatorCompleteProfile } from './pages/CoordinatorCompleteProfile';
import { CoordinatorPendingApproval } from './pages/CoordinatorPendingApproval';
import { CoordinatorProfile } from './pages/CoordinatorProfile';
import { CoordinatorDashboard } from './pages/CoordinatorDashboard';
import { CreateJob } from './pages/CreateJob';
import { CoordinatorManageJobs } from './pages/coordinator/CoordinatorManageJobs';
import { CoordinatorEditJob } from './pages/coordinator/CoordinatorEditJob';
import { CoordinatorInviteCompany } from './pages/coordinator/CoordinatorInviteCompany';
import { ReviewApplications } from './pages/ReviewApplications';
import { VerifyOTP } from './pages/auth/VerifyOTP';
import { Dashboard } from './pages/Dashboard';
import { Profile } from './pages/Profile';
import { CompleteProfile } from './pages/CompleteProfile';
import { Jobs } from './pages/Jobs';
import { JobDetails } from './pages/JobDetails';
import { JobApplication } from './pages/JobApplication';
import { Companies } from './pages/Companies';
import { CompanyDetails } from './pages/CompanyDetails';
import { ResumeBuilder } from './pages/ResumeBuilder';
import { ResumeTemplateSelection } from './pages/ResumeTemplateSelection';
import { ResumeEditor } from './pages/ResumeEditor';
import { AdminDashboard } from './pages/admin/AdminDashboard';
import { NotFound } from './pages/NotFound';

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="min-h-screen bg-gray-50">
          <Routes>
            {/* Public Routes */}
            <Route path="/" element={<Layout><Home /></Layout>} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
          <Route path="/admin/register" element={<AdminRegister />} />
          <Route path="/admin/complete-profile" element={<AdminCompleteProfile />} />
          <Route path="/admin/pending-approval" element={<AdminPendingApproval />} />
          <Route path="/coordinator/complete-profile" element={<CoordinatorCompleteProfile />} />
          <Route path="/coordinator/pending-approval" element={<CoordinatorPendingApproval />} />
          <Route 
            path="/coordinator/profile" 
            element={
              <ProtectedRoute allowedRoles={['coordinator']}>
                <Layout><CoordinatorProfile /></Layout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/coordinator/dashboard" 
            element={
              <ProtectedRoute allowedRoles={['coordinator']}>
                <Layout><CoordinatorDashboard /></Layout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/coordinator/jobs/create" 
            element={
              <ProtectedRoute allowedRoles={['coordinator']}>
                <Layout><CreateJob /></Layout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/coordinator/jobs" 
            element={
              <ProtectedRoute allowedRoles={['coordinator']}>
                <Layout><CoordinatorManageJobs /></Layout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/coordinator/jobs/:id/edit"
            element={
              <ProtectedRoute allowedRoles={['coordinator']}>
                <Layout><CoordinatorEditJob /></Layout>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/coordinator/invite-company"
            element={
              <ProtectedRoute allowedRoles={['coordinator']}>
                <Layout><CoordinatorInviteCompany /></Layout>
              </ProtectedRoute>
            } 
          />
            <Route path="/verify-otp" element={<VerifyOTP />} />
            <Route path="/jobs" element={<Layout><Jobs /></Layout>} />
            <Route path="/jobs/:id" element={<Layout><JobDetails /></Layout>} />
            <Route 
              path="/jobs/:id/apply" 
              element={
                <ProtectedRoute allowedRoles={['user']}>
                  <Layout><JobApplication /></Layout>
                </ProtectedRoute>
              } 
            />
            <Route 
              path="/jobs/:id/applications" 
              element={
                <ProtectedRoute allowedRoles={['coordinator', 'company']}>
                  <Layout><ReviewApplications /></Layout>
                </ProtectedRoute>
              } 
            />
            <Route path="/companies" element={<Layout><Companies /></Layout>} />
            <Route path="/companies/:id" element={<Layout><CompanyDetails /></Layout>} />

            {/* Protected Routes */}
            <Route 
              path="/dashboard" 
              element={
                <ProtectedRoute>
                  <Layout><Dashboard /></Layout>
                </ProtectedRoute>
              } 
            />
            <Route 
              path="/profile" 
              element={
                <ProtectedRoute>
                  <Layout><Profile /></Layout>
                </ProtectedRoute>
              } 
            />
            <Route 
              path="/complete-profile" 
              element={
                <ProtectedRoute>
                  <Layout><CompleteProfile /></Layout>
                </ProtectedRoute>
              } 
            />
            <Route 
              path="/resume-builder" 
              element={
                <ProtectedRoute allowedRoles={['user']}>
                  <Layout><ResumeBuilder /></Layout>
                </ProtectedRoute>
              } 
            />
            <Route 
              path="/resume-builder/templates" 
              element={
                <ProtectedRoute allowedRoles={['user']}>
                  <Layout><ResumeTemplateSelection /></Layout>
                </ProtectedRoute>
              } 
            />
            <Route 
              path="/resume-builder/edit/:id" 
              element={
                <ProtectedRoute allowedRoles={['user']}>
                  <ResumeEditor />
                </ProtectedRoute>
              } 
            />

            {/* Admin Routes */}
            <Route 
              path="/admin/*" 
              element={
                <ProtectedRoute allowedRoles={['admin']}>
                  <AdminDashboard />
                </ProtectedRoute>
              } 
            />

            {/* 404 Route */}
            <Route path="*" element={<Layout><NotFound /></Layout>} />
          </Routes>

          <Toaster 
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#16a34a',
                color: '#fff',
              },
              success: {
                style: {
                  background: '#16a34a',
                },
              },
              error: {
                style: {
                  background: '#ef4444',
                },
              },
            }}
          />
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
