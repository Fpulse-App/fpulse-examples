import android.content.Context
import android.os.Build
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.*

class FeedbackPulse(
    private val apiKey: String,
    private val context: Context,
    private val environment: String = "production"
) {
    companion object {
        private const val BASE_URL = "https://api.fpulse.app/v1"
    }

    data class FeedbackResult(
        val success: Boolean,
        val feedbackId: Int? = null,
        val error: String? = null
    )

    suspend fun submit(
        sentiment: String,
        comment: String? = null,
        screenId: String? = null,
        userIdentifier: String? = null,
        metadata: Map<String, Any>? = null
    ): FeedbackResult = withContext(Dispatchers.IO) {
        try {
            val url = URL("$BASE_URL/feedback")
            val connection = url.openConnection() as HttpURLConnection

            connection.requestMethod = "POST"
            connection.setRequestProperty("Content-Type", "application/json")
            connection.setRequestProperty("X-API-Key", apiKey)
            connection.doOutput = true

            val appVersion = context.packageManager
                .getPackageInfo(context.packageName, 0).versionName

            val deviceInfo = JSONObject().apply {
                put("os", "Android")
                put("os_version", Build.VERSION.RELEASE)
                put("device_model", "${Build.MANUFACTURER} ${Build.MODEL}")
                put("locale", Locale.getDefault().toString())
                put("timezone", TimeZone.getDefault().id)
            }

            val body = JSONObject().apply {
                put("sentiment", sentiment)
                put("app_version", appVersion)
                put("app_type", "android")
                put("environment", environment)
                put("device_info", deviceInfo)
                comment?.let { put("comment", it) }
                screenId?.let { put("screen_id", it) }
                userIdentifier?.let { put("user_identifier", it) }
                metadata?.let { put("metadata", JSONObject(it)) }
            }

            connection.outputStream.bufferedWriter().use {
                it.write(body.toString())
            }

            val responseCode = connection.responseCode
            val response = if (responseCode == HttpURLConnection.HTTP_CREATED) {
                connection.inputStream.bufferedReader().readText()
            } else {
                connection.errorStream.bufferedReader().readText()
            }

            val json = JSONObject(response)
            FeedbackResult(
                success = json.getBoolean("success"),
                feedbackId = if (json.has("feedback_id")) json.getInt("feedback_id") else null,
                error = if (json.has("error")) json.getString("error") else null
            )
        } catch (e: Exception) {
            FeedbackResult(success = false, error = e.message)
        }
    }
}

// Usage Example (in a ViewModel or Activity)
class MyViewModel : ViewModel() {
    private val feedbackPulse = FeedbackPulse(
        apiKey = "fp_your_api_key_here",
        context = applicationContext
    )

    fun submitFeedback(isPositive: Boolean, comment: String?) {
        viewModelScope.launch {
            val result = feedbackPulse.submit(
                sentiment = if (isPositive) "positive" else "negative",
                comment = comment,
                screenId = "main_screen"
            )

            if (result.success) {
                Log.d("Feedback", "Submitted: ${result.feedbackId}")
            } else {
                Log.e("Feedback", "Error: ${result.error}")
            }
        }
    }
}
