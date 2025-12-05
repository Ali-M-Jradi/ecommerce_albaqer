# E-Commerce Albaqer

A complete e-commerce platform with Node.js backend and Flutter mobile app.

## Project Structure

```
ecommerce_albaqer/
├── ecommerce_albaqer_backend/    # Node.js + Express + Supabase
│   ├── controllers/
│   ├── routes/
│   ├── sql/
│   ├── index.js
│   ├── supabaseClient.js
│   ├── package.json
│   └── .env.example
└── ecommerce_albaqer_flutter/    # Flutter mobile app (coming soon)
    ├── lib/
    ├── pubspec.yaml
    └── README.md
```

## Getting Started

### Backend Setup

```bash
cd ecommerce_albaqer_backend
npm install
cp .env.example .env
# Add your Supabase credentials to .env
npm start
```

### Flutter App Setup

```bash
cd ecommerce_albaqer_flutter
flutter pub get
flutter run
```

## Documentation

- Backend API: See `ecommerce_albaqer_backend/README.md`
- Database Schema: See `ecommerce_albaqer_backend/sql/init.sql`
- Flutter App: See `ecommerce_albaqer_flutter/README.md` (coming soon)

## Technologies

- **Backend:** Node.js, Express, Supabase (PostgreSQL)
- **Frontend:** Flutter, Dart
- **Database:** PostgreSQL (Supabase)
- **Hosting:** Supabase, Render/Railway (backend)

## Authors

- Ali-M-Jradi

## License

ISC
