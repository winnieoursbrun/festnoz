<template>
  <div class="min-h-screen">
    <div class="container mx-auto px-4 lg:px-8 py-8 lg:py-12">
      <!-- Welcome Header -->
      <div class="mb-10" v-motion-fade-up>
        <div class="flex items-center gap-3 mb-2">
          <h1 class="text-3xl lg:text-4xl font-bold tracking-tight">
            Hello, {{ authStore.user?.username }}
          </h1>
          <span class="text-3xl lg:text-4xl">👋</span>
        </div>
        <p class="text-muted-foreground">
          Here's what's happening with your music
        </p>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 lg:gap-6 mb-10">
        <!-- Following Card -->
        <Card
          class="relative overflow-hidden hover-lift bg-card/50 border-border/50 group cursor-pointer"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 100 } }"
        >
          <div class="absolute top-0 right-0 w-32 h-32 bg-gradient-to-br from-primary/10 to-transparent rounded-full -translate-y-1/2 translate-x-1/2" />
          <CardHeader class="pb-2">
            <CardDescription class="flex items-center gap-2 text-sm font-medium">
              <Users class="w-4 h-4 text-primary" />
              Following
            </CardDescription>
            <CardTitle class="text-4xl font-bold text-gradient-purple">
              {{ artistsStore.followedCount }}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p class="text-sm text-muted-foreground">
              {{ artistsStore.followedCount === 1 ? 'artist' : 'artists' }} in your collection
            </p>
            <router-link to="/artists" class="flex items-center gap-1 mt-3 text-primary text-sm font-medium opacity-0 group-hover:opacity-100 transition-opacity">
              View all
              <ChevronRight class="w-4 h-4" />
            </router-link>
          </CardContent>
        </Card>

        <!-- Upcoming Shows Card -->
        <Card
          class="relative overflow-hidden hover-lift bg-card/50 border-border/50 group cursor-pointer"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 200 } }"
        >
          <div class="absolute top-0 right-0 w-32 h-32 bg-gradient-to-br from-purple-500/10 to-transparent rounded-full -translate-y-1/2 translate-x-1/2" />
          <CardHeader class="pb-2">
            <CardDescription class="flex items-center gap-2 text-sm font-medium">
              <Calendar class="w-4 h-4 text-purple-500" />
              Upcoming Shows
            </CardDescription>
            <CardTitle class="text-4xl font-bold text-gradient">
              {{ upcomingCount }}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p class="text-sm text-muted-foreground">
              concerts from artists you follow
            </p>
            <router-link to="/map" class="flex items-center gap-1 mt-3 text-purple-500 text-sm font-medium opacity-0 group-hover:opacity-100 transition-opacity">
              View concerts
              <ChevronRight class="w-4 h-4" />
            </router-link>
          </CardContent>
        </Card>

        <!-- Quick Actions Card -->
        <Card
          class="relative overflow-hidden bg-card/50 border-border/50"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 300 } }"
        >
          <CardHeader class="pb-2">
            <CardDescription class="flex items-center gap-2 text-sm font-medium">
              <Sparkles class="w-4 h-4 text-pink-500" />
              Quick Actions
            </CardDescription>
          </CardHeader>
          <CardContent class="space-y-2">
            <Button as-child variant="outline" class="w-full justify-start h-10 bg-background/50 hover:bg-accent group">
              <router-link to="/artists" class="flex items-center gap-3">
                <div class="p-1.5 rounded-md bg-primary/10">
                  <Users class="w-4 h-4 text-primary" />
                </div>
                <span class="font-medium">Discover Artists</span>
              </router-link>
            </Button>
            <Button
              v-if="authStore.user?.provider === 'spotify'"
              as-child
              variant="outline"
              class="w-full justify-start h-10 bg-background/50 hover:bg-accent group"
            >
              <router-link to="/suggested-artists" class="flex items-center gap-3">
                <div class="p-1.5 rounded-md bg-purple-500/10">
                  <Sparkles class="w-4 h-4 text-purple-500" />
                </div>
                <span class="font-medium">Suggested Artists</span>
              </router-link>
            </Button>
            <Button as-child variant="outline" class="w-full justify-start h-10 bg-background/50 hover:bg-accent group">
              <router-link to="/map" class="flex items-center gap-3">
                <div class="p-1.5 rounded-md bg-pink-500/10">
                  <MapIcon class="w-4 h-4 text-pink-500" />
                </div>
                <span class="font-medium">Explore Map</span>
              </router-link>
            </Button>
          </CardContent>
        </Card>
      </div>

      <!-- Your Artists Section -->
      <div v-motion :initial="{ opacity: 0, y: 20 }" :enter="{ opacity: 1, y: 0, transition: { delay: 400 } }">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h2 class="text-2xl font-bold mb-1">Your Artists</h2>
            <p class="text-sm text-muted-foreground">Artists you're following</p>
          </div>
          <Button as-child variant="ghost" class="group">
            <router-link to="/artists" class="flex items-center gap-2">
              <span class="font-medium">View all</span>
              <ArrowRight class="w-4 h-4 transition-transform group-hover:translate-x-1" />
            </router-link>
          </Button>
        </div>

        <!-- Loading State with Skeletons -->
        <div v-if="artistsStore.loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 lg:gap-6">
          <Card v-for="i in 6" :key="i" class="bg-card/50 border-border/50">
            <div class="h-32 skeleton-shimmer rounded-t-lg" />
            <CardContent class="pt-4 space-y-3">
              <Skeleton class="h-5 w-3/4" />
              <Skeleton class="h-4 w-1/2" />
              <div class="flex gap-4 pt-2">
                <Skeleton class="h-4 w-16" />
                <Skeleton class="h-4 w-20" />
              </div>
            </CardContent>
          </Card>
        </div>

        <!-- Empty State -->
        <Card v-else-if="artistsStore.followedArtists.length === 0" class="border-dashed border-border/50 bg-card/30">
          <CardContent class="flex flex-col items-center justify-center py-16">
            <div class="p-4 rounded-2xl bg-primary/10 mb-6">
              <Music class="w-12 h-12 text-primary" />
            </div>
            <h3 class="text-xl font-bold mb-2">No artists yet</h3>
            <p class="text-muted-foreground text-center max-w-sm mb-6">
              Start following your favorite Breton artists to see their upcoming concerts here
            </p>
            <Button as-child class="font-medium">
              <router-link to="/artists" class="flex items-center gap-2">
                <Search class="w-4 h-4" />
                Discover Artists
              </router-link>
            </Button>
          </CardContent>
        </Card>

        <!-- Artists Grid -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 lg:gap-6">
          <div
            v-for="(artist, index) in artistsStore.followedArtists.slice(0, 6)"
            :key="artist.id"
            v-motion
            :initial="{ opacity: 0, y: 20 }"
            :enter="{ opacity: 1, y: 0, transition: { delay: 100 + index * 50 } }"
          >
            <ArtistCard :artist="artist" />
          </div>
        </div>

        <!-- View More -->
        <div v-if="artistsStore.followedArtists.length > 6" class="text-center mt-8">
          <Button as-child variant="outline" class="font-medium group">
            <router-link to="/artists" class="flex items-center gap-2">
              View all {{ artistsStore.followedCount }} artists
              <ArrowRight class="w-4 h-4 transition-transform group-hover:translate-x-1" />
            </router-link>
          </Button>
        </div>
      </div>

      <!-- Suggested Artists Section -->
      <div
        v-if="authStore.user?.provider === 'spotify'"
        class="mt-12"
        v-motion
        :initial="{ opacity: 0, y: 20 }"
        :enter="{ opacity: 1, y: 0, transition: { delay: 500 } }"
      >
        <div class="flex items-center justify-between mb-6">
          <div>
            <div class="flex items-center gap-2 mb-1">
              <Sparkles class="w-5 h-5 text-purple-400" />
              <h2 class="text-2xl font-bold">Suggested for You</h2>
            </div>
            <p class="text-sm text-muted-foreground">Based on your Spotify listening history</p>
          </div>
          <Button as-child variant="ghost" class="group">
            <router-link to="/suggested-artists" class="flex items-center gap-2">
              <span class="font-medium">View all</span>
              <ArrowRight class="w-4 h-4 transition-transform group-hover:translate-x-1" />
            </router-link>
          </Button>
        </div>

        <!-- Loading State -->
        <div v-if="artistsStore.loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          <Card v-for="i in 4" :key="i" class="bg-card/50 border-border/50">
            <div class="h-32 skeleton-shimmer rounded-t-lg" />
            <CardContent class="pt-4 space-y-3">
              <Skeleton class="h-5 w-3/4" />
              <Skeleton class="h-4 w-1/2" />
            </CardContent>
          </Card>
        </div>

        <!-- Empty State / Call to Action -->
        <Card
          v-else-if="artistsStore.suggestedArtists.length === 0"
          class="border-dashed border-border/50 bg-gradient-to-r from-purple-500/5 to-pink-500/5"
        >
          <CardContent class="flex flex-col items-center justify-center py-12">
            <div class="p-4 rounded-2xl bg-purple-500/10 mb-6">
              <Sparkles class="w-12 h-12 text-purple-400" />
            </div>
            <h3 class="text-xl font-bold mb-2">Get Personalized Recommendations</h3>
            <p class="text-muted-foreground text-center max-w-md mb-6">
              Sync your Spotify listening history to discover new Breton artists tailored to your taste
            </p>
            <Button @click="handleSyncArtists" :disabled="artistsStore.syncing" class="font-medium">
              <Sparkles v-if="!artistsStore.syncing" class="w-4 h-4 mr-2" />
              <span v-if="artistsStore.syncing">Syncing...</span>
              <span v-else>Sync from Spotify</span>
            </Button>
          </CardContent>
        </Card>

        <!-- Suggested Artists Grid -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          <div
            v-for="(suggestion, index) in artistsStore.suggestedArtists.slice(0, 4)"
            :key="suggestion.id"
            v-motion
            :initial="{ opacity: 0, y: 20 }"
            :enter="{ opacity: 1, y: 0, transition: { delay: 100 + index * 50 } }"
          >
            <ArtistCard :artist="suggestion.artist" />
          </div>
        </div>

        <!-- View More Suggestions -->
        <div v-if="artistsStore.suggestedArtists.length > 4" class="text-center mt-6">
          <Button as-child variant="outline" class="font-medium group">
            <router-link to="/suggested-artists" class="flex items-center gap-2">
              View all {{ artistsStore.suggestedCount }} suggestions
              <ArrowRight class="w-4 h-4 transition-transform group-hover:translate-x-1" />
            </router-link>
          </Button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useArtistsStore } from '../stores/artists'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import ArtistCard from '../components/artists/ArtistCard.vue'
import {
  Users,
  Calendar,
  ChevronRight,
  ArrowRight,
  Sparkles,
  Map as MapIcon,
  Music,
  Search
} from 'lucide-vue-next'

const authStore = useAuthStore()
const artistsStore = useArtistsStore()

const upcomingCount = computed(() => {
  return artistsStore.followedArtists.reduce((sum: number, artist: any) => {
    return sum + (artist.upcoming_concerts_count || 0)
  }, 0)
})

async function handleSyncArtists() {
  try {
    await artistsStore.syncTopArtistsFromSpotify('medium_term', 20)
  } catch (err) {
    console.error('Failed to sync artists:', err)
  }
}

onMounted(async () => {
  await artistsStore.fetchFollowedArtists()

  // Fetch suggested artists if user is authenticated with Spotify
  if (authStore.user?.provider === 'spotify') {
    try {
      await artistsStore.fetchSuggestedArtists()
    } catch (err) {
      console.error('Failed to fetch suggested artists:', err)
    }
  }
})
</script>
