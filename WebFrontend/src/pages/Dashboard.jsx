import React, { useEffect, useState, useCallback, useMemo } from 'react';
import { getPaginatedQuestions, searchQuestions, getMe } from '../api/api';
import { Link, useNavigate } from 'react-router-dom';
import { Search, Bell, Sun, Moon, MessageSquare, Flame, Clock, Star, Frown, ChevronLeft, ChevronRight, Loader2, AlertCircle, RefreshCw, User } from 'lucide-react';

// --- Helper component for individual question cards ---
const QuestionCard = ({ question }) => {
    const tagColors = [
        'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300',
        'bg-pink-100 text-pink-800 dark:bg-pink-900 dark:text-pink-300',
        'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300',
        'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300',
        'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300',
    ];

    const formatDate = (dateString) => {
        if (!dateString) return '';
        const date = new Date(dateString);
        const now = new Date();
        const diffTime = Math.abs(now - date);
        const diffMinutes = Math.ceil(diffTime / (1000 * 60));
        const diffHours = Math.ceil(diffTime / (1000 * 60 * 60));
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffMinutes < 60) return `${diffMinutes}m ago`;
        if (diffHours < 24) return `${diffHours}h ago`;
        if (diffDays === 1) return 'Yesterday';
        if (diffDays < 7) return `${diffDays}d ago`;
        return date.toLocaleDateString();
    };

    const truncateBody = (text, maxLength = 180) => {
        if (!text || text.length <= maxLength) return text;
        return text.substring(0, maxLength) + '...';
    };

    return (
        <div className="bg-white dark:bg-gray-800/50 rounded-lg shadow-sm hover:shadow-md transition-all duration-300 p-6 border border-gray-200 dark:border-gray-700/50 hover:border-indigo-300 dark:hover:border-indigo-700">
            <div className="flex justify-between items-start mb-3">
                <div className="flex items-center space-x-3">
                     <img 
                        className="w-8 h-8 rounded-full object-cover bg-gray-100" 
                        src={`https://api.dicebear.com/8.x/lorelei/svg?seed=${question.user?.name || 'anonymous'}`} 
                        alt="User"
                    />
                    <div>
                        <span className="text-sm font-medium text-gray-900 dark:text-gray-100">Anonymous</span>
                        <span className="text-xs text-gray-500 dark:text-gray-400 ml-2">
                            {formatDate(question.createdAt)}
                        </span>
                    </div>
                </div>
            </div>
            
            <div className="mb-4">
                <Link 
                    to={`/questions/${question._id}`} 
                    className="text-xl font-bold text-gray-900 dark:text-gray-100 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors duration-200 block mb-2"
                >
                    {question.title}
                </Link>
                {question.body && (
                    <p className="text-gray-700 dark:text-gray-300 text-sm leading-relaxed opacity-90">
                        {truncateBody(question.body)}
                    </p>
                )}
            </div>

            <div className="flex flex-wrap gap-2 mb-4">
                {question.tags?.slice(0, 5).map((tag, index) => (
                    <span 
                        key={index} 
                        className={`text-xs font-medium px-2.5 py-1 rounded-full ${tagColors[index % tagColors.length]}`}
                    >
                        {tag}
                    </span>
                ))}
            </div>

            <div className="flex items-center justify-between text-sm text-gray-500 dark:text-gray-400">
                <div className="flex items-center space-x-2 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors cursor-pointer">
                    <MessageSquare className="w-4 h-4" />
                    <span>{question.answers?.length || 0} {(question.answers?.length || 0) === 1 ? 'comment' : 'comments'}</span>
                </div>
            </div>
        </div>
    );
};

