// frontend/src/components/MatchNotifications.tsx
import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Bell, X, Check, Heart, MessageCircle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';
import toast from 'react-hot-toast';

interface Notification {
  id: string;
  type: string;
  message: string;
  read: boolean;
  createdAt: string;
  fromUser?: {
    id: string;
    name: string;
    age: number;
    location: string;
    photos: string[];
    bio: string;
  };
  matchId?: string;
}

const MatchNotifications: React.FC = () => {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [showDropdown, setShowDropdown] = useState(false);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    fetchNotifications();
    fetchUnreadCount();

    // Poll for new notifications every 30 seconds
    const interval = setInterval(() => {
      fetchUnreadCount();
    }, 30000);

    return () => clearInterval(interval);
  }, []);

  const fetchNotifications = async () => {
    try {
      const response = await api.get('/notifications');
      if (response.data.success) {
        setNotifications(response.data.notifications);
      }
    } catch (error) {
      console.error('Error fetching notifications:', error);
    }
  };

  const fetchUnreadCount = async () => {
    try {
      const response = await api.get('/notifications/unread/count');
      if (response.data.success) {
        setUnreadCount(response.data.count);
      }
    } catch (error) {
      console.error('Error fetching unread count:', error);
    }
  };

  const handleMarkAsRead = async (notificationId: string) => {
    try {
      await api.patch(`/notifications/${notificationId}/read`);
      setNotifications(prev =>
        prev.map(n => n.id === notificationId ? { ...n, read: true } : n)
      );
      setUnreadCount(prev => Math.max(0, prev - 1));
    } catch (error) {
      console.error('Error marking notification as read:', error);
    }
  };

  const handleAcceptMatch = async (matchId: string, notificationId: string) => {
    if (loading) return;
    setLoading(true);

    try {
      const response = await api.put(`/matches/${matchId}/respond`, {
        action: 'accept'
      });

      if (response.data.success) {
        toast.success('Match accepted! You can now chat.');
        handleMarkAsRead(notificationId);
        
        // Navigate to chat with the conversation ID
        if (response.data.conversationId) {
          navigate(`/chat/${response.data.conversationId}`);
        } else {
          navigate('/dashboard?tab=matches');
        }
      }
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Failed to accept match');
    } finally {
      setLoading(false);
    }
  };

  const handleRejectMatch = async (matchId: string, notificationId: string) => {
    if (loading) return;
    setLoading(true);

    try {
      const response = await api.put(`/matches/${matchId}/respond`, {
        action: 'reject'
      });

      if (response.data.success) {
        toast.success('Match declined');
        handleMarkAsRead(notificationId);
        fetchNotifications();
      }
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Failed to decline match');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteNotification = async (notificationId: string) => {
    try {
      await api.delete(`/notifications/${notificationId}`);
      setNotifications(prev => prev.filter(n => n.id !== notificationId));
      fetchUnreadCount();
    } catch (error) {
      console.error('Error deleting notification:', error);
    }
  };

  return (
    <div className="relative">
      {/* Notification Bell Button */}
      <button
        onClick={() => setShowDropdown(!showDropdown)}
        className="relative p-2 rounded-full hover:bg-white/20 transition-colors"
      >
        <Bell className="w-6 h-6 text-warm-700" />
        {unreadCount > 0 && (
          <span className="absolute -top-1 -right-1 w-5 h-5 bg-coral-500 text-white text-xs rounded-full flex items-center justify-center font-bold">
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {/* Notifications Dropdown */}
      <AnimatePresence>
        {showDropdown && (
          <motion.div
            initial={{ opacity: 0, y: 10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 10, scale: 0.95 }}
            className="absolute right-0 mt-2 w-96 max-h-[500px] overflow-y-auto bg-white rounded-2xl shadow-2xl border border-warm-100 z-50"
          >
            {/* Header */}
            <div className="sticky top-0 bg-white border-b border-warm-100 p-4 rounded-t-2xl">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-bold text-warm-800">Notifications</h3>
                <button
                  onClick={() => setShowDropdown(false)}
                  className="p-1 hover:bg-warm-100 rounded-full transition-colors"
                >
                  <X className="w-5 h-5 text-warm-600" />
                </button>
              </div>
            </div>

            {/* Notifications List */}
            <div className="divide-y divide-warm-100">
              {notifications.length === 0 ? (
                <div className="p-8 text-center text-warm-500">
                  <Bell className="w-12 h-12 mx-auto mb-3 opacity-50" />
                  <p>No notifications yet</p>
                </div>
              ) : (
                notifications.map((notification) => (
                  <motion.div
                    key={notification.id}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    className={`p-4 ${!notification.read ? 'bg-coral-50' : 'bg-white'}`}
                  >
                    <div className="flex gap-3">
                      {/* User Avatar */}
                      {notification.fromUser && notification.fromUser.photos?.[0] ? (
                        <img
                          src={notification.fromUser.photos[0]}
                          alt={notification.fromUser.name}
                          className="w-12 h-12 rounded-full object-cover border-2 border-white shadow-sm"
                        />
                      ) : (
                        <div className="w-12 h-12 rounded-full bg-gradient-to-br from-coral-400 to-peach-400 flex items-center justify-center">
                          <Heart className="w-6 h-6 text-white" />
                        </div>
                      )}

                      {/* Notification Content */}
                      <div className="flex-1">
                        <p className="text-warm-800 text-sm font-medium mb-1">
                          {notification.message}
                        </p>
                        <p className="text-xs text-warm-500">
                          {new Date(notification.createdAt).toLocaleDateString('en-US', {
                            month: 'short',
                            day: 'numeric',
                            hour: 'numeric',
                            minute: '2-digit'
                          })}
                        </p>

                        {/* Match Request Actions */}
                        {notification.type === 'match_request' && notification.matchId && (
                          <div className="flex gap-2 mt-3">
                            <button
                              onClick={() => handleAcceptMatch(notification.matchId!, notification.id)}
                              disabled={loading}
                              className="flex-1 flex items-center justify-center gap-1 px-3 py-2 bg-gradient-to-r from-coral-400 to-peach-400 text-white rounded-lg hover:shadow-coral transition-all text-sm font-medium disabled:opacity-50"
                            >
                              <Check className="w-4 h-4" />
                              Accept
                            </button>
                            <button
                              onClick={() => handleRejectMatch(notification.matchId!, notification.id)}
                              disabled={loading}
                              className="flex-1 flex items-center justify-center gap-1 px-3 py-2 bg-warm-100 text-warm-700 rounded-lg hover:bg-warm-200 transition-all text-sm font-medium disabled:opacity-50"
                            >
                              <X className="w-4 h-4" />
                              Decline
                            </button>
                          </div>
                        )}

                        {/* Match Accepted - Go to Chat */}
                        {notification.type === 'match_accepted' && (
                          <button
                            onClick={() => {
                              handleMarkAsRead(notification.id);
                              navigate('/dashboard?tab=messages');
                            }}
                            className="flex items-center gap-1 mt-3 px-3 py-2 bg-gradient-to-r from-mint-400 to-mint-500 text-white rounded-lg hover:shadow-lg transition-all text-sm font-medium"
                          >
                            <MessageCircle className="w-4 h-4" />
                            Start Chatting
                          </button>
                        )}
                      </div>

                      {/* Delete Button */}
                      <button
                        onClick={() => handleDeleteNotification(notification.id)}
                        className="p-1 hover:bg-warm-100 rounded transition-colors self-start"
                      >
                        <X className="w-4 h-4 text-warm-400" />
                      </button>
                    </div>
                  </motion.div>
                ))
              )}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default MatchNotifications;
