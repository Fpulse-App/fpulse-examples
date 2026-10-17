import requests
import platform
from typing import Optional, Dict, Any
from dataclasses import dataclass


@dataclass
class FeedbackResult:
    success: bool
    feedback_id: Optional[int] = None
    error: Optional[str] = None


class FeedbackPulse:
    BASE_URL = "https://api.fpulse.app/v1"

    def __init__(
        self,
        api_key: str,
        app_version: str = "1.0.0",
        app_type: str = "desktop",
        environment: str = "production"
    ):
        self.api_key = api_key
        self.app_version = app_version
        self.app_type = app_type
        self.environment = environment
        self.session = requests.Session()
        self.session.headers.update({
            "Content-Type": "application/json",
            "X-API-Key": api_key
        })

    def _get_device_info(self) -> Dict[str, str]:
        return {
            "os": platform.system(),
            "os_version": platform.release(),
            "device_model": platform.machine(),
            "locale": "en_US",  # You might want to detect this
        }

    def submit(
        self,
        sentiment: str,  # "positive" or "negative"
        comment: Optional[str] = None,
        screen_id: Optional[str] = None,
        user_identifier: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> FeedbackResult:
        """Submit feedback to F-Pulse App API."""

        payload = {
            "sentiment": sentiment,
            "app_version": self.app_version,
            "app_type": self.app_type,
            "environment": self.environment,
            "device_info": self._get_device_info()
        }

        if comment:
            payload["comment"] = comment
        if screen_id:
            payload["screen_id"] = screen_id
        if user_identifier:
            payload["user_identifier"] = user_identifier
        if metadata:
            payload["metadata"] = metadata

        try:
            response = self.session.post(
                f"{self.BASE_URL}/feedback",
                json=payload
            )
            data = response.json()

            return FeedbackResult(
                success=data.get("success", False),
                feedback_id=data.get("feedback_id"),
                error=data.get("error")
            )
        except Exception as e:
            return FeedbackResult(success=False, error=str(e))

    def submit_batch(
        self,
        feedbacks: list[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Submit multiple feedback items at once."""

        try:
            response = self.session.post(
                f"{self.BASE_URL}/feedback/batch",
                json={"feedbacks": feedbacks}
            )
            return response.json()
        except Exception as e:
            return {"success": False, "error": str(e)}


# Usage Example
if __name__ == "__main__":
    # Initialize the client
    client = FeedbackPulse(
        api_key="fp_your_api_key_here",
        app_version="2.1.0",
        app_type="desktop"
    )

    # Submit positive feedback
    result = client.submit(
        sentiment="positive",
        comment="The new export feature is amazing!",
        screen_id="export_dialog",
        user_identifier="user@example.com",
        metadata={
            "export_format": "csv",
            "record_count": 1500
        }
    )

    if result.success:
        print(f"Feedback submitted! ID: {result.feedback_id}")
    else:
        print(f"Error: {result.error}")
