<template>
  <div class="h-screen flex flex-col">
    <!-- Header with Glassmorphism -->
    <div class="glass border-b border-border/50 z-10">
      <div class="container mx-auto px-4 lg:px-8 py-4">
        <div class="flex flex-col lg:flex-row gap-4 items-start lg:items-center justify-between">
          <!-- Title -->
          <div class="flex items-center gap-3" v-motion-fade-up>
            <div class="p-2.5 rounded-xl bg-purple-500/10">
              <MapIcon class="w-6 h-6 text-purple-500" />
            </div>
            <div>
              <h1 class="text-xl font-bold">Concert Map</h1>
              <p class="text-sm text-muted-foreground">Discover live music near you</p>
            </div>
          </div>

          <!-- Controls -->
          <div
            class="flex flex-col sm:flex-row gap-3 w-full lg:w-auto"
            v-motion
            :initial="{ opacity: 0, y: -10 }"
            :enter="{ opacity: 1, y: 0, transition: { delay: 100 } }"
          >
            <Button
              @click="getUserLocation"
              :disabled="loadingLocation"
              variant="outline"
              class="sm:w-auto bg-background/50 hover:bg-accent group"
            >
              <Crosshair v-if="!loadingLocation" class="w-4 h-4 mr-2 group-hover:text-primary transition-colors" />
              <Loader2 v-else class="w-4 h-4 mr-2 animate-spin" />
              {{ loadingLocation ? 'Locating...' : 'My Location' }}
            </Button>

            <div class="flex gap-2 flex-1 sm:flex-initial">
              <div class="relative flex-1 sm:w-[200px] group">
                <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                <Input
                  v-model="searchQuery"
                  @keyup.enter="searchLocation"
                  type="text"
                  placeholder="Search city..."
                  class="pl-10 bg-background/50 border-border/50"
                />
              </div>
              <Select v-model="searchRadius" @update:model-value="handleRadiusChange">
                <SelectTrigger class="w-[110px] bg-background/50 border-border/50">
                  <Ruler class="w-4 h-4 mr-2 text-muted-foreground" />
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="25">25 km</SelectItem>
                  <SelectItem value="50">50 km</SelectItem>
                  <SelectItem value="100">100 km</SelectItem>
                  <SelectItem value="200">200 km</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <Badge variant="secondary" class="justify-center py-2 px-4 bg-primary/10 text-primary border-primary/20">
              <Music class="w-3 h-3 mr-1.5" />
              {{ concertsStore.nearbyConcerts.length }} concerts
            </Badge>
          </div>
        </div>
      </div>
    </div>

    <!-- Map Container -->
    <div class="flex-1 relative">
      <MapView
        v-if="mapCenter"
        :center="mapCenter"
        :concerts="concertsStore.nearbyConcerts"
        :zoom="mapZoom"
        @concert-click="showConcertDetails"
      />

      <!-- No Location State -->
      <div v-else class="h-full flex items-center justify-center gradient-dark">
        <div class="absolute inset-0">
          <div class="absolute top-1/4 left-1/4 w-[400px] h-[400px] gradient-glow opacity-30" />
          <div class="absolute bottom-1/4 right-1/4 w-[300px] h-[300px] gradient-glow opacity-20" />
        </div>
        <Card class="relative max-w-md mx-4 bg-card/50 border-border/50 backdrop-blur-sm" v-motion-fade-up>
          <CardContent class="flex flex-col items-center justify-center py-12">
            <div class="p-5 rounded-2xl bg-purple-500/10 mb-6">
              <MapIcon class="w-14 h-14 text-purple-500" />
            </div>
            <h3 class="text-2xl font-bold mb-2">Find concerts near you</h3>
            <p class="text-muted-foreground text-center mb-8 max-w-sm">
              Allow location access or search for a city to discover upcoming concerts
            </p>
            <div class="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
              <Button @click="getUserLocation" :disabled="loadingLocation" class="font-medium">
                <Crosshair class="w-4 h-4 mr-2" />
                Use My Location
              </Button>
              <Button variant="outline" @click="setDefaultLocation" class="font-medium bg-background/50">
                <Navigation class="w-4 h-4 mr-2" />
                Browse Brittany
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

      <!-- Loading Overlay -->
      <div
        v-if="concertsStore.loading && mapCenter"
        class="absolute inset-0 bg-background/60 backdrop-blur-sm flex items-center justify-center z-10"
      >
        <Card class="p-6 bg-card/80 border-border/50">
          <div class="flex items-center gap-3">
            <Loader2 class="w-5 h-5 text-primary animate-spin" />
            <span class="font-medium">Loading concerts...</span>
          </div>
        </Card>
      </div>
    </div>

    <!-- Concert Details Dialog -->
    <Dialog :open="!!selectedConcert" @update:open="(open) => !open && (selectedConcert = null)">
      <DialogContent class="max-w-lg bg-card/95 backdrop-blur-sm border-border/50">
        <DialogHeader>
          <DialogTitle class="text-xl">{{ selectedConcert?.title }}</DialogTitle>
          <DialogDescription class="flex items-center gap-2">
            <Music class="w-4 h-4" />
            {{ selectedConcert?.artist?.name }}
          </DialogDescription>
        </DialogHeader>
        <div v-if="selectedConcert" class="space-y-5">
          <div class="grid grid-cols-2 gap-4">
            <div class="p-4 rounded-lg bg-background/50">
              <p class="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                <Calendar class="w-3 h-3" />
                Date
              </p>
              <p class="font-semibold">{{ formatDate(selectedConcert.starts_at) }}</p>
            </div>
            <div class="p-4 rounded-lg bg-background/50">
              <p class="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                <Clock class="w-3 h-3" />
                Time
              </p>
              <p class="font-semibold">{{ formatTime(selectedConcert.starts_at) }}</p>
            </div>
            <div class="p-4 rounded-lg bg-background/50">
              <p class="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                <Building class="w-3 h-3" />
                Venue
              </p>
              <p class="font-semibold">{{ selectedConcert.venue_name }}</p>
            </div>
            <div class="p-4 rounded-lg bg-background/50">
              <p class="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                <MapPin class="w-3 h-3" />
                Location
              </p>
              <p class="font-semibold">{{ selectedConcert.city }}, {{ selectedConcert.country }}</p>
            </div>
          </div>

          <div v-if="selectedConcert.price" class="flex items-center gap-2">
            <Badge variant="secondary" class="bg-green-500/10 text-green-400 border-green-500/20 px-4 py-2">
              <Ticket class="w-4 h-4 mr-2" />
              {{ Number(selectedConcert.price).toFixed(2) }} EUR
            </Badge>
          </div>

          <div class="flex gap-3 pt-2">
            <Button v-if="selectedConcert.ticket_url" as-child class="flex-1 font-medium">
              <a :href="selectedConcert.ticket_url" target="_blank" class="flex items-center justify-center gap-2">
                <Ticket class="w-4 h-4" />
                Get Tickets
              </a>
            </Button>
            <Button variant="outline" @click="centerOnConcert(selectedConcert)" class="bg-background/50">
              <MapPin class="w-4 h-4 mr-2" />
              Center Map
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useConcertsStore } from '../stores/concerts'
import { getCurrentLocation, searchLocation as geocodeSearch } from '../services/geocoding'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle
} from '@/components/ui/dialog'
import MapView from '../components/map/MapView.vue'
import {
  Map as MapIcon,
  Crosshair,
  Search,
  Ruler,
  Music,
  Navigation,
  Loader2,
  Calendar,
  Clock,
  Building,
  MapPin,
  Ticket
} from 'lucide-vue-next'

