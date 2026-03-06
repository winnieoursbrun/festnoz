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
            <div class="flex flex-col gap-1">
              <Button
                @click="getUserLocation"
                :disabled="loadingLocation"
                variant="outline"
                class="h-10 sm:w-auto bg-background/50 hover:bg-accent group"
              >
                <Crosshair v-if="!loadingLocation" class="w-4 h-4 mr-2 group-hover:text-primary transition-colors" />
                <Loader2 v-else class="w-4 h-4 mr-2 animate-spin" />
                {{ loadingLocation ? 'Locating...' : userLocation ? 'My Location' : 'Use My Location' }}
              </Button>
              <p v-if="locationError" class="text-xs text-destructive px-1">{{ locationError }}</p>
            </div>

            <div class="flex gap-2 flex-1 sm:flex-initial">
              <div class="relative w-[160px] group">
                <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                <Input
                  v-model="searchQuery"
                  @keyup.enter="searchLocation"
                  type="text"
                  placeholder="Search city..."
                  class="h-10 pl-10 bg-background/50 border-border/50"
                />
              </div>
            </div>

            <Select v-model="selectedArtistId">
              <SelectTrigger class="h-10 w-[160px] bg-background/50 border-border/50">
                <Users class="w-4 h-4 mr-2 text-muted-foreground" />
                <SelectValue placeholder="All Followed" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Followed</SelectItem>
                <SelectItem
                  v-for="artist in uniqueArtists"
                  :key="artist.id"
                  :value="artist.id.toString()"
                >
                  {{ artist.name }}
                </SelectItem>
              </SelectContent>
            </Select>

            <Select v-model="selectedTimePeriod">
              <SelectTrigger class="h-10 w-[160px] bg-background/50 border-border/50">
                <Calendar class="w-4 h-4 mr-2 text-muted-foreground" />
                <SelectValue placeholder="Time period" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="this_week">This week</SelectItem>
                <SelectItem value="this_month">This month</SelectItem>
                <SelectItem value="next_3_months">Next 3 months</SelectItem>
                <SelectItem value="next_6_months">Next 6 months</SelectItem>
                <SelectItem value="all">All upcoming</SelectItem>
              </SelectContent>
            </Select>

            <Badge variant="secondary" class="h-10 justify-center py-2 px-4 bg-primary/10 text-primary border-primary/20">
              <Music class="w-3 h-3 mr-1.5" />
              {{ filteredConcerts.length }} concerts
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
        :concerts="filteredConcerts"
        :zoom="mapZoom"
        :selected-artist-id="selectedArtistId !== 'all' ? Number.parseInt(selectedArtistId) : null"
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
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useConcertsStore } from '../stores/concerts'
import { useArtistsStore } from '../stores/artists'
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
  Music,
  Navigation,
  Loader2,
  Calendar,
  Clock,
  Building,
  MapPin,
  Ticket,
  Users
} from 'lucide-vue-next'
import { formatDateLong, formatTime as formatTimeUtil } from '@/lib/utils'

const concertsStore = useConcertsStore()
const artistsStore = useArtistsStore()
const route = useRoute()
const router = useRouter()

const mapCenter = ref<[number, number] | null>(null)
const mapZoom = ref(8)
const searchQuery = ref('')
const loadingLocation = ref(false)
const locationError = ref<string | null>(null)
const userLocation = ref<[number, number] | null>(null)
const selectedConcert = ref<any>(null)
const selectedArtistId = ref<string>('all')
const selectedTimePeriod = ref<string>('this_month')
const validTimePeriods = ['this_week', 'this_month', 'next_3_months', 'next_6_months', 'all']

function getQueryValue(value: unknown): string {
  return Array.isArray(value) ? String(value[0] ?? '') : String(value ?? '')
}

function hydrateFiltersFromUrl() {
  const search = getQueryValue(route.query.search).trim()
  const artist = getQueryValue(route.query.artist).trim()
  const period = getQueryValue(route.query.period).trim()

  searchQuery.value = search
  selectedArtistId.value = artist && /^\d+$/.test(artist) ? artist : 'all'
  selectedTimePeriod.value = validTimePeriods.includes(period) ? period : 'this_month'
}

function syncFiltersToUrl() {
  const query: Record<string, string> = {}

  if (searchQuery.value.trim()) query.search = searchQuery.value.trim()
  if (selectedArtistId.value !== 'all') query.artist = selectedArtistId.value
  if (selectedTimePeriod.value !== 'this_month') query.period = selectedTimePeriod.value

  router.replace({ query })
}

// Get unique followed artists that have concerts
const uniqueArtists = computed(() => {
  const followedArtistIds = new Set(artistsStore.followedArtists.map(artist => artist.id))
  const artistsMap = new Map()

  concertsStore.concerts.forEach(concert => {
    if (concert.artist && followedArtistIds.has(concert.artist.id) && !artistsMap.has(concert.artist.id)) {
      artistsMap.set(concert.artist.id, {
        id: concert.artist.id,
        name: concert.artist.name,
        image_url: concert.artist.primary_image_url || concert.artist.image_url
      })
    }
  })
  return Array.from(artistsMap.values()).sort((a, b) => a.name.localeCompare(b.name))
})

