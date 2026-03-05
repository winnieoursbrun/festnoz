import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import axios from 'axios'

// Mock axios so axios.create returns a controlled instance
vi.mock('axios', () => ({
  default: {
    create: vi.fn(() => ({
      get: vi.fn()
    }))
  }
}))

describe('Geocoding Service', () => {
  let mockNominatimGet: ReturnType<typeof vi.fn>

  beforeEach(() => {
    // Reset modules so the geocoding service re-runs axios.create with the new mock
    vi.resetModules()
    mockNominatimGet = vi.fn()
    vi.mocked(axios.create).mockReturnValue({ get: mockNominatimGet } as any)
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  describe('searchLocation', () => {
    it('calls nominatim /search with correct params', async () => {
      mockNominatimGet.mockResolvedValueOnce({ data: [] })

      const { searchLocation } = await import('../geocoding')
      await searchLocation('Quimper, France')

      expect(mockNominatimGet).toHaveBeenCalledWith('/search', {
        params: {
          q: 'Quimper, France',
          format: 'json',
          limit: 5,
          addressdetails: 1
        }
      })
    })

    it('returns the response data array', async () => {
      const mockData = [{ place_id: 1, display_name: 'Quimper, Finistère, France' }]
      mockNominatimGet.mockResolvedValueOnce({ data: mockData })

      const { searchLocation } = await import('../geocoding')
      const result = await searchLocation('Quimper')

      expect(result).toEqual(mockData)
    })

    it('returns empty array when no results', async () => {
      mockNominatimGet.mockResolvedValueOnce({ data: [] })

      const { searchLocation } = await import('../geocoding')
      const result = await searchLocation('nonexistentplace123')

      expect(result).toEqual([])
    })

    it('throws on API error', async () => {
      mockNominatimGet.mockRejectedValueOnce(new Error('Network error'))

      const { searchLocation } = await import('../geocoding')
      await expect(searchLocation('Quimper')).rejects.toThrow('Network error')
    })
  })

  describe('reverseGeocode', () => {
    it('calls nominatim /reverse with correct lat/lon params', async () => {
      mockNominatimGet.mockResolvedValueOnce({ data: {} })

      const { reverseGeocode } = await import('../geocoding')
      await reverseGeocode(48.1173, -1.6778)

      expect(mockNominatimGet).toHaveBeenCalledWith('/reverse', {
        params: {
          lat: 48.1173,
          lon: -1.6778,
          format: 'json',
          addressdetails: 1
        }
      })
    })

    it('returns the response data object', async () => {
      const mockData = { place_id: 123, display_name: 'Rennes, France', address: { city: 'Rennes' } }
      mockNominatimGet.mockResolvedValueOnce({ data: mockData })

      const { reverseGeocode } = await import('../geocoding')
      const result = await reverseGeocode(48.1173, -1.6778)

      expect(result).toEqual(mockData)
    })

    it('throws on API error', async () => {
      mockNominatimGet.mockRejectedValueOnce(new Error('Service unavailable'))

      const { reverseGeocode } = await import('../geocoding')
      await expect(reverseGeocode(48.1173, -1.6778)).rejects.toThrow('Service unavailable')
    })
  })

  describe('getCurrentLocation', () => {
    it('resolves with {lat, lng} when geolocation succeeds', async () => {
      const mockPosition = {
        coords: { latitude: 48.1173, longitude: -1.6778 }
      }

      Object.defineProperty(global, 'navigator', {
        value: {
          geolocation: {
            getCurrentPosition: vi.fn((success: (pos: typeof mockPosition) => void) =>
              success(mockPosition)
            )
          }
        },
        writable: true,
        configurable: true
      })

      const { getCurrentLocation } = await import('../geocoding')
      const result = await getCurrentLocation()

      expect(result).toEqual({ lat: 48.1173, lng: -1.6778 })
    })

    it('rejects when geolocation getCurrentPosition calls error callback', async () => {
      const mockError = new Error('Permission denied')

      Object.defineProperty(global, 'navigator', {
        value: {
          geolocation: {
            getCurrentPosition: vi.fn(
              (_success: unknown, error: (err: Error) => void) => error(mockError)
            )
          }
        },
        writable: true,
        configurable: true
      })

      const { getCurrentLocation } = await import('../geocoding')
      await expect(getCurrentLocation()).rejects.toEqual(mockError)
    })

    it('rejects when geolocation is not supported', async () => {
      Object.defineProperty(global, 'navigator', {
        value: { geolocation: undefined },
        writable: true,
        configurable: true
      })

      const { getCurrentLocation } = await import('../geocoding')
      await expect(getCurrentLocation()).rejects.toThrow(
        'Geolocation is not supported by your browser'
      )
    })
  })
})