const concertsStore = useConcertsStore()

const mapCenter = ref<[number, number] | null>(null)
const mapZoom = ref(10)
const searchQuery = ref('')
const searchRadius = ref('50')
const loadingLocation = ref(false)
const selectedConcert = ref<any>(null)

function formatDate(dateString: string): string {
  return new Date(dateString).toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

function formatTime(dateString: string): string {
  return new Date(dateString).toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

async function getUserLocation() {
  loadingLocation.value = true
  try {
    const location = await getCurrentLocation()
    mapCenter.value = [location.lat, location.lng]
    mapZoom.value = 10
    await updateConcerts(location.lat, location.lng)
  } catch (error) {
    console.error('Failed to get location:', error)
  } finally {
    loadingLocation.value = false
  }
}

function setDefaultLocation() {
  // Default to Brittany, France
  mapCenter.value = [48.1173, -1.6778]
  mapZoom.value = 8
  updateConcerts(48.1173, -1.6778)
}

async function searchLocation() {
  if (!searchQuery.value.trim()) return

  try {
    const results = await geocodeSearch(searchQuery.value)
    if (results.length > 0) {
      const location = results[0]
      mapCenter.value = [Number.parseFloat(location.lat), Number.parseFloat(location.lon)]
      mapZoom.value = 12
      await updateConcerts(Number.parseFloat(location.lat), Number.parseFloat(location.lon))
    }
  } catch (error) {
    console.error('Search error:', error)
  }
}

function handleRadiusChange() {
  if (mapCenter.value) {
    updateConcerts(mapCenter.value[0], mapCenter.value[1])
  }
}

async function updateConcerts(lat: number, lng: number) {
  try {
    await concertsStore.fetchNearbyConcerts(lat, lng, Number.parseInt(searchRadius.value))
  } catch (error) {
    console.error('Failed to fetch concerts:', error)
  }
}

function showConcertDetails(concert: any) {
  selectedConcert.value = concert
}

function centerOnConcert(concert: any) {
  mapCenter.value = [concert.latitude, concert.longitude]
  mapZoom.value = 14
  selectedConcert.value = null
}

onMounted(() => {
  getUserLocation()
})
</script>
