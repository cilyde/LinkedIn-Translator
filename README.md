# LinkedIn Translator

A Flutter app that turns a short description of a work achievement into a polished LinkedIn post draft using Google Gemini. Choose a tone, length, and vocabulary complexity, optionally add hashtags, then review and copy the result.

## Features

- Four tones: Visionary, Professional, Humblebrag, and Thought Leader.
- Short or long drafts, with accessible or advanced vocabulary.
- Optional hashtags and Markdown-formatted output.
- Copy generated text to the clipboard.
- A local limit of 20 generation requests per day.
- Light and dark appearance that follows the device setting.

Generated text is a draft, not a verified account of events. Review it for accuracy before posting; the app's prompting can embellish the impact of the original input.

## Requirements

- Flutter SDK with a Dart version satisfying the constraint in `pubspec.yaml` (`>=3.10.4 <4.0.0`).
- A Google Gemini API key for post generation.
- A configured Flutter target, such as an Android emulator or iOS Simulator.

## Run Locally

1. Clone the repository and enter its directory.
2. Create a `.env` file in the project root with your Gemini API key:

	```dotenv
	GEMINI_API_KEY=your_gemini_api_key
	```

	The `.env` file is listed as a Flutter asset and ignored by Git. Keep your key private; do not commit it or share builds containing a personal key. Keys embedded in a client app can be extracted. For a public or production release, route Gemini requests through a backend that protects the key.

3. Fetch dependencies and start the app on a connected device or simulator:

	```sh
	flutter pub get
	flutter run
	```

The app also attempts generation with a fallback Gemini model if its primary model is unavailable. Requests require network access and are subject to your Google AI project’s model availability, quotas, and billing settings.

## Development

Run static analysis and the test suite with:

```sh
flutter analyze
flutter test
```

The current widget test is still Flutter's starter counter test and does not match this app, so `flutter test` currently fails until that test is replaced.

Build for a configured platform with Flutter's usual build command, for example:

```sh
flutter build apk
flutter build ios
```

Platform builds may require additional platform-specific tools and signing configuration. See the [Flutter documentation](https://docs.flutter.dev/) for setup instructions.

## Privacy

The text you submit is sent to Google Gemini to generate a draft. The app stores the daily request count and date locally; draft text is held in the current app session. Avoid entering confidential or sensitive information. See the [privacy policy](PRIVACY_POLICY.md) for more detail.

## Project Notes

- [Design system](DESIGN_SYSTEM.md)
- [Implementation guide](IMPLEMENTATION_GUIDE.md)
- [UI overhaul notes](UI_OVERHAUL_README.md)
