async function submitFeedback(sentiment, comment) {
  const response = await fetch('https://api.fpulse.app/v1/feedback', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-API-Key': 'fp_your_api_key_here'
    },
    body: JSON.stringify({
      sentiment: sentiment,  // 'positive' or 'negative' (classic mode)
      // OR use rating types:
      // rating_type: 'stars',   // 'emoji', 'stars', or 'nps'
      // rating_score: 5,        // auto-normalized to positive/negative
      comment: comment,
      app_version: '2.1.0',
      app_type: 'web',
      screen_id: window.location.pathname,
      environment: process.env.NODE_ENV === 'production' ? 'production' : 'development'
    })
  });

  const data = await response.json();

  if (data.success) {
    console.log('Feedback submitted:', data.feedback_id);
  } else {
    console.error('Error:', data.error);
  }

  return data;
}

// Usage
submitFeedback('positive', 'Great new feature!');