// Filter concerts by followed artists, selected artist, and date range
const filteredConcerts = computed(() => {
  let concerts = concertsStore.concerts

  // Filter to only show concerts from followed artists
  const followedArtistIds = new Set(artistsStore.followedArtists.map(artist => artist.id))
  if (followedArtistIds.size > 0) {
    concerts = concerts.filter(
      concert => concert.artist?.id && followedArtistIds.has(concert.artist.id)
    )
  }

  // Filter by selected artist
  if (selectedArtistId.value !== 'all') {
    concerts = concerts.filter(
      concert => concert.artist?.id === Number.parseInt(selectedArtistId.value)
    )
  }

  // Filter by time period
  const now = new Date()
  now.setHours(0, 0, 0, 0)
  const periodEnd = new Date(now)
  if (selectedTimePeriod.value === 'this_week') {
    periodEnd.setDate(periodEnd.getDate() + 7)
  } else if (selectedTimePeriod.value === 'this_month') {
    periodEnd.setDate(periodEnd.getDate() + 30)
  } else if (selectedTimePeriod.value === 'next_3_months') {
    periodEnd.setMonth(periodEnd.getMonth() + 3)
  } else if (selectedTimePeriod.value === 'next_6_months') {
    periodEnd.setMonth(periodEnd.getMonth() + 6)
  }
  concerts = concerts.filter(concert => {
    const date = new Date(concert.starts_at)
    if (date < now) return false
    if (selectedTimePeriod.value !== 'all' && date > periodEnd) return false
    return true
  })

  return concerts
})

function formatDate(dateString: string): string {
  return formatDateLong(dateString)
}

function formatTime(dateString: string): string {
  return formatTimeUtil(dateString)
}

async function getUserLocation() {
  locationError.value = null

  // If we already have a confirmed GPS fix, just re-center — no new prompt needed
  if (userLocation.value) {
    mapCenter.value = userLocation.value
    mapZoom.value = 8
    return
  }

  // Check permission state before requesting (Permissions API)
  if (navigator.permissions) {
    try {
      const status = await navigator.permissions.query({ name: 'geolocation' })
      if (status.state === 'denied') {
        locationError.value = 'Location blocked — enable it in your browser settings.'
        return
      }
    } catch {
      // permissions API not fully supported, fall through to getCurrentPosition
    }
  }

  loadingLocation.value = true
  try {
    const location = await getCurrentLocation()
    userLocation.value = [location.lat, location.lng]
    mapCenter.value = [location.lat, location.lng]
    mapZoom.value = 8
    await loadAllConcerts()
  } catch (error: any) {
    console.error('Failed to get location:', error)
    if (error?.code === 1 /* PERMISSION_DENIED */) {
      locationError.value = 'Location blocked — enable it in your browser settings.'
    } else if (error?.code === 2 /* POSITION_UNAVAILABLE */) {
      locationError.value = 'Location temporarily unavailable. Try again in a moment.'
    } else {
      locationError.value = 'Could not get your location. Try again.'
    }
  } finally {
    loadingLocation.value = false
  }
}

function setDefaultLocation() {
  // Default to Brittany, France
  mapCenter.value = [48.1173, -1.6778]
  mapZoom.value = 8
  loadAllConcerts()
}

async function searchLocation() {
  if (!searchQuery.value.trim()) return

  try {
    const results = await geocodeSearch(searchQuery.value)
    if (results.length > 0) {
      const location = results[0]
      mapCenter.value = [Number.parseFloat(location.lat), Number.parseFloat(location.lon)]
      mapZoom.value = 8
    }
  } catch (error) {
    console.error('Search error:', error)
  }
}

watch([searchQuery, selectedArtistId, selectedTimePeriod], () => {
  syncFiltersToUrl()
})

async function loadAllConcerts() {
  try {
    await concertsStore.fetchConcerts()
  } catch (error) {
    console.error('Failed to fetch concerts:', error)
  }
}

function showConcertDetails(concert: any) {
  if (concert?.artist?.id) {
    router.push({
      name: 'ArtistDetail',
      params: { id: concert.artist.id },
      query: {
        concertDate: concert.starts_at,
        concertId: String(concert.id)
      }
    })
    return
  }

  selectedConcert.value = concert
}

function centerOnConcert(concert: any) {
  mapCenter.value = [concert.latitude, concert.longitude]
  mapZoom.value = 14
  selectedConcert.value = null
}

onMounted(async () => {
  hydrateFiltersFromUrl()

  // Fetch followed artists and all concerts
  await Promise.all([
    artistsStore.fetchFollowedArtists(),
    concertsStore.fetchConcerts()
  ])

  // Auto-request location only when the browser hasn't been asked yet (permission = 'prompt')
  // Avoids re-triggering a dialog on every navigation if the user previously denied
  if (navigator.permissions) {
    try {
      const status = await navigator.permissions.query({ name: 'geolocation' })
      if (status.state === 'granted') {
        // Permission already granted – fetch silently
        getUserLocation()
      } else if (status.state === 'prompt') {
        // First visit – auto-prompt
        getUserLocation()
      }
      // state === 'denied' → leave map empty, let user click the button for the error message
    } catch {
      // Permissions API unsupported – fall back to always trying
      getUserLocation()
    }
  } else {
    getUserLocation()
  }

  // Show Brittany by default if no location after a short delay
  setTimeout(() => {
    if (!mapCenter.value) {
      setDefaultLocation()
    }
  }, 3000)
})
</script>
