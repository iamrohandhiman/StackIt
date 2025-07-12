import React, { useEffect, useState } from 'react';
import { getMe, getQuestionById, markAllMentionsViewed, getMyQuestions, getMyAnswers } from '../api/api'; // Assuming you have these API functions
import { Link } from 'react-router-dom';
import { User, Mail, HelpCircle, MessageCircle, AtSign, Loader2, Star } from 'lucide-react';

// --- Helper component for displaying lists of questions/mentions ---
const ActivityItem = ({ item, type }) => (
    <li className="border-b border-gray-200 dark:border-gray-700 py-4">
        <div className="flex items-center justify-between">
            <div className="flex-grow">
                <Link
                    to={`/questions/${type === 'mention' ? item._id : item.questionId || item._id}`}
                    className="text-gray-800 dark:text-gray-200 font-medium hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors"
                >
                    {item.body}
                </Link>
                {type === 'answer' && (
                    <div className="flex items-center text-sm text-gray-500 mt-1">
                        <Star className="w-4 h-4 mr-2 text-yellow-500" />
                        <span>{item.upvotes - item.downvotes} points</span>
                    </div>
                )}
            </div>
            <span className="text-xs text-gray-400 dark:text-gray-500 ml-4 whitespace-nowrap">
                {new Date(item.createdAt).toLocaleDateString()}
            </span>
        </div>
    </li>
);


// --- Main Profile Component ---
function Profile() {
    const [user, setUser] = useState(null);
    const [mentionedQuestions, setMentionedQuestions] = useState([]);
    const [myQuestions, setMyQuestions] = useState([]);
    const [myAnswers, setMyAnswers] = useState([]);
    const [activeTab, setActiveTab] = useState('mentions');
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const loadProfileData = async () => {
            try {
                // Fetch user data and mark mentions as viewed
                const userRes = await getMe();
                setUser(userRes.data);
                await markAllMentionsViewed();

                // Fetch all related data in parallel for speed
                const [mentionRes, questionRes, answerRes] = await Promise.all([
                    Promise.all(userRes.data.mentions.map(m => getQuestionById(m.questionId))),
                    getMyQuestions(), // Assumes an API endpoint that returns the user's questions
                    getMyAnswers(),   // Assumes an API endpoint that returns the user's answers
                ]);

                setMentionedQuestions(mentionRes.map(r => r.data));
                setMyQuestions(questionRes.data);
                setMyAnswers(answerRes.data);

            } catch (err) {
                console.error("Failed to load profile data:", err);
            } finally {
                setLoading(false);
            }
        };

        loadProfileData();
    }, []);

    if (loading) {
        return (
            <div className="flex justify-center items-center min-h-[calc(100vh-8rem)]">
                <Loader2 className="h-12 w-12 animate-spin text-indigo-600" />
            </div>
        );
    }

    if (!user) {
        return <div className="text-center py-10">Could not load user profile. Please try again later.</div>;
    }

    const TABS = {
        mentions: {
            label: 'Mentions',
            icon: AtSign,
            data: mentionedQuestions,
            emptyText: 'You have not been mentioned in any questions yet.',
            type: 'mention'
        },
        questions: {
            label: 'My Questions',
            icon: HelpCircle,
            data: myQuestions,
            emptyText: 'You have not asked any questions yet.',
            type: 'question'
        },
        answers: {
            label: 'My Answers',
            icon: MessageCircle,
            data: myAnswers,
            emptyText: 'You have not answered any questions yet.',
            type: 'answer'
        },
    };

    const activeTabData = TABS[activeTab];

    return (
        <div className="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-800 dark:text-gray-200 transition-colors duration-500">
            <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-10">
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
                    
                    {/* Left Column: User Card */}
                    <aside className="lg:col-span-4 xl:col-span-3">
                        <div className="bg-white dark:bg-gray-800/50 p-6 rounded-xl shadow-lg border border-gray-200 dark:border-gray-700/50">
                            <div className="flex flex-col items-center">
                                <img
                                    className="h-24 w-24 rounded-full object-cover ring-4 ring-indigo-300 dark:ring-indigo-500"
                                    src={`https://api.dicebear.com/8.x/lorelei/svg?seed=${user.name}`}
                                    alt="Profile Avatar"
                                />
                                <h1 className="mt-4 text-2xl font-bold text-gray-900 dark:text-gray-100">{user.name}</h1>
                                <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{user.email}</p>
                            </div>
                            <div className="mt-6 border-t border-gray-200 dark:border-gray-700 pt-6">
                                <h3 className="text-sm font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Stats</h3>
                                <div className="mt-4 space-y-4">
                                    <div className="flex items-center">
                                        <HelpCircle className="h-5 w-5 text-indigo-500" />
                                        <p className="ml-3 text-sm font-medium">{myQuestions.length} Questions asked</p>
                                    </div>
                                    <div className="flex items-center">
                                        <MessageCircle className="h-5 w-5 text-green-500" />
                                        <p className="ml-3 text-sm font-medium">{myAnswers.length} Answers provided</p>
                                    </div>
                                    <div className="flex items-center">
                                        <AtSign className="h-5 w-5 text-rose-500" />
                                        <p className="ml-3 text-sm font-medium">{user.mentions.length} Mentions</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </aside>

                    {/* Right Column: Activity Feed */}
                    <div className="lg:col-span-8 xl:col-span-9">
                        <div className="bg-white dark:bg-gray-800/50 rounded-xl shadow-lg border border-gray-200 dark:border-gray-700/50">
                             {/* Tabs */}
                             <div className="border-b border-gray-200 dark:border-gray-700">
                                <nav className="-mb-px flex space-x-6 px-6">
                                    {Object.keys(TABS).map(tabKey => {
                                        const tab = TABS[tabKey];
                                        const Icon = tab.icon;
                                        const isActive = activeTab === tabKey;
                                        return (
                                            <button
                                                key={tabKey}
                                                onClick={() => setActiveTab(tabKey)}
                                                className={`flex items-center whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                                                    isActive
                                                        ? 'border-indigo-500 text-indigo-600 dark:text-indigo-400'
                                                        : 'border-transparent text-gray-500 hover:text-gray-700 dark:hover:text-gray-300 hover:border-gray-300'
                                                }`}
                                            >
                                                <Icon className={`mr-2 h-5 w-5 ${isActive ? 'text-indigo-500' : ''}`} />
                                                {tab.label}
                                            </button>
                                        );
                                    })}
                                </nav>
                            </div>

                            {/* Tab Content */}
                            <div className="p-6">
                                {activeTabData.data.length > 0 ? (
                                    <ul>
                                        {activeTabData.data.map(item => (
                                            <ActivityItem key={item._id} item={item} type={activeTabData.type} />
                                        ))}
                                    </ul>
                                ) : (
                                    <div className="text-center py-12">
                                        <p className="text-gray-500 dark:text-gray-400">{activeTabData.emptyText}</p>
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default Profile;