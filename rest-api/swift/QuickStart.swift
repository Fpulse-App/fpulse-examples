import FeedbackPulse

// 1. Configure in your App init
FeedbackPulse.configure(apiKey: "fp_your_api_key")

// 2. Submit feedback programmatically
FeedbackPulse.submit(sentiment: .positive, comment: "Great app!") { result in
    switch result {
    case .success(let response):
        print("Submitted: \(response.feedbackId)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Or use async/await (iOS 15+)
let response = try await FeedbackPulse.submit(sentiment: .positive)

// 3. Or use the built-in SwiftUI view
Button("Feedback") { showFeedback = true }
    .feedbackSheet(isPresented: $showFeedback)
