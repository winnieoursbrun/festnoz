<template>
  <div id="app" class="min-h-screen bg-background relative overflow-x-hidden">
    <!-- Background gradient effects -->
    <div class="fixed inset-0 pointer-events-none">
      <div class="absolute inset-0 gradient-dark" />
      <div class="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[600px] gradient-glow opacity-50" />
      <div class="absolute bottom-0 right-0 w-[600px] h-[400px] gradient-glow opacity-30" />
    </div>

    <!-- App content -->
    <div class="relative z-10">
      <AppHeader v-if="!isAuthPage" />

      <main class="min-h-screen">
        <router-view />
      </main>
    </div>

    <!-- Toast notifications -->
    <Toaster position="bottom-right" :theme="'dark'" rich-colors />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from './stores/auth'
import AppHeader from './components/layout/AppHeader.vue'
import { Toaster } from '@/components/ui/sonner'

const route = useRoute()
const authStore = useAuthStore()

const isAuthPage = computed(() => {
  return ['Login', 'Signup', 'Welcome'].includes(route.name as string)
})

onMounted(async () => {
  // Check if user is logged in on app mount
  const token = localStorage.getItem('authToken')
  if (token && !authStore.user) {
    await authStore.fetchCurrentUser()
  }
})
</script>
