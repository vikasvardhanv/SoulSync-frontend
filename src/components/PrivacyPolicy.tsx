import React from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';

const PrivacyPolicy: React.FC = () => {
    return (
        <div className="min-h-screen bg-warm-50 py-12 px-4 sm:px-6 lg:px-8">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="max-w-3xl mx-auto bg-white rounded-3xl shadow-xl shadow-warm-200/50 p-8 sm:p-12 border border-warm-100"
            >
                <div className="flex justify-between items-center mb-10">
                    <Link to="/" className="text-coral-500 font-bold flex items-center gap-2 hover:text-coral-600 transition-colors">
                        <span className="text-2xl">💞</span>
                        <span>SoulSync</span>
                    </Link>
                    <span className="text-warm-400 text-sm">Last Updated: {new Date().toLocaleDateString()}</span>
                </div>

                <h1 className="text-4xl font-bold text-warm-900 mb-8">Privacy Policy</h1>

                <div className="space-y-8 text-warm-700 leading-relaxed">
                    <section>
                        <p>
                            SoulSync ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and share information about you when you use our mobile application and services.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-warm-800 mb-4">1. Information We Collect</h2>
                        <p className="mb-4">To provide our AI-driven matching services, we collect the following types of information:</p>
                        <ul className="list-disc pl-6 space-y-2">
                            <li><strong>Account Data:</strong> Name, email address, age, and gender provided during registration.</li>
                            <li><strong>User Content:</strong> Profile photos, bio, and your responses to our personality quizzes.</li>
                            <li><strong>Location Data:</strong> We collect your <strong>precise location (GPS)</strong> to find compatible matches nearby. This can happen in the background if you grant permission.</li>
                            <li><strong>Interaction Data:</strong> Messages sent within the app, match history, and how you interact with app features.</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-warm-800 mb-4">2. How We Use Your Information</h2>
                        <p className="mb-4">We use your data strictly for the following purposes:</p>
                        <ul className="list-disc pl-6 space-y-2">
                            <li><strong>Matching Services:</strong> Using AI to calculate compatibility scores between users.</li>
                            <li><strong>App Functionality:</strong> Authenticating users, enabling chat, and displaying profiles.</li>
                            <li><strong>Safety:</strong> Preventing fraud and maintaining a respectful community.</li>
                            <li><strong>Analytics:</strong> Improving our matching algorithms and app performance.</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-warm-800 mb-4">3. Data Sharing & Third Parties</h2>
                        <p>
                            <strong>We do not sell your personal data to third parties.</strong> We do not share your data with third-party advertisers or data brokers for tracking purposes. Data is only shared with service providers necessary for app operations (e.g., cloud hosting).
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-warm-800 mb-4">4. Data Retention & Deletion</h2>
                        <p>
                            We keep your data as long as your account is active. You can delete your account at any time through the <strong>Settings &gt; Delete Account</strong> menu in the app. Upon deletion, your profile, photos, and messages are permanently removed from our active databases.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-warm-800 mb-4">5. Security</h2>
                        <p>
                            We implement industry-standard security measures to protect your data, including encryption in transit (HTTPS) and secure storage of sensitive identifiers.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-warm-800 mb-4">6. Contact Us</h2>
                        <p>
                            If you have questions about this policy, contact us at <a href="mailto:privacy@soulsync.solutions" className="text-coral-500 font-semibold hover:underline">privacy@soulsync.solutions</a>.
                        </p>
                    </section>
                </div>

                <div className="mt-12 pt-8 border-t border-warm-100 text-center">
                    <Link to="/" className="inline-block bg-warm-100 text-warm-600 px-6 py-2 rounded-full font-semibold hover:bg-warm-200 transition-colors">
                        Back to Home
                    </Link>
                </div>
            </motion.div>
        </div>
    );
};

export default PrivacyPolicy;
