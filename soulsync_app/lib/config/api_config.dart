import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5001/api';
    }
    return 'http://localhost:5001/api'; 
  }
  // static const String baseUrl = 'https://soulsync.solutions/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String getMe = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String deleteAccount = '/auth/delete-account';

  // User endpoints
  static const String userProfile = '/users/profile';
  static const String potentialMatches = '/users/matches';
  static const String myMatches = '/users/matches/my';

  // Question endpoints
  static const String questions = '/questions';
  static String questionById(String id) => '/questions/$id';
  static String randomQuestions(int count) => '/questions/random/$count';
  static String submitAnswer(String questionId) => '/questions/$questionId/answer';
  static const String myAnswers = '/questions/answers/me';
  static String questionsByCategory(String category) => '/questions/category/$category';

  // Match endpoints
  static const String matches = '/matches';
  static String matchDetails(String id) => '/matches/$id';
  static String updateMatchStatus(String id) => '/matches/$id/status';
  static const String pendingMatches = '/matches/pending';
  static const String acceptedMatches = '/matches/accepted';

  // Message endpoints
  static const String conversations = '/messages/conversations';
  static String conversation(String userId) => '/messages/conversation/$userId';
  static const String sendMessage = '/messages';
  static String markAsRead(String senderId) => '/messages/read/$senderId';
  static const String unreadCount = '/messages/unread/count';
  static String deleteMessage(String id) => '/messages/$id';

  // Image endpoints
  static const String uploadImage = '/images/upload';
  static const String uploadMultipleImages = '/images/upload-multiple';
  static const String deleteImage = '/images/delete';
  static const String reorderImages = '/images/reorder';
  static String renderImage(String id) => '$baseUrl/images/render/$id';

  // Payment endpoints
  static const String paymentCurrencies = '/payments/currencies';
  static const String paymentEstimate = '/payments/estimate';
  static const String createPayment = '/payments/create';
  static String paymentStatus(String id) => '/payments/status/$id';
  static const String createSubscription = '/payments/subscription';
  static const String paymentHistory = '/payments/history';
  static const String applyPromo = '/payments/promo';

  // Subscription endpoints
  static const String mySubscription = '/subscriptions/me';
  static const String subscriptions = '/subscriptions';
  static const String cancelSubscription = '/subscriptions/cancel';
  static const String premiumCheck = '/subscriptions/premium/check';

  // Location endpoints
  static const String cities = '/locations/cities';
  static String citiesByCountry(String country) => '/locations/cities/country/$country';
  static const String nearbyCities = '/locations/cities/nearby';
  static const String locationStats = '/locations/stats';

  // Notification endpoints
  static const String notifications = '/notifications';
}
