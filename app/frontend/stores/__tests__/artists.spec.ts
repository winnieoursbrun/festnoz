import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useArtistsStore } from '../artists'
import api from '../../services/api'

vi.mock('../../services/api', () => ({
  default: { get: vi.fn(), post: vi.fn(), put: vi.fn(), delete: vi.fn() }
}))

describe('Artists Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  describe('Initial State', () => {
    it('initializes with empty arrays', () => {
      const store = useArtistsStore()
      expect(store.artists).toEqual([])
      expect(store.followedArtists).toEqual([])
      expect(store.suggestedArtists).toEqual([])
    })

    it('initializes with null currentArtist', () => {
      const store = useArtistsStore()
      expect(store.currentArtist).toBeNull()
    })

    it('initializes with loading false', () => {
      const store = useArtistsStore()
      expect(store.loading).toBe(false)
    })

    it('initializes with null error', () => {
      const store = useArtistsStore()
      expect(store.error).toBeNull()
    })

    it('initializes with followedArtistsFetched false', () => {
      const store = useArtistsStore()
      expect(store.followedArtistsFetched).toBe(false)
    })

    it('initializes with syncing false', () => {
      const store = useArtistsStore()
      expect(store.syncing).toBe(false)
    })
  })

  describe('Getters', () => {
    it('artistCount reflects artists array length', () => {
      const store = useArtistsStore()
      expect(store.artistCount).toBe(0)
      store.artists = [{ id: 1 }, { id: 2 }] as any
      expect(store.artistCount).toBe(2)
    })

    it('followedCount reflects followedArtists array length', () => {
      const store = useArtistsStore()
      expect(store.followedCount).toBe(0)
      store.followedArtists = [{ id: 1 }] as any
      expect(store.followedCount).toBe(1)
    })

    it('suggestedCount reflects suggestedArtists array length', () => {
      const store = useArtistsStore()
      expect(store.suggestedCount).toBe(0)
      store.suggestedArtists = [{ id: 1 }, { id: 2 }, { id: 3 }] as any
      expect(store.suggestedCount).toBe(3)
    })
  })

  describe('fetchArtists', () => {
    it('populates artists array with response data', async () => {
      const mockArtists = [{ id: 1, name: 'Artist 1' }, { id: 2, name: 'Artist 2' }]
      vi.mocked(api.get).mockResolvedValueOnce({ data: { artists: mockArtists } } as any)

      const store = useArtistsStore()
      await store.fetchArtists()

      expect(store.artists).toEqual(mockArtists)
    })

    it('calls API without params when no filters', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { artists: [] } } as any)

      const store = useArtistsStore()
      await store.fetchArtists()

      expect(api.get).toHaveBeenCalledWith('/api/v1/artists', { params: {} })
    })

    it('passes genre filter as query param', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { artists: [] } } as any)

      const store = useArtistsStore()
      await store.fetchArtists({ genre: 'Celtic' })

      expect(api.get).toHaveBeenCalledWith('/api/v1/artists', { params: { genre: 'Celtic' } })
    })

    it('passes search filter as query param', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { artists: [] } } as any)

      const store = useArtistsStore()
      await store.fetchArtists({ search: 'Tri Yann' })

      expect(api.get).toHaveBeenCalledWith('/api/v1/artists', { params: { search: 'Tri Yann' } })
    })

    it('sets loading to true during fetch and false after', async () => {
      let loadingDuringFetch = false
      vi.mocked(api.get).mockImplementationOnce(async () => {
        loadingDuringFetch = useArtistsStore().loading
        return { data: { artists: [] } }
      })

      const store = useArtistsStore()
      await store.fetchArtists()

      expect(loadingDuringFetch).toBe(true)
      expect(store.loading).toBe(false)
    })

    it('sets error and throws on failure', async () => {
      const error = { response: { data: { message: 'Server error' } } }
      vi.mocked(api.get).mockRejectedValueOnce(error)

      const store = useArtistsStore()
      await expect(store.fetchArtists()).rejects.toEqual(error)
      expect(store.error).toBe('Server error')
    })
  })

  describe('fetchArtist', () => {
    it('sets currentArtist with fetched artist', async () => {
      const mockArtist = { id: 1, name: 'Tri Yann' }
      vi.mocked(api.get).mockResolvedValueOnce({ data: { artist: mockArtist } } as any)

      const store = useArtistsStore()
      await store.fetchArtist(1)

      expect(store.currentArtist).toEqual(mockArtist)
      expect(api.get).toHaveBeenCalledWith('/api/v1/artists/1')
    })

    it('returns the fetched artist', async () => {
      const mockArtist = { id: 2, name: 'Denez Prigent' }
      vi.mocked(api.get).mockResolvedValueOnce({ data: { artist: mockArtist } } as any)

      const store = useArtistsStore()
      const result = await store.fetchArtist(2)

      expect(result).toEqual(mockArtist)
    })
  })

  describe('fetchFollowedArtists', () => {
    it('populates followedArtists with response data', async () => {
      const mockArtists = [{ id: 1, name: 'Artist 1' }]
      vi.mocked(api.get).mockResolvedValueOnce({ data: { artists: mockArtists } } as any)

      const store = useArtistsStore()
      await store.fetchFollowedArtists()

      expect(store.followedArtists).toEqual(mockArtists)
      expect(store.followedArtistsFetched).toBe(true)
    })

    it('does not fetch again if already fetched (caching)', async () => {
      const mockArtists = [{ id: 1, name: 'Artist 1' }]
      vi.mocked(api.get).mockResolvedValueOnce({ data: { artists: mockArtists } } as any)

      const store = useArtistsStore()
      await store.fetchFollowedArtists()
      await store.fetchFollowedArtists()

      expect(api.get).toHaveBeenCalledTimes(1)
    })

    it('fetches again when force=true even if already fetched', async () => {
      const mockArtists = [{ id: 1, name: 'Artist 1' }]
      vi.mocked(api.get)
        .mockResolvedValueOnce({ data: { artists: mockArtists } } as any)
        .mockResolvedValueOnce({ data: { artists: mockArtists } } as any)

      const store = useArtistsStore()
      await store.fetchFollowedArtists()
      await store.fetchFollowedArtists(true)

      expect(api.get).toHaveBeenCalledTimes(2)
    })

    it('calls correct API endpoint', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { artists: [] } } as any)

      const store = useArtistsStore()
      await store.fetchFollowedArtists()

      expect(api.get).toHaveBeenCalledWith('/api/v1/user/followed_artists')
    })
  })

  describe('followArtist', () => {
    it('adds artist to followedArtists array', async () => {
      const mockArtist = { id: 5, name: 'New Artist' }
      vi.mocked(api.post).mockResolvedValueOnce({ data: { artist: mockArtist } } as any)

      const store = useArtistsStore()
      await store.followArtist(5)

      expect(store.followedArtists).toContainEqual(mockArtist)
    })

    it('calls correct API endpoint', async () => {
      vi.mocked(api.post).mockResolvedValueOnce({ data: { artist: { id: 5 } } } as any)

      const store = useArtistsStore()
      await store.followArtist(5)

      expect(api.post).toHaveBeenCalledWith('/api/v1/user/followed_artists', { artist_id: 5 })
    })

    it('does not add artist twice if already in followedArtists', async () => {
      const mockArtist = { id: 5, name: 'New Artist' }
      vi.mocked(api.post).mockResolvedValue({ data: { artist: mockArtist } } as any)

      const store = useArtistsStore()
      store.followedArtists = [mockArtist] as any
      await store.followArtist(5)

      expect(store.followedArtists).toHaveLength(1)
    })
  })

  describe('unfollowArtist', () => {
    it('removes artist from followedArtists array', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useArtistsStore()
      store.followedArtists = [{ id: 1, name: 'Artist 1' }, { id: 2, name: 'Artist 2' }] as any
      await store.unfollowArtist(1)

      expect(store.followedArtists).toHaveLength(1)
      expect(store.followedArtists.find((a: any) => a.id === 1)).toBeUndefined()
    })

    it('calls correct API endpoint', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useArtistsStore()
      store.followedArtists = [{ id: 3 }] as any
      await store.unfollowArtist(3)

      expect(api.delete).toHaveBeenCalledWith('/api/v1/user/followed_artists/3')
    })
  })

  describe('createArtist', () => {
    it('adds new artist to artists array', async () => {
      const newArtist = { id: 10, name: 'New Artist' }
      vi.mocked(api.post).mockResolvedValueOnce({ data: { artist: newArtist } } as any)

      const store = useArtistsStore()
      await store.createArtist({ name: 'New Artist' })

      expect(store.artists).toContainEqual(newArtist)
    })

    it('calls correct API endpoint with wrapped artist data', async () => {
      const artistData = { name: 'New Artist', genre: 'Celtic' }
      vi.mocked(api.post).mockResolvedValueOnce({ data: { artist: { id: 1, ...artistData } } } as any)

      const store = useArtistsStore()
      await store.createArtist(artistData)

      expect(api.post).toHaveBeenCalledWith('/api/v1/artists', { artist: artistData })
    })
  })

  describe('updateArtist', () => {
    it('updates existing artist in artists array', async () => {
      const updatedArtist = { id: 1, name: 'Updated Name' }
      vi.mocked(api.put).mockResolvedValueOnce({ data: { artist: updatedArtist } } as any)

      const store = useArtistsStore()
      store.artists = [{ id: 1, name: 'Original Name' }, { id: 2, name: 'Other' }] as any
      await store.updateArtist(1, { name: 'Updated Name' })

      expect(store.artists[0]).toEqual(updatedArtist)
    })

    it('updates currentArtist if it matches the updated id', async () => {
      const updatedArtist = { id: 1, name: 'Updated Name' }
      vi.mocked(api.put).mockResolvedValueOnce({ data: { artist: updatedArtist } } as any)

      const store = useArtistsStore()
      store.artists = [{ id: 1, name: 'Original Name' }] as any
      store.currentArtist = { id: 1, name: 'Original Name' } as any
      await store.updateArtist(1, { name: 'Updated Name' })

      expect(store.currentArtist).toEqual(updatedArtist)
    })

    it('does not update currentArtist if id does not match', async () => {
      const updatedArtist = { id: 2, name: 'Updated Name' }
      vi.mocked(api.put).mockResolvedValueOnce({ data: { artist: updatedArtist } } as any)

      const store = useArtistsStore()
      store.artists = [{ id: 2, name: 'Other' }] as any
      store.currentArtist = { id: 1, name: 'Current' } as any
      await store.updateArtist(2, { name: 'Updated Name' })

      expect(store.currentArtist).toEqual({ id: 1, name: 'Current' })
    })
  })

  describe('deleteArtist', () => {
    it('removes artist from artists array', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useArtistsStore()
      store.artists = [{ id: 1 }, { id: 2 }] as any
      await store.deleteArtist(1)

      expect(store.artists).toHaveLength(1)
      expect(store.artists.find((a: any) => a.id === 1)).toBeUndefined()
    })

    it('also removes artist from followedArtists array', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useArtistsStore()
      store.artists = [{ id: 1 }] as any
      store.followedArtists = [{ id: 1 }, { id: 2 }] as any
      await store.deleteArtist(1)

      expect(store.followedArtists).toHaveLength(1)
      expect(store.followedArtists.find((a: any) => a.id === 1)).toBeUndefined()
    })

    it('calls correct API endpoint', async () => {
      vi.mocked(api.delete).mockResolvedValueOnce({} as any)

      const store = useArtistsStore()
      store.artists = [{ id: 7 }] as any
      await store.deleteArtist(7)

      expect(api.delete).toHaveBeenCalledWith('/api/v1/artists/7')
    })
  })

  describe('isFollowing', () => {
    it('returns true when artist is in followedArtists', () => {
      const store = useArtistsStore()
      store.followedArtists = [{ id: 1 }, { id: 2 }] as any
      expect(store.isFollowing(1)).toBe(true)
    })

    it('returns false when artist is not in followedArtists', () => {
      const store = useArtistsStore()
      store.followedArtists = [{ id: 1 }] as any
      expect(store.isFollowing(99)).toBe(false)
    })

    it('returns false when followedArtists is empty', () => {
      const store = useArtistsStore()
      expect(store.isFollowing(1)).toBe(false)
    })
  })

  describe('fetchSuggestedArtists', () => {
    it('populates suggestedArtists with response data', async () => {
      const mockSuggested = [{ id: 1, artist: { name: 'Artist 1' } }]
      vi.mocked(api.get).mockResolvedValueOnce({ data: { data: mockSuggested } } as any)

      const store = useArtistsStore()
      await store.fetchSuggestedArtists()

      expect(store.suggestedArtists).toEqual(mockSuggested)
    })

    it('does not fetch again if already fetched (caching)', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { data: [] } } as any)

      const store = useArtistsStore()
      await store.fetchSuggestedArtists()
      await store.fetchSuggestedArtists()

      expect(api.get).toHaveBeenCalledTimes(1)
    })

    it('fetches again when force=true', async () => {
      vi.mocked(api.get)
        .mockResolvedValueOnce({ data: { data: [] } } as any)
        .mockResolvedValueOnce({ data: { data: [] } } as any)

      const store = useArtistsStore()
      await store.fetchSuggestedArtists()
      await store.fetchSuggestedArtists(true)

      expect(api.get).toHaveBeenCalledTimes(2)
    })

    it('calls correct API endpoint', async () => {
      vi.mocked(api.get).mockResolvedValueOnce({ data: { data: [] } } as any)

      const store = useArtistsStore()
      await store.fetchSuggestedArtists()

      expect(api.get).toHaveBeenCalledWith('/api/v1/suggested_artists')
    })
  })
})
