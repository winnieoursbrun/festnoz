import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createPinia, setActivePinia } from 'pinia'
import AuthSuccess from '../AuthSuccess.vue'
import { useAuthStore } from '../../stores/auth'

// Mock localStorage
const mockLocalStorage = {
  setItem: vi.fn(),
  getItem: vi.fn(),
  removeItem: vi.fn(),
}
global.localStorage = mockLocalStorage as any

describe('AuthSuccess', () => {
  let router: any
  let pinia: any

  beforeEach(() => {
    // Create fresh pinia instance
    pinia = createPinia()
    setActivePinia(pinia)

    // Create router with required routes
    router = createRouter({
      history: createMemoryHistory(),
      routes: [
        {
          path: '/auth/success',
          name: 'AuthSuccess',
          component: AuthSuccess
        },
        {
          path: '/dashboard',
          name: 'Dashboard',
          component: { template: '<div>Dashboard</div>' }
        },
        {
          path: '/login',
          name: 'Login',
          component: { template: '<div>Login</div>' }
        }
      ]
    })

    // Clear mocks
    vi.clearAllMocks()
    mockLocalStorage.setItem.mockClear()
  })

  it('renders authentication success message', () => {
    const wrapper = mount(AuthSuccess, {
      global: {
        plugins: [router, pinia],
        stubs: {
          Music: { template: '<div class="music-icon"></div>' }
        }
      }
    })

    expect(wrapper.text()).toContain('Authentication Successful!')
    expect(wrapper.text()).toContain('Redirecting you to the dashboard')
  })

  it('redirects to login when no token in query', async () => {
    const pushSpy = vi.spyOn(router, 'push')

    // Navigate to auth success without token
    await router.push('/auth/success')

    mount(AuthSuccess, {
      global: {
        plugins: [router, pinia],
        stubs: {
          Music: { template: '<div></div>' }
        }
      }
    })

    await flushPromises()

    expect(pushSpy).toHaveBeenCalledWith('/login')
  })

  it('saves token to localStorage when token is present', async () => {
    const mockToken = 'test-jwt-token-123'
    const mockUser = {
      id: 1,
      email: 'test@example.com',
      username: 'testuser',
      admin: false
    }

    // Mock fetchCurrentUser
    const authStore = useAuthStore()
    authStore.fetchCurrentUser = vi.fn().mockResolvedValue(mockUser)

    // Navigate with token in query
    await router.push(`/auth/success?token=${mockToken}`)

    mount(AuthSuccess, {
      global: {
        plugins: [router, pinia],
        stubs: {
          Music: { template: '<div></div>' }
        }
      }
    })

    await flushPromises()

    expect(mockLocalStorage.setItem).toHaveBeenCalledWith('authToken', mockToken)
  })

  it('fetches current user after saving token', async () => {
    const mockToken = 'test-jwt-token-123'
    const mockUser = {
      id: 1,
      email: 'test@example.com',
      username: 'testuser',
      admin: false
    }

    const authStore = useAuthStore()
    const fetchUserSpy = vi.spyOn(authStore, 'fetchCurrentUser').mockResolvedValue(mockUser)

    await router.push(`/auth/success?token=${mockToken}`)

    mount(AuthSuccess, {
      global: {
        plugins: [router, pinia],
        stubs: {
          Music: { template: '<div></div>' }
        }
      }
    })

    await flushPromises()

    expect(fetchUserSpy).toHaveBeenCalled()
  })

  it('redirects to dashboard after successful authentication', async () => {
    const mockToken = 'test-jwt-token-123'
    const mockUser = {
      id: 1,
      email: 'test@example.com',
      username: 'testuser',
      admin: false
    }

    const authStore = useAuthStore()
    authStore.fetchCurrentUser = vi.fn().mockResolvedValue(mockUser)

    const pushSpy = vi.spyOn(router, 'push')

    await router.push(`/auth/success?token=${mockToken}`)

    mount(AuthSuccess, {
      global: {
        plugins: [router, pinia],
        stubs: {
          Music: { template: '<div></div>' }
        }
      }
    })

    await flushPromises()

    // Wait for the setTimeout to complete (1000ms delay)
    await new Promise(resolve => setTimeout(resolve, 1100))

    expect(pushSpy).toHaveBeenCalledWith('/dashboard')
  })

  it('redirects to login on authentication error', async () => {
    const mockToken = 'invalid-token'

    const authStore = useAuthStore()
    authStore.fetchCurrentUser = vi.fn().mockRejectedValue(new Error('Invalid token'))

    const pushSpy = vi.spyOn(router, 'push')
    const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})

    await router.push(`/auth/success?token=${mockToken}`)

    mount(AuthSuccess, {
      global: {
        plugins: [router, pinia],
        stubs: {
          Music: { template: '<div></div>' }
        }
      }
    })

    await flushPromises()

    expect(pushSpy).toHaveBeenCalledWith('/login')
    expect(consoleErrorSpy).toHaveBeenCalled()

    consoleErrorSpy.mockRestore()
  })

  it('displays loading animation', () => {
    const wrapper = mount(AuthSuccess, {
      global: {
        plugins: [router, pinia],
        stubs: {
          Music: { template: '<div class="music-icon"></div>' }
        }
      }
    })

    // Check for loading dots
    const dots = wrapper.findAll('.animate-bounce')
    expect(dots.length).toBeGreaterThan(0)
  })

  it('handles OAuth provider parameter', async () => {
    const mockToken = 'spotify-oauth-token'
    const mockUser = {
      id: 1,
      email: 'spotify@example.com',
      username: 'spotifyuser',
      admin: false,
      provider: 'spotify'
    }

    const authStore = useAuthStore()
    authStore.fetchCurrentUser = vi.fn().mockResolvedValue(mockUser)

    await router.push(`/auth/success?token=${mockToken}&provider=spotify`)

    mount(AuthSuccess, {
      global: {
        plugins: [router, pinia],
        stubs: {
          Music: { template: '<div></div>' }
        }
      }
    })

    await flushPromises()

    expect(mockLocalStorage.setItem).toHaveBeenCalledWith('authToken', mockToken)
    expect(authStore.fetchCurrentUser).toHaveBeenCalled()
  })

  it('handles error parameter in query', async () => {
    const pushSpy = vi.spyOn(router, 'push')
    const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})

    await router.push('/auth/success?error=authentication_failed')

    mount(AuthSuccess, {
      global: {
        plugins: [router, pinia],
        stubs: {
          Music: { template: '<div></div>' }
        }
      }
    })

    await flushPromises()

    expect(pushSpy).toHaveBeenCalledWith('/login')

    consoleErrorSpy.mockRestore()
  })
})
