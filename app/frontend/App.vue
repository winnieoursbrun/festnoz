<template>
  <div id="app" class="min-h-screen bg-gradient-to-br from-purple-900 via-purple-800 to-indigo-900">
    <AppHeader v-if="!isAuthPage" />
    <main class="min-h-screen">
      <router-view />
    </main>
    <AppFooter v-if="!isAuthPage" />
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from './stores/auth'
import AppHeader from './components/layout/AppHeader.vue'
import AppFooter from './components/layout/AppFooter.vue'

const route = useRoute()
const authStore = useAuthStore()

const isAuthPage = computed(() => {
  return ['Login', 'Signup', 'Welcome'].includes(route.name)
})

onMounted(async () => {
  // Check if user is logged in on app mount
  const token = localStorage.getItem('authToken')
  if (token && !authStore.user) {
    await authStore.fetchCurrentUser()
  }
})
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#app {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
