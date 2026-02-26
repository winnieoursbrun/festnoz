import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../services/api'

export const useUsersStore = defineStore('users', () => {
  // State
  const users = ref([])
  const currentUser = ref(null)
  const loading = ref(false)
  const error = ref(null)

  // Getters
  const userCount = computed(() => users.value.length)
  const adminCount = computed(() => users.value.filter(u => u.admin).length)

  // Actions
  async function fetchUsers() {
    loading.value = true
    error.value = null
    try {
      const response = await api.get('/api/v1/users')
      users.value = response.data
      return response.data
    } catch (err) {
      error.value = err.response?.data?.error || 'Failed to fetch users'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function fetchUser(id) {
    loading.value = true
    error.value = null
    try {
      const response = await api.get(`/api/v1/users/${id}`)
      currentUser.value = response.data
      return response.data
    } catch (err) {
      error.value = err.response?.data?.error || 'Failed to fetch user'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function createUser(userData) {
    loading.value = true
    error.value = null
    try {
      const response = await api.post('/api/v1/users', userData)
      users.value.push(response.data)
      return response.data
    } catch (err) {
      error.value = err.response?.data?.errors?.join(', ') || 'Failed to create user'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateUser(id, userData) {
    loading.value = true
    error.value = null
    try {
      const response = await api.put(`/api/v1/users/${id}`, userData)

      const index = users.value.findIndex(u => u.id === id)
      if (index !== -1) {
        users.value[index] = response.data
      }

      if (currentUser.value?.id === id) {
        currentUser.value = response.data
      }

      return response.data
    } catch (err) {
      error.value = err.response?.data?.errors?.join(', ') || 'Failed to update user'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteUser(id) {
    loading.value = true
    error.value = null
    try {
      await api.delete(`/api/v1/users/${id}`)
      users.value = users.value.filter(u => u.id !== id)

      if (currentUser.value?.id === id) {
        currentUser.value = null
      }

      return true
    } catch (err) {
      error.value = err.response?.data?.error || 'Failed to delete user'
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    users,
    currentUser,
    loading,
    error,
    userCount,
    adminCount,
    fetchUsers,
    fetchUser,
    createUser,
    updateUser,
    deleteUser
  }
})
