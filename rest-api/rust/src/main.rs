mod feedback_pulse;

use feedback_pulse::FeedbackPulse;

// Run with: FPULSE_API_KEY=fp_your_api_key cargo run
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let api_key = std::env::var("FPULSE_API_KEY").expect("Set FPULSE_API_KEY to your project API key (fp_...)");
    let client = FeedbackPulse::new(&api_key, "2.1.0")
        .with_app_type("desktop")
        .with_environment("development");

    let result = client
        .submit("positive", Some("Blazing fast!"), Some("main"))
        .await?;

    if result.success {
        println!("Feedback submitted! ID: {:?}", result.feedback_id);
    } else {
        eprintln!("Error: {:?}", result.error);
    }

    Ok(())
}
