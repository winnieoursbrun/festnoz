<template>
  <div class="min-h-screen relative overflow-hidden">
    <!-- Animated Background -->
    <div class="absolute inset-0 bg-gradient-to-br from-background via-primary/5 to-purple-500/10">
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_80%_20%,_var(--tw-gradient-stops))] from-primary/10 via-transparent to-transparent"></div>
    </div>

    <div class="relative container mx-auto px-4 py-10">
      <!-- Header -->
      <div class="mb-10 animate-in fade-in slide-in-from-bottom-4 duration-1000">
        <h1 class="text-5xl font-black tracking-tight mb-3">Discover Artists</h1>
        <p class="text-xl text-muted-foreground font-medium">
          Explore Breton musicians and build your collection
        </p>
      </div>

      <!-- Search & Filters -->
      <Card class="mb-10 border-2 shadow-lg animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-100">
        <CardContent class="pt-6">
          <div class="flex flex-col lg:flex-row gap-4">
            <!-- Search Input -->
            <div class="relative flex-1 group">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground group-focus-within:text-primary transition-colors"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="2"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              <Input
                v-model="searchQuery"
                @input="debouncedSearch"
                type="text"
                placeholder="Search by name..."
                class="pl-12 h-14 text-base border-2 focus:border-primary transition-all"
              />
            </div>

            <!-- Genre Filter -->
            <Select v-model="selectedGenre" @update:model-value="handleFilter">
              <SelectTrigger class="w-full lg:w-[240px] h-14 border-2 focus:border-primary transition-all">
                <SelectValue placeholder="All Genres" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="">All Genres</SelectItem>
                <SelectItem value="Breton Folk">Breton Folk</SelectItem>
                <SelectItem value="Traditional">Traditional</SelectItem>
                <SelectItem value="Breton Traditional">Breton Traditional</SelectItem>
                <SelectItem value="World Music">World Music</SelectItem>
                <SelectItem value="Celtic Rock">Celtic Rock</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <!-- Active Filters -->
          <div v-if="searchQuery || selectedGenre" class="flex flex-wrap gap-2 mt-5 pt-5 border-t">
            <div class="text-sm text-muted-foreground font-medium mr-2">Active filters:</div>
            <Badge v-if="searchQuery" variant="secondary" class="gap-2 px-3 py-1.5 text-sm">
              Search: {{ searchQuery }}
              <button @click="clearSearch" class="hover:text-destructive transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M18 6 6 18"/><path d="m6 6 12 12"/>
                </svg>
              </button>
            </Badge>
            <Badge v-if="selectedGenre" variant="secondary" class="gap-2 px-3 py-1.5 text-sm">
              Genre: {{ selectedGenre }}
              <button @click="clearGenre" class="hover:text-destructive transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M18 6 6 18"/><path d="m6 6 12 12"/>
                </svg>
              </button>
            </Badge>
            <Button variant="ghost" size="sm" @click="clearFilters" class="h-7 text-xs font-medium">
              Clear all
            </Button>
          </div>
        </CardContent>
      </Card>

      <!-- Results Count -->
      <div class="flex items-center justify-between mb-8 animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-200">
        <p class="text-lg font-semibold text-muted-foreground">
          <span class="text-2xl font-black text-foreground">{{ artistsStore.artists.length }}</span> artists found
        </p>
      </div>

      <!-- Loading State -->
      <div v-if="artistsStore.loading" class="flex items-center justify-center py-32">
        <div class="text-center space-y-4">
          <div class="h-16 w-16 animate-spin rounded-full border-4 border-primary border-t-transparent mx-auto"></div>
          <p class="text-muted-foreground font-medium text-lg">Loading artists...</p>
        </div>
      </div>

      <!-- Empty State -->
      <Card v-else-if="artistsStore.artists.length === 0" class="border-2 border-dashed hover:border-primary/50 transition-all animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-300">
        <CardContent class="flex flex-col items-center justify-center py-24">
          <div class="text-8xl mb-6 animate-bounce">🔍</div>
          <h3 class="text-2xl font-bold mb-3">No artists found</h3>
          <p class="text-muted-foreground text-center max-w-md text-lg leading-relaxed mb-6">
            {{ searchQuery || selectedGenre ? 'Try adjusting your search or filters' : 'No artists available yet' }}
          </p>
          <Button v-if="searchQuery || selectedGenre" variant="outline" size="lg" class="h-12 px-8 font-semibold" @click="clearFilters">
            Clear filters
          </Button>
        </CardContent>
      </Card>

      <!-- Artists Grid -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-300">
        <ArtistCard
          v-for="artist in artistsStore.artists"
          :key="artist.id"
          :artist="artist"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useArtistsStore } from '../stores/artists'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'
import ArtistCard from '../components/artists/ArtistCard.vue'

const artistsStore = useArtistsStore()

const searchQuery = ref('')
const selectedGenre = ref('')
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
  selectedGenre.value = ''
  fetchArtists()
}

function clearFilters() {
  searchQuery.value = ''
  selectedGenre.value = ''
  fetchArtists()
}

async function fetchArtists() {
  const filters: Record<string, string> = {}
  if (searchQuery.value) filters.search = searchQuery.value
  if (selectedGenre.value) filters.genre = selectedGenre.value
  await artistsStore.fetchArtists(filters)
}

onMounted(async () => {
  await fetchArtists()
})
</script>
