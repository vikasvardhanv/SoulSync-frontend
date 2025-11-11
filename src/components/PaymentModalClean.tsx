import { useEffect, useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { Lock, Check, Star, Zap, Coins } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { paymentsAPI } from '../services/api';
import { useAuthStore } from '../stores/authStore';

const PaymentModalClean = () => {
  const [isProcessing, setIsProcessing] = useState(false);
  const [paymentError, setPaymentError] = useState('');
  const [paymentSuccess, setPaymentSuccess] = useState(false);
  const [paymentId, setPaymentId] = useState<string | null>(null);
  const [paymentStatus, setPaymentStatus] = useState<'pending' | 'completed' | 'failed'>('pending');
  const [promoCode, setPromoCode] = useState('');
  const [isRedeeming, setIsRedeeming] = useState(false);
  const [promoError, setPromoError] = useState('');
  const [promoApplied, setPromoApplied] = useState(false);
  const BASE_PRICE = 10.0;
  const price = promoApplied ? 0 : BASE_PRICE;
  const navigate = useNavigate();
  const { dispatch } = useApp();
  const { user } = useAuthStore();

  const pollIntervalRef = useRef<number | null>(null);
  const pollTimeoutRef = useRef<number | null>(null);

  // Check if user already has premium access on mount
  useEffect(() => {
    if (user?.hasPremium) {
      console.log('✅ User has premium access, redirecting to quiz');
      // User already has premium, skip payment modal and go to quiz
      dispatch({ type: 'SET_PAYMENT_STATUS', payload: true });
      navigate('/compatibility-quiz', { replace: true });
    }
  }, [user, navigate, dispatch]);

  useEffect(() => {
    return () => {
      if (pollIntervalRef.current) clearInterval(pollIntervalRef.current);
      if (pollTimeoutRef.current) clearTimeout(pollTimeoutRef.current);
    };
  }, []);

  const createNowPayment = async () => {
    try {
      setIsProcessing(true);
      setPaymentError('');
      // If promo is applied (price is $0), skip external provider and grant access immediately
      if (price <= 0) {
        setPaymentSuccess(true);
        dispatch({ type: 'SET_PAYMENT_STATUS', payload: true });
        setIsProcessing(false);
        setTimeout(() => navigate('/compatibility-quiz'), 800);
        return;
      }

      const response = await paymentsAPI.createPayment({
        price_amount: price,
        price_currency: 'USD',
        pay_currency: 'BTC',
        order_description: 'SoulSync AI Matchmaking - Limited Launch Offer',
      });
      const { payment_id, payment_url } = response.data.data || {};
      if (!payment_id) throw new Error('Payment ID missing');
      setPaymentId(payment_id);
      if (payment_url) window.open(payment_url, '_blank');
      startPolling(payment_id);
    } catch (error) {
      console.error('NOWPayments create error:', error);
      setPaymentError('Failed to create payment. Please try again.');
      setIsProcessing(false);
    }
  };

  const startPolling = (id: string) => {
    if (pollIntervalRef.current) clearInterval(pollIntervalRef.current);
    if (pollTimeoutRef.current) clearTimeout(pollTimeoutRef.current);
    pollIntervalRef.current = window.setInterval(async () => {
      try {
        const response = await paymentsAPI.getPaymentStatus(id);
        const status: string = response.data?.data?.status || '';
        if (['finished', 'confirmed', 'completed'].includes(status)) {
          setPaymentStatus('completed');
          setPaymentSuccess(true);
          dispatch({ type: 'SET_PAYMENT_STATUS', payload: true });
          if (pollIntervalRef.current) clearInterval(pollIntervalRef.current);
          setTimeout(() => navigate('/compatibility-quiz'), 1200);
        } else if (['failed', 'expired', 'cancelled'].includes(status)) {
          setPaymentStatus('failed');
          setPaymentError('Payment failed. Please try again.');
          setIsProcessing(false);
          if (pollIntervalRef.current) clearInterval(pollIntervalRef.current);
        }
      } catch (error) {
        console.error('Payment status check error:', error);
      }
    }, 5000);
    pollTimeoutRef.current = window.setTimeout(() => {
      if (pollIntervalRef.current) clearInterval(pollIntervalRef.current);
      if (paymentStatus === 'pending') {
        setPaymentError('Payment timeout. Please try again.');
        setIsProcessing(false);
      }
    }, 600000);
  };

  const applyPromo = async () => {
    try {
      setIsRedeeming(true);
      setPromoError('');
      if (!promoCode.trim()) {
        setPromoError('Please enter a promo code.');
        setIsRedeeming(false);
        return;
      }
      const { data } = await paymentsAPI.applyPromo(promoCode.trim());
      if (data?.success) {
        // Mark promo as applied; price becomes $0 and user can proceed without external payment
        setPromoApplied(true);
        setPaymentError('');
      } else {
        setPromoError(data?.message || 'Invalid promo code.');
      }
    } catch (e: any) {
      setPromoError(e?.response?.data?.message || 'Invalid promo code.');
    } finally {
      setIsRedeeming(false);
    }
  };

  if (paymentSuccess) {
    return (
      <div className="min-h-screen warm-gradient flex items-center justify-center p-4 relative overflow-hidden">
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-20 left-10 w-32 h-32 bg-coral-200 rounded-full opacity-20 animate-bounce-gentle"></div>
          <div className="absolute bottom-20 right-10 w-24 h-24 bg-mint-200 rounded-full opacity-30 animate-bounce-gentle" style={{ animationDelay: '1s' }}></div>
          <div className="absolute top-1/2 left-1/4 w-16 h-16 bg-peach-200 rounded-full opacity-25 animate-bounce-gentle" style={{ animationDelay: '2s' }}></div>
        </div>
        <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} className="w-full max-w-md text-center relative z-10">
          <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ delay: 0.2, type: 'spring' }} className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-mint-400 to-mint-600 rounded-full mb-6 shadow-coral">
            <Check className="w-10 h-10 text-white" />
          </motion.div>
          <h1 className="text-3xl font-bold text-warm-800 mb-4">Access Granted! 🎉</h1>
          <p className="text-warm-600 text-lg mb-6">Welcome to SoulSync Premium. Let's find your perfect match.</p>
          <motion.div animate={{ rotate: 360 }} transition={{ duration: 1, repeat: Infinity, ease: 'linear' }} className="inline-block w-8 h-8 border-2 border-coral-400 border-t-transparent rounded-full" />
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen warm-gradient flex items-center justify-center p-4 relative overflow-hidden">
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 w-32 h-32 bg-coral-200 rounded-full opacity-20 animate-bounce-gentle"></div>
        <div className="absolute bottom-20 right-10 w-24 h-24 bg-mint-200 rounded-full opacity-30 animate-bounce-gentle" style={{ animationDelay: '1s' }}></div>
        <div className="absolute top-1/3 right-1/4 w-20 h-20 bg-lavender-200 rounded-full opacity-20 animate-bounce-gentle" style={{ animationDelay: '0.5s' }}></div>
      </div>
      <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} className="w-full max-w-md relative z-10">
        <div className="text-center mb-8">
          <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ delay: 0.2, type: 'spring' }} className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-coral-400 to-peach-400 rounded-full mb-4 shadow-coral">
            <Lock className="w-10 h-10 text-white" />
          </motion.div>
          <h1 className="text-3xl font-bold text-warm-800 mb-2">Limited Launch Offer</h1>
          <p className="text-warm-600 mb-4">Unlock SoulSync AI Matchmaking & Premium Chat</p>
          <div className="bg-white/90 backdrop-blur-sm border border-coral-200 rounded-xl p-4 mb-6 shadow-soft">
            <div className="flex items-center justify-center gap-2 mb-2">
              <Star className="w-5 h-5 text-coral-500" fill="currentColor" />
              {promoApplied ? (
                <>
                  <span className="text-2xl font-bold text-mint-700">$0</span>
                  <span className="text-warm-400 line-through">${BASE_PRICE}</span>
                </>
              ) : (
                <>
                  <span className="text-2xl font-bold text-warm-800">${BASE_PRICE}</span>
                  <span className="text-warm-400 line-through">$29</span>
                </>
              )}
            </div>
            <p className="text-sm text-warm-600">We're invite-only. Your payment ensures real users & accurate matching.</p>
          </div>
        </div>
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }} className="bg-white/90 backdrop-blur-sm border border-peach-200 rounded-2xl p-6 mb-6 shadow-soft">
          <h3 className="text-lg font-semibold text-warm-800 mb-4 flex items-center gap-2">
            <Zap className="w-5 h-5 text-coral-500" />
            What You Get:
          </h3>
          <div className="space-y-3">
            {['AI-Powered Compatibility Matching','Unlimited Premium Chat Features','Advanced Personality Analysis','Smart Date Location Finder','Priority Match Recommendations'].map((feature, index) => (
              <motion.div key={feature} initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.6 + index * 0.1 }} className="flex items-center gap-3">
                <Check className="w-5 h-5 text-mint-500" />
                <span className="text-warm-700">{feature}</span>
              </motion.div>
            ))}
          </div>
        </motion.div>
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.8 }} className="bg-white/90 backdrop-blur-sm border border-mint-200 rounded-2xl p-6 shadow-soft">
          <div className="mb-6">
            <h3 className="text-lg font-semibold text-warm-800 mb-3">Have a promo code?</h3>
            <div className="flex gap-2">
              <input 
                type="text" 
                value={promoCode} 
                onChange={(e) => setPromoCode(e.target.value)} 
                placeholder="Enter code (e.g., soulsync101)"
                className="flex-1 px-4 py-3 border-2 border-warm-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-coral-400 focus:border-coral-400 bg-white text-warm-800 placeholder-warm-400" 
              />
              <button 
                onClick={applyPromo} 
                disabled={isRedeeming || !promoCode.trim()} 
                className="px-6 py-3 rounded-lg bg-gradient-to-r from-coral-500 to-peach-500 text-white font-bold hover:from-coral-600 hover:to-peach-600 disabled:opacity-50 disabled:cursor-not-allowed shadow-md hover:shadow-lg transition-all whitespace-nowrap"
              >
                {isRedeeming ? 'Applying...' : 'Apply'}
              </button>
            </div>
            {promoError && <p className="text-sm text-coral-600 mt-2 font-medium">{promoError}</p>}
            {promoApplied && <p className="text-sm text-mint-700 mt-2 font-semibold flex items-center gap-1">
              <Check className="w-4 h-4" />
              Promo code applied! Payment waived.
            </p>}
          </div>
          <div className="mb-6 border-t border-warm-100 pt-6">
            <h3 className="text-lg font-semibold text-warm-800 mb-3 flex items-center gap-2">
              <Coins className="w-5 h-5 text-coral-500" />
              Pay with Crypto
            </h3>
            <p className="text-sm text-warm-600 mb-4">Secure payment via NOWPayments. Opens an invoice in a new tab.</p>
            <motion.button whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }} onClick={createNowPayment} disabled={isProcessing} className="w-full bg-gradient-to-r from-coral-400 to-peach-400 text-white py-3 px-6 rounded-xl font-semibold disabled:opacity-50 disabled:cursor-not-allowed hover:shadow-coral transition-all flex items-center justify-center gap-2">
              <Coins className="w-5 h-5" />
              {isProcessing
                ? 'Processing...'
                : promoApplied
                ? 'Activate for $0'
                : `Pay $${BASE_PRICE} with Crypto`}
            </motion.button>
            {promoApplied && (
              <p className="text-xs text-mint-700 mt-2 text-center">Promo applied! Total due: $0</p>
            )}
          </div>
          {paymentError && (
            <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} className="bg-coral-100 border border-coral-300 rounded-lg p-3 mb-4">
              <p className="text-coral-700 text-sm font-medium">{paymentError}</p>
            </motion.div>
          )}
          {paymentId && (
            <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} className="bg-coral-50 border border-coral-200 rounded-lg p-3 mb-4">
              <div className="flex items-center gap-2 mb-2">
                <Coins className="w-4 h-4 text-coral-500" />
                <span className="text-coral-700 text-sm font-medium">Crypto Payment</span>
              </div>
              <p className="text-warm-700 text-sm">Payment page opened in new tab. Please complete payment there.</p>
              <p className="text-warm-500 text-xs mt-1">Status: {paymentStatus === 'pending' ? 'Waiting for payment...' : paymentStatus}</p>
            </motion.div>
          )}
          {isProcessing && (
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="mt-4 text-center">
              <motion.div animate={{ rotate: 360 }} transition={{ duration: 1, repeat: Infinity, ease: 'linear' }} className="inline-block w-5 h-5 border-2 border-coral-400 border-t-transparent rounded-full mr-2" />
              <span className="text-warm-600">Processing payment...</span>
            </motion.div>
          )}
          <div className="mt-4 text-center">
            <p className="text-xs text-warm-500 flex items-center justify-center gap-1">
              <Lock className="w-3 h-3" />
              Secured by NOWPayments & blockchain technology
            </p>
          </div>
        </motion.div>
        <div className="mt-4 text-center">
          <button onClick={() => navigate(-1)} className="text-warm-600 hover:text-warm-800 transition-colors text-sm font-medium">← Back to quiz</button>
        </div>
      </motion.div>
    </div>
  );
};

export default PaymentModalClean;