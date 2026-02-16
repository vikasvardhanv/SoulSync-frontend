import React from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';

const Support: React.FC = () => {
    return (
        <div className="min-h-screen bg-warm-50 py-12 px-4 sm:px-6 lg:px-8 font-sans">
            <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="max-w-3xl mx-auto bg-white rounded-3xl shadow-xl shadow-warm-200/50 p-8 sm:p-12 border border-warm-100"
            >
                <div className="text-center mb-12">
                    <div className="text-6xl mb-4">💞</div>
                    <h1 className="text-4xl font-bold text-warm-900 mb-2">SoulSync Support</h1>
                    <p className="text-warm-600">AI-Powered Matching for Meaningful Connections</p>
                </div>

                <div className="bg-warm-50 rounded-2xl p-8 border border-coral-100 mb-10">
                    <h2 className="text-2xl font-bold text-warm-800 mb-4 flex items-center gap-2">
                        <span>👋</span> Need Help?
                    </h2>
                    <p className="text-warm-700 mb-6">
                        We are dedicated to providing you with the best dating experience. If you have any questions, technical issues, or feedback, please reach out to our team.
                    </p>
                    <div className="flex items-center gap-3 text-lg font-semibold text-warm-900">
                        <span>📧 Email:</span>
                        <a href="mailto:support@soulsync.solutions" className="text-coral-500 hover:underline">
                            support@soulsync.solutions
                        </a>
                    </div>
                    <p className="mt-4 text-warm-500 text-sm italic">Our team typically responds within 24 hours.</p>
                </div>

                <div className="space-y-10">
                    <section>
                        <h2 className="text-2xl font-bold text-warm-900 mb-6 border-b-2 border-warm-100 pb-2">Frequently Asked Questions</h2>

                        <div className="space-y-6">
                            <div>
                                <h3 className="text-xl font-bold text-warm-800 mb-2">How do I delete my account?</h3>
                                <p className="text-warm-700">
                                    We respect your data privacy. You can permanently delete your account and all associated data at any time:
                                </p>
                                <ol className="list-decimal pl-6 mt-2 space-y-1 text-warm-700">
                                    <li>Open the SoulSync app</li>
                                    <li>Go to <strong>Profile &gt; Settings</strong></li>
                                    <li>Select <strong>Delete Account</strong> at the bottom</li>
                                    <li>Type "DELETE MY ACCOUNT" to confirm</li>
                                </ol>
                                <p className="mt-2 text-warm-600 italic">Data deletion is immediate and irreversible.</p>
                            </div>

                            <div>
                                <h3 className="text-xl font-bold text-warm-800 mb-2">How does the AI matching work?</h3>
                                <p className="text-warm-700">
                                    SoulSync uses advanced psychology-based algorithms. By analyzing your answers to our personality quizzes, we calculate compatibility scores to match you with users who share your values and communication style.
                                </p>
                            </div>

                            <div>
                                <h3 className="text-xl font-bold text-warm-800 mb-2">I'm not receiving matches. What should I do?</h3>
                                <p className="text-warm-700">
                                    Ensure your profile is complete! Users with a bio, profile picture, and verified email get 80% more matches. Also, try expanding your distance or age preferences in Settings.
                                </p>
                            </div>
                        </div>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-warm-900 mb-6 border-b-2 border-warm-100 pb-2">Safety & Privacy</h2>
                        <p className="text-warm-700 mb-6">Your safety is our priority. Please review our guidelines and policies:</p>
                        <div className="flex flex-wrap gap-4">
                            <Link to="/privacy-policy" className="text-coral-500 font-bold hover:underline">Privacy Policy</Link>
                            <span className="text-warm-300">|</span>
                            <span className="text-coral-400 font-medium">Terms of Service</span>
                            <span className="text-warm-300">|</span>
                            <span className="text-coral-400 font-medium">Safety Tips</span>
                        </div>
                    </section>
                </div>

                <div className="mt-16 pt-8 border-t border-warm-100 text-center">
                    <Link to="/" className="inline-block bg-coral-500 text-white px-8 py-3 rounded-full font-bold hover:bg-coral-600 transition-shadow shadow-lg shadow-coral-200 hover:shadow-coral-300 transform hover:-translate-y-0.5 transition-transform">
                        Back to SoulSync
                    </Link>
                    <p className="mt-8 text-warm-400 text-sm">
                        &copy; {new Date().getFullYear()} SoulSync Solutions. All rights reserved.
                    </p>
                </div>
            </motion.div>
        </div>
    );
};

export default Support;
