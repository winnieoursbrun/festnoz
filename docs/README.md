# 🎵 FestNoz - Track Artists, Catch Them Live

A modern web application for tracking your favorite artists and discovering their concerts on an interactive map.

## Features

- 🎭 **Follow Artists**: Track your favorite musicians
- 🗺️ **Interactive Map**: Find concerts happening near you using Leaflet
- 📍 **Location-Based Search**: Discover concerts by proximity
- 🎫 **Concert Information**: Get details, dates, venues, and ticket links
- 👤 **User Dashboard**: View followed artists and upcoming shows
- 🔐 **Secure Authentication**: JWT-based authentication with Devise
- 🛠️ **Admin Panel**: Manage artists and concerts (admin users only)

## Tech Stack

### Backend
- **Rails 8.1.1** - Modern Rails with PostgreSQL
- **Devise + JWT** - Token-based authentication
- **PostgreSQL** - Database with geographic queries (Haversine formula)
- **CORS** - Configured for Vite dev server
- **JSON:API** - API serialization

### Frontend
- **Vue 3** - Progressive JavaScript framework
- **Vite** - Next-generation frontend tooling
- **Pinia** - Vue state management
- **Vue Router** - Client-side routing
- **Tailwind CSS** - Utility-first CSS framework
- **Leaflet** - Interactive maps with OpenStreetMap
- **Axios** - HTTP client with interceptors

## Installation

### Prerequisites
- Ruby 3.3.6+ (via rbenv or asdf - NOT mise)
- Node.js 18+ and npm
- PostgreSQL 14+

### Setup

```bash
# Install dependencies
bundle install
npm install

# Database setup
rails db:create
rails db:migrate
rails db:seed

# Start servers
bin/dev
# Or separately:
# rails server (port 3000)
# npm run dev (port 5173)
```

### Test Credentials
- Admin: `admin@festnoz.com` / `password123`
- User: `user@example.com` / `password123`

## Development URLs
- Frontend: http://127.0.0.1:3000
- Backend API: http://127.0.0.1:3000/api/v1

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Create account
- `POST /api/auth/login` - Login
- `DELETE /api/auth/logout` - Logout
- `GET /api/v1/auth/me` - Current user

### Artists
- `GET /api/v1/artists` - List artists
- `GET /api/v1/artists/:id` - Artist details
- `POST /api/v1/artists` - Create (admin)
- `PUT /api/v1/artists/:id` - Update (admin)
- `DELETE /api/v1/artists/:id` - Delete (admin)

### Concerts
- `GET /api/v1/concerts` - List concerts
- `GET /api/v1/concerts/upcoming` - Upcoming concerts
- `GET /api/v1/concerts/nearby` - Nearby concerts
- `POST /api/v1/concerts` - Create (admin)
- `PUT /api/v1/concerts/:id` - Update (admin)
- `DELETE /api/v1/concerts/:id` - Delete (admin)

### Following
- `GET /api/v1/user/followed_artists` - List followed
- `POST /api/v1/user/followed_artists` - Follow artist
- `DELETE /api/v1/user/followed_artists/:id` - Unfollow

## Project Structure

```
festnoz/
├── app/
│   ├── controllers/api/v1/    # API controllers
│   ├── models/                # ActiveRecord models
│   ├── serializers/           # JSON:API serializers
│   └── frontend/              # Vue application
│       ├── components/        # Vue components
│       ├── views/             # Vue pages
│       ├── stores/            # Pinia stores
│       └── services/          # API services
├── config/
│   ├── initializers/
│   │   ├── devise.rb          # JWT config
│   │   └── cors.rb            # CORS settings
│   └── routes.rb              # Routes
├── db/
│   ├── migrate/               # Migrations
│   └── seeds.rb               # Seed data
└── vite.config.js             # Vite config
```

## License

MIT License - Made with ❤️ for music
