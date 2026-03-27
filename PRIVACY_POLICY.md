# Privacy Policy - LinkedIn Translator

Last updated: March 27, 2026

## 1. Introduction
LinkedIn Translator is designed to help you turn your achievements into professional LinkedIn post drafts quickly and securely. We respect your privacy and do not collect personal information unless you choose to share it in-app.

## 2. Data We Collect
- Input text: the content you type into the translator field (temporary use only to generate the post).
- App settings: tone, length, complexity, and hashtag toggles.
- Usage metadata: local counters and timestamps for daily request limiting.

We do NOT collect or transmit personal contact lists, location, photos, or device identifiers.

## 3. API Key & Third-Party Services
- The app uses Google Gemini API through your configured API key stored locally in `.env` (never checked into Git).
- 3rd-party service calls are limited to text generation requests and are protected by your API key.

## 4. Local Storage
- Shared Preferences: for request count and date to impose a daily limit (20 translations/day).
- No external analytics or crash-tracking libraries are included by default.

## 5. Data Usage
Text you enter is used only to generate a LinkedIn post suggestion in the current session. No text is persisted long-term in our app.

## 6. Security
- API key is kept in `.env` local file and is excluded from version control via `.gitignore`.
- Network access is performed via HTTPS through the provider’s secured endpoint.

## 7. Your Rights
You can:
- clear the input field with the built-in clear button
- reset app state by closing the app (no persistent user profiles)

## 8. Contact
If you have privacy questions, please contact the developer through the app store listing.

---

By using LinkedIn Translator, you agree to this privacy policy.
