import React, { useEffect, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { userAPI } from '../services/api';
import { 
  HomeIcon,
  BriefcaseIcon,
  BuildingOfficeIcon,
  UserIcon,
  Cog6ToothIcon,
  ArrowRightOnRectangleIcon,
  UserCircleIcon,
  DocumentTextIcon,
  Bars3Icon,
  XMarkIcon,
} from '@heroicons/react/24/outline';
import { clsx } from 'clsx';

interface LayoutProps {
  children: React.ReactNode;
}

interface NavbarInfo {
  firstName: string;
  lastName: string;
  profilePhotoUrl: string | null;
  email: string;
  role: string;
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [navbarInfo, setNavbarInfo] = useState<NavbarInfo | null>(null);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    if (user) {
      fetchNavbarInfo();
    }
  }, [user]);

  // Close mobile menu when route changes
  useEffect(() => {
    setIsMobileMenuOpen(false);
  }, [location.pathname]);

  const fetchNavbarInfo = async () => {
    try {
      const response = await userAPI.getNavbarInfo();
      setNavbarInfo(response.data);
    } catch (error) {
      console.error('Failed to fetch navbar info:', error);
    }
  };

  const handleLogout = () => {
    const confirmLogout = window.confirm(
      `Are you sure you want to logout from your ${user?.role || 'account'}?`
    );
    
    if (confirmLogout) {
      logout();
      navigate('/');
    }
  };

  const navigation = [
    { name: 'Home', href: '/', icon: HomeIcon },
    { name: 'Jobs', href: '/jobs', icon: BriefcaseIcon },
    { name: 'Our Team', href: '/companies', icon: BuildingOfficeIcon },
  ];

  const userNavigation = user
    ? [
        ...(user.role === 'user'
          ? [{ name: 'Resume Builder', href: '/resume-builder', icon: DocumentTextIcon }]
          : []),
        { name: 'Dashboard', href: '/dashboard', icon: Cog6ToothIcon },
        { 
          name: 'Profile', 
          href: user.role === 'coordinator' 
            ? '/coordinator/profile' 
            : user.role === 'company'
            ? '/company/profile'
            : '/profile', 
          icon: UserIcon 
        },
      ]
    : [];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            {/* Logo */}
            <Link to="/" className="flex items-center space-x-2">
              <div className="w-10 h-10 bg-primary-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-lg">ACC</span>
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">ACC</h1>
                <p className="text-xs text-gray-500 -mt-1">Asiatech Career Connect</p>
              </div>
            </Link>

            {/* Navigation */}
            <nav className="hidden md:flex items-center space-x-8">
              {navigation.map((item) => {
                const isActive = location.pathname === item.href;
                return (
                  <Link
                    key={item.name}
                    to={item.href}
                    className={clsx(
                      'flex items-center space-x-1 px-3 py-2 text-sm font-medium rounded-md transition-colors',
                      isActive
                        ? 'text-primary-600 bg-primary-50'
                        : 'text-gray-700 hover:text-primary-600 hover:bg-gray-100'
                    )}
                  >
                    <item.icon className="w-4 h-4" />
                    <span>{item.name}</span>
                  </Link>
                );
              })}
            </nav>

            {/* Mobile menu button */}
            <div className="md:hidden">
              <button
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                className="inline-flex items-center justify-center p-2 rounded-md text-gray-700 hover:text-primary-600 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500"
                aria-expanded="false"
              >
                <span className="sr-only">Open main menu</span>
                {isMobileMenuOpen ? (
                  <XMarkIcon className="block h-6 w-6" aria-hidden="true" />
                ) : (
                  <Bars3Icon className="block h-6 w-6" aria-hidden="true" />
                )}
              </button>
            </div>

            {/* User Menu */}
            <div className="hidden md:flex items-center space-x-4">
              {user ? (
                <div className="flex items-center space-x-4">
                  {/* User Navigation */}
                  <nav className="hidden md:flex items-center space-x-4">
                    {userNavigation.map((item) => {
                      const isActive = location.pathname === item.href;
                      return (
                        <Link
                          key={item.name}
                          to={item.href}
                          className={clsx(
                            'flex items-center space-x-1 px-3 py-2 text-sm font-medium rounded-md transition-colors',
                            isActive
                              ? 'text-primary-600 bg-primary-50'
                              : 'text-gray-700 hover:text-primary-600 hover:bg-gray-100'
                          )}
                        >
                          <item.icon className="w-4 h-4" />
                          <span>{item.name}</span>
                        </Link>
                      );
                    })}
                  </nav>

                  {/* User Info */}
                  <div className="flex items-center space-x-3 text-sm text-gray-700">
                    {/* Profile Photo */}
                    {navbarInfo?.profilePhotoUrl ? (
                      <img
                        src={navbarInfo.profilePhotoUrl}
                        alt="Profile"
                        className="w-8 h-8 rounded-full object-cover border border-gray-200"
                      />
                    ) : (
                      <UserCircleIcon className="w-8 h-8 text-gray-400" />
                    )}
                    
                    {/* User Name and Email */}
                    <div className="hidden sm:block">
                      {navbarInfo?.firstName && navbarInfo?.lastName ? (
                        <div>
                          <p className="font-medium text-gray-900">
                            {navbarInfo.firstName} {navbarInfo.lastName}
                          </p>
                          <p className="text-xs text-gray-500">{user.email}</p>
                        </div>
                      ) : (
                        <p className="text-gray-700">{user.email}</p>
                      )}
                    </div>
                    
                    <span className="px-2 py-1 text-xs font-medium text-primary-700 bg-primary-100 rounded-full">
                      {user.role.charAt(0).toUpperCase() + user.role.slice(1)}
                    </span>
                  </div>

                  {/* Logout */}
                  <button
                    onClick={handleLogout}
                    className="flex items-center space-x-1 px-3 py-2 text-sm font-medium text-red-600 hover:text-red-700 hover:bg-red-50 rounded-md transition-colors"
                  >
                    <ArrowRightOnRectangleIcon className="w-4 h-4" />
                    <span className="hidden sm:inline">Logout</span>
                  </button>
                </div>
              ) : (
                <div className="flex items-center space-x-4">
                  <Link
                    to="/login"
                    className="text-sm font-medium text-gray-700 hover:text-primary-600"
                  >
                    Login
                  </Link>
                  <Link
                    to="/register"
                    className="btn-primary text-sm"
                  >
                    Register
                  </Link>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMobileMenuOpen && (
          <div className="md:hidden bg-white border-t border-gray-200 shadow-lg">
            <div className="px-4 py-3 space-y-1">
              {/* Main Navigation */}
              {navigation.map((item) => {
                const isActive = location.pathname === item.href;
                return (
                  <Link
                    key={item.name}
                    to={item.href}
                    onClick={() => setIsMobileMenuOpen(false)}
                    className={clsx(
                      'flex items-center space-x-2 px-3 py-2 text-sm font-medium rounded-md',
                      isActive
                        ? 'text-primary-600 bg-primary-50'
                        : 'text-gray-700 hover:text-primary-600 hover:bg-gray-100'
                    )}
                  >
                    <item.icon className="w-4 h-4" />
                    <span>{item.name}</span>
                  </Link>
                );
              })}
              
              {/* Authenticated User Navigation */}
              {user && (
                <>
                  <div className="border-t border-gray-200 my-2"></div>
                  {userNavigation.map((item) => {
                    const isActive = location.pathname === item.href;
                    return (
                      <Link
                        key={item.name}
                        to={item.href}
                        onClick={() => setIsMobileMenuOpen(false)}
                        className={clsx(
                          'flex items-center space-x-2 px-3 py-2 text-sm font-medium rounded-md',
                          isActive
                            ? 'text-primary-600 bg-primary-50'
                            : 'text-gray-700 hover:text-primary-600 hover:bg-gray-100'
                        )}
                      >
                        <item.icon className="w-4 h-4" />
                        <span>{item.name}</span>
                      </Link>
                    );
                  })}
                  
                  {/* User Info Section */}
                  <div className="border-t border-gray-200 mt-2 pt-2">
                    <div className="flex items-center space-x-3 px-3 py-2">
                      {navbarInfo?.profilePhotoUrl ? (
                        <img
                          src={navbarInfo.profilePhotoUrl}
                          alt="Profile"
                          className="w-8 h-8 rounded-full object-cover border border-gray-200"
                        />
                      ) : (
                        <UserCircleIcon className="w-8 h-8 text-gray-400" />
                      )}
                      <div>
                        {navbarInfo?.firstName && navbarInfo?.lastName ? (
                          <p className="text-sm font-medium text-gray-900">
                            {navbarInfo.firstName} {navbarInfo.lastName}
                          </p>
                        ) : null}
                        <p className="text-xs text-gray-500">{user.email}</p>
                        <span className="inline-block mt-1 px-2 py-1 text-xs font-medium text-primary-700 bg-primary-100 rounded-full">
                          {user.role.charAt(0).toUpperCase() + user.role.slice(1)}
                        </span>
                      </div>
                    </div>
                    <button
                      onClick={() => {
                        handleLogout();
                        setIsMobileMenuOpen(false);
                      }}
                      className="w-full flex items-center space-x-2 px-3 py-2 text-sm font-medium text-red-600 hover:text-red-700 hover:bg-red-50 rounded-md"
                    >
                      <ArrowRightOnRectangleIcon className="w-4 h-4" />
                      <span>Logout</span>
                    </button>
                  </div>
                </>
              )}
              
              {/* Non-authenticated Navigation */}
              {!user && (
                <div className="border-t border-gray-200 mt-2 pt-2 space-y-1">
                  <Link
                    to="/login"
                    onClick={() => setIsMobileMenuOpen(false)}
                    className="block px-3 py-2 text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-100 rounded-md"
                  >
                    Login
                  </Link>
                  <Link
                    to="/register"
                    onClick={() => setIsMobileMenuOpen(false)}
                    className="block px-3 py-2 text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 rounded-md text-center"
                  >
                    Register
                  </Link>
                </div>
              )}
            </div>
          </div>
        )}
      </header>

      {/* Main Content */}
      <main className="flex-1">
        {children}
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="col-span-1 md:col-span-2">
              <div className="flex items-center space-x-2 mb-4">
                <div className="w-8 h-8 bg-primary-600 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold">ACC</span>
                </div>
                <span className="text-lg font-bold text-gray-900">Asiatech Career Connect</span>
              </div>
              <p className="text-gray-600 text-sm mb-4">
                Making job finding easier for OJT college students and alumni. Connect with opportunities that match your skills and career goals.
              </p>
              <p className="text-gray-500 text-xs">
                © 2024 Asiatech Career Connect. All rights reserved.
              </p>
            </div>

            <div>
              <h3 className="text-sm font-semibold text-gray-900 mb-4">Quick Links</h3>
              <ul className="space-y-2">
                <li><Link to="/jobs" className="text-sm text-gray-600 hover:text-primary-600">Browse Jobs</Link></li>
                <li><Link to="/companies" className="text-sm text-gray-600 hover:text-primary-600">Companies</Link></li>
                {user && user.role === 'user' && (
                  <li><Link to="/resume-builder" className="text-sm text-gray-600 hover:text-primary-600">Resume Builder</Link></li>
                )}
              </ul>
            </div>

            <div>
              <h3 className="text-sm font-semibold text-gray-900 mb-4">Support</h3>
              <ul className="space-y-2">
                <li><a href="#" className="text-sm text-gray-600 hover:text-primary-600">Help Center</a></li>
                <li><a href="#" className="text-sm text-gray-600 hover:text-primary-600">Contact Us</a></li>
                <li><a href="#" className="text-sm text-gray-600 hover:text-primary-600">Privacy Policy</a></li>
                <li><a href="#" className="text-sm text-gray-600 hover:text-primary-600">Terms of Service</a></li>
              </ul>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};
