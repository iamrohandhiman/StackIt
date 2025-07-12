import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { createQuestion } from '../api/api'; // Assuming your API function is here
import { HelpCircle, Tag, Send, ChevronLeft } from 'lucide-react';

function CreateQuestion() {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [tags, setTags] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!title.trim() || !body.trim()) {
      alert('Please fill in both the title and body for the question.');
      return;
    }
    
    setIsSubmitting(true);
    try {
      // The API call now correctly includes the title
      await createQuestion({ 
        title, 
        body, 
        tags: tags.split(',').map(t => t.trim()).filter(t => t) // Filter out empty tags
      });
      alert('Question posted successfully!');
      navigate('/dashboard'); // Navigate to a relevant page after posting
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.message || 'An error occurred while posting the question.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center p-4">
      <div className="w-full max-w-2xl">
        <button 
          onClick={() => navigate(-1)} // Go back to the previous page
          className="flex items-center space-x-2 text-sm text-blue-600 dark:text-blue-400 hover:underline mb-6"
        >
          <ChevronLeft className="w-4 h-4" />
          <span>Back</span>
        </button>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md border border-gray-200 dark:border-gray-700">
          <div className="p-6 border-b border-gray-200 dark:border-gray-700">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100 flex items-center">
              <HelpCircle className="w-7 h-7 mr-3 text-blue-500" />
              Ask a Public Question
            </h2>
          </div>
          
          <form onSubmit={handleSubmit}>
            <div className="p-6 space-y-6">
              {/* Title Input */}
              <div>
                <label htmlFor="question-title" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Title
                </label>
                <input 
                  id="question-title"
                  type="text" 
                  placeholder="e.g. How to center a div in CSS?"
                  value={title}
                  onChange={e => setTitle(e.target.value)} 
                  className="w-full px-4 py-2 bg-gray-50 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                />
                <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">Be specific and imagine you’re asking a question to another person.</p>
              </div>

              {/* Body Textarea */}
              <div>
                <label htmlFor="question-body" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Body
                </label>
                <textarea 
                  id="question-body"
                  placeholder="Include all the information someone would need to answer your question..." 
                  value={body}
                  onChange={e => setBody(e.target.value)}
                  className="w-full px-4 py-2 bg-gray-50 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                  rows="8"
                />
              </div>

              {/* Tags Input */}
              <div>
                <label htmlFor="question-tags" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Tags
                </label>
                <div className="relative">
                  <Tag className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                  <input
                    id="question-tags" 
                    placeholder="e.g. react,javascript,css" 
                    value={tags}
                    onChange={e => setTags(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 bg-gray-50 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                  />
                </div>
                <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">Add up to 5 tags to describe what your question is about. Use comma to separate tags.</p>
              </div>
            </div>

            {/* Footer and Submit Button */}
            <div className="bg-gray-50 dark:bg-gray-800/50 px-6 py-4 border-t border-gray-200 dark:border-gray-700 flex justify-end">
              <button 
                type="submit"
                disabled={isSubmitting}
                className="flex items-center justify-center space-x-2 px-6 py-2.5 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                {isSubmitting ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    <span>Posting...</span>
                  </>
                ) : (
                  <>
                    <Send className="w-4 h-4" />
                    <span>Post Question</span>
                  </>
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

export default CreateQuestion;