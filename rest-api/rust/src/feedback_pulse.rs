use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

const BASE_URL: &str = "https://api.fpulse.app/v1";

#[derive(Debug, Serialize)]
pub struct FeedbackRequest {
    pub sentiment: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub comment: Option<String>,
    pub app_version: String,
    pub app_type: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub screen_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub user_identifier: Option<String>,
    pub environment: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub device_info: Option<HashMap<String, String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub metadata: Option<serde_json::Value>,
}

#[derive(Debug, Deserialize)]
pub struct FeedbackResult {
    pub success: bool,
    pub feedback_id: Option<i32>,
    pub error: Option<String>,
}

pub struct FeedbackPulse {
    client: Client,
    api_key: String,
    app_version: String,
    app_type: String,
    environment: String,
}

impl FeedbackPulse {
    pub fn new(api_key: &str, app_version: &str) -> Self {
        Self {
            client: Client::new(),
            api_key: api_key.to_string(),
            app_version: app_version.to_string(),
            app_type: "desktop".to_string(),
            environment: "production".to_string(),
        }
    }

    pub fn with_environment(mut self, env: &str) -> Self {
        self.environment = env.to_string();
        self
    }

    pub fn with_app_type(mut self, app_type: &str) -> Self {
        self.app_type = app_type.to_string();
        self
    }

    fn get_device_info() -> HashMap<String, String> {
        let mut info = HashMap::new();
        info.insert("os".to_string(), std::env::consts::OS.to_string());
        info.insert("arch".to_string(), std::env::consts::ARCH.to_string());
        info
    }

    pub async fn submit(
        &self,
        sentiment: &str,
        comment: Option<&str>,
        screen_id: Option<&str>,
    ) -> Result<FeedbackResult, reqwest::Error> {
        let request = FeedbackRequest {
            sentiment: sentiment.to_string(),
            comment: comment.map(|s| s.to_string()),
            app_version: self.app_version.clone(),
            app_type: self.app_type.clone(),
            screen_id: screen_id.map(|s| s.to_string()),
            user_identifier: None,
            environment: self.environment.clone(),
            device_info: Some(Self::get_device_info()),
            metadata: None,
        };

        self.client
            .post(format!("{}/feedback", BASE_URL))
            .header("Content-Type", "application/json")
            .header("X-API-Key", &self.api_key)
            .json(&request)
            .send()
            .await?
            .json()
            .await
    }
}

// Usage Example
// #[tokio::main]
// async fn main() -> Result<(), Box<dyn std::error::Error>> {
//     let client = FeedbackPulse::new("fp_your_api_key", "2.1.0")
//         .with_environment("production");
//
//     let result = client
//         .submit("positive", Some("Blazing fast!"), Some("main"))
//         .await?;
//
//     if result.success {
//         println!("Feedback submitted! ID: {:?}", result.feedback_id);
//     } else {
//         eprintln!("Error: {:?}", result.error);
//     }
//
//     Ok(())
// }