// --- Sidebar Component ---
const CommunitySidebar = ({ questions, onTagClick }) => {
    const formatDate = (dateString) => {
        if (!dateString) return '';
        const date = new Date(dateString);
        const now = new Date();
        const diffTime = Math.abs(now - date);
        const diffMinutes = Math.ceil(diffTime / (1000 * 60));
        
        if (diffMinutes < 60) return `${diffMinutes}m`;
        const diffHours = Math.ceil(diffTime / (1000 * 60 * 60));
        if (diffHours < 24) return `${diffHours}h`;
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        if (diffDays < 7) return `${diffDays}d`;
        return `${Math.ceil(diffDays/7)}w`;
    };

    return (
        <div className="space-y-6">
            <div className="bg-white dark:bg-gray-800/50 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700/50 p-4">
                <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4 flex items-center">
                    <Clock className="w-5 h-5 text-indigo-500 mr-2" />
                    Recent Activity
                </h3>
                <div className="space-y-1">
                    {questions.slice(0, 8).map((question) => (
                        <Link
                            key={question._id}
                            to={`/questions/${question._id}`}
                            className="block p-3 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors group"
                        >
                            <p className="text-sm font-medium text-gray-800 dark:text-gray-200 line-clamp-2 mb-1 group-hover:text-indigo-600 dark:group-hover:text-indigo-400">
                                {question.title}
                            </p>
                            <div className="flex items-center space-x-2 text-xs text-gray-500 dark:text-gray-400">
                                <span>{formatDate(question.createdAt)}</span>
                                <span>•</span>
                                <span>{question.answers?.length || 0} replies</span>
                            </div>
                        </Link>
                    ))}
                </div>
            </div>

            <div className="bg-white dark:bg-gray-800/50 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700/50 p-4">
                <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4 flex items-center">
                    <Flame className="w-5 h-5 text-indigo-500 mr-2" />
                    Trending Tags
                </h3>
                <div className="flex flex-wrap gap-2">
                    {['React', 'JavaScript', 'Python', 'CSS', 'Node.js', 'API', 'Database', 'Git'].map((tag) => (
                        <button 
                            key={tag}
                            onClick={() => onTagClick(tag)}
                            className="px-3 py-1 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-full text-sm font-medium hover:bg-indigo-100 dark:hover:bg-indigo-900/50 hover:text-indigo-600 dark:hover:text-indigo-400 cursor-pointer transition-colors"
                        >
                            #{tag.toLowerCase()}
                        </button>
                    ))}
                </div>
            </div>
        </div>
    );
};

// --- Reusable Components ---
const LoadingSpinner = () => (
    <div className="flex justify-center items-center py-20">
        <Loader2 className="h-8 w-8 animate-spin text-indigo-500" />
        <span className="ml-3 text-gray-600 dark:text-gray-400">Loading Questions...</span>
    </div>
);

const ErrorMessage = ({ message, onRetry }) => (
    <div className="flex flex-col items-center justify-center py-20 text-center bg-gray-50 dark:bg-gray-800/30 rounded-lg">
        <AlertCircle className="h-12 w-12 text-red-500 mb-4" />
        <p className="text-gray-700 dark:text-gray-300 mb-4 font-medium">{message}</p>
        {onRetry && (
            <button
                onClick={onRetry}
                className="flex items-center px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 transition-colors"
            >
                <RefreshCw className="h-4 w-4 mr-2" />
                Try Again
            </button>
        )}
    </div>
);

