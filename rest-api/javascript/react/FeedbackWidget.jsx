import { useState } from 'react';

const API_KEY = process.env.REACT_APP_FPULSE_API_KEY;
const API_URL = 'https://api.fpulse.app/v1/feedback';

function FeedbackWidget({ screenId }) {
  const [comment, setComment] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);

  const submitFeedback = async (sentiment) => {
    setLoading(true);

    try {
      const response = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': API_KEY
        },
        body: JSON.stringify({
          sentiment,
          comment,
          app_version: process.env.REACT_APP_VERSION || '1.0.0',
          app_type: 'web',
          screen_id: screenId,
          environment: process.env.NODE_ENV
        })
      });

      const data = await response.json();

      if (data.success) {
        setSubmitted(true);
      }
    } catch (error) {
      console.error('Feedback error:', error);
    } finally {
      setLoading(false);
    }
  };

  if (submitted) {
    return <div>Thank you for your feedback!</div>;
  }

  return (
    <div className="feedback-widget">
      <p>How was your experience?</p>
      <textarea
        value={comment}
        onChange={(e) => setComment(e.target.value)}
        placeholder="Tell us more (optional)"
      />
      <div>
        <button onClick={() => submitFeedback('positive')} disabled={loading}>
          Good
        </button>
        <button onClick={() => submitFeedback('negative')} disabled={loading}>
          Bad
        </button>
      </div>
    </div>
  );
}
