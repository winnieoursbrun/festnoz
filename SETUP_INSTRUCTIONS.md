# FestNoz Concert Tracking App - Setup Instructions

## Current Status

✅ **COMPLETED:**
1. Rails 8.1.1 application created with PostgreSQL and Tailwind
2. All required gems added to Gemfile and installed
3. Devise initializer configured with JWT authentication
4. CORS configuration created
5. All 5 database migrations created:
   - Users (Devise with JWT)
   - JWT Denylist
   - Artists
   - Concerts
   - UserArtists (join table)
6. All 5 model files created with associations and validations

## Ruby Installation Issue

⚠️ **CURRENT BLOCKER:** Ruby installed via mise has libyaml/psych issues causing segmentation faults on your macOS system.

### Solution Options:

**Option 1: Use rbenv (Recommended)**
```bash
brew install rbenv ruby-build
rbenv install 3.3.6
rbenv global 3.3.6
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
```

**Option 2: Use asdf**
```bash
brew install asdf
asdf plugin add ruby
asdf install ruby 3.3.6
asdf global ruby 3.3.6
```

**Option 3: Use system Ruby via Homebrew**
```bash
brew install ruby
```

## Once Ruby is Working

Run these commands in order:

```bash
# 1. Install gems
bundle install

# 2. Create database
rails db:create

# 3. Run migrations
rails db:migrate

# 4. Seed database (after seed file is created)
rails db:seed

# 5. Install Node dependencies
npm install

# 6. Start development servers
bin/dev
```

## Next Steps (To Be Implemented)

### Backend (Remaining):
- [ ] Create seed data (db/seeds.rb)
- [ ] Configure routes (config/routes.rb)
- [ ] Create API controllers (7 controllers)
- [ ] Create serializers (3 serializers)

### Frontend:
- [ ] Set up Vite configuration
- [ ] Install NPM dependencies (Vue, Pinia, Leaflet, Axios)
- [ ] Create API service
- [ ] Create Pinia stores (auth, artists, concerts)
- [ ] Create Vue components (layouts, auth, artists, concerts, map)
- [ ] Configure Vue Router

### Testing:
- [ ] Test authentication flow
- [ ] Test API endpoints
- [ ] Test frontend components
- [ ] Test map functionality

## Files Created So Far

### Configuration:
- `config/initializers/devise.rb` - Devise + JWT configuration
- `config/initializers/cors.rb` - CORS settings
- `config/boot.rb` - Bootsnap disabled due to code signing

### Database:
- `db/migrate/20251230120001_devise_create_users.rb`
- `db/migrate/20251230120002_create_jwt_denylist.rb`
- `db/migrate/20251230120003_create_artists.rb`
- `db/migrate/20251230120004_create_concerts.rb`
- `db/migrate/20251230120005_create_user_artists.rb`

### Models:
- `app/models/user.rb` - Devise user with JWT, following functionality
- `app/models/jwt_denylist.rb` - JWT token revocation
- `app/models/artist.rb` - Artist with concerts and followers
- `app/models/concert.rb` - Concert with geolocation
- `app/models/user_artist.rb` - Follow relationship

## Test Credentials (After Seeding)

- **Admin**: admin@festnoz.com / password123
- **User**: user@example.com / password123

## Architecture

- **Backend**: Rails 8.1.1 API with PostgreSQL
- **Authentication**: Devise + JWT tokens
- **Frontend**: Vue 3 + Vite + Pinia
- **Styling**: TailwindCSS
- **Maps**: Leaflet + OpenStreetMap
- **API Format**: JSON:API via jsonapi-serializer

## Development URLs

- **Frontend**: http://localhost:5173 (Vite dev server)
- **Backend API**: http://localhost:3000/api/v1
