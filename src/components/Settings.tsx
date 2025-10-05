// frontend/src/components/Settings.tsx
import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import {
  ArrowLeft,
  Bell,
  Lock,
  Eye,
  Globe,
  Moon,
  Sun,
  Shield,
  Mail,
  Heart,
  Users,
  MessageSquare,
  ChevronRight,
  Check
} from 'lucide-react';
import { useAuthStore } from '../stores/authStore';
import toast from 'react-hot-toast';

const Settings = () => {
  const navigate = useNavigate();
  const { user } = useAuthStore();
  
  // Settings State
  const [notifications, setNotifications] = useState({
    matches: true,
    messages: true,
    likes: true,
    email: false,
    push: true
  });
  
  const [privacy, setPrivacy] = useState({
    showAge: true,
    showLocation: true,
    showOnline: true,
    showDistance: true
  });
  
  const [preferences, setPreferences] = useState({
    darkMode: false,
    language: 'en',
    distanceUnit: 'km'
  });

  const handleSaveSettings = () => {
    // TODO: Save settings to backend
    toast.success('Settings saved successfully!');
  };

  return (
    <div className="min-h-screen warm-gradient">
      {/* Header */}
      <header className="bg-white/20 backdrop-blur-lg border-b border-white/30 sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate(-1)}
              className="p-2 hover:bg-white/20 rounded-full transition-colors"
            >
              <ArrowLeft className="w-6 h-6 text-warm-700" />
            </button>
            <div>
              <h1 className="text-2xl font-friendly font-bold text-warm-800">Settings</h1>
              <p className="text-sm text-warm-600">Manage your account preferences</p>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-4 py-8">
        <div className="space-y-6">
          {/* Account Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="friendly-card p-6"
          >
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-gradient-to-br from-coral-400 to-peach-400 rounded-full flex items-center justify-center">
                <Users className="w-5 h-5 text-white" />
              </div>
              <h2 className="text-xl font-bold text-warm-800">Account</h2>
            </div>
            
            <div className="space-y-3">
              <button
                onClick={() => navigate('/profile')}
                className="w-full flex items-center justify-between p-4 hover:bg-warm-50 rounded-xl transition-colors text-left"
              >
                <div className="flex items-center gap-3">
                  <Heart className="w-5 h-5 text-warm-600" />
                  <div>
                    <p className="font-medium text-warm-800">Edit Profile</p>
                    <p className="text-sm text-warm-600">Update your photos and bio</p>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-warm-400" />
              </button>
              
              <button
                onClick={() => toast('Password change coming soon', { icon: 'ℹ️' })}
                className="w-full flex items-center justify-between p-4 hover:bg-warm-50 rounded-xl transition-colors text-left"
              >
                <div className="flex items-center gap-3">
                  <Lock className="w-5 h-5 text-warm-600" />
                  <div>
                    <p className="font-medium text-warm-800">Change Password</p>
                    <p className="text-sm text-warm-600">Update your security credentials</p>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-warm-400" />
              </button>
            </div>
          </motion.div>

          {/* Notifications Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="friendly-card p-6"
          >
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-gradient-to-br from-mint-400 to-mint-500 rounded-full flex items-center justify-center">
                <Bell className="w-5 h-5 text-white" />
              </div>
              <h2 className="text-xl font-bold text-warm-800">Notifications</h2>
            </div>
            
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Heart className="w-5 h-5 text-warm-600" />
                  <div>
                    <p className="font-medium text-warm-800">New Matches</p>
                    <p className="text-sm text-warm-600">Get notified of new matches</p>
                  </div>
                </div>
                <button
                  onClick={() => setNotifications({ ...notifications, matches: !notifications.matches })}
                  className={`relative w-12 h-6 rounded-full transition-colors ${
                    notifications.matches ? 'bg-coral-400' : 'bg-warm-300'
                  }`}
                >
                  <div className={`absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform ${
                    notifications.matches ? 'translate-x-6' : ''
                  }`} />
                </button>
              </div>
              
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <MessageSquare className="w-5 h-5 text-warm-600" />
                  <div>
                    <p className="font-medium text-warm-800">Messages</p>
                    <p className="text-sm text-warm-600">Get notified of new messages</p>
                  </div>
                </div>
                <button
                  onClick={() => setNotifications({ ...notifications, messages: !notifications.messages })}
                  className={`relative w-12 h-6 rounded-full transition-colors ${
                    notifications.messages ? 'bg-coral-400' : 'bg-warm-300'
                  }`}
                >
                  <div className={`absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform ${
                    notifications.messages ? 'translate-x-6' : ''
                  }`} />
                </button>
              </div>
              
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Mail className="w-5 h-5 text-warm-600" />
                  <div>
                    <p className="font-medium text-warm-800">Email Notifications</p>
                    <p className="text-sm text-warm-600">Receive updates via email</p>
                  </div>
                </div>
                <button
                  onClick={() => setNotifications({ ...notifications, email: !notifications.email })}
                  className={`relative w-12 h-6 rounded-full transition-colors ${
                    notifications.email ? 'bg-coral-400' : 'bg-warm-300'
                  }`}
                >
                  <div className={`absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform ${
                    notifications.email ? 'translate-x-6' : ''
                  }`} />
                </button>
              </div>
            </div>
          </motion.div>

          {/* Privacy Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="friendly-card p-6"
          >
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-gradient-to-br from-lavender-400 to-purple-400 rounded-full flex items-center justify-center">
                <Shield className="w-5 h-5 text-white" />
              </div>
              <h2 className="text-xl font-bold text-warm-800">Privacy</h2>
            </div>
            
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Eye className="w-5 h-5 text-warm-600" />
                  <div>
                    <p className="font-medium text-warm-800">Show Age</p>
                    <p className="text-sm text-warm-600">Display your age on profile</p>
                  </div>
                </div>
                <button
                  onClick={() => setPrivacy({ ...privacy, showAge: !privacy.showAge })}
                  className={`relative w-12 h-6 rounded-full transition-colors ${
                    privacy.showAge ? 'bg-coral-400' : 'bg-warm-300'
                  }`}
                >
                  <div className={`absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform ${
                    privacy.showAge ? 'translate-x-6' : ''
                  }`} />
                </button>
              </div>
              
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Globe className="w-5 h-5 text-warm-600" />
                  <div>
                    <p className="font-medium text-warm-800">Show Location</p>
                    <p className="text-sm text-warm-600">Display your city on profile</p>
                  </div>
                </div>
                <button
                  onClick={() => setPrivacy({ ...privacy, showLocation: !privacy.showLocation })}
                  className={`relative w-12 h-6 rounded-full transition-colors ${
                    privacy.showLocation ? 'bg-coral-400' : 'bg-warm-300'
                  }`}
                >
                  <div className={`absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform ${
                    privacy.showLocation ? 'translate-x-6' : ''
                  }`} />
                </button>
              </div>
              
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Users className="w-5 h-5 text-warm-600" />
                  <div>
                    <p className="font-medium text-warm-800">Show Online Status</p>
                    <p className="text-sm text-warm-600">Let others see when you're active</p>
                  </div>
                </div>
                <button
                  onClick={() => setPrivacy({ ...privacy, showOnline: !privacy.showOnline })}
                  className={`relative w-12 h-6 rounded-full transition-colors ${
                    privacy.showOnline ? 'bg-coral-400' : 'bg-warm-300'
                  }`}
                >
                  <div className={`absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform ${
                    privacy.showOnline ? 'translate-x-6' : ''
                  }`} />
                </button>
              </div>
            </div>
          </motion.div>

          {/* Preferences Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="friendly-card p-6"
          >
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-gradient-to-br from-peach-400 to-yellow-400 rounded-full flex items-center justify-center">
                {preferences.darkMode ? <Moon className="w-5 h-5 text-white" /> : <Sun className="w-5 h-5 text-white" />}
              </div>
              <h2 className="text-xl font-bold text-warm-800">Preferences</h2>
            </div>
            
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  {preferences.darkMode ? <Moon className="w-5 h-5 text-warm-600" /> : <Sun className="w-5 h-5 text-warm-600" />}
                  <div>
                    <p className="font-medium text-warm-800">Dark Mode</p>
                    <p className="text-sm text-warm-600">Coming soon</p>
                  </div>
                </div>
                <button
                  onClick={() => {
                    setPreferences({ ...preferences, darkMode: !preferences.darkMode });
                    toast('Dark mode coming soon!', { icon: '🌙' });
                  }}
                  className={`relative w-12 h-6 rounded-full transition-colors ${
                    preferences.darkMode ? 'bg-coral-400' : 'bg-warm-300'
                  }`}
                >
                  <div className={`absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform ${
                    preferences.darkMode ? 'translate-x-6' : ''
                  }`} />
                </button>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-warm-700 mb-2">
                  Distance Unit
                </label>
                <select
                  value={preferences.distanceUnit}
                  onChange={(e) => setPreferences({ ...preferences, distanceUnit: e.target.value })}
                  className="w-full px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 focus:outline-none focus:ring-2 focus:ring-coral-400"
                >
                  <option value="km">Kilometers (km)</option>
                  <option value="mi">Miles (mi)</option>
                </select>
              </div>
            </div>
          </motion.div>

          {/* Save Button */}
          <motion.button
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            onClick={handleSaveSettings}
            className="w-full friendly-button py-4 font-semibold flex items-center justify-center gap-2"
          >
            <Check className="w-5 h-5" />
            Save Settings
          </motion.button>

          {/* Danger Zone */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
            className="friendly-card p-6 border-2 border-red-200"
          >
            <h3 className="text-lg font-bold text-red-600 mb-4">Danger Zone</h3>
            <div className="space-y-3">
              <button
                onClick={() => toast('Account deletion coming soon', { icon: '⚠️' })}
                className="w-full px-4 py-3 bg-red-50 text-red-600 rounded-xl hover:bg-red-100 transition-colors font-medium text-left"
              >
                Delete Account
              </button>
              <p className="text-sm text-warm-600">
                This action cannot be undone. All your data will be permanently deleted.
              </p>
            </div>
          </motion.div>
        </div>
      </main>
    </div>
  );
};

export default Settings;
