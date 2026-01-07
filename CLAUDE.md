# CLAUDE.md

This file provides guidance for Claude Code when working with this repository.

## Project Overview

FestNoz is a concert tracking application for Breton music, built with Rails 8.1.1 API backend and Vue 3 + Vite frontend. Users can follow artists, discover concerts on an interactive map, and get location-based recommendations.

## Development Commands

```bash
# Install dependencies
bundle install
npm install

# Database setup (requires PostgreSQL)
rails db:create
rails db:migrate
rails db:seed

# Start development servers (both Rails + Vite)
bin/dev

# Or start separately:
rails server              # Backend on port 3000
npm run dev               # Frontend on port 5173

# Build frontend for production
npm run build

# Run tests
npm test                  # Frontend tests (watch mode)
npm run test:run          # Frontend tests (run once)
npm run test:ui           # Frontend tests with UI
npm run test:coverage     # Frontend tests with coverage
rails test                # Backend tests (if configured)

# Run linting
bundle exec rubocop       # Ruby
npm run lint              # JS (if configured)

# Security checks
bundle exec brakeman      # Rails security scanner
bundle exec bundler-audit # Gem vulnerability check
```

## Test Credentials (from seeds)

- Admin: `admin@example.com` / `password`
- User 1: `user@example.com` / `password`
- User 2: `breizh@example.com` / `password`

## Architecture

### Backend (Rails API)

- **Framework**: Rails 8.1.1 (API mode with Vite integration)
- **Database**: PostgreSQL with geographic queries (geocoder gem for location services)
- **Geocoding**: geocoder gem with Nominatim (OpenStreetMap) for automatic address-to-coordinate conversion
- **Authentication**: Devise + devise-jwt for token-based auth
- **Serialization**: jsonapi-serializer gem
- **Key models**: User, Artist, Concert, UserArtist (follows)

### Frontend (Vue SPA)

- **Framework**: Vue 3 with Composition API + TypeScript
- **Build tool**: Vite with vite_rails gem integration
- **UI Components**: shadcn-vue (Tailwind CSS v4 + Reka UI primitives)
- **State**: Pinia stores (`auth`, `artists`, `concerts`)
- **Routing**: Vue Router with catch-all for SPA
- **Styling**: Tailwind CSS v4 with CSS variables theming
- **Maps**: Leaflet with OpenStreetMap tiles
- **HTTP**: Axios with JWT interceptors

### Directory Structure

```
app/
├── controllers/
│   ├── api/v1/              # API controllers
│   │   ├── artists_controller.rb
│   │   ├── concerts_controller.rb
│   │   └── user/followed_artists_controller.rb
│   └── users/               # Devise session/registration overrides
├── models/
│   ├── user.rb              # Devise user with follows
│   ├── artist.rb            # Artist model
│   ├── concert.rb           # Concert with geocoding support
│   └── user_artist.rb       # Follow relationship
├── serializers/             # JSON:API serializers
└── frontend/
    ├── entrypoints/application.js  # Vite entry
    ├── App.vue                      # Root component
    ├── router/index.js              # Vue Router config
    ├── stores/                      # Pinia stores
    │   ├── auth.js                  # Authentication state
    │   ├── artists.js               # Artists + following
    │   └── concerts.js              # Concerts + nearby
    ├── services/
    │   ├── api.js                   # Axios instance with interceptors
    │   └── geocoding.js             # Location services
    ├── lib/
    │   └── utils.ts                 # shadcn-vue utility functions (cn)
    ├── views/                       # Page components
    └── components/
        ├── ui/                      # shadcn-vue components
        │   └── button/              # Button component (example)
        ├── layout/                  # Header, Footer
        ├── artists/                 # ArtistCard, FollowButton, ArtistForm
        ├── concerts/                # ConcertCard, ConcertForm
        └── map/                     # MapView (Leaflet)
```

## API Routes

All API routes are namespaced under `/api/v1/`:

- `GET /api/v1/auth/me` - Current user info
- `GET/POST /api/v1/artists` - List/create artists
- `GET/PUT/DELETE /api/v1/artists/:id` - Artist CRUD
- `GET /api/v1/artists/:id/concerts` - Artist's concerts
- `GET/POST /api/v1/concerts` - List/create concerts
- `GET /api/v1/concerts/upcoming` - Future concerts
- `GET /api/v1/concerts/nearby?lat=&lng=&radius=` - Location-based search
- `GET/POST /api/v1/user/followed_artists` - User follows
- `DELETE /api/v1/user/followed_artists/:artist_id` - Unfollow

Auth routes under `/api/auth/`:
- `POST /api/auth/signup` - Registration
- `POST /api/auth/login` - Login (returns JWT)
- `DELETE /api/auth/logout` - Logout (denylists token)

## Key Configuration Files

- `config/vite.json` - Vite Rails integration settings
- `config/initializers/devise.rb` - JWT configuration
- `config/initializers/geocoder.rb` - Geocoding service configuration (Nominatim)
- `config/initializers/cors.rb` - CORS for frontend dev server
- `vite.config.ts` - Vite build configuration (TypeScript)
- `tailwind.config.js` - Tailwind CSS setup
- `components.json` - shadcn-vue configuration
- `tsconfig.json` - TypeScript configuration with path aliases

## Common Patterns

### Authentication Flow

The app uses Devise HTML views for authentication (not custom Vue forms) with JWT token-based API authentication.

