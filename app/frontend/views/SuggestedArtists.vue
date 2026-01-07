<template>
  <div class="min-h-screen">
    <!-- Background -->
    <div class="fixed inset-0 gradient-dark -z-10">
      <div class="absolute top-0 left-1/4 w-[600px] h-[600px] gradient-glow opacity-30" />
      <div class="absolute bottom-1/4 right-0 w-[500px] h-[500px] gradient-glow opacity-20" />
    </div>

    <div class="container mx-auto px-4 lg:px-8 py-8 lg:py-12">
      <!-- Header -->
      <div class="mb-10" v-motion-fade-up>
        <div class="flex items-center gap-3 mb-2">
          <div class="p-3 rounded-2xl bg-purple-500/10">
            <Sparkles class="w-8 h-8 text-purple-400" />
          </div>
          <h1 class="text-3xl lg:text-4xl font-bold tracking-tight">Suggested Artists</h1>
        </div>
        <p class="text-muted-foreground">
          Discover artists based on your Spotify listening history
        </p>
      </div>

      <!-- Sync Controls -->
      <Card
        class="mb-8 bg-card/50 border-border/50 backdrop-blur-sm"
        v-motion
        :initial="{ opacity: 0, y: 20 }"
        :enter="{ opacity: 1, y: 0, transition: { delay: 100 } }"
      >
        <CardContent class="pt-6">
          <div class="flex flex-col md:flex-row gap-4 items-center">
            <div class="flex-1">
              <p class="font-medium mb-1">Sync your top artists</p>
              <p class="text-sm text-muted-foreground">
                Import artists from your Spotify listening history
              </p>
            </div>
            <div class="flex gap-3 items-center">
              <Select v-model="timeRange" :disabled="syncing">
                <SelectTrigger class="w-[180px] h-10 bg-background/50 border-border/50">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="short_term">Last 4 weeks</SelectItem>
                  <SelectItem value="medium_term">Last 6 months</SelectItem>
                  <SelectItem value="long_term">All time</SelectItem>
                </SelectContent>
              </Select>
              <Button
                @click="handleSync"
                :disabled="syncing || !isSpotifyAuthenticated"
                class="flex items-center gap-2"
              >
                <svg
                  v-if="syncing"
                  class="animate-spin h-4 w-4"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                >
                  <circle
                    class="opacity-25"
                    cx="12"
                    cy="12"
                    r="10"
                    stroke="currentColor"
                    stroke-width="4"
                  ></circle>
                  <path
                    class="opacity-75"
                    fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                  ></path>
                </svg>
                <Sparkles v-else class="w-4 h-4" />
                <span v-if="syncing">Syncing...</span>
                <span v-else>Sync Now</span>
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      <!-- Error Message -->
      <Alert v-if="error" variant="destructive" class="mb-6">
        <AlertDescription>{{ error }}</AlertDescription>
      </Alert>

      <!-- Not authenticated message -->
      <Alert v-if="!isSpotifyAuthenticated" class="mb-6 border-yellow-500/50 bg-yellow-500/10">
        <AlertDescription class="text-foreground">
          You need to connect your Spotify account to sync suggested artists.
          <a href="/api/auth/spotify" class="underline font-medium text-primary hover:text-primary/80">
            Connect Spotify
          </a>
        </AlertDescription>
      </Alert>

      <!-- Loading State -->
      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        <Card v-for="i in 8" :key="i" class="bg-card/50 border-border/50">
          <div class="h-40 skeleton-shimmer rounded-t-lg" />
          <CardContent class="pt-4 space-y-3">
            <Skeleton class="h-5 w-3/4" />
            <Skeleton class="h-4 w-1/2" />
          </CardContent>
        </Card>
      </div>

      <!-- Empty State -->
      <Card
        v-else-if="suggestedArtists.length === 0"
        class="border-dashed border-border/50 bg-card/30"
        v-motion
        :initial="{ opacity: 0, y: 20 }"
        :enter="{ opacity: 1, y: 0, transition: { delay: 200 } }"
      >
        <CardContent class="flex flex-col items-center justify-center py-20">
          <div class="p-4 rounded-2xl bg-purple-500/10 mb-6">
            <Sparkles class="w-12 h-12 text-purple-400" />
          </div>
          <h3 class="text-xl font-bold mb-2">No suggested artists yet</h3>
          <p class="text-muted-foreground text-center max-w-md">
            Click "Sync from Spotify" to get artist recommendations based on your listening history
          </p>
        </CardContent>
      </Card>

      <!-- Suggested Artists Grid -->
      <div
        v-else
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
        v-motion
        :initial="{ opacity: 0, y: 20 }"
        :enter="{ opacity: 1, y: 0, transition: { delay: 300 } }"
      >
        <div
          v-for="(suggestion, index) in suggestedArtists"
          :key="suggestion.id"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 100 + index * 30 } }"
          class="relative"
        >
          <!-- Rank Badge -->
          <div class="absolute top-2 left-2 z-10 flex items-center gap-1 px-2 py-1 rounded-full bg-purple-500/90 backdrop-blur-sm text-white text-xs font-semibold">
            <Sparkles class="w-3 h-3" />
            #{{ suggestion.rank + 1 }}
          </div>

          <!-- Remove Button -->
          <button
            @click="handleRemove(suggestion.id)"
            class="absolute top-2 right-2 z-10 p-1.5 rounded-full bg-background/90 backdrop-blur-sm hover:bg-destructive hover:text-destructive-foreground transition-colors"
            title="Remove suggestion"
          >
            <X class="w-4 h-4" />
          </button>

          <ArtistCard :artist="suggestion.artist" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useArtistsStore } from '../stores/artists'
import { useAuthStore } from '../stores/auth'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'
import ArtistCard from '../components/artists/ArtistCard.vue'
import { X, Sparkles } from 'lucide-vue-next'

const artistsStore = useArtistsStore()
const authStore = useAuthStore()

const timeRange = ref('medium_term')

const loading = computed(() => artistsStore.loading)
const syncing = computed(() => artistsStore.syncing)
const error = computed(() => artistsStore.error)
const suggestedArtists = computed(() => artistsStore.suggestedArtists)
const isSpotifyAuthenticated = computed(() => authStore.user?.provider === 'spotify')

onMounted(async () => {
  try {
    await artistsStore.fetchSuggestedArtists()
    await artistsStore.fetchFollowedArtists()
  } catch (err) {
    console.error('Failed to load suggested artists:', err)
  }
})

async function handleSync() {
  try {
    await artistsStore.syncTopArtistsFromSpotify(timeRange.value, 20)
  } catch (err) {
    console.error('Failed to sync artists:', err)
  }
}

async function handleRemove(suggestionId) {
  try {
    await artistsStore.removeSuggestedArtist(suggestionId)
  } catch (err) {
    console.error('Failed to remove suggestion:', err)
  }
}
</script>
