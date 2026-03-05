import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useConcertsStore } from '../concerts'
import api from '../../services/api'

vi.mock('../../services/api', () => ({
  default: { get: vi.fn(), post: vi.fn(), put: vi.fn(), delete: vi.fn() }
}))

describe('Concerts Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  describe('Initial State', () => {
    it('initializes with empty concerts array', () => {
      const store = useConcertsStore()
      expect(store.concerts).toEqual([])
    })

    it('initializes with empty nearbyConcerts array', () => {
      const store = useConcertsStore()
      expect(store.nearbyConcerts).toEqual([])
    })

    it('initializes with null currentConcert', () => {
      const store = useConcertsStore()
      expect(store.currentConcert).toBeNull()
    })

    it('initializes with loading false', () => {
      const store = useConcertsStore()
      expect(store.loading).toBe(false)
    })

    it('initializes with null error', () => {
      const store = useConcertsStore()
      expect(store.error).toBeNull()
    })

    it('initializes with null userLocation', () => {
      const store = useConcertsStore()
      expect(store.userLocation).toBeNull()
    })
  })

  describe('Getters', () => {
    it('concertCount reflects concerts array length', () => {
      const store = useConcertsStore()
      expect(store.concertCount).toBe(0)
      store.concerts = [{ id: 1 }, { id: 2 }] as any
      expect(store.concertCount).toBe(2)
    })

    it('upcomingConcerts only returns concerts with is_upcoming=true', () => {
      const store = useConcertsStore()
      store.concerts = [
        { id: 1, is_upcoming: true },
        { id: 2, is_upcoming: false },
        { id: 3, is_upcoming: true },
      ] as any
      expect(store.upcomingConcerts).toHaveLength(2)
      expect(store.upcomingConcerts.every((c: any) => c.is_upcoming)).toBe(true)
    })

    it('upcomingConcerts returns empty array when no upcoming concerts', () => {
      const store = useConcertsStore()
      store.concerts = [{ id: 1, is_upcoming: false }] as any
      expect(store.upcomingConcerts).toEqual([])
    })

    it('upcomingConcerts returns empty array when concerts is empty', () => {
      const store = useConcertsStore()
      expect(store.upcomingConcerts).toEqual([])
    })
  })

  describe('fetchConcerts', () => {
    it('populates concerts array with response data', async () => {
      const mockConcerts = [{ id: 1, name: 'Concert 1' }, { id: 2, name: 'Concert 2' }]
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: mockConcerts } } as any)

      const store = useConcertsStore()
      await store.fetchConcerts()

      expect(store.concerts).toEqual(mockConcerts)
    })

    it('calls API without params when no filters', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: [] } } as any)

      const store = useConcertsStore()
      await store.fetchConcerts()

      expect(api.get).toHaveBeenCalledWith('/api/v1/concerts', { params: {} })
    })

    it('passes artistId filter as artist_id param', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: [] } } as any)

      const store = useConcertsStore()
      await store.fetchConcerts({ artistId: 5 })

      expect(api.get).toHaveBeenCalledWith('/api/v1/concerts', { params: { artist_id: 5 } })
    })

    it('passes city filter', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: [] } } as any)

      const store = useConcertsStore()
      await store.fetchConcerts({ city: 'Rennes' })

      expect(api.get).toHaveBeenCalledWith('/api/v1/concerts', { params: { city: 'Rennes' } })
    })

    it('sets loading to false after fetch', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: [] } } as any)

      const store = useConcertsStore()
      await store.fetchConcerts()

      expect(store.loading).toBe(false)
    })

    it('sets error and throws on failure', async () => {
      const error = { response: { data: { message: 'Not found' } } }
      vi.mocked(api.get).mockRejectedValueOnce(error)

      const store = useConcertsStore()
      await expect(store.fetchConcerts()).rejects.toEqual(error)
      expect(store.error).toBe('Not found')
    })
  })

  describe('fetchUpcomingConcerts', () => {
    it('populates concerts with upcoming concerts', async () => {
      const mockConcerts = [{ id: 1, is_upcoming: true }]
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: mockConcerts } } as any)

      const store = useConcertsStore()
      await store.fetchUpcomingConcerts()

      expect(store.concerts).toEqual(mockConcerts)
    })

    it('calls correct API endpoint', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: [] } } as any)

      const store = useConcertsStore()
      await store.fetchUpcomingConcerts()

      expect(api.get).toHaveBeenCalledWith('/api/v1/concerts/upcoming')
    })
  })

  describe('fetchNearbyConcerts', () => {
    it('populates nearbyConcerts with response data', async () => {
      const mockConcerts = [{ id: 1, name: 'Nearby Concert' }]
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: mockConcerts } } as any)

      const store = useConcertsStore()
      await store.fetchNearbyConcerts(48.1173, -1.6778)

      expect(store.nearbyConcerts).toEqual(mockConcerts)
    })

    it('sets userLocation with provided lat/lng', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: [] } } as any)

      const store = useConcertsStore()
      await store.fetchNearbyConcerts(48.1173, -1.6778)

      expect(store.userLocation).toEqual({ lat: 48.1173, lng: -1.6778 })
    })

    it('calls API with correct params including default radius of 50', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: [] } } as any)

      const store = useConcertsStore()
      await store.fetchNearbyConcerts(48.1173, -1.6778)

      expect(api.get).toHaveBeenCalledWith('/api/v1/concerts/nearby', {
        params: { lat: 48.1173, lng: -1.6778, radius: 50 }
      })
    })

    it('calls API with custom radius', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concerts: [] } } as any)

      const store = useConcertsStore()
      await store.fetchNearbyConcerts(48.1173, -1.6778, 100)

      expect(api.get).toHaveBeenCalledWith('/api/v1/concerts/nearby', {
        params: { lat: 48.1173, lng: -1.6778, radius: 100 }
      })
    })
  })

  describe('fetchConcert', () => {
    it('sets currentConcert with fetched concert', async () => {
      const mockConcert = { id: 1, name: 'My Concert' }
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concert: mockConcert } } as any)

      const store = useConcertsStore()
      await store.fetchConcert(1)

      expect(store.currentConcert).toEqual(mockConcert)
      expect(api.get).toHaveBeenCalledWith('/api/v1/concerts/1')
    })

    it('returns the fetched concert', async () => {
      const mockConcert = { id: 2, name: 'Another Concert' }
      vi.mocked(api.get).mockResolvedValueOnce({ data: { concert: mockConcert } } as any)

      const store = useConcertsStore()
      const result = await store.fetchConcert(2)

      expect(result).toEqual(mockConcert)
    })
  })

  describe('createConcert', () => {
    it('adds new concert to concerts array', async () => {
      const newConcert = { id: 10, name: 'New Concert' }
      vi.mocked(api.post).mockResolvedValueOnce({ data: { concert: newConcert } } as any)

      const store = useConcertsStore()
      await store.createConcert({ name: 'New Concert' })

      expect(store.concerts).toContainEqual(newConcert)
    })

    it('calls correct API endpoint with wrapped concert data', async () => {
      const concertData = { name: 'New Concert', city: 'Brest' }
      vi.mocked(api.post).mockResolvedValueOnce({ data: { concert: { id: 1, ...concertData } } } as any)

      const store = useConcertsStore()
      await store.createConcert(concertData)

      expect(api.post).toHaveBeenCalledWith('/api/v1/concerts', { concert: concertData })
    })
  })

  describe('updateConcert', () => {
    it('updates existing concert in concerts array', async () => {
      const updatedConcert = { id: 1, name: 'Updated Concert' }
      vi.mocked(api.put).mockResolvedValueOnce({ data: { concert: updatedConcert } } as any)

      const store = useConcertsStore()
      store.concerts = [{ id: 1, name: 'Original' }, { id: 2, name: 'Other' }] as any
      await store.updateConcert(1, { name: 'Updated Concert' })

      expect(store.concerts[0]).toEqual(updatedConcert)
    })

    it('updates currentConcert if it matches the updated id', async () => {
      const updatedConcert = { id: 1, name: 'Updated Concert' }
      vi.mocked(api.put).mockResolvedValueOnce({ data: { concert: updatedConcert } } as any)

      const store = useConcertsStore()
      store.concerts = [{ id: 1, name: 'Original' }] as any
      store.currentConcert = { id: 1, name: 'Original' } as any
      await store.updateConcert(1, { name: 'Updated Concert' })

      expect(store.currentConcert).toEqual(updatedConcert)
    })

    it('does not update currentConcert if id does not match', async () => {
      const updatedConcert = { id: 2, name: 'Updated' }
      vi.mocked(api.put).mockResolvedValueOnce({ data: { concert: updatedConcert } } as any)

      const store = useConcertsStore()
      store.concerts = [{ id: 2, name: 'Other' }] as any
      store.currentConcert = { id: 1, name: 'Current' } as any
      await store.updateConcert(2, { name: 'Updated' })

      expect(store.currentConcert).toEqual({ id: 1, name: 'Current' })
    })
  })

  describe('deleteConcert', () => {
    it('removes concert from concerts array', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useConcertsStore()
      store.concerts = [{ id: 1 }, { id: 2 }] as any
      await store.deleteConcert(1)

      expect(store.concerts).toHaveLength(1)
      expect(store.concerts.find((c: any) => c.id === 1)).toBeUndefined()
    })

    it('also removes from nearbyConcerts array', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useConcertsStore()
      store.concerts = [{ id: 1 }] as any
      store.nearbyConcerts = [{ id: 1 }, { id: 2 }] as any
      await store.deleteConcert(1)

      expect(store.nearbyConcerts).toHaveLength(1)
      expect(store.nearbyConcerts.find((c: any) => c.id === 1)).toBeUndefined()
    })

    it('clears currentConcert if it matches deleted id', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useConcertsStore()
      store.concerts = [{ id: 1 }] as any
      store.currentConcert = { id: 1, name: 'Concert' } as any
      await store.deleteConcert(1)

      expect(store.currentConcert).toBeNull()
    })

    it('calls correct API endpoint', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useConcertsStore()
      store.concerts = [{ id: 3 }] as any
      await store.deleteConcert(3)

      expect(api.delete).toHaveBeenCalledWith('/api/v1/concerts/3')
    })
  })

  describe('setUserLocation', () => {
    it('sets userLocation state', () => {
      const store = useConcertsStore()
      store.setUserLocation(48.1173, -1.6778)

      expect(store.userLocation).toEqual({ lat: 48.1173, lng: -1.6778 })
    })

    it('overwrites previous userLocation', () => {
      const store = useConcertsStore()
      store.setUserLocation(48.1173, -1.6778)
      store.setUserLocation(47.9960, -4.0971)

      expect(store.userLocation).toEqual({ lat: 47.9960, lng: -4.0971 })
    })
  })
})
