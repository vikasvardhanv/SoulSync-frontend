import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { 
  Heart, 
  User, 
  Settings, 
  LogOut, 
  MessageCircle, 
  Users, 
  Bell,
  Search
} from 'lucide-react';
import { useAuthStore } from '../stores/authStore';
import MatchNotifications from './MatchNotifications';

const Dashboard = () => {
  const [activeTab, setActiveTab] = useState('discover');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { user, signOut } = useAuthStore();

  // Debug logging
  console.log('Dashboard render - User:', user);
  console.log('Dashboard render - Loading:', loading);

  useEffect(() => {
    console.log('Dashboard useEffect - User:', user);
    if (!user) {
      console.log('No user found, redirecting to login');
      navigate('/login');
      return;
    }
  }, [user, navigate]);

  const handleLogout = async () => {
    console.log('Logout clicked');
    await signOut();
    navigate('/');
  };

  if (!user) {
    console.log('Rendering loading state - no user');
    return (
      <div className="min-h-screen warm-gradient flex items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-coral-500"></div>
          <p className="text-warm-600">Loading user data...</p>
        </div>
      </div>
    );
  }

  console.log('Rendering main dashboard');

  return (
    <div className="min-h-screen warm-gradient">
      {/* Header */}
      <header className="bg-white/20 backdrop-blur-lg border-b border-white/30">
        <div className="max-w-6xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-r from-coral-400 to-peach-400 rounded-full flex items-center justify-center shadow-coral">
                <Heart className="w-6 h-6 text-white" />
              </div>
              <span className="text-xl font-friendly font-bold text-warm-800">SoulSync</span>
            </div>

            {/* Navigation */}
            <nav className="hidden md:flex items-center space-x-8">
              <button
                onClick={() => setActiveTab('discover')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-all font-medium ${
                  activeTab === 'discover' 
                    ? 'bg-coral-400 text-white shadow-coral' 
                    : 'text-warm-700 hover:text-warm-900 hover:bg-white/20'
                }`}
              >
                <Search className="w-5 h-5" />
                <span>Discover</span>
              </button>
              
              <button
                onClick={() => setActiveTab('matches')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-all font-medium ${
                  activeTab === 'matches' 
                    ? 'bg-coral-400 text-white shadow-coral' 
                    : 'text-warm-700 hover:text-warm-900 hover:bg-white/20'
                }`}
              >
                <Users className="w-5 h-5" />
                <span>Matches</span>
              </button>
              
              <button
                onClick={() => setActiveTab('messages')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-all font-medium ${
                  activeTab === 'messages' 
                    ? 'bg-coral-400 text-white shadow-coral' 
                    : 'text-warm-700 hover:text-warm-900 hover:bg-white/20'
                }`}
              >
                <MessageCircle className="w-5 h-5" />
                <span>Messages</span>
              </button>
            </nav>

            {/* User Menu */}
            <div className="flex items-center space-x-4">
              <MatchNotifications />
              
              <div className="relative group">
                <button className="flex items-center space-x-2 p-2 rounded-lg hover:bg-white/20 transition-all">
                  <div className="w-8 h-8 bg-gradient-to-r from-coral-400 to-peach-400 rounded-full flex items-center justify-center shadow-coral">
                    <User className="w-4 h-4 text-white" />
                  </div>
                  <span className="text-warm-800 font-medium hidden md:block">{user.name || 'User'}</span>
                </button>
                
                {/* Dropdown Menu */}
                <div className="absolute right-0 mt-2 w-48 friendly-card border border-white/30 shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all z-50">
                  <div className="py-2">
                    <button
                      onClick={() => navigate('/profile')}
                      className="w-full flex items-center space-x-2 px-4 py-2 text-warm-700 hover:text-warm-900 hover:bg-white/20 transition-all"
                    >
                      <User className="w-4 h-4" />
                      <span>Profile</span>
                    </button>
                    <button
                      onClick={() => navigate('/settings')}
                      className="w-full flex items-center space-x-2 px-4 py-2 text-warm-700 hover:text-warm-900 hover:bg-white/20 transition-all"
                    >
                      <Settings className="w-4 h-4" />
                      <span>Settings</span>
                    </button>
                    <button
                      onClick={handleLogout}
                      className="w-full flex items-center space-x-2 px-4 py-2 text-red-600 hover:text-red-700 hover:bg-red-50 transition-all"
                    >
                      <LogOut className="w-4 h-4" />
                      <span>Sign Out</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-4 py-8">
        {activeTab === 'discover' && (
          <div className="space-y-6">
            {/* User Profile Card */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="friendly-card p-6"
            >
              <div className="flex flex-col md:flex-row gap-6">
                {/* Profile Picture */}
                <div className="flex-shrink-0">
                  {user.photos && user.photos.length > 0 && user.photos[0] ? (
                    <img
                      src={user.photos[0]}
                      alt={user.name}
                      className="w-32 h-32 rounded-2xl object-cover shadow-coral border-4 border-white"
                    />
                  ) : (
                    <div className="w-32 h-32 bg-gradient-to-br from-coral-400 to-peach-400 rounded-2xl flex items-center justify-center shadow-coral">
                      <User className="w-16 h-16 text-white" />
                    </div>
                  )}
                </div>

                {/* Profile Info */}
                <div className="flex-grow">
                  <div className="flex items-start justify-between">
                    <div>
                      <h2 className="text-2xl font-friendly font-bold text-warm-800">{user.name || 'Unknown User'}</h2>
                      <p className="text-warm-600 mt-1">
                        {user.age ? `${user.age} years old` : 'Age not set'} • {user.location || 'Location not set'}
                      </p>
                    </div>
                    <button
                      onClick={() => navigate('/profile')}
                      className="px-4 py-2 bg-white/50 hover:bg-white/80 text-warm-700 rounded-lg transition-all font-medium border border-warm-200"
                    >
                      Edit Profile
                    </button>
                  </div>
                  
                  <p className="text-warm-700 mt-4">{user.bio || 'No bio yet. Tell others about yourself!'}</p>
                  
                  {/* Interests */}
                  {user.interests && user.interests.length > 0 && (
                    <div className="mt-4">
                      <h3 className="text-sm font-semibold text-warm-600 mb-2">Interests</h3>
                      <div className="flex flex-wrap gap-2">
                        {user.interests.map((interest, index) => (
                          <span
                            key={index}
                            className="px-3 py-1 bg-coral-50 text-coral-700 rounded-full text-sm font-medium"
                          >
                            {interest}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Photo Gallery */}
                  {user.photos && user.photos.length > 1 && (
                    <div className="mt-4">
                      <h3 className="text-sm font-semibold text-warm-600 mb-2">Photos</h3>
                      <div className="flex gap-2 overflow-x-auto pb-2">
                        {user.photos.slice(1).map((photo, index) => (
                          <img
                            key={index}
                            src={photo}
                            alt={`${user.name} - ${index + 2}`}
                            className="w-20 h-20 rounded-lg object-cover border-2 border-white shadow-sm"
                          />
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </motion.div>

            {/* Welcome Message */}
            <div className="friendly-card p-8 text-center">
              <h3 className="text-2xl font-friendly font-bold text-warm-800 mb-4">Welcome to SoulSync!</h3>
              <p className="text-warm-600 mb-6">Your dashboard is loading. Soon you'll be able to discover amazing matches!</p>
              <button
                onClick={() => navigate('/personality-quiz')}
                className="friendly-button px-6 py-3 font-medium"
              >
                Take Personality Quiz
              </button>
            </div>
          </div>
        )}

        {activeTab === 'matches' && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center py-20"
          >
            <div className="friendly-card p-12 max-w-2xl mx-auto">
              <div className="w-20 h-20 bg-gradient-to-br from-coral-400 to-peach-400 rounded-full flex items-center justify-center mx-auto mb-6">
                <Heart className="w-10 h-10 text-white" />
              </div>
              <h2 className="text-3xl font-friendly font-bold text-warm-800 mb-4">Your Matches</h2>
              
              {user.personalityScore !== undefined && user.personalityScore > 0 ? (
                <>
                  <div className="mb-6">
                    <div className="inline-flex items-center gap-3 bg-gradient-to-r from-coral-50 to-peach-50 px-6 py-3 rounded-full border-2 border-coral-200">
                      <div className="text-3xl font-bold text-coral-600">{user.personalityScore}%</div>
                      <div className="text-left">
                        <p className="text-sm font-semibold text-warm-700">Personality Profile</p>
                        <p className="text-xs text-warm-600">{user.questionsAnswered || 0} questions answered</p>
                      </div>
                    </div>
                  </div>
                  
                  <p className="text-warm-600 mb-6 text-lg">
                    {user.personalityScore >= 80 
                      ? "Great profile! You're ready to find amazing matches."
                      : user.personalityScore >= 50
                      ? "Good start! Answer more questions to improve your match quality."
                      : "Let's build your personality profile for better matches!"}
                  </p>
                  
                  <p className="text-warm-600 mb-8">
                    {user.personalityScore >= 80 
                      ? "Our AI is finding your best matches based on deep compatibility analysis."
                      : "The more questions you answer, the better we can find your perfect match. Each answer helps our AI understand you better!"}
                  </p>
                  
                  <button
                    onClick={() => navigate('/personality-quiz')}
                    className="friendly-button px-8 py-4 font-semibold text-lg"
                  >
                    {user.personalityScore >= 80 
                      ? "Refine My Profile" 
                      : user.personalityScore >= 50
                      ? "Answer More Questions"
                      : "Build My Personality Profile"}
                  </button>
                  
                  {user.personalityScore < 80 && (
                    <p className="text-sm text-warm-500 mt-4">
                      💡 Tip: Answer {Math.ceil((50 - (user.questionsAnswered || 0)) * 0.8)} more questions to reach 80% and unlock premium matches!
                    </p>
                  )}
                </>
              ) : (
                <>
                  <p className="text-warm-600 mb-8 text-lg">Start building your personality profile to discover compatible matches!</p>
                  <button
                    onClick={() => navigate('/personality-quiz')}
                    className="friendly-button px-8 py-4 font-semibold text-lg"
                  >
                    Take Personality Quiz
                  </button>
                </>
              )}
            </div>
          </motion.div>
        )}

        {activeTab === 'messages' && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center py-20"
          >
            <div className="friendly-card p-12 max-w-2xl mx-auto">
              <div className="w-20 h-20 bg-gradient-to-br from-mint-400 to-mint-500 rounded-full flex items-center justify-center mx-auto mb-6">
                <MessageCircle className="w-10 h-10 text-white" />
              </div>
              <h2 className="text-3xl font-friendly font-bold text-warm-800 mb-4">Messages</h2>
              <p className="text-warm-600 mb-4 text-lg">No conversations yet!</p>
              <p className="text-warm-600 mb-8">Once you match with someone and they accept, you'll be able to chat here.</p>
              <button
                onClick={() => setActiveTab('discover')}
                className="friendly-button px-8 py-4 font-semibold text-lg"
              >
                Find Matches
              </button>
            </div>
          </motion.div>
        )}
      </main>
    </div>
  );
};

export default Dashboard;