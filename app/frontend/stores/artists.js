import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../services/api'

export const useArtistsStore = defineStore('artists', () => {
  // State
  const artists = ref([])
  const followedArtists = ref([])
  const currentArtist = ref(null)
  const loading = ref(false)
  const error = ref(null)
  const followedArtistsFetched = ref(false)

  // Getters
  const artistCount = computed(() => artists.value.length)
  const followedCount = computed(() => followedArtists.value.length)

  // Actions
  async function fetchArtists(filters = {}) {
    loading.value = true
    error.value = null
    try {
      const params = {}
      if (filters.genre) params.genre = filters.genre
      if (filters.search) params.search = filters.search

      const response = await api.get('/api/v1/artists', { params })
      artists.value = response.data.artists
      return response.data.artists
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to fetch artists'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function fetchArtist(id) {
    loading.value = true
    error.value = null
    try {
      const response = await api.get(`/api/v1/artists/${id}`)
      currentArtist.value = response.data.artist
      return response.data.artist
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to fetch artist'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function fetchFollowedArtists(force = false) {
    // Prevent duplicate fetches
    if (followedArtistsFetched.value && !force) return followedArtists.value
    if (loading.value) return followedArtists.value

    loading.value = true
    error.value = null
    try {
      const response = await api.get('/api/v1/user/followed_artists')
      followedArtists.value = response.data.artists
      followedArtistsFetched.value = true
      return response.data.artists
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to fetch followed artists'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function followArtist(artistId) {
    loading.value = true
    error.value = null
    try {
      const response = await api.post('/api/v1/user/followed_artists', {
        artist_id: artistId
      })

      // Add to followed artists list
      const artist = response.data.artist
      if (!followedArtists.value.find(a => a.id === artist.id)) {
        followedArtists.value.push(artist)
      }

      return response.data
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to follow artist'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function unfollowArtist(artistId) {
    loading.value = true
    error.value = null
    try {
      await api.delete(`/api/v1/user/followed_artists/${artistId}`)

      // Remove from followed artists list
      followedArtists.value = followedArtists.value.filter(a => a.id !== artistId)

      return true
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to unfollow artist'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function createArtist(artistData) {
    loading.value = true
    error.value = null
    try {
      const response = await api.post('/api/v1/artists', {
        artist: artistData
      })

      artists.value.push(response.data.artist)
      return response.data.artist
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to create artist'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateArtist(id, artistData) {
    loading.value = true
    error.value = null
    try {
      const response = await api.put(`/api/v1/artists/${id}`, {
        artist: artistData
      })

      const index = artists.value.findIndex(a => a.id === id)
      if (index !== -1) {
        artists.value[index] = response.data.artist
      }

      if (currentArtist.value?.id === id) {
        currentArtist.value = response.data.artist
      }

      return response.data.artist
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to update artist'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteArtist(id) {
    loading.value = true
    error.value = null
    try {
      await api.delete(`/api/v1/artists/${id}`)

      artists.value = artists.value.filter(a => a.id !== id)
      followedArtists.value = followedArtists.value.filter(a => a.id !== id)

      if (currentArtist.value?.id === id) {
        currentArtist.value = null
      }

      return true
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to delete artist'
      throw err
    } finally {
      loading.value = false
    }
  }

  function isFollowing(artistId) {
    return followedArtists.value.some(a => a.id === artistId)
  }

  return {
    artists,
    followedArtists,
    currentArtist,
    loading,
    error,
    followedArtistsFetched,
    artistCount,
    followedCount,
    fetchArtists,
    fetchArtist,
    fetchFollowedArtists,
    followArtist,
    unfollowArtist,
    createArtist,
    updateArtist,
    deleteArtist,
    isFollowing
  }
})
