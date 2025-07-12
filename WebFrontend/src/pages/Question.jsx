import React, { useEffect, useState, useCallback } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { getQuestionById, addAnswer, upvoteAnswer, downvoteAnswer, getMe } from '../api/api';
import { 
  ChevronUp, 
  ChevronDown, 
  MessageSquare, 
  User, 
  Calendar, 
  Tag, 
  Home, 
  ChevronRight, 
  Clock, 
  Eye,
  Share2,
  BookmarkPlus,
  Flag,
  Edit,
  Award,
  Check,
  X,
  Send,
  AtSign,
  Bold,
  Italic,
  Link as LinkIcon,
  Code,
  List,
  ListOrdered,
  Quote,
  Smile
} from 'lucide-react';

function Question() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [question, setQuestion] = useState(null);
  const [answerBody, setAnswerBody] = useState('');
  const [currentUser, setCurrentUser] = useState(null);
  const [mentionSuggestions, setMentionSuggestions] = useState([]);
  const [mentions, setMentions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submittingAnswer, setSubmittingAnswer] = useState(false);
  const [activeTab, setActiveTab] = useState('answer');

  // Load question data
  const load = useCallback(async () => {
    try {
      setLoading(true);
      const res = await getQuestionById(id);
      setQuestion(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, [id]);

  // Fetch question and current user on mount
  useEffect(() => {
    load();
    const fetchUser = async () => {
      try {
        const res = await getMe();
        setCurrentUser(res.data);
      } catch (err) {
        console.error(err);
      }
    };
    fetchUser();
  }, [load]);

  const handleAddAnswer = async () => {
    if (!currentUser) {
      alert('You must be logged in to post an answer.');
      return;
    }
    
    if (!answerBody.trim()) {
      alert('Please enter an answer before submitting.');
      return;
    }

    try {
      setSubmittingAnswer(true);
      await addAnswer(id, {
        body: answerBody,
        mentions,
        userId: currentUser._id,
        userName: currentUser.name
      });
      setAnswerBody('');
      setMentions([]);
      await load();
    } catch (err) {
      console.error(err);
      alert('Failed to submit answer. Please try again.');
    } finally {
      setSubmittingAnswer(false);
    }
  };

  const handleUpvote = async (answerId) => {
    try {
      await upvoteAnswer(answerId);
      await load();
    } catch (err) {
      console.error(err);
    }
  };

  const handleDownvote = async (answerId) => {
    try {
      await downvoteAnswer(answerId);
      await load();
    } catch (err) {
      console.error(err);
    }
  };

  const handleInputChange = (e) => {
    const val = e.target.value;
    setAnswerBody(val);

    // Detect @ trigger for mention suggestions
    const atIndex = val.lastIndexOf('@');
    if (atIndex !== -1 && question?.answers) {
      const typed = val.slice(atIndex + 1).toLowerCase();
      const uniqueUsers = [
        ...new Map(
          question.answers.map(a => [a.userId, { userId: a.userId, userName: a.userName }])
        ).values()
      ];

      const suggestions = uniqueUsers.filter(u =>
        u.userName && u.userName.toLowerCase().startsWith(typed)
      );

      setMentionSuggestions(suggestions);
    } else {
      setMentionSuggestions([]);
    }
  };

  const handleSelectMention = (user) => {
    const atIndex = answerBody.lastIndexOf('@');
    const newText = answerBody.substring(0, atIndex) + '@' + user.userName + ' ';
    setAnswerBody(newText);

    if (!mentions.includes(user.userId)) {
      setMentions([...mentions, user.userId]);
    }

    setMentionSuggestions([]);
  };

  const formatDate = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    const now = new Date();
    const diffTime = Math.abs(now - date);
    const diffMinutes = Math.ceil(diffTime / (1000 * 60));
    const diffHours = Math.ceil(diffTime / (1000 * 60 * 60));
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffMinutes < 60) return `asked ${diffMinutes} minutes ago`;
    if (diffHours < 24) return `asked ${diffHours} hours ago`;
    if (diffDays === 1) return 'asked yesterday';
    if (diffDays < 7) return `asked ${diffDays} days ago`;
    return `asked ${date.toLocaleDateString()}`;
  };

  const VoteControls = ({ item, onUpvote, onDownvote }) => (
    <div className="flex flex-col items-center space-y-2 mr-4">
      <button 
        onClick={() => onUpvote(item._id)}
        className="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors group"
      >
        <ChevronUp className="w-6 h-6 text-gray-400 group-hover:text-green-500" />
      </button>
      <span className="text-lg font-semibold text-gray-600 dark:text-gray-300">
        {(item.upvotes || 0) - (item.downvotes || 0)}
      </span>
      <button 
        onClick={() => onDownvote(item._id)}
        className="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors group"
      >
        <ChevronDown className="w-6 h-6 text-gray-400 group-hover:text-red-500" />
      </button>
      <button className="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors">
        <BookmarkPlus className="w-5 h-5 text-gray-400" />
      </button>
    </div>
  );

  const UserCard = ({ user, date, action = 'asked' }) => (
    <div className="bg-blue-50 dark:bg-blue-900/20 p-3 rounded-lg">
      <div className="text-xs text-gray-500 dark:text-gray-400 mb-2">{action} {formatDate(date)}</div>
      <div className="flex items-center space-x-2">
        <img 
          className="w-8 h-8 rounded-full"
          src={user?.avatarUrl || `https://api.dicebear.com/8.x/lorelei/svg?seed=${user?.name || 'anonymous'}`}
          alt={user?.name || 'Anonymous'}
        />
        <div>
          <div className="font-medium text-sm text-blue-600 dark:text-blue-400">
            {user?.name || 'Anonymous'}
          </div>
          <div className="text-xs text-gray-500 dark:text-gray-400">
            {user?.reputation || 1} reputation
          </div>
        </div>
      </div>
    </div>
  );

  const EditorToolbar = () => (
    <div className="flex items-center space-x-1 p-2 border-b border-gray-200 dark:border-gray-700">
      <button className="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700">
        <Bold className="w-4 h-4" />
      </button>
      <button className="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700">
        <Italic className="w-4 h-4" />
      </button>
      <button className="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700">
        <LinkIcon className="w-4 h-4" />
      </button>
      <button className="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700">
        <Code className="w-4 h-4" />
      </button>
      <button className="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700">
        <List className="w-4 h-4" />
      </button>
      <button className="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700">
        <ListOrdered className="w-4 h-4" />
      </button>
      <button className="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700">
        <Quote className="w-4 h-4" />
      </button>
      <button className="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700">
        <Smile className="w-4 h-4" />
      </button>
    </div>
  );

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-400">Loading question...</p>
        </div>
      </div>
    );
  }

  if (!question) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <p className="text-gray-600 dark:text-gray-400">Question not found</p>
          <button 
            onClick={() => navigate('/')}
            className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            Back to Home
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Header */}
      <header className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-4">
              <Link to="/" className="text-blue-600 hover:text-blue-800 font-semibold">
                DevDiscuss
              </Link>
            </div>
            <div className="flex items-center space-x-3">
              <Link to="/profile" className="flex items-center space-x-2 hover:bg-gray-100 dark:hover:bg-gray-700 px-3 py-2 rounded-lg">
                <img 
                  className="w-6 h-6 rounded-full"
                  src={currentUser?.avatarUrl || `https://api.dicebear.com/8.x/lorelei/svg?seed=${currentUser?.name || 'user'}`}
                  alt="Profile"
                />
                <span className="text-sm font-medium">{currentUser?.name || 'User'}</span>
              </Link>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {/* Breadcrumb */}
        <nav className="flex items-center space-x-2 text-sm text-gray-600 dark:text-gray-400 mb-6">
          <Link to="/" className="hover:text-blue-600 flex items-center">
            <Home className="w-4 h-4 mr-1" />
            Home
          </Link>
          <ChevronRight className="w-4 h-4" />
          <Link to="/" className="hover:text-blue-600">Questions</Link>
          <ChevronRight className="w-4 h-4" />
          <span className="text-gray-900 dark:text-gray-100 font-medium truncate max-w-96">
            {question.title}
          </span>
        </nav>

        {/* Question Header */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 mb-6">
          <div className="p-6">
            <div className="flex items-start justify-between mb-4">
              <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100 pr-4">
                {question.title}
              </h1>
              <div className="flex items-center space-x-2 flex-shrink-0">
                <button className="p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700">
                  <Share2 className="w-5 h-5" />
                </button>
                <button className="p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700">
                  <Flag className="w-5 h-5" />
                </button>
                <button className="p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700">
                  <Edit className="w-5 h-5" />
                </button>
              </div>
            </div>

            <div className="flex items-center space-x-6 text-sm text-gray-600 dark:text-gray-400 mb-6">
              <div className="flex items-center space-x-1">
                <Clock className="w-4 h-4" />
                <span>{formatDate(question.createdAt)}</span>
              </div>
              <div className="flex items-center space-x-1">
                <Eye className="w-4 h-4" />
                <span>{question.views || 0} views</span>
              </div>
              <div className="flex items-center space-x-1">
                <MessageSquare className="w-4 h-4" />
                <span>{question.answers?.length || 0} answers</span>
              </div>
            </div>

            {/* Question Content */}
            <div className="flex">
              <VoteControls 
                item={question} 
                onUpvote={handleUpvote} 
                onDownvote={handleDownvote} 
              />
              <div className="flex-1">
                <div className="prose dark:prose-invert max-w-none mb-6">
                  <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                    {question.body}
                  </p>
                </div>

                {/* Tags */}
                <div className="flex flex-wrap gap-2 mb-6">
                  {question.tags?.map((tag, index) => (
                    <span 
                      key={index}
                      className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300"
                    >
                      <Tag className="w-3 h-3 mr-1" />
                      {tag}
                    </span>
                  ))}
                </div>

                {/* Author Info */}
                <div className="flex justify-end">
                  <UserCard user={question.user} date={question.createdAt} />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Answers Section */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 mb-6">
          <div className="p-6">
            <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100 mb-6">
              {question.answers?.length || 0} Answer{(question.answers?.length || 0) !== 1 ? 's' : ''}
            </h2>

            {question.answers?.map((answer, index) => (
              <div key={answer._id} className={`${index > 0 ? 'border-t border-gray-200 dark:border-gray-700 pt-6' : ''} mb-6`}>
                <div className="flex">
                  <VoteControls 
                    item={answer} 
                    onUpvote={handleUpvote} 
                    onDownvote={handleDownvote} 
                  />
                  <div className="flex-1">
                    <div className="prose dark:prose-invert max-w-none mb-6">
                      <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                        {answer.body}
                      </p>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4 text-sm text-gray-500 dark:text-gray-400">
                        <button className="hover:text-blue-600 transition-colors">Share</button>
                        <button className="hover:text-blue-600 transition-colors">Edit</button>
                        <button className="hover:text-blue-600 transition-colors">Flag</button>
                      </div>
                      <UserCard user={{ name: answer.userName }} date={answer.createdAt} action="answered" />
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Answer Form */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">
              Your Answer
            </h3>

            <div className="border border-gray-200 dark:border-gray-700 rounded-lg mb-4">
              <EditorToolbar />
              <div className="relative">
                <textarea
                  value={answerBody}
                  onChange={handleInputChange}
                  placeholder="Write your answer here... (Use @ to mention other users)"
                  className="w-full p-4 border-0 resize-none focus:ring-0 focus:outline-none bg-transparent text-gray-900 dark:text-gray-100"
                  rows="8"
                />
                
                {/* Mention Suggestions */}
                {mentionSuggestions.length > 0 && (
                  <div className="absolute bottom-full left-4 mb-2 w-64 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg z-10">
                    <div className="p-2 border-b border-gray-200 dark:border-gray-700">
                      <div className="flex items-center space-x-2 text-sm text-gray-600 dark:text-gray-400">
                        <AtSign className="w-4 h-4" />
                        <span>Mention users</span>
                      </div>
                    </div>
                    <div className="max-h-48 overflow-y-auto">
                      {mentionSuggestions.map(user => (
                        <button
                          key={user.userId}
                          onClick={() => handleSelectMention(user)}
                          className="w-full flex items-center space-x-3 p-3 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors text-left"
                        >
                          <img 
                            className="w-6 h-6 rounded-full"
                            src={`https://api.dicebear.com/8.x/lorelei/svg?seed=${user.userName}`}
                            alt={user.userName}
                          />
                          <span className="text-sm text-gray-900 dark:text-gray-100">
                            @{user.userName}
                          </span>
                        </button>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>

            <div className="flex items-center justify-between">
              <div className="text-sm text-gray-500 dark:text-gray-400">
                <p>
                  Thanks for contributing an answer! Please be sure to answer the question and provide details.
                </p>
              </div>
              <button
                onClick={handleAddAnswer}
                disabled={submittingAnswer || !answerBody.trim()}
                className="flex items-center space-x-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {submittingAnswer ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    <span>Posting...</span>
                  </>
                ) : (
                  <>
                    <Send className="w-4 h-4" />
                    <span>Post Your Answer</span>
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Question;