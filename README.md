# 🤖 Flutter AI Chat — Gemini Powered

A production-ready AI chat app built with **Flutter**, powered by **Google Gemini API**, with **GetX** state management and **Hive** for local chat history.

---

## ✨ Features

- 🧠 **Gemini 2.0 Flash** — Fast & smart AI responses
- ⚡ **Streaming responses** — Typewriter effect, real-time
- 💬 **Chat history** — Persisted locally with Hive
- 🎨 **Beautiful dark UI** — Clean, modern design
- 📝 **Markdown support** — Code blocks, bold, lists
- 🗑️ **Clear chat** — Reset conversation anytime
- 📱 **Cross-platform** — Android & iOS ready


## 🏗️ Architecture

```
lib/
├── main.dart
├── models/
│   ├── chat_message.dart       # Hive model
│   └── chat_message.g.dart     # Generated adapter
├── controllers/
│   └── chat_controller.dart    # GetX controller
└── screens/
    └── chat_screen.dart        # Main UI
```

---

## 🚀 Getting Started

### 1. Clone the repo
```bash
git clone https://github.com/YOUR_USERNAME/flutter_ai_chat.git
cd flutter_ai_chat
```

### 2. Get your FREE Gemini API Key
- Go to [https://ai.google.dev](https://ai.google.dev)
- Click **Get API Key** → **Create API key**
- It's completely free!

### 3. Add your API key
Open `lib/controllers/chat_controller.dart` and replace:
```dart
static const _apiKey = 'YOUR_GEMINI_API_KEY';
```

### 4. Install dependencies & run
```bash
flutter pub get
flutter run
```

---

## 📦 Packages Used

| Package | Purpose |
|---|---|
| `google_generative_ai` | Gemini API |
| `get` | State management |
| `hive_flutter` | Local storage |
| `flutter_animate` | Animations |
| `flutter_markdown` | Markdown rendering |
| `google_fonts` | Typography |
| `iconsax` | Icons |

---

## 🔑 Free Tier Limits (Gemini API)

- ✅ 15 requests/minute
- ✅ 1,500 requests/day
- ✅ No credit card required

---

## 👨‍💻 Author

**Flutter by Sunny**
- GitHub: [@flutterbysunny](https://github.com/flutterbysunny)

---

## ⭐ Star this repo if it helped you!