**Login/Signup Flow:**
1. User visits `/api/auth/login` or `/api/auth/signup` (Devise HTML views)
2. User submits credentials via HTML form
3. Backend authenticates user and generates JWT token with required claims:
   - `sub` - User ID
   - `scp` - Scope ('user')
   - `aud` - Audience (null)
   - `iat` - Issued at timestamp
   - `exp` - Expiration timestamp (1 week)
   - `jti` - JWT ID (UUID for revocation via denylist)
4. Backend redirects to frontend: `{URL}/auth/success?token={JWT}`
5. Frontend `AuthSuccess.vue` component:
   - Extracts token from query parameter
   - Saves to localStorage as 'authToken'
   - Fetches current user via `/api/v1/auth/me`
   - Redirects to `/dashboard`

**Spotify OAuth Flow:**
1. User clicks "Continue with Spotify" → `/api/auth/auth/spotify`
2. Redirected to Spotify authorization page
3. Spotify redirects back to `/api/auth/auth/spotify/callback`
4. Backend creates/updates user from OAuth data
5. Generates JWT token and redirects to `/auth/success?token={JWT}`
6. Same frontend flow as login/signup

**API Authentication:**
- Frontend Axios interceptor adds `Authorization: Bearer {token}` header
- Backend Devise JWT strategy validates token via Warden
- Protected endpoints use `before_action :authenticate_user!`
- Token validated against JwtDenylist for revocation

**JWT Token Format:**
All manually generated tokens MUST include these claims to work with Devise JWT:
```ruby
{
  sub: user.id,                    # Subject (user ID)
  scp: 'user',                     # Scope
  aud: nil,                        # Audience
  iat: Time.now.to_i,              # Issued at
  exp: (Time.now + 1.week).to_i,   # Expiration
  jti: SecureRandom.uuid           # JWT ID (required for denylist)
}
```
Algorithm: HS256
Secret: `Rails.application.credentials.devise_jwt_secret_key || Rails.application.credentials.secret_key_base`

### Following Artists
- UserArtist join model with `user_id` + `artist_id`
- User model has `followed_artists` association
- `user.follow(artist)` / `user.unfollow(artist)` methods
- Frontend tracks in `artistsStore.followedArtists`

### Geocoding Concerts

The app uses the `geocoder` gem with Nominatim (OpenStreetMap) for location lookups.

**Automatic Geocoding:**
- Concerts auto-geocode on save if lat/lng are blank
- Requires: venue_name, city, country (venue_address optional but helpful)
- Respects Nominatim's 1 req/sec rate limit in production
- Geocoding happens in `after_validation` callback

**Manual Override:**
- Provide latitude/longitude in params to skip geocoding
- Useful when automatic geocoding fails or for testing
- Manual coordinates always take precedence

**Finding Nearby Concerts:**
```ruby
# Use geocoder's near method
Concert.near([lat, lng], radius_km, units: :km)
# Returns ActiveRecord relation with :distance attribute
# Example: Concert.near([48.8566, 2.3522], 50) finds concerts within 50km of Paris
```

**Error Handling:**
- Geocoding failures add validation errors to the model
- Controller rescues `Geocoder::Error` and returns 503 Service Unavailable
- Check logs for geocoding errors: `Rails.logger.error`
- Falls back to manual coordinate entry on failure

**Configuration:**
- Settings in `config/initializers/geocoder.rb`
- Email required: Set `NOMINATIM_EMAIL` env var (Nominatim TOS)
- User-Agent header required for Nominatim requests
- Cache enabled: Uses `Rails.cache` for 24-hour cache
- Rate limit: 1 request/second enforced in production

### shadcn-vue Components
- Add new components: `npx shadcn-vue@latest add <component>`
- Components installed to `app/frontend/components/ui/`
- Import with alias: `import { Button } from '@/components/ui/button'`
- Uses CSS variables for theming (light/dark mode in `application.css`)
- Utility function `cn()` from `@/lib/utils` for class merging

## Important Notes

- The app uses `app/frontend/` for Vue source (not `app/javascript/`)
- CSS is imported in JS entry point, not separate Vite entrypoint
- Admin routes require `current_user.admin?` check
- Frontend runs on port 5173, backend on 3000 during development
- CORS is configured to allow 127.0.0.1:3000 in development

## Configuration Management

**IMPORTANT**: Use Rails encrypted credentials instead of environment variables for sensitive data.

### Managing Credentials

```bash
# Edit credentials (opens in $EDITOR)
EDITOR="code --wait" rails credentials:edit

# Or for specific environment
EDITOR="code --wait" rails credentials:edit --environment production
```

### Required Credentials

The following credentials should be stored in Rails encrypted credentials:

- `devise_jwt_secret_key` - JWT secret for authentication (optional, falls back to secret_key_base)
- `spotify_client_id` - Spotify OAuth client ID (required for OAuth)
- `spotify_client_secret` - Spotify OAuth client secret (required for OAuth)
- `nominatim_email` - Email for Nominatim geocoding service (defaults to admin@example.com)

### Environment Variables

The following environment variables can be set (optional):

- `URL` - Base URL for the application (defaults to http://127.0.0.1:3000 in development)
  - In production, frontend and backend share the same URL (e.g., https://festnoz.app)
  - Used for OAuth redirects and other URL construction

### Accessing Credentials in Code

```ruby
# Access credentials in Ruby code
Rails.application.credentials.spotify_client_id
Rails.application.credentials.spotify_client_secret

# With environment-specific credentials
Rails.application.credentials.dig(:spotify, :client_id)
```

### Why Credentials Over ENV Variables?

- Encrypted at rest in version control
- Environment-specific configuration supported
- Better for team collaboration
- No risk of leaking .env files
- Rails best practice
