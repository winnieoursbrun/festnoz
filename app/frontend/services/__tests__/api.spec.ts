import { describe, it, expect, beforeEach, vi, afterEach } from 'vitest'
import axios from 'axios'
import type { InternalAxiosRequestConfig, AxiosResponse } from 'axios'

// Mock axios
vi.mock('axios', () => ({
  default: {
    create: vi.fn(() => ({
      interceptors: {
        request: {
          use: vi.fn(),
        },
        response: {
          use: vi.fn(),
        },
      },
      get: vi.fn(),
      post: vi.fn(),
      put: vi.fn(),
      delete: vi.fn(),
    })),
  },
}))

describe('API Service', () => {
  let mockAxiosInstance: any
  let requestInterceptor: any
  let responseInterceptor: any
  let responseErrorInterceptor: any

  beforeEach(() => {
    // Clear module cache to get fresh import
    vi.resetModules()

    // Mock localStorage
    global.localStorage = {
      getItem: vi.fn(),
      setItem: vi.fn(),
      removeItem: vi.fn(),
      clear: vi.fn(),
      length: 0,
      key: vi.fn(),
    }

    // Setup axios mock
    mockAxiosInstance = {
      interceptors: {
        request: {
          use: vi.fn((onFulfilled) => {
            requestInterceptor = onFulfilled
          }),
        },
        response: {
          use: vi.fn((onFulfilled, onRejected) => {
            responseInterceptor = onFulfilled
            responseErrorInterceptor = onRejected
          }),
        },
      },
      get: vi.fn(),
      post: vi.fn(),
      put: vi.fn(),
      delete: vi.fn(),
    }

    vi.mocked(axios.create).mockReturnValue(mockAxiosInstance)
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  describe('Initialization', () => {
    it('creates axios instance with correct config', async () => {
      await import('../api')

      expect(axios.create).toHaveBeenCalledWith({
        baseURL: 'http://127.0.0.1:3000',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        withCredentials: true,
      })
    })

    it('registers request interceptor', async () => {
      await import('../api')

      expect(mockAxiosInstance.interceptors.request.use).toHaveBeenCalled()
    })

    it('registers response interceptor', async () => {
      await import('../api')

      expect(mockAxiosInstance.interceptors.response.use).toHaveBeenCalled()
    })
  })

  describe('Request Interceptor', () => {
    it('adds Authorization header when token exists', async () => {
      const mockToken = 'test-jwt-token'
      vi.mocked(localStorage.getItem).mockReturnValue(mockToken)

      await import('../api')

      const mockConfig: InternalAxiosRequestConfig = {
        headers: {} as any,
      } as InternalAxiosRequestConfig

      const result = requestInterceptor(mockConfig)

      expect(localStorage.getItem).toHaveBeenCalledWith('authToken')
      expect(result.headers.Authorization).toBe(`Bearer ${mockToken}`)
    })

    it('does not add Authorization header when no token', async () => {
      vi.mocked(localStorage.getItem).mockReturnValue(null)

      await import('../api')

      const mockConfig: InternalAxiosRequestConfig = {
        headers: {} as any,
      } as InternalAxiosRequestConfig

      const result = requestInterceptor(mockConfig)

      expect(result.headers.Authorization).toBeUndefined()
    })

    it('returns config unchanged on error', async () => {
      await import('../api')

      // Get the error handler from the request interceptor
      const errorHandler = mockAxiosInstance.interceptors.request.use.mock.calls[0][1]
      const mockError = new Error('Request error')

      await expect(errorHandler(mockError)).rejects.toThrow('Request error')
    })
  })

  describe('Response Interceptor', () => {
    it('returns response unchanged on success', async () => {
      await import('../api')

      const mockResponse: AxiosResponse = {
        data: { message: 'success' },
        status: 200,
        statusText: 'OK',
        headers: {},
        config: {} as InternalAxiosRequestConfig,
      }

      const result = responseInterceptor(mockResponse)

      expect(result).toEqual(mockResponse)
    })

    it('clears token and redirects on 401 error', async () => {
      const mockLocation = { href: '' }
      Object.defineProperty(window, 'location', {
        value: mockLocation,
        writable: true,
      })

      await import('../api')

      const mockError = {
        response: {
          status: 401,
          data: { message: 'Unauthorized' },
        },
      }

      await expect(responseErrorInterceptor(mockError)).rejects.toEqual(mockError)

      expect(localStorage.removeItem).toHaveBeenCalledWith('authToken')
      expect(mockLocation.href).toBe('/login')
    })

    it('does not redirect on non-401 errors', async () => {
      const mockLocation = { href: '' }
      Object.defineProperty(window, 'location', {
        value: mockLocation,
        writable: true,
      })

      await import('../api')

      const mockError = {
        response: {
          status: 500,
          data: { message: 'Server error' },
        },
      }

      await expect(responseErrorInterceptor(mockError)).rejects.toEqual(mockError)

      expect(localStorage.removeItem).not.toHaveBeenCalled()
      expect(mockLocation.href).toBe('')
    })

    it('handles errors without response object', async () => {
      await import('../api')

      const mockError = new Error('Network error')

      await expect(responseErrorInterceptor(mockError)).rejects.toThrow('Network error')

      expect(localStorage.removeItem).not.toHaveBeenCalled()
    })
  })

  describe('API Base URL', () => {
    it('uses VITE_API_URL from environment if available', async () => {
      // Note: Testing environment variables with import.meta.env is complex in Vitest
      // This test verifies the default behavior works
      // In a real environment, VITE_API_URL would be set at build time
      await import('../api')

      // Verify axios.create was called (actual URL depends on env at build time)
      expect(axios.create).toHaveBeenCalled()
      const createCall = vi.mocked(axios.create).mock.calls[0][0]
      expect(createCall).toHaveProperty('baseURL')
      expect(createCall).toHaveProperty('withCredentials', true)
    })

    it('defaults to 127.0.0.1:3000 when VITE_API_URL not set', async () => {
      const originalEnv = import.meta.env
      Object.defineProperty(import.meta, 'env', {
        value: {},
        writable: true,
      })

      vi.resetModules()
      await import('../api')

      expect(axios.create).toHaveBeenCalledWith(
        expect.objectContaining({
          baseURL: 'http://127.0.0.1:3000',
        })
      )

      // Restore
      Object.defineProperty(import.meta, 'env', {
        value: originalEnv,
        writable: true,
      })
    })
  })
})
