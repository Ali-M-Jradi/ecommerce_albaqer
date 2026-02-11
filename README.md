# 💎 AlBaqer Islamic Gemstone E-Commerce Platform

A complete full-stack e-commerce solution for Islamic gemstone jewelry with AI-powered chatbot assistance.

## 🌟 Features

✨ **NEW: AI Chatbot** - Intelligent assistant powered by multi-agent RAG system
- 🤖 Product recommendations
- 📚 Islamic gemstone education
- 💬 Customer support
- 🔍 Smart search assistance

### Platform Features
- **Mobile App** - Flutter iOS/Android app with beautiful UI
- **REST API** - Node.js backend with PostgreSQL database  
- **Product Catalog** - Rings, necklaces, bracelets with Islamic significance
- **Order Management** - Complete shopping cart and checkout flow
- **User Accounts** - Authentication and profile management
- **Multi-Role System** - 4 user roles with complete workflows:
  - 👤 **Customer** - Browse, order, track deliveries
  - 👨‍💼 **Admin** - Manage products, confirm orders, full control
  - 📋 **Manager** - Assign orders to delivery personnel
  - 🚚 **Delivery Man** - View assignments, contact customers, update delivery status

---

## 📂 Project Structure

```
ecommerce_albaqer/
├── albaqer_gemstone_backend/    # Node.js REST API (Port 3000)
│   ├── controllers/             # API controllers
│   ├── routes/                  # API routes
│   ├── middleware/              # Auth & validation
│   ├── docs/                    # ✨ Backend documentation
│   ├── server.js
│   └── README.md
│
├── albaqer_gemstone_flutter/    # Flutter Mobile App
│   ├── lib/
│   │   ├── screens/            # UI screens
│   │   │   └── chatbot_screen.dart  # ✨ NEW: AI Chat Interface
│   │   ├── services/           # API services
│   │   │   └── chatbot_service.dart  # ✨ NEW: Chatbot API Client
│   │   ├── models/             # Data models
│   │   └── repositories/       # Data layer
│   ├── docs/                   # ✨ Flutter documentation
│   └── README.md
│
├── albaqer_chatbot/            # ✨ NEW: AI Chatbot System (Port 8000)
│   ├── agents/                 # 11 specialized AI agents
│   ├── tools/                  # LangChain tools
│   ├── config/                 # LLM configuration
│   ├── database/               # DB connection
│   ├── api_server.py          # FastAPI REST server
│   ├── vector_rag_simple.py   # RAG system with PostgreSQL
│   ├── docs/                  # ✨ Chatbot documentation
│   │   ├── 00_START_HERE.md
│   │   ├── ARCHITECTURE.md
│   │   ├── MOBILE_INTEGRATION_COMPLETE.md
│   │   └── ...
│   └── README.md
│
└── docs/                       # ✨ Project-wide documentation
    ├── DATABASE_SETUP_GUIDE.md
    ├── INTEGRATION_GUIDE.md
    ├── CHATBOT_INTEGRATION_COMPLETE.md
    └── ...
```

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Python 3.9+
- PostgreSQL 14+
- Flutter 3.0+

### 1. Start Backend API

```bash
cd albaqer_gemstone_backend
npm install
node server.js
```
✅ Backend running on `http://localhost:3000`

### 2. Start Chatbot API ✨ NEW

```bash
cd albaqer_chatbot
pip install -r requirements.txt
uvicorn api_server:app --host 0.0.0.0 --port 8000
```
✅ Chatbot running on `http://localhost:8000`

### 3. Run Flutter App

```bash
cd albaqer_gemstone_flutter
flutter pub get

# Update chatbot IP in lib/services/chatbot_service.dart
# Then run:
flutter run
```

---

## 🤖 AI Chatbot System

The chatbot uses a **multi-agent architecture** with 11 specialized agents:

1. **Supervisor Agent** - Routes queries intelligently
2. **Search Agent** - Product search and filtering
3. **Knowledge Agent** - RAG-powered stone education
4. **Recommendation Agent** - Personalized suggestions
5. **Comparison Agent** - Product comparisons
6. **Pricing Agent** - Currency conversion
7. **Delivery Agent** - Shipping information
8. **Payment Agent** - Payment methods
9. **Customer Service** - General support
10. **Cultural Agent** - Islamic guidance
11. **Inventory Agent** - Stock checking

### RAG System
- **Vector Database**: PostgreSQL with JSON embeddings
- **Embeddings**: HuggingFace sentence-transformers (local, free!)
- **Knowledge Base**: 20+ articles about Islamic gemstones
- **Similarity Search**: Python-side cosine similarity

---

## 📱 Using the Chatbot in Flutter

Add to your navigation drawer or app bar:

