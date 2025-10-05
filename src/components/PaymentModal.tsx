import { useState } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { Lock, Check, Star, Zap, CreditCard, TestTube, Bitcoin, Coins } from 'lucide-react';
import { PayPalScriptProvider, PayPalButtons } from '@paypal/react-paypal-js';
import { useApp } from '../context/AppContext';
import { paymentsAPI } from '../services/api';
import NOWPaymentsButton from './NOWPaymentsButton';

const PaymentModal = () => {
  const [isProcessing, setIsProcessing] = useState(false);
  const [paymentError, setPaymentError] = useState('');
  const [paymentSuccess, setPaymentSuccess] = useState(false);
  const [paymentMethod, setPaymentMethod] = useState<'crypto' | 'paypal' | 'nowpayments' | 'demo'>('crypto');
  const [paymentId, setPaymentId] = useState<string | null>(null);
  const [paymentStatus, setPaymentStatus] = useState<'pending' | 'completed' | 'failed'>('pending');
  const navigate = useNavigate();
  const { dispatch } = useApp();

  // PayPal configuration
  const paypalOptions = {
    clientId: import.meta.env.VITE_PAYPAL_CLIENT_ID || "AZDxjDScFpQtjWTOUtWKbyN_bDt4OgqaF4eYXlewfBP4-8aqX3PiV8e1GWU6liB2CUXlkA59kJXE7M6R",
    currency: "USD",
    intent: "capture"
  };

  // Create crypto payment
  const createCryptoPayment = async () => {
    try {
      setIsProcessing(true);
      setPaymentError('');
      
      const response = await paymentsAPI.createPayment({
        amount: 10.00,
        currency: 'USD',
        description: 'SoulSync AI Matchmaking - Limited Launch Offer'
      });

      const { payment } = response.data.data;
      setPaymentId(payment.id);

      // Open Coinbase Commerce payment page
      if (payment.hostedUrl) {
        window.open(payment.hostedUrl, '_blank');
      }

      // Start polling for payment status
      pollPaymentStatus(payment.id);
      
    } catch (error) {
      console.error('Crypto payment creation error:', error);
      setPaymentError('Failed to create payment. Please try again.');
      setIsProcessing(false);
    }
  };

  // Poll payment status
  const pollPaymentStatus = async (id: string) => {
    const pollInterval = setInterval(async () => {
      try {
        const response = await paymentsAPI.getPaymentStatus(id);
        const { payment } = response.data.data;
        
        if (payment.status === 'completed') {
          setPaymentStatus('completed');
          setPaymentSuccess(true);
          dispatch({ type: 'SET_PAYMENT_STATUS', payload: true });
          clearInterval(pollInterval);
          
          setTimeout(() => {
            navigate('/compatibility-quiz');
          }, 2000);
        } else if (payment.status === 'failed') {
          setPaymentStatus('failed');
          setPaymentError('Payment failed. Please try again.');
          setIsProcessing(false);
          clearInterval(pollInterval);
        }
      } catch (error) {
        console.error('Payment status check error:', error);
      }
    }, 5000); // Poll every 5 seconds

    // Stop polling after 10 minutes
    setTimeout(() => {
      clearInterval(pollInterval);
      if (paymentStatus === 'pending') {
        setPaymentError('Payment timeout. Please try again.');
        setIsProcessing(false);
      }
    }, 600000);
  };

  // PayPal payment handlers
  const createOrder = (_data: any, actions: any) => {
    setIsProcessing(true);
    setPaymentError('');
    
    return actions.order.create({
      purchase_units: [{
        amount: {
          value: "10.00",
          currency_code: "USD"
        },
        description: "SoulSync AI Matchmaking - Limited Launch Offer"
      }],
      application_context: {
        brand_name: "SoulSync",
        user_action: "PAY_NOW"
      }
    });
  };

  const onApprove = async (_data: any, actions: any) => {
    try {
      const details = await actions.order.capture();
      
      // Create subscription via backend
      await paymentsAPI.createPayment({
        amount: 10.00,
        currency: 'USD',
        description: 'SoulSync AI Matchmaking - Limited Launch Offer',
        provider: 'paypal',
        providerId: details.id
      });
      
      console.log('PayPal payment completed:', details);
      
      setPaymentSuccess(true);
      dispatch({ type: 'SET_PAYMENT_STATUS', payload: true });
      
      setTimeout(() => {
        navigate('/compatibility-quiz');
      }, 2000);
      
    } catch (error) {
      console.error('PayPal payment error:', error);
      setPaymentError('Payment failed. Please try again.');
      setIsProcessing(false);
    }
  };

  const onError = (error: any) => {
    console.error('PayPal error:', error);
    setPaymentError('Payment failed. Please try again.');
    setIsProcessing(false);
  };

  const onCancel = () => {
    setIsProcessing(false);
    setPaymentError('Payment was cancelled.');
  };

  const handleDemoPayment = () => {
    setIsProcessing(true);
    setPaymentError('');
    
    // Simulate payment processing
    setTimeout(() => {
      setPaymentSuccess(true);
      dispatch({ type: 'SET_PAYMENT_STATUS', payload: true });
      
      setTimeout(() => {
        navigate('/compatibility-quiz');
      }, 2000);
    }, 2000);
  };

  if (paymentSuccess) {
    return (
      <div className="min-h-screen warm-gradient flex items-center justify-center p-4 relative overflow-hidden">
        {/* Decorative elements */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-20 left-10 w-32 h-32 bg-coral-200 rounded-full opacity-20 animate-bounce-gentle"></div>
          <div className="absolute bottom-20 right-10 w-24 h-24 bg-mint-200 rounded-full opacity-30 animate-bounce-gentle" style={{ animationDelay: '1s' }}></div>
          <div className="absolute top-1/2 left-1/4 w-16 h-16 bg-peach-200 rounded-full opacity-25 animate-bounce-gentle" style={{ animationDelay: '2s' }}></div>
        </div>

        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          className="w-full max-w-md text-center relative z-10"
        >
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.2, type: "spring" }}
            className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-mint-400 to-mint-600 rounded-full mb-6 shadow-coral"
          >
            <Check className="w-10 h-10 text-white" />
          </motion.div>

          <h1 className="text-3xl font-bold text-warm-800 mb-4">
            Payment Successful! 🎉
          </h1>

          <p className="text-warm-600 text-lg mb-6">
            Welcome to SoulSync! Let's find your perfect match.
          </p>

          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
            className="inline-block w-8 h-8 border-2 border-coral-400 border-t-transparent rounded-full"
          />
        </motion.div>
      </div>
    );
  }

  return (
    <PayPalScriptProvider options={paypalOptions}>
      <div className="min-h-screen warm-gradient flex items-center justify-center p-4 relative overflow-hidden">
        {/* Decorative elements */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-20 left-10 w-32 h-32 bg-coral-200 rounded-full opacity-20 animate-bounce-gentle"></div>
          <div className="absolute bottom-20 right-10 w-24 h-24 bg-mint-200 rounded-full opacity-30 animate-bounce-gentle" style={{ animationDelay: '1s' }}></div>
          <div className="absolute top-1/2 left-1/4 w-16 h-16 bg-peach-200 rounded-full opacity-25 animate-bounce-gentle" style={{ animationDelay: '2s' }}></div>
          <div className="absolute top-1/3 right-1/4 w-20 h-20 bg-lavender-200 rounded-full opacity-20 animate-bounce-gentle" style={{ animationDelay: '0.5s' }}></div>
        </div>

        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="w-full max-w-md relative z-10"
        >
          {/* Header */}
          <div className="text-center mb-8">
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.2, type: "spring" }}
              className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-coral-400 to-peach-400 rounded-full mb-4 shadow-coral"
            >
              <Lock className="w-10 h-10 text-white" />
            </motion.div>
            
            <h1 className="text-3xl font-bold text-warm-800 mb-2">
              Limited Launch Offer
            </h1>
            
            <p className="text-warm-600 mb-4">
              Unlock SoulSync AI Matchmaking & Premium Chat
            </p>
            
            <div className="bg-white/90 backdrop-blur-sm border border-coral-200 rounded-xl p-4 mb-6 shadow-soft">
              <div className="flex items-center justify-center gap-2 mb-2">
                <Star className="w-5 h-5 text-coral-500" fill="currentColor" />
                <span className="text-2xl font-bold text-warm-800">$10</span>
                <span className="text-warm-400 line-through">$29</span>
              </div>
              <p className="text-sm text-warm-600">
                We're invite-only. Your payment ensures real users & accurate matching.
              </p>
            </div>
          </div>

          {/* Features */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-white/90 backdrop-blur-sm border border-peach-200 rounded-2xl p-6 mb-6 shadow-soft"
          >
            <h3 className="text-lg font-semibold text-warm-800 mb-4 flex items-center gap-2">
              <Zap className="w-5 h-5 text-coral-500" />
              What You Get:
            </h3>
            
            <div className="space-y-3">
              {[
                'AI-Powered Compatibility Matching',
                'Unlimited Premium Chat Features',
                'Advanced Personality Analysis',
                'Smart Date Location Finder',
                'Priority Match Recommendations'
              ].map((feature, index) => (
                <motion.div
                  key={feature}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.6 + index * 0.1 }}
                  className="flex items-center gap-3"
                >
                  <Check className="w-5 h-5 text-mint-500" />
                  <span className="text-warm-700">{feature}</span>
                </motion.div>
              ))}
            </div>
          </motion.div>

          {/* Payment Methods */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.8 }}
            className="bg-white/90 backdrop-blur-sm border border-mint-200 rounded-2xl p-6 shadow-soft"
          >
            {/* Payment Method Selection */}
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-warm-800 mb-3 flex items-center gap-2">
                <CreditCard className="w-5 h-5 text-coral-500" />
                Payment Method
              </h3>
              
              <div className="grid grid-cols-4 gap-3 mb-6">
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setPaymentMethod('crypto')}
                  className={`p-3 rounded-xl border-2 transition-all text-center ${
                    paymentMethod === 'crypto'
                      ? 'border-coral-400 bg-coral-50 text-warm-800 shadow-soft'
                      : 'border-warm-200 bg-white hover:border-coral-300 text-warm-600'
                  }`}
                >
                  <Bitcoin className="w-6 h-6 mx-auto mb-2" />
                  <div className="font-medium text-sm">Crypto</div>
                  <div className="text-xs opacity-75">Recommended</div>
                </motion.button>
                
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setPaymentMethod('paypal')}
                  className={`p-3 rounded-xl border-2 transition-all text-center ${
                    paymentMethod === 'paypal'
                      ? 'border-peach-400 bg-peach-50 text-warm-800 shadow-soft'
                      : 'border-warm-200 bg-white hover:border-peach-300 text-warm-600'
                  }`}
                >
                  <CreditCard className="w-6 h-6 mx-auto mb-2" />
                  <div className="font-medium text-sm">PayPal</div>
                  <div className="text-xs opacity-75">Fallback</div>
                </motion.button>
                
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setPaymentMethod('nowpayments')}
                  className={`p-3 rounded-xl border-2 transition-all text-center ${
                    paymentMethod === 'nowpayments'
                      ? 'border-mint-400 bg-mint-50 text-warm-800 shadow-soft'
                      : 'border-warm-200 bg-white hover:border-mint-300 text-warm-600'
                  }`}
                >
                  <Coins className="w-6 h-6 mx-auto mb-2" />
                  <div className="font-medium text-sm">NOW</div>
                  <div className="text-xs opacity-75">Payments</div>
                </motion.button>
                
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setPaymentMethod('demo')}
                  className={`p-3 rounded-xl border-2 transition-all text-center ${
                    paymentMethod === 'demo'
                      ? 'border-lavender-400 bg-lavender-50 text-warm-800 shadow-soft'
                      : 'border-warm-200 bg-white hover:border-lavender-300 text-warm-600'
                  }`}
                >
                  <TestTube className="w-6 h-6 mx-auto mb-2" />
                  <div className="font-medium text-sm">Demo</div>
                  <div className="text-xs opacity-75">Testing</div>
                </motion.button>
              </div>
            </div>

            <div className="mb-4">
              <h3 className="text-lg font-semibold text-warm-800 mb-2">
                Secure Payment
              </h3>
              <p className="text-sm text-warm-600">
                {paymentMethod === 'crypto' 
                  ? 'Pay securely with Bitcoin, Ethereum, or other cryptocurrencies'
                  : paymentMethod === 'paypal'
                  ? 'Pay securely with PayPal or credit card'
                  : paymentMethod === 'nowpayments'
                  ? 'Pay securely with multiple cryptocurrency options'
                  : 'Demo payment for testing purposes'
                }
              </p>
            </div>

            {paymentError && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="bg-coral-100 border border-coral-300 rounded-lg p-3 mb-4"
              >
                <p className="text-coral-700 text-sm font-medium">{paymentError}</p>
              </motion.div>
            )}

            {/* Crypto Payment Status */}
            {paymentMethod === 'crypto' && paymentId && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="bg-coral-50 border border-coral-200 rounded-lg p-3 mb-4"
              >
                <div className="flex items-center gap-2 mb-2">
                  <Coins className="w-4 h-4 text-coral-500" />
                  <span className="text-coral-700 text-sm font-medium">Crypto Payment</span>
                </div>
                <p className="text-warm-700 text-sm">
                  Payment page opened in new tab. Please complete payment there.
                </p>
                <p className="text-warm-500 text-xs mt-1">
                  Status: {paymentStatus === 'pending' ? 'Waiting for payment...' : paymentStatus}
                </p>
              </motion.div>
            )}

            {paymentMethod === 'crypto' ? (
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={createCryptoPayment}
                disabled={isProcessing}
                className="w-full bg-gradient-to-r from-coral-400 to-peach-400 text-white py-3 px-6 rounded-xl font-semibold disabled:opacity-50 disabled:cursor-not-allowed hover:shadow-coral transition-all flex items-center justify-center gap-2"
              >
                <Bitcoin className="w-5 h-5" />
                {isProcessing ? 'Creating Payment...' : 'Pay with Crypto ($10)'}
              </motion.button>
            ) : paymentMethod === 'paypal' ? (
              <div className="paypal-button-container">
                <PayPalButtons
                  style={{
                    layout: "vertical",
                    color: "gold",
                    shape: "rect",
                    label: "paypal",
                    height: 45
                  }}
                  createOrder={createOrder}
                  onApprove={onApprove}
                  onError={onError}
                  onCancel={onCancel}
                  disabled={isProcessing}
                />
              </div>
            ) : paymentMethod === 'nowpayments' ? (
              <NOWPaymentsButton
                amount={10.00}
                currency="USD"
                description="SoulSync AI Matchmaking - Limited Launch Offer"
                onSuccess={() => {
                  setPaymentSuccess(true);
                  dispatch({ type: 'SET_PAYMENT_STATUS', payload: true });
                  setTimeout(() => {
                    navigate('/compatibility-quiz');
                  }, 2000);
                }}
                onError={(error) => {
                  setPaymentError(error);
                  setIsProcessing(false);
                }}
                onPending={() => {
                  setIsProcessing(true);
                  setPaymentError('');
                }}
              />
            ) : (
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={handleDemoPayment}
                disabled={isProcessing}
                className="w-full bg-gradient-to-r from-mint-400 to-mint-600 text-white py-3 px-6 rounded-xl font-semibold disabled:opacity-50 disabled:cursor-not-allowed hover:shadow-soft transition-all flex items-center justify-center gap-2"
              >
                <TestTube className="w-5 h-5" />
                {isProcessing ? 'Processing Demo Payment...' : 'Complete Demo Payment ($10)'}
              </motion.button>
            )}

            {isProcessing && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="mt-4 text-center"
              >
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                  className="inline-block w-5 h-5 border-2 border-coral-400 border-t-transparent rounded-full mr-2"
                />
                <span className="text-warm-600">
                  {paymentMethod === 'crypto' ? 'Creating crypto payment...' : 'Processing payment...'}
                </span>
              </motion.div>
            )}

            <div className="mt-4 text-center">
              <p className="text-xs text-warm-500 flex items-center justify-center gap-1">
                <Lock className="w-3 h-3" />
                {paymentMethod === 'crypto' 
                  ? 'Secured by Coinbase Commerce & blockchain technology'
                  : paymentMethod === 'paypal'
                  ? 'Secured by PayPal & 256-bit SSL encryption'
                  : paymentMethod === 'nowpayments'
                  ? 'Secured by NOWPayments & blockchain technology'
                  : 'Demo mode - No real payment processed'
                }
              </p>
            </div>
          </motion.div>

          <div className="mt-4 text-center">
            <button
              onClick={() => navigate(-1)}
              className="text-warm-600 hover:text-warm-800 transition-colors text-sm font-medium"
            >
              ← Back to quiz
            </button>
          </div>
        </motion.div>
      </div>
    </PayPalScriptProvider>
  );
};

export default PaymentModal;