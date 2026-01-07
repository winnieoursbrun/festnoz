<template>
  <div class="min-h-screen">
    <!-- Background -->
    <div class="fixed inset-0 gradient-dark -z-10">
      <div class="absolute top-0 right-1/4 w-[600px] h-[600px] gradient-glow opacity-30" />
      <div class="absolute bottom-1/4 left-0 w-[500px] h-[500px] gradient-glow opacity-20" />
    </div>

    <div class="container mx-auto px-4 lg:px-8 py-8 lg:py-12">
      <!-- Header -->
      <div class="mb-10" v-motion-fade-up>
        <div class="flex items-center gap-3 mb-2">
          <div class="p-3 rounded-2xl bg-primary/10">
            <Users class="w-8 h-8 text-primary" />
          </div>
          <h1 class="text-3xl lg:text-4xl font-bold tracking-tight">Discover Artists</h1>
        </div>
        <p class="text-muted-foreground">
          Explore Breton musicians and build your collection
        </p>
      </div>

      <!-- Suggested Artists Banner -->
      <Card
        v-if="authStore.user?.provider === 'spotify'"
        class="mb-6 bg-gradient-to-r from-purple-500/10 to-pink-500/10 border-purple-500/20"
        v-motion
        :initial="{ opacity: 0, y: 20 }"
        :enter="{ opacity: 1, y: 0, transition: { delay: 50 } }"
      >
        <CardContent class="py-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="p-2 rounded-lg bg-purple-500/20">
                <Sparkles class="w-5 h-5 text-purple-400" />
              </div>
              <div>
                <p class="font-semibold text-foreground">Get personalized recommendations</p>
                <p class="text-sm text-muted-foreground">Discover artists based on your Spotify listening history</p>
              </div>
            </div>
            <Button @click="$router.push('/suggested-artists')" variant="default" class="shrink-0">
              View Suggestions
            </Button>
          </div>
        </CardContent>
      </Card>

      <!-- Search & Filters -->
      <Card
        class="mb-8 bg-card/50 border-border/50 backdrop-blur-sm"
        v-motion
        :initial="{ opacity: 0, y: 20 }"
        :enter="{ opacity: 1, y: 0, transition: { delay: 100 } }"
      >
        <CardContent class="pt-6">
          <div class="flex flex-col lg:flex-row gap-4">
            <!-- Search Input -->
            <div class="relative flex-1 group">
              <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground group-focus-within:text-primary transition-colors" />
              <Input
                v-model="searchQuery"
                @input="debouncedSearch"
                type="text"
                placeholder="Search by name..."
                class="pl-12 h-12 bg-background/50 border-border/50 focus:border-primary transition-all"
              />
            </div>

            <!-- Genre Filter -->
            <Select v-model="selectedGenre" @update:model-value="handleFilter">
              <SelectTrigger class="w-full lg:w-[240px] h-12 bg-background/50 border-border/50">
                <Filter class="w-4 h-4 mr-2 text-muted-foreground" />
                <SelectValue placeholder="All Genres" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Genres</SelectItem>
                <SelectItem value="Breton Folk">Breton Folk</SelectItem>
                <SelectItem value="Traditional">Traditional</SelectItem>
                <SelectItem value="Breton Traditional">Breton Traditional</SelectItem>
                <SelectItem value="World Music">World Music</SelectItem>
                <SelectItem value="Celtic Rock">Celtic Rock</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <!-- Active Filters -->
          <div v-if="searchQuery || (selectedGenre && selectedGenre !== 'all')" class="flex flex-wrap gap-2 mt-5 pt-5 border-t border-border/50">
            <div class="text-sm text-muted-foreground font-medium mr-2 flex items-center gap-2">
              <SlidersHorizontal class="w-4 h-4" />
              Active filters:
            </div>
            <Badge
              v-if="searchQuery"
              variant="secondary"
              class="gap-2 px-3 py-1.5 bg-primary/10 text-primary border-primary/20 hover:bg-primary/20 transition-colors"
            >
              <Search class="w-3 h-3" />
              {{ searchQuery }}
              <button @click="clearSearch" class="hover:text-destructive transition-colors">
                <X class="w-3.5 h-3.5" />
              </button>
            </Badge>
            <Badge
              v-if="selectedGenre && selectedGenre !== 'all'"
              variant="secondary"
              class="gap-2 px-3 py-1.5 bg-purple-500/10 text-purple-400 border-purple-500/20 hover:bg-purple-500/20 transition-colors"
            >
              <Music class="w-3 h-3" />
              {{ selectedGenre }}
              <button @click="clearGenre" class="hover:text-destructive transition-colors">
                <X class="w-3.5 h-3.5" />
              </button>
            </Badge>
            <Button variant="ghost" size="sm" @click="clearFilters" class="h-7 text-xs font-medium text-muted-foreground hover:text-foreground">
              Clear all
            </Button>
          </div>
        </CardContent>
      </Card>

      <!-- Results Count -->
      <div
        class="flex items-center justify-between mb-6"
        v-motion
        :initial="{ opacity: 0, y: 20 }"
        :enter="{ opacity: 1, y: 0, transition: { delay: 200 } }"
      >
        <p class="text-muted-foreground flex items-center gap-2">
          <span class="text-2xl font-bold text-foreground">{{ artistsStore.artists.length }}</span>
          artists found
        </p>
      </div>

      <!-- Loading State with Skeletons -->
      <div v-if="artistsStore.loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 lg:gap-6">
        <Card v-for="i in 8" :key="i" class="bg-card/50 border-border/50">
          <div class="h-40 skeleton-shimmer rounded-t-lg" />
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
      <Card
        v-else-if="artistsStore.artists.length === 0"
        class="border-dashed border-border/50 bg-card/30"
        v-motion
        :initial="{ opacity: 0, y: 20 }"
        :enter="{ opacity: 1, y: 0, transition: { delay: 300 } }"
      >
        <CardContent class="flex flex-col items-center justify-center py-20">
          <div class="p-4 rounded-2xl bg-muted/50 mb-6">
            <SearchX class="w-12 h-12 text-muted-foreground" />
          </div>
          <h3 class="text-xl font-bold mb-2">No artists found</h3>
          <p class="text-muted-foreground text-center max-w-md mb-6">
            {{ searchQuery || (selectedGenre && selectedGenre !== 'all') ? 'Try adjusting your search or filters' : 'No artists available yet' }}
          </p>
          <Button v-if="searchQuery || (selectedGenre && selectedGenre !== 'all')" variant="outline" @click="clearFilters" class="font-medium">
            <X class="w-4 h-4 mr-2" />
            Clear filters
          </Button>
        </CardContent>
      </Card>

      <!-- Artists Grid -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 lg:gap-6">
        <div
          v-for="(artist, index) in artistsStore.artists"
          :key="artist.id"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 100 + index * 30 } }"
        >
          <ArtistCard :artist="artist" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useArtistsStore } from '../stores/artists'