```dart
import 'screens/chatbot_screen.dart';

// In your navigation:
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

The chatbot screen features:
- ✅ Real-time messaging
- ✅ Connection status indicator
- ✅ Agent routing visibility
- ✅ Message history
- ✅ Beautiful chat bubbles

---

## 📊 System Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Mobile)       │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌─────────┐ ┌──────────────┐
│ Backend │ │   Chatbot    │
│  API    │ │   AI API     │
│ :3000   │ │   :8000      │
└────┬────┘ └──────┬───────┘
     │             │
     │    ┌────────┴────────┐
     │    │                 │
     │    ▼                 ▼
     │  ┌─────────┐  ┌──────────┐
     └─►│PostgreSQL│  │ 11 AI   │
        │ Database │  │ Agents  │
        │          │  │ + RAG   │
        └──────────┘  └──────────┘
```

---

## 📖 Documentation

Each project has its own documentation:

- **Backend**: [`albaqer_gemstone_backend/docs/`](albaqer_gemstone_backend/docs/)
- **Flutter**: [`albaqer_gemstone_flutter/docs/`](albaqer_gemstone_flutter/docs/)
- **Chatbot**: [`albaqer_chatbot/docs/`](albaqer_chatbot/docs/) ⭐ Start here for chatbot setup
- **General**: [`docs/`](docs/)

### Key Documentation Files
- [Chatbot Mobile Integration Guide](albaqer_chatbot/docs/MOBILE_INTEGRATION_COMPLETE.md)
- [Database Setup](docs/DATABASE_SETUP_GUIDE.md)
- [Integration Guide](docs/INTEGRATION_GUIDE.md)

---

## 🛠️ Tech Stack

### Frontend
- Flutter 3.0+
- Dart
- Material Design

### Backend
- Node.js + Express
- PostgreSQL
- JWT Authentication

### AI Chatbot ✨ NEW
- Python 3.9+
- FastAPI
- LangChain
- HuggingFace Transformers
- OpenAI/DeepSeek/Gemini (configurable)
- PostgreSQL (vector storage)

---

## 🎯 API Endpoints

### Backend API (Port 3000)
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/products` - List products
- `POST /api/orders` - Create order
- `GET /api/orders/delivery/my-deliveries` - Get delivery person's assigned orders
- `GET /api/orders/:id/items` - Get order items with product details
- `PUT /api/orders/:id/status` - Update order status

### Chatbot API (Port 8000) ✨ NEW
- `GET /api/health` - Health check
- `POST /api/chat` - Send message to chatbot
- `GET /api/chat/history/{user_id}` - Get chat history
- `DELETE /api/chat/history/{session_id}` - Delete conversation

---

## 🔒 Environment Configuration

### Backend (.env)
```env
DB_HOST=localhost
DB_NAME=albaqer_gemstone_ecommerce_db
DB_USER=postgres
DB_PASSWORD=your_password
JWT_SECRET=your_secret
PORT=3000
```

### Chatbot (.env)
```env
DB_HOST=localhost
DB_NAME=albaqer_gemstone_ecommerce_db
DB_USER=postgres
DB_PASSWORD=your_password
DEEPSEEK_API_KEY=your_key_here
GEMINI_API_KEY=your_key_here
```

---

## 🎉 What's New in This Release

### ✨ AI Chatbot Integration
- Multi-agent system with 11 specialized agents
- RAG-powered knowledge base for gemstone education
- FastAPI REST endpoints for mobile integration
- Chat history tracking per user
- Real-time intelligent routing

### � Delivery Role Complete (P1-6)
- Complete delivery workflow implementation
- **Dashboard**: Order statistics (assigned, in transit, delivered)
- **My Deliveries**: List of orders assigned to delivery person
- **Order Details**: 
  - Customer contact with tap-to-call and SMS
  - Shipping address with Google Maps integration
  - Order items with product details and images
  - Status update buttons (Start Delivery, Mark Delivered)
- **Security**: Entity-level authorization (delivery persons only see their orders)
- **Status Workflow**: Validates status transitions (prevents backwards changes)

### 📱 Flutter Chat Screen
- Beautiful chat UI with message bubbles
- Connection status monitoring
- Agent routing visibility
- Message history
- Easy integration into existing app

### 📚 Documentation Reorganization
- Separate `docs/` folders for each project
- Clear README files with quick start guides
- Comprehensive setup instructions
- [DELIVERY_ROLE_GUIDE.md](docs/DELIVERY_ROLE_GUIDE.md) - Complete delivery setup guide
- [P1-6_DELIVERY_ROLE_SUMMARY.md](docs/P1-6_DELIVERY_ROLE_SUMMARY.md) - Implementation summary

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## 📄 License

This project is for educational purposes.

---

## 🔗 Links

- [Chatbot Setup Guide](albaqer_chatbot/docs/00_START_HERE.md)
- [Mobile Integration Guide](albaqer_chatbot/docs/MOBILE_INTEGRATION_COMPLETE.md)
- [Database Setup](docs/DATABASE_SETUP_GUIDE.md)

---

**Built with ❤️ for the Islamic gemstone community**
