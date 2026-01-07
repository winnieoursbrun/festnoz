import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useAuthStore } from '../auth'
import api from '../../services/api'

// Mock the API module
vi.mock('../../services/api', () => ({
  default: {
    post: vi.fn(),
    delete: vi.fn(),
    get: vi.fn(),
  }
}))

describe('Auth Store', () => {
  beforeEach(() => {
    // Create a fresh pinia instance for each test
    setActivePinia(createPinia())
    // Clear localStorage mock
    localStorage.getItem = vi.fn()
    localStorage.setItem = vi.fn()
    localStorage.removeItem = vi.fn()
    // Reset API mocks
    vi.clearAllMocks()
  })

  describe('Initial State', () => {
    it('initializes with null user', () => {
      const store = useAuthStore()
      expect(store.user).toBeNull()
    })

    it('loads token from localStorage on initialization', () => {
      localStorage.getItem = vi.fn(() => 'stored-token')
      const store = useAuthStore()
      expect(store.token).toBe('stored-token')
      expect(localStorage.getItem).toHaveBeenCalledWith('authToken')
    })

    it('initializes as not authenticated when no token', () => {
      localStorage.getItem = vi.fn(() => null)
      const store = useAuthStore()
      expect(store.isAuthenticated).toBe(false)
    })

    it('initializes as authenticated when token exists', () => {
      localStorage.getItem = vi.fn(() => 'test-token')
      const store = useAuthStore()
      expect(store.isAuthenticated).toBe(true)
    })
  })

  describe('login', () => {
    it('successfully logs in with valid credentials', async () => {
      const mockUser = { id: 1, email: 'test@example.com', username: 'testuser' }
      const mockToken = 'jwt-token-123'

      vi.mocked(api.post).mockResolvedValueOnce({
        data: { user: mockUser },
        headers: { authorization: mockToken }
      } as any)

      const store = useAuthStore()
      const result = await store.login('test@example.com', 'password')

      expect(api.post).toHaveBeenCalledWith('/api/auth/login', {
        user: { email: 'test@example.com', password: 'password' }
      })
      expect(store.token).toBe(mockToken)
      expect(store.user).toEqual(mockUser)
      expect(localStorage.setItem).toHaveBeenCalledWith('authToken', mockToken)
      expect(result).toEqual({ user: mockUser })
    })

    it('handles login with no token in response', async () => {
      const mockUser = { id: 1, email: 'test@example.com', username: 'testuser' }

      vi.mocked(api.post).mockResolvedValueOnce({
        data: { user: mockUser },
        headers: {}
      } as any)

      const store = useAuthStore()
      await store.login('test@example.com', 'password')

      // Token stays as whatever it was initialized (from localStorage getter mock)
      // User stays null when no token is provided
      expect(store.user).toBeNull()
      expect(localStorage.setItem).not.toHaveBeenCalled()
    })

    it('handles login failure with error message', async () => {
      const errorMessage = 'Invalid credentials'
      vi.mocked(api.post).mockRejectedValueOnce({
        response: { data: { message: errorMessage } }
      })

      const store = useAuthStore()
      await expect(store.login('test@example.com', 'wrong')).rejects.toThrow()

      expect(store.error).toBe(errorMessage)
      // Token and user remain at their initial values (null) on error
      expect(store.user).toBeNull()
    })

    it('handles network error during login', async () => {
      vi.mocked(api.post).mockRejectedValueOnce(new Error('Network error'))

      const store = useAuthStore()
      await expect(store.login('test@example.com', 'password')).rejects.toThrow()

      expect(store.error).toBe('Login failed')
    })

    it('sets loading state during login', async () => {
      vi.mocked(api.post).mockImplementationOnce(() =>
        new Promise(resolve => setTimeout(() => resolve({
          data: { user: {} },
          headers: { authorization: 'token' }
        } as any), 100))
      )

      const store = useAuthStore()
      const loginPromise = store.login('test@example.com', 'password')

      expect(store.loading).toBe(true)

      await loginPromise

      expect(store.loading).toBe(false)
    })
  })

  describe('signup', () => {
    it('successfully signs up with valid data', async () => {
      const mockUser = { id: 1, email: 'new@example.com', username: 'newuser' }
      const mockToken = 'jwt-token-456'

      vi.mocked(api.post).mockResolvedValueOnce({
        data: { user: mockUser },
        headers: { authorization: mockToken }
      } as any)

      const store = useAuthStore()
      const result = await store.signup('newuser', 'new@example.com', 'password123', 'password123')

      expect(api.post).toHaveBeenCalledWith('/api/auth/signup', {
        user: {
          username: 'newuser',
          email: 'new@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }
      })
      expect(store.token).toBe(mockToken)
      expect(store.user).toEqual(mockUser)
      expect(localStorage.setItem).toHaveBeenCalledWith('authToken', mockToken)
    })

    it('handles signup failure with validation errors', async () => {
      const errorMessage = 'Email has already been taken'
      vi.mocked(api.post).mockRejectedValueOnce({
        response: { data: { message: errorMessage } }
      })

      const store = useAuthStore()
      await expect(store.signup('user', 'taken@example.com', 'pass', 'pass')).rejects.toThrow()

      expect(store.error).toBe(errorMessage)
    })
  })

  describe('logout', () => {
    it('successfully logs out and clears state', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({ data: { message: 'success' } } as any)

      const store = useAuthStore()
      store.token = 'test-token'
      store.user = { id: 1, email: 'test@example.com', username: 'test' }

      await store.logout()

      expect(api.delete).toHaveBeenCalledWith('/api/auth/logout')
      expect(store.token).toBeNull()
      expect(store.user).toBeNull()
      expect(localStorage.removeItem).toHaveBeenCalledWith('authToken')
    })

    it('clears state even if API call fails', async () => {
      vi.mocked(api.delete).mockRejectedValueOnce(new Error('API error'))

      const store = useAuthStore()
      store.token = 'test-token'
      store.user = { id: 1, email: 'test@example.com', username: 'test' }

      await store.logout()

      expect(store.token).toBeNull()
      expect(store.user).toBeNull()
      expect(localStorage.removeItem).toHaveBeenCalledWith('authToken')
    })
  })

  describe('fetchCurrentUser', () => {
    it('fetches current user when token exists', async () => {
      const mockUser = { id: 1, email: 'test@example.com', username: 'testuser', admin: false }
      vi.mocked(api.get).mockResolvedValueOnce({
        data: { user: mockUser }
      } as any)

      const store = useAuthStore()
      store.token = 'valid-token'

      const result = await store.fetchCurrentUser()

      expect(api.get).toHaveBeenCalledWith('/api/v1/auth/me')
      expect(store.user).toEqual(mockUser)
      expect(result).toEqual(mockUser)
    })

    it('does not fetch when no token exists', async () => {
      const store = useAuthStore()
      store.token = null

      await store.fetchCurrentUser()

      expect(api.get).not.toHaveBeenCalled()
    })

    it('clears token and user on 401 error', async () => {
      vi.mocked(api.get).mockRejectedValueOnce({
        response: { status: 401, data: { message: 'Unauthorized' } }
      })

      const store = useAuthStore()
      store.token = 'invalid-token'

      await expect(store.fetchCurrentUser()).rejects.toThrow()

      expect(store.token).toBeNull()
      expect(store.user).toBeNull()
      expect(localStorage.removeItem).toHaveBeenCalledWith('authToken')
    })

    it('sets error message on failure', async () => {
      vi.mocked(api.get).mockRejectedValueOnce({
        response: { data: { message: 'Server error' } }
      })

      const store = useAuthStore()
      store.token = 'test-token'

      await expect(store.fetchCurrentUser()).rejects.toThrow()
      expect(store.error).toBe('Server error')
    })
  })

  describe('Computed Properties', () => {
    it('isAuthenticated returns true when token exists', () => {
      const store = useAuthStore()
      store.token = 'test-token'
      expect(store.isAuthenticated).toBe(true)
    })

    it('isAuthenticated returns false when no token', () => {
      const store = useAuthStore()
      store.token = null
      expect(store.isAuthenticated).toBe(false)
    })

    it('isAdmin returns true for admin user', () => {
      const store = useAuthStore()
      store.user = { id: 1, email: 'admin@example.com', username: 'admin', admin: true }
      expect(store.isAdmin).toBe(true)
    })

    it('isAdmin returns false for non-admin user', () => {
      const store = useAuthStore()
      store.user = { id: 1, email: 'user@example.com', username: 'user', admin: false }
      expect(store.isAdmin).toBe(false)
    })

    it('isAdmin returns false when no user', () => {
      const store = useAuthStore()
      store.user = null
      expect(store.isAdmin).toBe(false)
    })
  })
})
