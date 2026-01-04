import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../services/api'

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref(null)
  const token = ref(localStorage.getItem('authToken'))
  const loading = ref(false)
  const error = ref(null)

  // Getters
  const isAuthenticated = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.admin || false)

  // Actions
  async function login(email, password) {
    loading.value = true
    error.value = null
    try {
      const response = await api.post('/api/auth/login', {
        user: { email, password }
      })

      const authToken = response.headers.authorization
      if (authToken) {
        token.value = authToken
        localStorage.setItem('authToken', authToken)
        user.value = response.data.user
      }

      return response.data
    } catch (err) {
      error.value = err.response?.data?.message || 'Login failed'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function signup(username, email, password, passwordConfirmation) {
    loading.value = true
    error.value = null
    try {
      const response = await api.post('/api/auth/signup', {
        user: {
          username,
          email,
          password,
          password_confirmation: passwordConfirmation
        }
      })

      const authToken = response.headers.authorization
      if (authToken) {
        token.value = authToken
        localStorage.setItem('authToken', authToken)
        user.value = response.data.user
      }

      return response.data
    } catch (err) {
      error.value = err.response?.data?.message || 'Signup failed'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    loading.value = true
    error.value = null
    try {
      await api.delete('/api/auth/logout')
    } catch (err) {
      console.error('Logout error:', err)
    } finally {
      token.value = null
      user.value = null
      localStorage.removeItem('authToken')
      loading.value = false
    }
  }

  async function fetchCurrentUser() {
    if (!token.value) return

    loading.value = true
    error.value = null
    try {
      const response = await api.get('/api/v1/auth/me')
      user.value = response.data.user
      return response.data.user
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to fetch user'
      token.value = null
      user.value = null
      localStorage.removeItem('authToken')
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    user,
    token,
    loading,
    error,
    isAuthenticated,
    isAdmin,
    login,
    signup,
    logout,
    fetchCurrentUser
  }
})
