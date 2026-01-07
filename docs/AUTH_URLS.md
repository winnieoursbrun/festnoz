# Authentication URLs Quick Reference

## Correct URLs (Development)

### Login & Signup
- **Login Page**: `http://127.0.0.1:3000/api/auth/login`
- **Signup Page**: `http://127.0.0.1:3000/api/auth/signup`
- **Logout**: `http://127.0.0.1:3000/api/auth/logout` (DELETE request)

### Spotify OAuth
- **Start OAuth Flow**: `http://127.0.0.1:3000/api/auth/spotify`
  - This redirects to `/api/auth/auth/spotify` (Devise's internal OAuth path)
  - The redirect is transparent to the user
- **OAuth Callback**: `http://127.0.0.1:3000/api/auth/spotify/callback` (handled automatically)
- **OAuth Failure**: `http://127.0.0.1:3000/api/auth/failure`

### Frontend Routes
- **Welcome Page**: `http://127.0.0.1:3000/` or `http://127.0.0.1:3000/`
- **Auth Success**: `http://127.0.0.1:3000/auth/success?token=JWT` (automatic redirect)
- **Dashboard**: `http://127.0.0.1:3000/dashboard` (after login)

## Common Mistakes

❌ **WRONG**: `/auth/spotify` → Returns 404 (missing /api prefix)
✅ **CORRECT**: `/api/auth/spotify`

❌ **WRONG**: `/api/auth/signup/sign_up` → Old path
✅ **CORRECT**: `/api/auth/signup`

## How to Use

### 1. Start the App
```bash
# Make sure both servers are running
bin/dev

# Or separately:
rails server    # Port 3000
npm run dev     # Port 5173
```

### 2. Access the Login
Option A: Visit the welcome page and click "Sign In"
```
http://127.0.0.1:3000/
```

Option B: Go directly to login
```
http://127.0.0.1:3000/api/auth/login
```

### 3. Login with Test Credentials
```
Email: admin@example.com
Password: password
```

### 4. After Login
- Automatically redirected to: `http://127.0.0.1:3000/auth/success?token=JWT`
- Token saved to localStorage
- Redirected to dashboard: `http://127.0.0.1:3000/dashboard`

## Spotify OAuth Flow

1. **Visit login/signup page**
2. **Click "Continue with Spotify" button**
   - Redirects to: `http://127.0.0.1:3000/api/auth/spotify`
3. **Spotify authorization page** (external)
4. **Callback to app**: `http://127.0.0.1:3000/api/auth/spotify/callback`
5. **Backend generates JWT**
6. **Redirect to frontend**: `http://127.0.0.1:3000/auth/success?token=JWT`
7. **Dashboard**: `http://127.0.0.1:3000/dashboard`

## API Endpoints (JSON)

For programmatic access (using JSON):

### Login
```bash
curl -X POST http://127.0.0.1:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"user":{"email":"admin@example.com","password":"password"}}'
```

### Signup
```bash
curl -X POST http://127.0.0.1:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"user":{"username":"newuser","email":"new@example.com","password":"password123","password_confirmation":"password123"}}'
```

### Get Current User
```bash
curl http://127.0.0.1:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Logout
```bash
curl -X DELETE http://127.0.0.1:3000/api/auth/logout \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Troubleshooting

### "Redirecting to /" when visiting login
- ✅ **FIXED**: Make sure you're using the latest code
- The sessions controller now properly handles GET requests

### "No route matches [GET] /api/auth/signup"
- ✅ **FIXED**: Custom routes added for cleaner signup URL
- Use `/api/auth/signup` not `/api/auth/signup/sign_up`

### "Not found. Authentication passthru"
- ✅ **FIXED**: Routes have been updated to use cleaner URLs
- Use the correct path: `/api/auth/spotify` (not `/auth/spotify`)
- Make sure to restart Rails server after route changes: `rails server` or `bin/dev`

### OAuth callback doesn't work
- Check Rails credentials are set:
  ```bash
  rails credentials:edit
  ```
- Ensure these are present:
  ```yaml
  spotify_client_id: your_client_id
  spotify_client_secret: your_client_secret
  ```

## Production URLs

In production, both frontend and backend share the same domain:

```
https://festnoz.app/api/auth/login
https://festnoz.app/api/auth/signup
https://festnoz.app/api/auth/spotify
```

Set the `URL` environment variable:
```bash
export URL=https://festnoz.app
```
