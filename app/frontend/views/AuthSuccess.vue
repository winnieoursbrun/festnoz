<template>
  <div class="min-h-screen flex items-center justify-center p-6">
    <div class="text-center space-y-6">
      <div class="space-y-4">
        <div class="relative mx-auto w-20 h-20">
          <div class="absolute inset-0 bg-primary/20 blur-2xl rounded-full animate-pulse" />
          <div class="relative p-4 rounded-2xl bg-card/50 border border-border/50 backdrop-blur-sm">
            <Music class="w-12 h-12 text-primary animate-bounce" />
          </div>
        </div>
        <div class="space-y-2">
          <h2 class="text-2xl font-bold">Authentication Successful!</h2>
          <p class="text-muted-foreground">Redirecting you to the dashboard...</p>
        </div>
        <div class="flex items-center justify-center gap-2">
          <div class="w-2 h-2 rounded-full bg-primary animate-bounce" style="animation-delay: 0ms" />
          <div class="w-2 h-2 rounded-full bg-primary animate-bounce" style="animation-delay: 150ms" />
          <div class="w-2 h-2 rounded-full bg-primary animate-bounce" style="animation-delay: 300ms" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { Music } from 'lucide-vue-next'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

onMounted(async () => {
  try {
    // Get token from query parameter
    const token = route.query.token as string

    if (!token) {
      console.error('No token received')
      router.push('/login')
      return
    }

    // Save token to localStorage
    localStorage.setItem('authToken', token)

    // Fetch user data
    await authStore.fetchCurrentUser()

    // Redirect to dashboard
    setTimeout(() => {
      router.push('/dashboard')
    }, 1000)
  } catch (error) {
    console.error('Auth success error:', error)
    router.push('/login')
  }
})
</script>