import { useAuthStore } from '../stores/auth'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'
import ArtistCard from '../components/artists/ArtistCard.vue'
import {
  Users,
  Search,
  SearchX,
  Filter,
  SlidersHorizontal,
  X,
  Music,
  Sparkles
} from 'lucide-vue-next'

const artistsStore = useArtistsStore()
const authStore = useAuthStore()

const searchQuery = ref('')
const selectedGenre = ref('all')
let searchTimeout: ReturnType<typeof setTimeout> | null = null

function debouncedSearch() {
  if (searchTimeout) clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    fetchArtists()
  }, 300)
}

function handleFilter() {
  fetchArtists()
}

function clearSearch() {
  searchQuery.value = ''
  fetchArtists()
}

function clearGenre() {
  selectedGenre.value = 'all'
  fetchArtists()
}

function clearFilters() {
  searchQuery.value = ''
  selectedGenre.value = 'all'
  fetchArtists()
}

async function fetchArtists() {
  const filters: Record<string, string> = {}
  if (searchQuery.value) filters.search = searchQuery.value
  if (selectedGenre.value && selectedGenre.value !== 'all') filters.genre = selectedGenre.value
  await artistsStore.fetchArtists(filters)
}

onMounted(async () => {
  await fetchArtists()
})
</script>
