<template>
  <div class="min-h-screen relative overflow-hidden">
    <!-- Animated Background -->
    <div class="absolute inset-0 bg-gradient-to-br from-background via-primary/5 to-purple-500/10">
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_20%_30%,_var(--tw-gradient-stops))] from-primary/10 via-transparent to-transparent"></div>
    </div>

    <div class="relative container mx-auto px-4 py-10">
      <!-- Welcome Header -->
      <div class="mb-12 animate-in fade-in slide-in-from-bottom-4 duration-1000">
        <div class="flex items-center gap-4 mb-3">
          <h1 class="text-5xl font-black tracking-tight">
            Hello, {{ authStore.user?.username }}
          </h1>
          <span class="text-5xl animate-bounce">👋</span>
        </div>
        <p class="text-xl text-muted-foreground font-medium">
          Here's what's happening with your music
        </p>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12 animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-100">
        <!-- Following Card -->
        <Card class="relative overflow-hidden border-2 transition-all hover:border-primary/50 hover:shadow-xl hover:-translate-y-1 duration-300 group">
          <div class="absolute top-0 right-0 w-40 h-40 bg-gradient-to-br from-primary/10 to-transparent rounded-full -translate-y-1/2 translate-x-1/2"></div>
          <CardHeader class="pb-3">
            <CardDescription class="text-base font-medium">Following</CardDescription>
            <CardTitle class="text-5xl font-black bg-gradient-to-br from-primary to-primary/60 bg-clip-text text-transparent">
              {{ artistsStore.followedCount }}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p class="text-sm text-muted-foreground font-medium">
              {{ artistsStore.followedCount === 1 ? 'artist' : 'artists' }} in your collection
            </p>
            <div class="flex items-center gap-1 mt-3 text-primary text-sm font-semibold opacity-0 group-hover:opacity-100 transition-opacity">
              View all
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="transition-transform group-hover:translate-x-1">
                <path d="m9 18 6-6-6-6"/>
              </svg>
            </div>
          </CardContent>
        </Card>

        <!-- Upcoming Shows Card -->
        <Card class="relative overflow-hidden border-2 transition-all hover:border-purple-500/50 hover:shadow-xl hover:-translate-y-1 duration-300 group">
          <div class="absolute top-0 right-0 w-40 h-40 bg-gradient-to-br from-purple-500/10 to-transparent rounded-full -translate-y-1/2 translate-x-1/2"></div>
          <CardHeader class="pb-3">
            <CardDescription class="text-base font-medium">Upcoming Shows</CardDescription>
            <CardTitle class="text-5xl font-black bg-gradient-to-br from-purple-500 to-purple-500/60 bg-clip-text text-transparent">
              {{ upcomingCount }}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p class="text-sm text-muted-foreground font-medium">
              concerts from artists you follow
            </p>
            <div class="flex items-center gap-1 mt-3 text-purple-500 text-sm font-semibold opacity-0 group-hover:opacity-100 transition-opacity">
              View concerts
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="transition-transform group-hover:translate-x-1">
                <path d="m9 18 6-6-6-6"/>
              </svg>
            </div>
          </CardContent>
        </Card>

        <!-- Quick Actions Card -->
        <Card class="relative overflow-hidden border-2 bg-gradient-to-br from-pink-500/5 to-primary/5 transition-all hover:shadow-xl hover:-translate-y-1 duration-300">
          <CardHeader class="pb-3">
            <CardDescription class="text-base font-medium flex items-center gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/>
                <circle cx="12" cy="12" r="3"/>
              </svg>
              Quick Actions
            </CardDescription>
          </CardHeader>
          <CardContent class="space-y-3">
            <Button as-child variant="outline" class="w-full justify-start h-11 border-2 hover:border-primary/50 transition-all group">
              <router-link to="/artists" class="flex items-center">
                <span class="text-2xl mr-3 transition-transform group-hover:scale-110">🎭</span>
                <span class="font-semibold">Discover Artists</span>
              </router-link>
            </Button>
            <Button as-child variant="outline" class="w-full justify-start h-11 border-2 hover:border-primary/50 transition-all group">
              <router-link to="/map" class="flex items-center">
                <span class="text-2xl mr-3 transition-transform group-hover:scale-110">🗺️</span>
                <span class="font-semibold">Explore Map</span>
              </router-link>
            </Button>
          </CardContent>
        </Card>
      </div>

      <!-- Your Artists Section -->
      <div class="animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-200">
        <div class="flex items-center justify-between mb-8">
          <div>
            <h2 class="text-3xl font-bold mb-2">Your Artists</h2>
            <p class="text-muted-foreground font-medium">Artists you're following</p>
          </div>
          <Button as-child variant="ghost" size="lg" class="group">
            <router-link to="/artists" class="flex items-center gap-2">
              <span class="font-semibold">View all</span>
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="transition-transform group-hover:translate-x-1">
                <path d="m9 18 6-6-6-6"/>
              </svg>
            </router-link>
          </Button>
        </div>

        <!-- Loading State -->
        <div v-if="artistsStore.loading" class="flex items-center justify-center py-24">
          <div class="text-center space-y-4">
            <div class="h-16 w-16 animate-spin rounded-full border-4 border-primary border-t-transparent mx-auto"></div>
            <p class="text-muted-foreground font-medium">Loading your artists...</p>
          </div>
        </div>

        <!-- Empty State -->
        <Card v-else-if="artistsStore.followedArtists.length === 0" class="border-2 border-dashed hover:border-primary/50 transition-all">
          <CardContent class="flex flex-col items-center justify-center py-20">
            <div class="text-8xl mb-6 animate-bounce">🎵</div>
            <h3 class="text-2xl font-bold mb-3">No artists yet</h3>
            <p class="text-muted-foreground text-center max-w-md mb-8 text-lg leading-relaxed">
              Start following your favorite Breton artists to see their upcoming concerts here
            </p>
            <Button as-child size="lg" class="h-12 px-8 font-semibold">
              <router-link to="/artists">
                Discover Artists
              </router-link>
            </Button>
          </CardContent>
        </Card>

        <!-- Artists Grid -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <ArtistCard
            v-for="artist in artistsStore.followedArtists.slice(0, 6)"
            :key="artist.id"
            :artist="artist"
          />
        </div>

        <!-- View More -->
        <div v-if="artistsStore.followedArtists.length > 6" class="text-center mt-10">
          <Button as-child variant="outline" size="lg" class="h-14 px-10 text-base font-semibold border-2 hover:border-primary/50 transition-all group">
            <router-link to="/artists" class="flex items-center gap-2">
              View all {{ artistsStore.followedCount }} artists
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="transition-transform group-hover:translate-x-1">
                <path d="m9 18 6-6-6-6"/>
              </svg>
            </router-link>
          </Button>
        </div>
      </div>
    </div>
  </div>

<Calendar />
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useArtistsStore } from '../stores/artists'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import ArtistCard from '../components/artists/ArtistCard.vue'

import { Calendar } from '@/components/ui/calendar'

const authStore = useAuthStore()
const artistsStore = useArtistsStore()

const upcomingCount = computed(() => {
  return artistsStore.followedArtists.reduce((sum: number, artist: any) => {
    return sum + (artist.upcoming_concerts_count || 0)
  }, 0)
})

onMounted(async () => {
  await artistsStore.fetchFollowedArtists()
})
</script>
