=== F-Pulse Feedback Widget ===
Contributors: fpulseapp
Tags: feedback, feedback widget, customer feedback, nps, survey
Requires at least: 6.3
Tested up to: 7.1
Requires PHP: 7.4
Stable tag: 1.0.0
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

Add a feedback button to your site. Visitors rate their experience and leave a comment in two clicks. Free for 1,000 feedbacks a month.

== Description ==

F-Pulse Feedback Widget adds a small feedback button to every page of your WordPress site. Visitors click it, rate their experience and can leave a comment. You see every response in your F-Pulse App dashboard, with sentiment trends, the page each feedback came from, email alerts and AI summaries.

**Why site owners use it**

* Find out what confuses or annoys visitors before they leave.
* Hear from people who would never fill in a contact form.
* See which pages get complaints, so you know what to fix first.

**Features**

* Thumbs, emoji, 1-5 stars or NPS rating, plus an optional comment
* Your colors, title, text and position (bottom right or left)
* Light, dark or automatic theme
* Optional email field, so you can reply to people
* Email alerts for every feedback, only negative feedback, or a daily digest, plus a weekly summary
* AI summaries and suggested actions, Slack, ClickUp and webhooks (paid plans)
* Separate test feedback from a staging site
* Works with any theme and page builder, including block themes, Elementor and Divi
* Loads after your page, so it does not slow your site down

**Free plan:** 1,000 feedbacks a month, no credit card. Paid plans start at $19 a month. See [pricing](https://fpulse.app/pricing).

== External service ==

This plugin loads the feedback widget from the F-Pulse App service (https://fpulse.app), which is required for it to work. Nothing is sent until you enter your widget ID in Settings > F-Pulse Feedback.

* On every public page, the visitor's browser loads the widget script and its settings from https://fpulse.app/w/.
* Loading the widget sends the usual request details to F-Pulse App (IP address, browser user agent and the page address as referrer).
* When a visitor sends feedback, F-Pulse App stores the rating, the comment, the email address (only if you ask for one), the page URL, the IP address and the browser user agent.
* The widget does not set cookies or use browser storage.

F-Pulse App [Terms of Service](https://fpulse.app/terms) and [Privacy Policy](https://fpulse.app/privacy).

== Installation ==

1. Install and activate the plugin.
2. [Create a free F-Pulse App account](https://fpulse.app/auth/register) and turn on the widget on the Widget page.
3. Copy the snippet (or just the widget ID that starts with fp_).
4. In WordPress, go to Settings > F-Pulse Feedback, paste it and click Save Changes.

The feedback button now appears on your site. Change its colors and texts any time in your F-Pulse dashboard; no need to touch WordPress again.

== Frequently Asked Questions ==

= Is it free? =

Yes. The Free plan includes 1,000 feedbacks a month and email alerts. Paid plans add more feedback, AI analysis and integrations.

= Will it slow down my site? =

No. The script is small and loads with defer in the footer, after your content.

= Can I hide the button from myself? =

Yes. Tick "Hide it from administrators" in the plugin settings.

= Can I test it on a staging site first? =

Yes. Choose "Development" as the environment. Feedback from that site is kept separate from your live feedback.

= Does it work with caching plugins? =

Yes. The widget is loaded by the visitor's browser, so cached pages show it too. Clear your cache after you save the settings.

= Where do I see the feedback? =

In your F-Pulse App dashboard at https://fpulse.app/dashboard. You can also get it by email, in Slack or in ClickUp.

== Screenshots ==

1. The feedback button and form on a website.
2. The plugin settings page.
3. Feedback and sentiment trend in the F-Pulse dashboard.

== Changelog ==

= 1.0.0 =
* First release.
