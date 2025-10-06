// frontend/src/components/ProfileEdit.tsx
import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import {
  ArrowLeft,
  User,
  MapPin,
  Calendar,
  Heart,
  Camera,
  Save,
  Plus,
  X
} from 'lucide-react';
import { useAuthStore } from '../stores/authStore';
import { usersAPI } from '../services/api';
import toast from 'react-hot-toast';
import ImageUpload from './ImageUpload';
import LocationSelector from './LocationSelector';

const ProfileEdit = () => {
  const navigate = useNavigate();
  const { user, updateUser } = useAuthStore();
  const [loading, setLoading] = useState(false);
  const [showImageUpload, setShowImageUpload] = useState(false);
  
  const [formData, setFormData] = useState({
    name: user?.name || '',
    age: user?.age || '',
    location: user?.location || '',
    city: user?.city || '',
    state: user?.state || '',
    country: user?.country || '',
    latitude: user?.latitude || null,
    longitude: user?.longitude || null,
    bio: user?.bio || '',
    interests: user?.interests || [],
    gender: user?.gender || '',
    lookingFor: user?.lookingFor || ''
  });
  
  const [newInterest, setNewInterest] = useState('');

  useEffect(() => {
    if (user) {
      setFormData({
        name: user.name || '',
        age: user.age || '',
        location: user.location || '',
        city: user.city || '',
        state: user.state || '',
        country: user.country || '',
        latitude: user.latitude || null,
        longitude: user.longitude || null,
        bio: user.bio || '',
        interests: user.interests || [],
        gender: user.gender || '',
        lookingFor: user.lookingFor || ''
      });
    }
  }, [user]);

  const handleAddInterest = () => {
    if (newInterest.trim() && formData.interests.length < 10) {
      setFormData({
        ...formData,
        interests: [...formData.interests, newInterest.trim()]
      });
      setNewInterest('');
    }
  };

  const handleRemoveInterest = (index: number) => {
    setFormData({
      ...formData,
      interests: formData.interests.filter((_, i) => i !== index)
    });
  };

  const handleSave = async () => {
    if (!formData.name.trim()) {
      toast.error('Name is required');
      return;
    }

    setLoading(true);
    try {
      const response = await usersAPI.updateProfile({
        name: formData.name,
        age: formData.age ? parseInt(formData.age.toString()) : undefined,
        location: formData.location,
        city: formData.city,
        state: formData.state,
        country: formData.country,
        latitude: formData.latitude,
        longitude: formData.longitude,
        bio: formData.bio,
        interests: formData.interests,
        gender: formData.gender,
        lookingFor: formData.lookingFor
      });

      if (response.data.success) {
        // Update user in auth store
        updateUser(response.data.data.user);
        toast.success('Profile updated successfully!');
        navigate('/dashboard');
      }
    } catch (error: any) {
      console.error('Error updating profile:', error);
      toast.error(error.response?.data?.message || 'Failed to update profile');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen warm-gradient">
      {/* Header */}
      <header className="bg-white/20 backdrop-blur-lg border-b border-white/30 sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <button
                onClick={() => navigate(-1)}
                className="p-2 hover:bg-white/20 rounded-full transition-colors"
              >
                <ArrowLeft className="w-6 h-6 text-warm-700" />
              </button>
              <div>
                <h1 className="text-2xl font-friendly font-bold text-warm-800">Edit Profile</h1>
                <p className="text-sm text-warm-600">Update your information</p>
              </div>
            </div>
            <button
              onClick={handleSave}
              disabled={loading}
              className="friendly-button px-6 py-2 flex items-center gap-2 disabled:opacity-50"
            >
              {loading ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  Saving...
                </>
              ) : (
                <>
                  <Save className="w-4 h-4" />
                  Save
                </>
              )}
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-4 py-8">
        <div className="space-y-6">
          {/* Profile Photo Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="friendly-card p-6"
          >
            <h2 className="text-xl font-bold text-warm-800 mb-4">Profile Photos</h2>
            
            <div className="flex flex-wrap gap-4">
              {user?.photos && user.photos.length > 0 ? (
                user.photos.map((photo, index) => (
                  <div key={index} className="relative group">
                    <img
                      src={photo}
                      alt={`Profile ${index + 1}`}
                      className="w-24 h-24 rounded-xl object-cover border-2 border-white shadow-sm"
                    />
                    <button
                      onClick={() => toast('Photo deletion coming soon', { icon: 'ℹ️' })}
                      className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                ))
              ) : (
                <div className="w-24 h-24 bg-gradient-to-br from-coral-400 to-peach-400 rounded-xl flex items-center justify-center">
                  <User className="w-12 h-12 text-white" />
                </div>
              )}
              
              <button
                onClick={() => setShowImageUpload(true)}
                className="w-24 h-24 border-2 border-dashed border-warm-300 rounded-xl hover:border-coral-400 hover:bg-coral-50 transition-colors flex flex-col items-center justify-center gap-1 text-warm-600 hover:text-coral-600"
              >
                <Plus className="w-6 h-6" />
                <span className="text-xs font-medium">Add Photo</span>
              </button>
            </div>
            
            <p className="text-sm text-warm-600 mt-3">
              Add up to 6 photos. Your first photo will be your main profile picture.
            </p>
          </motion.div>

          {/* Basic Information */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="friendly-card p-6"
          >
            <h2 className="text-xl font-bold text-warm-800 mb-4">Basic Information</h2>
            
            <div className="space-y-4">
              {/* Name */}
              <div>
                <label className="flex items-center gap-2 text-sm font-medium text-warm-700 mb-2">
                  <User className="w-4 h-4" />
                  Name *
                </label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 placeholder-warm-400 focus:outline-none focus:ring-2 focus:ring-coral-400"
                  placeholder="Enter your name"
                  required
                />
              </div>

              {/* Age */}
              <div>
                <label className="flex items-center gap-2 text-sm font-medium text-warm-700 mb-2">
                  <Calendar className="w-4 h-4" />
                  Age
                </label>
                <input
                  type="number"
                  value={formData.age}
                  onChange={(e) => setFormData({ ...formData, age: e.target.value })}
                  className="w-full px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 placeholder-warm-400 focus:outline-none focus:ring-2 focus:ring-coral-400"
                  placeholder="Enter your age"
                  min="18"
                  max="100"
                />
              </div>

              {/* Location */}
              <div>
                <label className="flex items-center gap-2 text-sm font-medium text-warm-700 mb-2">
                  <MapPin className="w-4 h-4" />
                  Location
                </label>
                <LocationSelector
                  value={{
                    city: formData.city,
                    state: formData.state,
                    country: formData.country,
                    latitude: formData.latitude || undefined,
                    longitude: formData.longitude || undefined
                  }}
                  onChange={(locationData) => {
                    setFormData({
                      ...formData,
                      city: locationData.city,
                      state: locationData.state,
                      country: locationData.country,
                      latitude: locationData.latitude,
                      longitude: locationData.longitude,
                      location: locationData.fullLocation // Keep for backward compatibility
                    });
                  }}
                  placeholder="Search for your city..."
                  className="w-full"
                />
              </div>

              {/* Gender */}
              <div>
                <label className="flex items-center gap-2 text-sm font-medium text-warm-700 mb-2">
                  <User className="w-4 h-4" />
                  Gender
                </label>
                <select
                  value={formData.gender}
                  onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
                  className="w-full px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 focus:outline-none focus:ring-2 focus:ring-coral-400"
                >
                  <option value="">Select gender</option>
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="non-binary">Non-binary</option>
                  <option value="other">Other</option>
                  <option value="prefer-not-to-say">Prefer not to say</option>
                </select>
              </div>

              {/* Looking For */}
              <div>
                <label className="flex items-center gap-2 text-sm font-medium text-warm-700 mb-2">
                  <Heart className="w-4 h-4" />
                  Looking For
                </label>
                <select
                  value={formData.lookingFor}
                  onChange={(e) => setFormData({ ...formData, lookingFor: e.target.value })}
                  className="w-full px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 focus:outline-none focus:ring-2 focus:ring-coral-400"
                >
                  <option value="">Select preference</option>
                  <option value="male">Men</option>
                  <option value="female">Women</option>
                  <option value="everyone">Everyone</option>
                </select>
              </div>
            </div>
          </motion.div>

          {/* Bio */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="friendly-card p-6"
          >
            <h2 className="text-xl font-bold text-warm-800 mb-4">About You</h2>
            
            <textarea
              value={formData.bio}
              onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
              rows={5}
              maxLength={500}
              className="w-full px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 placeholder-warm-400 focus:outline-none focus:ring-2 focus:ring-coral-400 resize-none"
              placeholder="Tell us about yourself... What makes you unique? What are you passionate about?"
            />
            <p className="text-sm text-warm-600 mt-2 text-right">
              {formData.bio.length}/500 characters
            </p>
          </motion.div>

          {/* Interests */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="friendly-card p-6"
          >
            <h2 className="text-xl font-bold text-warm-800 mb-4">Interests</h2>
            
            <div className="flex gap-2 mb-4">
              <input
                type="text"
                value={newInterest}
                onChange={(e) => setNewInterest(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleAddInterest()}
                className="flex-1 px-4 py-3 bg-white/50 border border-warm-200 rounded-xl text-warm-800 placeholder-warm-400 focus:outline-none focus:ring-2 focus:ring-coral-400"
                placeholder="Add an interest (e.g., Hiking, Photography)"
                maxLength={30}
              />
              <button
                onClick={handleAddInterest}
                disabled={!newInterest.trim() || formData.interests.length >= 10}
                className="px-6 py-3 bg-gradient-to-r from-coral-400 to-peach-400 text-white rounded-xl hover:shadow-coral transition-all font-medium disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Add
              </button>
            </div>

            <div className="flex flex-wrap gap-2">
              {formData.interests.map((interest, index) => (
                <span
                  key={index}
                  className="inline-flex items-center gap-2 px-4 py-2 bg-coral-50 text-coral-700 rounded-full text-sm font-medium"
                >
                  {interest}
                  <button
                    onClick={() => handleRemoveInterest(index)}
                    className="hover:bg-coral-100 rounded-full p-1 transition-colors"
                  >
                    <X className="w-3 h-3" />
                  </button>
                </span>
              ))}
            </div>

            {formData.interests.length === 0 && (
              <p className="text-sm text-warm-600 text-center py-8">
                No interests added yet. Add some to help others get to know you!
              </p>
            )}

            <p className="text-sm text-warm-600 mt-4">
              Add up to 10 interests. Maximum 30 characters per interest.
            </p>
          </motion.div>
        </div>
      </main>

      {/* Image Upload Modal */}
      {showImageUpload && (
        <ImageUpload onClose={() => setShowImageUpload(false)} />
      )}
    </div>
  );
};

export default ProfileEdit;
