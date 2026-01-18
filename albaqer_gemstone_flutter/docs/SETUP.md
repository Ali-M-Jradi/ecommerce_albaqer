# Flutter App Documentation

## Project Structure

```
lib/
├── models/          # Data models
├── repositories/    # Data repositories
├── screens/         # UI screens
│   ├── chatbot_screen.dart  # NEW: AI Chatbot
│   ├── home_screen.dart
│   ├── products_screen.dart
│   └── ...
├── services/        # API services
│   ├── chatbot_service.dart  # NEW: Chatbot API
│   ├── product_service.dart
│   └── ...
└── main.dart        # App entry point
```

## New Features

### AI Chatbot Integration ✨
- Real-time chat with AI assistant
- Multi-agent support for specialized queries
- Product recommendations
- Islamic gemstone education
- Order tracking assistance

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Update chatbot service IP in `lib/services/chatbot_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:8000/api';
```

3. Run app:
```bash
flutter run
```

## Adding Chatbot to Navigation

In your drawer or navigation:
```dart
ListTile(
  leading: Icon(Icons.chat),
  title: Text('AI Assistant'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotScreen(userId: currentUserId),
      ),
    );
  },
)
```

## Backend Requirements

- AlBaqer Backend API running on port 3000
- Chatbot API running on port 8000

See respective README files for setup instructions.
