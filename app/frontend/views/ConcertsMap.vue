<template>
  <div class="h-screen flex flex-col">
    <!-- Header -->
    <div class="bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 border-b">
      <div class="container mx-auto px-4 py-4">
        <div class="flex flex-col lg:flex-row gap-4 items-start lg:items-center justify-between">
          <!-- Title -->
          <div>
            <h1 class="text-2xl font-bold">Concert Map</h1>
            <p class="text-sm text-muted-foreground">Discover live music near you</p>
          </div>

          <!-- Controls -->
          <div class="flex flex-col sm:flex-row gap-3 w-full lg:w-auto">
            <Button
              @click="getUserLocation"
              :disabled="loadingLocation"
              variant="outline"
              class="sm:w-auto"
            >
              <svg v-if="!loadingLocation" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mr-2"><circle cx="12" cy="12" r="3"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/></svg>
              <span v-else class="h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent mr-2"></span>
              {{ loadingLocation ? 'Locating...' : 'My Location' }}
            </Button>

            <div class="flex gap-2 flex-1 sm:flex-initial">
              <Input
                v-model="searchQuery"
                @keyup.enter="searchLocation"
                type="text"
                placeholder="Search city..."
                class="flex-1 sm:w-[200px]"
              />
              <Select v-model="searchRadius" @update:model-value="handleRadiusChange">
                <SelectTrigger class="w-[110px]">
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

            <Badge variant="secondary" class="justify-center py-2">
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
      <div v-else class="h-full flex items-center justify-center bg-muted/50">
        <Card class="max-w-md mx-4">
          <CardContent class="flex flex-col items-center justify-center py-12">
            <div class="text-6xl mb-4">🗺️</div>
            <h3 class="text-xl font-semibold mb-2">Find concerts near you</h3>
            <p class="text-muted-foreground text-center mb-6">
              Allow location access or search for a city to discover upcoming concerts
            </p>
            <div class="flex flex-col sm:flex-row gap-3">
              <Button @click="getUserLocation" :disabled="loadingLocation">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mr-2"><circle cx="12" cy="12" r="3"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/></svg>
                Use My Location
              </Button>
              <Button variant="outline" @click="setDefaultLocation">
                Browse Brittany
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

      <!-- Loading Overlay -->
      <div
        v-if="concertsStore.loading && mapCenter"
        class="absolute inset-0 bg-background/50 backdrop-blur-sm flex items-center justify-center"
      >
        <Card class="p-6">
          <div class="flex items-center gap-3">
            <div class="h-5 w-5 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
            <span>Loading concerts...</span>
          </div>
        </Card>
      </div>
    </div>

    <!-- Concert Details Dialog -->
    <Dialog :open="!!selectedConcert" @update:open="(open) => !open && (selectedConcert = null)">
      <DialogContent class="max-w-lg">
        <DialogHeader>
          <DialogTitle>{{ selectedConcert?.title }}</DialogTitle>
          <DialogDescription>
            {{ selectedConcert?.artist?.name }}
          </DialogDescription>
        </DialogHeader>
        <div v-if="selectedConcert" class="space-y-4">
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
              <p class="text-muted-foreground">Date</p>
              <p class="font-medium">{{ formatDate(selectedConcert.starts_at) }}</p>
            </div>
            <div>
              <p class="text-muted-foreground">Time</p>
              <p class="font-medium">{{ formatTime(selectedConcert.starts_at) }}</p>
            </div>
            <div>
              <p class="text-muted-foreground">Venue</p>
              <p class="font-medium">{{ selectedConcert.venue_name }}</p>
            </div>
            <div>
              <p class="text-muted-foreground">Location</p>
              <p class="font-medium">{{ selectedConcert.city }}, {{ selectedConcert.country }}</p>
            </div>
          </div>
          <div v-if="selectedConcert.price" class="flex items-center gap-2">
            <Badge variant="secondary">{{ Number(selectedConcert.price).toFixed(2) }} EUR</Badge>
          </div>
          <div class="flex gap-2 pt-2">
            <Button v-if="selectedConcert.ticket_url" as-child class="flex-1">
              <a :href="selectedConcert.ticket_url" target="_blank">Get Tickets</a>
            </Button>
            <Button variant="outline" @click="centerOnConcert(selectedConcert)">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mr-2"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>
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