// --- Main Dashboard Component ---
function Dashboard() {
    // Main feed state
    const [questions, setQuestions] = useState([]);
    const [currentPage, setCurrentPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);
    const [sortBy, setSortBy] = useState('new');
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    // Search state
    const [searchQuery, setSearchQuery] = useState('');
    const [searchResults, setSearchResults] = useState([]);
    const [searchLoading, setSearchLoading] = useState(false);
    
    // Other state
    const [allQuestionsForSidebar, setAllQuestionsForSidebar] = useState([]);
    const [user, setUser] = useState(null);
    const [hasUnviewedMentions, setHasUnviewedMentions] = useState(false);
    const [theme, setTheme] = useState(() => {
        if (typeof window === 'undefined') return 'light';
        const stored = localStorage.getItem('theme');
        return stored || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
    });

    const navigate = useNavigate();

    const sortOptions = useMemo(() => [
        { key: 'trending', label: 'Trending', icon: Flame },
        { key: 'new', label: 'New', icon: Clock },
        { key: 'mostAnswered', label: 'Most Answered', icon: Star },
        { key: 'unanswered', label: 'Unanswered', icon: Frown },
    ], []);

    // --- Effects ---

    useEffect(() => {
        document.documentElement.classList.toggle('dark', theme === 'dark');
        localStorage.setItem('theme', theme);
    }, [theme]);

    useEffect(() => {
        const loadInitialData = async () => {
            try {
                const [userRes, sidebarRes] = await Promise.all([
                    getMe(),
                    getPaginatedQuestions(1, 8, 'new')
                ]);
                setUser(userRes.data);
                setHasUnviewedMentions(userRes.data.mentions?.some(m => !m.viewed) || false);
                setAllQuestionsForSidebar(sidebarRes.data || []);
            } catch (err) {
                console.error("Failed to fetch initial data:", err);
            }
        };
        loadInitialData();
    }, []);

    useEffect(() => {
        const loadQuestions = async () => {
            setLoading(true);
            setError(null);
            try {
                const res = await getPaginatedQuestions(currentPage, 10, sortBy);
                const data = res.data || [];
                setQuestions(data);
                setTotalPages(data.length < 10 ? currentPage : currentPage + 1); 
            } catch (err) {
                console.error("Failed to load questions:", err);
                setError("Could not load the question feed. Please check your connection.");
            } finally {
                setLoading(false);
            }
        };
        loadQuestions();
    }, [sortBy, currentPage]);
    
    // --- Handlers ---
    
    const performSearch = useCallback(async (query) => {
        const trimmedQuery = query.trim();
        if (!trimmedQuery) {
            setSearchResults([]);
            setSearchLoading(false);
            return;
        }
        setSearchLoading(true);
        try {
            // 1. API Search for titles/tags
            const apiRes = await searchQuestions(trimmedQuery);
            const apiResults = apiRes.data || [];

            // 2. Client-side Search for body text
            const lowerCaseQuery = trimmedQuery.toLowerCase();
            const allLoadedQuestions = [...questions, ...allQuestionsForSidebar];
            const clientSideResults = allLoadedQuestions.filter(q => 
                q.body && q.body.toLowerCase().includes(lowerCaseQuery)
            );

            // 3. Merge and Deduplicate results
            const combinedResults = new Map();
            apiResults.forEach(q => combinedResults.set(q._id, q));

            clientSideResults.forEach(q => {
                if (!combinedResults.has(q._id)) {
                    // Create a context snippet for body matches
                    const bodyIndex = q.body.toLowerCase().indexOf(lowerCaseQuery);
                    const startIndex = Math.max(0, bodyIndex - 30);
                    const endIndex = Math.min(q.body.length, bodyIndex + lowerCaseQuery.length + 30);
                    const snippet = `...${q.body.substring(startIndex, endIndex)}...`;
                    combinedResults.set(q._id, { ...q, matchContext: snippet });
                }
            });

            setSearchResults(Array.from(combinedResults.values()));
        } catch (err) {
            console.error("Search failed:", err);
            setSearchResults([]);
        } finally {
            setSearchLoading(false);
        }
    }, [questions, allQuestionsForSidebar]);

    const handleSearchInputChange = (e) => {
        const query = e.target.value;
        setSearchQuery(query);
        performSearch(query);
    };

    const handleTagClick = (tag) => {
        setSearchQuery(tag);
        performSearch(tag);
        document.getElementById('search-input')?.focus();
    };

    const handleSelectResult = useCallback((questionId) => {
        navigate(`/questions/${questionId}`);
        setSearchQuery('');
        setSearchResults([]);
    }, [navigate]);

    const handlePageChange = useCallback((page) => {
        if (page > 0 && page !== currentPage) {
            setCurrentPage(page);
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    }, [currentPage]);
    
    const toggleTheme = useCallback(() => setTheme(prev => prev === 'dark' ? 'light' : 'dark'), []);
    
    const retryLoadQuestions = useCallback(() => {
        setError(null);
        setLoading(true);
        // Re-trigger useEffect for fetching main questions
        setQuestions(prev => [...prev]); 
        setCurrentPage(p => p); 
    }, []);
    
    // --- Render ---

    return (
        <div className="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-800 dark:text-gray-200 transition-colors duration-300">
            <header className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-lg sticky top-0 z-40 border-b border-gray-200 dark:border-gray-700/50">
                <div className="container mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex items-center justify-between h-16">
                        <div className="flex items-center space-x-4">
                            <Link to="/" className="flex items-center space-x-2">
                                <Flame className="h-7 w-7 text-indigo-600" />
                                <span className="font-bold text-xl text-gray-800 dark:text-gray-200 hidden sm:inline">DevDiscuss</span>
                            </Link>
                        </div>

                        <div className="flex-1 max-w-xl mx-6">
                            <div className="relative search-container">
                                <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400 pointer-events-none" />
                                <input
                                    id="search-input"
                                    type="text"
                                    placeholder="Search titles and question bodies..."
                                    value={searchQuery}
                                    onChange={handleSearchInputChange}
                                    className="w-full pl-12 pr-10 py-2.5 bg-gray-100 dark:bg-gray-700 border-transparent rounded-full focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white dark:focus:bg-gray-600 transition-all duration-300"
                                    autoComplete="off"
                                />
                                {searchLoading && (
                                    <Loader2 className="absolute right-4 top-1/2 -translate-y-1/2 h-5 w-5 animate-spin text-gray-400" />
                                )}
                                {searchQuery && !searchLoading && (
                                    <ul className="absolute mt-2 w-full bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg z-10 max-h-96 overflow-y-auto">
                                        {searchResults.length === 0 ? (
                                             <li className="px-4 py-4 text-center text-sm text-gray-500 dark:text-gray-400">
                                                No results found for "{searchQuery}"
                                            </li>
                                        ) : (
                                            searchResults.map(q => (
                                                <li
                                                    key={q._id}
                                                    className="px-4 py-3 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors duration-200 border-b border-gray-100 dark:border-gray-700/50 last:border-b-0"
                                                    onClick={() => handleSelectResult(q._id)}
                                                >
                                                    <div className="font-medium text-sm text-gray-800 dark:text-gray-200 line-clamp-1">{q.title}</div>
                                                    {q.matchContext && (
                                                        <div className="mt-1 pl-2 border-l-2 border-indigo-200 dark:border-indigo-800">
                                                          <p className="text-xs italic text-gray-500 dark:text-gray-400 line-clamp-1">
                                                              {q.matchContext}
                                                          </p>
                                                        </div>
                                                    )}
                                                </li>
                                            ))
                                        )}
                                    </ul>
                                )}
                            </div>
                        </div>

                        <div className="flex items-center space-x-2">
                            <Link to="/create-question" className="px-3 py-2 text-sm font-semibold text-white bg-indigo-600 rounded-lg shadow hover:bg-indigo-700 transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 hidden sm:block">
                                Ask Question
                            </Link>
                            <button 
                                onClick={toggleTheme} 
                                className="p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500"
                            >
                                {theme === 'dark' ? <Sun className="h-5 w-5 text-yellow-400" /> : <Moon className="h-5 w-5 text-gray-600" />}
                            </button>
                            <Link 
                                to="/notifications" 
                                className="relative p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
                            >
                                <Bell className="h-5 w-5 text-gray-600 dark:text-gray-300" />
                                {hasUnviewedMentions && (
                                    <span className="absolute top-1.5 right-1.5 block h-2 w-2 rounded-full bg-red-500 ring-2 ring-white dark:ring-gray-800"></span>
                                )}
                            </Link>
                             <Link to="/profile" className="p-1 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
                                <img 
                                    className="h-8 w-8 rounded-full object-cover" 
                                    src={user?.avatarUrl || `https://api.dicebear.com/8.x/lorelei/svg?seed=${user?.name || 'default'}`} 
                                    alt="Profile"
                                />
                            </Link>
                        </div>
                    </div>
                </div>
            </header>

            <main className="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div className="flex flex-col lg:flex-row gap-8">
                    <div className="flex-1">
                        <div className="flex items-center justify-between mb-6">
                            <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Public Questions</h2>
                            <div className="flex items-center space-x-1 bg-white dark:bg-gray-800/50 p-1 rounded-full shadow-sm border border-transparent dark:border-gray-700/50">
                                {sortOptions.map(option => {
                                    const Icon = option.icon;
                                    const isActive = sortBy === option.key;
                                    return (
                                        <button
                                            key={option.key}
                                            onClick={() => setSortBy(option.key)}
                                            className={`flex items-center justify-center px-3 py-1.5 text-sm font-semibold rounded-full transition-all duration-300 ${
                                                isActive
                                                    ? 'bg-indigo-600 text-white shadow'
                                                    : 'text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700/50'
                                            }`}
                                        >
                                            <Icon className={`h-4 w-4 mr-2`} />
                                            <span>{option.label}</span>
                                        </button>
                                    );
                                })}
                            </div>
                        </div>

                        <div className="min-h-[600px]">
                            {loading ? (
                                <LoadingSpinner />
                            ) : error ? (
                                <ErrorMessage message={error} onRetry={retryLoadQuestions} />
                            ) : questions.length > 0 ? (
                                <div className="space-y-4">
                                    {questions.map(q => <QuestionCard key={q._id} question={q} />)}
                                </div>
                            ) : (
                                 <div className="flex flex-col items-center justify-center py-20 text-center bg-gray-50 dark:bg-gray-800/30 rounded-lg">
                                    <Frown className="h-12 w-12 text-gray-400 mb-4" />
                                    <h3 className="text-xl font-semibold text-gray-800 dark:text-gray-200">No Questions Here... Yet</h3>
                                    <p className="text-gray-500 dark:text-gray-400 mt-2">
                                        Check back later or be the first to ask a question!
                                    </p>
                                </div>
                            )}
                        </div>

                        {totalPages > 1 && !loading && !error && (
                            <div className="flex justify-center items-center mt-12 space-x-2">
                                <button
                                    onClick={() => handlePageChange(currentPage - 1)}
                                    disabled={currentPage === 1}
                                    className="flex items-center px-3 py-2 text-sm font-medium text-gray-600 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 disabled:opacity-50 transition-colors"
                                >
                                    <ChevronLeft className="h-4 w-4 mr-1" />
                                    Previous
                                </button>
                                {/* A full pagination implementation would go here */}
                                <button
                                    onClick={() => handlePageChange(currentPage + 1)}
                                    disabled={currentPage === totalPages}
                                    className="flex items-center px-3 py-2 text-sm font-medium text-gray-600 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 disabled:opacity-50 transition-colors"
                                >
                                    Next
                                    <ChevronRight className="h-4 w-4 ml-1" />
                                </button>
                            </div>
                        )}
                    </div>
                    <aside className="w-full lg:w-80 lg:sticky top-24 self-start">
                        <CommunitySidebar questions={allQuestionsForSidebar} onTagClick={handleTagClick} />
                    </aside>
                </div>
            </main>
        </div>
    );
}

export default Dashboard;