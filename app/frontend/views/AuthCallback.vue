<template>
  <div class="min-h-screen flex items-center justify-center p-6">
    <div class="text-center space-y-6">
      <!-- Loading State -->
      <div v-if="loading" class="space-y-4">
        <div class="relative mx-auto w-20 h-20">
          <div class="absolute inset-0 bg-primary/20 blur-2xl rounded-full animate-pulse" />
          <div class="relative p-4 rounded-2xl bg-card/50 border border-border/50 backdrop-blur-sm">
            <Music class="w-12 h-12 text-primary animate-bounce" />
          </div>
        </div>
        <div class="space-y-2">
          <h2 class="text-2xl font-bold">Connecting to Spotify...</h2>
          <p class="text-muted-foreground">Please wait while we complete your authentication</p>
        </div>
        <div class="flex items-center justify-center gap-2">
          <div class="w-2 h-2 rounded-full bg-primary animate-bounce" style="animation-delay: 0ms" />
          <div class="w-2 h-2 rounded-full bg-primary animate-bounce" style="animation-delay: 150ms" />
          <div class="w-2 h-2 rounded-full bg-primary animate-bounce" style="animation-delay: 300ms" />
        </div>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="space-y-4">
        <div class="relative mx-auto w-20 h-20">
          <div class="relative p-4 rounded-2xl bg-destructive/10 border border-destructive/50">
            <AlertCircle class="w-12 h-12 text-destructive" />
          </div>
        </div>
        <div class="space-y-2">
          <h2 class="text-2xl font-bold">Authentication Failed</h2>
          <p class="text-muted-foreground">{{ errorMessage }}</p>
        </div>
        <Button as-child>
          <router-link to="/login">
            Back to Login
          </router-link>
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { Button } from '@/components/ui/button'
import { Music, AlertCircle } from 'lucide-vue-next'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const loading = ref(true)
const error = ref(false)
const errorMessage = ref('')

onMounted(async () => {
  try {
    // Extract token and error from query parameters
    const token = route.query.token as string
    const errorParam = route.query.error as string

    if (errorParam) {
      error.value = true
      errorMessage.value = getErrorMessage(errorParam)
      loading.value = false
      return
    }

    if (!token) {
      error.value = true
      errorMessage.value = 'No authentication token received'
      loading.value = false
      return
    }

    // Save token and fetch user data
    localStorage.setItem('authToken', token)
    await authStore.fetchCurrentUser()

    // Redirect to dashboard on success
    router.push('/dashboard')
  } catch (err) {
    console.error('OAuth callback error:', err)
    error.value = true
    errorMessage.value = 'An unexpected error occurred during authentication'
    loading.value = false
  }
})

function getErrorMessage(errorCode: string): string {
  const errorMessages: Record<string, string> = {
    'authentication_failed': 'Failed to authenticate with Spotify. Please try again.',
    'access_denied': 'You denied access to your Spotify account.',
    'invalid_request': 'Invalid authentication request. Please try again.',
    'server_error': 'A server error occurred. Please try again later.',
  }

  return errorMessages[errorCode] || 'An unknown error occurred. Please try again.'
}
</script>
