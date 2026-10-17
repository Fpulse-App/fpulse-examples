package feedbackpulse

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"runtime"
	"time"
)

const baseURL = "https://api.fpulse.app/v1"

type Client struct {
	APIKey      string
	AppVersion  string
	AppType     string
	Environment string
	HTTPClient  *http.Client
}

type FeedbackRequest struct {
	Sentiment      string                 `json:"sentiment"`
	Comment        string                 `json:"comment,omitempty"`
	AppVersion     string                 `json:"app_version"`
	AppType        string                 `json:"app_type"`
	ScreenID       string                 `json:"screen_id,omitempty"`
	UserIdentifier string                 `json:"user_identifier,omitempty"`
	Environment    string                 `json:"environment"`
	DeviceInfo     map[string]string      `json:"device_info,omitempty"`
	Metadata       map[string]interface{} `json:"metadata,omitempty"`
}

type FeedbackResult struct {
	Success    bool   `json:"success"`
	FeedbackID int    `json:"feedback_id,omitempty"`
	Error      string `json:"error,omitempty"`
}

func NewClient(apiKey, appVersion string) *Client {
	return &Client{
		APIKey:      apiKey,
		AppVersion:  appVersion,
		AppType:     "desktop",
		Environment: "production",
		HTTPClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

func (c *Client) Submit(sentiment, comment, screenID string) (*FeedbackResult, error) {
	req := FeedbackRequest{
		Sentiment:   sentiment,
		Comment:     comment,
		AppVersion:  c.AppVersion,
		AppType:     c.AppType,
		ScreenID:    screenID,
		Environment: c.Environment,
		DeviceInfo: map[string]string{
			"os":         runtime.GOOS,
			"os_version": runtime.Version(),
			"arch":       runtime.GOARCH,
		},
	}

	return c.doRequest("POST", "/feedback", req)
}

func (c *Client) SubmitWithMetadata(
	sentiment, comment, screenID, userID string,
	metadata map[string]interface{},
) (*FeedbackResult, error) {
	req := FeedbackRequest{
		Sentiment:      sentiment,
		Comment:        comment,
		AppVersion:     c.AppVersion,
		AppType:        c.AppType,
		ScreenID:       screenID,
		UserIdentifier: userID,
		Environment:    c.Environment,
		Metadata:       metadata,
		DeviceInfo: map[string]string{
			"os":         runtime.GOOS,
			"os_version": runtime.Version(),
			"arch":       runtime.GOARCH,
		},
	}

	return c.doRequest("POST", "/feedback", req)
}

func (c *Client) doRequest(method, endpoint string, body interface{}) (*FeedbackResult, error) {
	jsonData, err := json.Marshal(body)
	if err != nil {
		return nil, fmt.Errorf("marshal error: %w", err)
	}

	req, err := http.NewRequest(method, baseURL+endpoint, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("request error: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-API-Key", c.APIKey)

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("http error: %w", err)
	}
	defer resp.Body.Close()

	var result FeedbackResult
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decode error: %w", err)
	}

	return &result, nil
}

// Usage Example
// func main() {
//     client := feedbackpulse.NewClient("fp_your_api_key", "2.1.0")
//     client.Environment = "production"
//
//     result, err := client.Submit("positive", "Great CLI tool!", "main")
//     if err != nil {
//         log.Fatal(err)
//     }
//
//     if result.Success {
//         fmt.Printf("Feedback submitted! ID: %d\n", result.FeedbackID)
//     }
// }
