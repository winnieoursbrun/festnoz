import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../services/api'

export const useConcertsStore = defineStore('concerts', () => {
  // State
  const concerts = ref([])
  const nearbyConcerts = ref([])
  const currentConcert = ref(null)
  const loading = ref(false)
  const error = ref(null)
  const userLocation = ref(null)

  // Getters
  const concertCount = computed(() => concerts.value.length)
  const upcomingConcerts = computed(() =>
    concerts.value.filter(c => c.is_upcoming)
  )

  // Actions
  async function fetchConcerts(filters = {}) {
    loading.value = true
    error.value = null
    try {
      const params = {}
      if (filters.artistId) params.artist_id = filters.artistId
      if (filters.city) params.city = filters.city
      if (filters.startDate) params.start_date = filters.startDate
      if (filters.endDate) params.end_date = filters.endDate

      const response = await api.get('/api/v1/concerts', { params })
      concerts.value = response.data.concerts
      return response.data.concerts
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to fetch concerts'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function fetchUpcomingConcerts() {
    loading.value = true
    error.value = null
    try {
      const response = await api.get('/api/v1/concerts/upcoming')
      concerts.value = response.data.concerts
      return response.data.concerts
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to fetch upcoming concerts'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function fetchNearbyConcerts(lat, lng, radius = 50) {
    loading.value = true
    error.value = null
    try {
      const response = await api.get('/api/v1/concerts/nearby', {
        params: { lat, lng, radius }
      })
      nearbyConcerts.value = response.data.concerts
      userLocation.value = { lat, lng }
      return response.data.concerts
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to fetch nearby concerts'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function fetchConcert(id) {
    loading.value = true
    error.value = null
    try {
      const response = await api.get(`/api/v1/concerts/${id}`)
      currentConcert.value = response.data.concert
      return response.data.concert
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to fetch concert'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function createConcert(concertData) {
    loading.value = true
    error.value = null
    try {
      const response = await api.post('/api/v1/concerts', {
        concert: concertData
      })

      concerts.value.push(response.data.concert)
      return response.data.concert
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to create concert'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateConcert(id, concertData) {
    loading.value = true
    error.value = null
    try {
      const response = await api.put(`/api/v1/concerts/${id}`, {
        concert: concertData
      })

      const index = concerts.value.findIndex(c => c.id === id)
      if (index !== -1) {
        concerts.value[index] = response.data.concert
      }

      if (currentConcert.value?.id === id) {
        currentConcert.value = response.data.concert
      }

      return response.data.concert
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to update concert'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteConcert(id) {
    loading.value = true
    error.value = null
    try {
      await api.delete(`/api/v1/concerts/${id}`)

      concerts.value = concerts.value.filter(c => c.id !== id)
      nearbyConcerts.value = nearbyConcerts.value.filter(c => c.id !== id)

      if (currentConcert.value?.id === id) {
        currentConcert.value = null
      }

      return true
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to delete concert'
      throw err
    } finally {
      loading.value = false
    }
  }

  function setUserLocation(lat, lng) {
    userLocation.value = { lat, lng }
  }

  return {
    concerts,
    nearbyConcerts,
    currentConcert,
    loading,
    error,
    userLocation,
    concertCount,
    upcomingConcerts,
    fetchConcerts,
    fetchUpcomingConcerts,
    fetchNearbyConcerts,
    fetchConcert,
    createConcert,
    updateConcert,
    deleteConcert,
    setUserLocation
  }
})
