<template>
  <div class="min-h-screen">
    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center min-h-screen">
      <div class="text-center space-y-4">
        <div class="p-4 rounded-2xl bg-primary/10 mx-auto w-fit">
          <Loader2 class="w-10 h-10 text-primary animate-spin" />
        </div>
        <p class="text-muted-foreground font-medium">Loading artist...</p>
      </div>
    </div>

    <!-- Artist Content -->
    <template v-else-if="artist">
      <!-- Banner with Parallax Effect -->
      <div class="relative h-64 md:h-80 overflow-hidden">
        <div class="absolute inset-0 bg-gradient-to-br from-primary/30 via-purple-600/20 to-pink-600/20">
          <div class="absolute inset-0 opacity-30">
            <div class="absolute top-1/4 left-1/4 w-64 h-64 bg-primary/30 rounded-full blur-3xl animate-pulse" />
            <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl animate-pulse" style="animation-delay: 1s" />
          </div>
        </div>
        <img
          v-if="artist.banner_url"
          :src="artist.banner_url"
          :alt="`${artist.name} banner`"
          class="w-full h-full object-cover"
        />
        <div class="absolute inset-0 bg-gradient-to-t from-background via-background/60 to-transparent" />
      </div>

      <div class="container mx-auto px-4 lg:px-8">
        <!-- Artist Header -->
        <div class="relative -mt-32 pb-8" v-motion-fade-up>
          <div class="flex flex-col md:flex-row gap-6 md:gap-8">
            <!-- Artist Image -->
            <div class="flex-shrink-0">
              <div class="relative group">
                <div class="absolute -inset-1 bg-gradient-to-r from-primary via-purple-500 to-pink-500 rounded-full blur opacity-30 group-hover:opacity-50 transition-opacity" />
                <Avatar class="relative w-40 h-40 md:w-48 md:h-48 ring-4 ring-background shadow-2xl">
                  <AvatarImage
                    v-if="artistImage"
                    :src="artistImage"
                    :alt="artist.name"
                    class="object-cover"
                  />
                  <AvatarFallback class="bg-gradient-to-br from-primary to-purple-600">
                    <Music class="w-16 h-16 text-white" />
                  </AvatarFallback>
                </Avatar>
              </div>
            </div>

            <!-- Artist Info -->
            <div class="flex-1 pt-4 md:pt-20">
              <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
                <div>
                  <div class="flex items-center gap-3 flex-wrap mb-3">
                    <h1 class="text-3xl md:text-4xl font-bold">{{ artist.name }}</h1>
                    <Badge v-if="artist.is_enriched" variant="secondary" class="bg-primary/10 text-primary border-primary/20">
                      <BadgeCheck class="w-3 h-3 mr-1" />
                      Verified
                    </Badge>
                    <Badge v-if="artist.on_tour" class="bg-green-500/10 text-green-400 border-green-500/20">
                      <Radio class="w-3 h-3 mr-1 animate-pulse" />
                      On Tour
                    </Badge>
                  </div>
                  <p class="text-muted-foreground text-lg flex flex-wrap items-center gap-2">
                    <span class="flex items-center gap-1">
                      <Music class="w-4 h-4" />
                      {{ artist.genre }}
                    </span>
                    <span v-if="artist.music_style" class="text-border">·</span>
                    <span v-if="artist.music_style">{{ artist.music_style }}</span>
                    <span v-if="artist.country" class="text-border">·</span>
                    <span v-if="artist.country" class="flex items-center gap-1">
                      <MapPin class="w-4 h-4" />
                      {{ artist.country }}
                    </span>
                  </p>
                  <p v-if="artist.formed_year" class="text-sm text-muted-foreground mt-2 flex items-center gap-2">
                    <CalendarDays class="w-4 h-4" />
                    Formed {{ artist.formed_year }}
                    <span v-if="artist.disbanded_year"> · Disbanded {{ artist.disbanded_year }}</span>
                  </p>
                </div>
                <FollowButton :artist-id="artist.id" size="lg" />
              </div>
            </div>
          </div>
        </div>

        <!-- Main Content -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 lg:gap-8 pb-12">
          <!-- Left Column - About & Concerts -->
          <div class="lg:col-span-2 space-y-6">
            <!-- Biography -->
            <Card
              v-if="artistBio"
              class="bg-card/50 border-border/50"
              v-motion
              :initial="{ opacity: 0, y: 20 }"
              :enter="{ opacity: 1, y: 0, transition: { delay: 100 } }"
            >
              <CardHeader>
                <CardTitle class="flex items-center gap-2">
                  <Info class="w-5 h-5 text-primary" />
                  About
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p class="text-muted-foreground leading-relaxed whitespace-pre-line">
                  {{ displayedBio }}
                </p>
                <Button
                  v-if="showExpandButton"
                  variant="link"
                  @click="expanded = !expanded"
                  class="px-0 mt-2 text-primary"
                >
                  {{ expanded ? 'Show less' : 'Read more' }}
                  <ChevronDown :class="['w-4 h-4 ml-1 transition-transform', expanded && 'rotate-180']" />
                </Button>
              </CardContent>
            </Card>

            <!-- Upcoming Concerts -->
            <div
              v-motion
              :initial="{ opacity: 0, y: 20 }"
              :enter="{ opacity: 1, y: 0, transition: { delay: 200 } }"
            >
              <div class="flex items-center justify-between mb-4">
                <h2 class="text-2xl font-bold flex items-center gap-2">
                  <Calendar class="w-6 h-6 text-purple-500" />
                  Upcoming Concerts
                </h2>
                <Badge variant="outline" class="border-border/50">
                  <Ticket class="w-3 h-3 mr-1" />
                  {{ concerts.length }} shows
                </Badge>
              </div>

              <!-- Loading Concerts -->
              <div v-if="loadingConcerts" class="space-y-4">
                <Card v-for="i in 3" :key="i" class="bg-card/50 border-border/50">
                  <CardContent class="pt-4">
                    <div class="flex gap-4">
                      <Skeleton class="w-16 h-16 rounded-lg" />
                      <div class="flex-1 space-y-2">
                        <Skeleton class="h-5 w-3/4" />
                        <Skeleton class="h-4 w-1/2" />
                        <Skeleton class="h-4 w-1/3" />
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>

              <!-- Empty State -->
              <Card v-else-if="concerts.length === 0" class="border-dashed border-border/50 bg-card/30">
                <CardContent class="flex flex-col items-center justify-center py-12">
                  <div class="p-3 rounded-xl bg-muted/50 mb-4">
                    <CalendarX class="w-8 h-8 text-muted-foreground" />
                  </div>
                  <p class="text-muted-foreground">No upcoming concerts scheduled</p>
                </CardContent>
              </Card>

              <!-- Concerts List -->
              <div v-else class="space-y-4">
                <div
                  v-for="(concert, index) in concerts"
                  :key="concert.id"
                  v-motion
                  :initial="{ opacity: 0, x: -20 }"
                  :enter="{ opacity: 1, x: 0, transition: { delay: 250 + index * 50 } }"
                >
                  <ConcertCard :concert="concert" />
                </div>
              </div>
            </div>
          </div>

          <!-- Right Column - Stats & Links -->
          <div class="space-y-6">
            <!-- Stats -->
            <Card
              class="bg-card/50 border-border/50"
              v-motion
              :initial="{ opacity: 0, y: 20 }"
              :enter="{ opacity: 1, y: 0, transition: { delay: 150 } }"
            >
              <CardHeader>
                <CardTitle class="flex items-center gap-2">
                  <BarChart3 class="w-5 h-5 text-primary" />
                  Stats
                </CardTitle>
              </CardHeader>
              <CardContent class="space-y-4">
                <div class="flex justify-between items-center">
                  <span class="text-muted-foreground flex items-center gap-2">
                    <Users class="w-4 h-4" />
                    Followers
                  </span>
                  <span class="text-2xl font-bold text-gradient-purple">{{ artist.followers_count || 0 }}</span>
                </div>
                <Separator class="bg-border/50" />
                <div class="flex justify-between items-center">
                  <span class="text-muted-foreground flex items-center gap-2">
                    <Calendar class="w-4 h-4" />
                    Upcoming Shows
                  </span>
                  <span class="text-2xl font-bold text-gradient">{{ artist.upcoming_concerts_count || 0 }}</span>
                </div>
              </CardContent>
            </Card>

            <!-- Links -->
            <Card
              v-if="hasLinks"
              class="bg-card/50 border-border/50"
              v-motion
              :initial="{ opacity: 0, y: 20 }"
              :enter="{ opacity: 1, y: 0, transition: { delay: 200 } }"
            >
              <CardHeader>
                <CardTitle class="flex items-center gap-2">
                  <LinkIcon class="w-5 h-5 text-primary" />
                  Links
                </CardTitle>
              </CardHeader>
              <CardContent class="space-y-2">
                <Button v-if="artist.website" as-child variant="outline" class="w-full justify-start bg-background/50 hover:bg-accent group">
                  <a :href="artist.website" target="_blank" class="flex items-center gap-3">
                    <div class="p-1.5 rounded-md bg-primary/10">
                      <Globe class="w-4 h-4 text-primary" />
                    </div>
                    <span class="font-medium">Website</span>
                    <ExternalLink class="w-3 h-3 ml-auto opacity-0 group-hover:opacity-100 transition-opacity" />
                  </a>
                </Button>
                <Button v-if="artist.facebook_url" as-child variant="outline" class="w-full justify-start bg-background/50 hover:bg-accent group">
                  <a :href="artist.facebook_url" target="_blank" class="flex items-center gap-3">
                    <div class="p-1.5 rounded-md bg-blue-500/10">
                      <Facebook class="w-4 h-4 text-blue-500" />
                    </div>
                    <span class="font-medium">Facebook</span>
                    <ExternalLink class="w-3 h-3 ml-auto opacity-0 group-hover:opacity-100 transition-opacity" />
                  </a>
                </Button>
                <Button v-if="artist.twitter_handle" as-child variant="outline" class="w-full justify-start bg-background/50 hover:bg-accent group">
                  <a :href="`https://twitter.com/${artist.twitter_handle}`" target="_blank" class="flex items-center gap-3">
                    <div class="p-1.5 rounded-md bg-foreground/10">
                      <Twitter class="w-4 h-4" />
                    </div>
                    <span class="font-medium">Twitter</span>
                    <ExternalLink class="w-3 h-3 ml-auto opacity-0 group-hover:opacity-100 transition-opacity" />
                  </a>
                </Button>
              </CardContent>
            </Card>

            <!-- Back Button -->
            <Button
              as-child
              variant="outline"
              class="w-full bg-background/50 font-medium group"
              v-motion
              :initial="{ opacity: 0, y: 20 }"
              :enter="{ opacity: 1, y: 0, transition: { delay: 250 } }"
            >
              <router-link to="/artists" class="flex items-center gap-2">
                <ArrowLeft class="w-4 h-4 transition-transform group-hover:-translate-x-1" />
                Back to Artists
              </router-link>
            </Button>
          </div>
        </div>
      </div>
    </template>

    <!-- Error State -->
    <div v-else class="flex items-center justify-center min-h-screen">
      <Card class="max-w-md bg-card/50 border-border/50" v-motion-fade-up>
        <CardContent class="flex flex-col items-center justify-center py-12">
          <div class="p-4 rounded-2xl bg-destructive/10 mb-6">
            <UserX class="w-12 h-12 text-destructive" />
          </div>
          <h3 class="text-xl font-bold mb-2">Artist not found</h3>
          <p class="text-muted-foreground text-center mb-6">
            We couldn't find the artist you're looking for
          </p>
          <Button as-child class="font-medium">
            <router-link to="/artists" class="flex items-center gap-2">
              <Users class="w-4 h-4" />
              Browse Artists
            </router-link>
          </Button>
        </CardContent>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useArtistsStore } from '../stores/artists'
import api from '../services/api'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'
import { Skeleton } from '@/components/ui/skeleton'
import FollowButton from '../components/artists/FollowButton.vue'
import ConcertCard from '../components/concerts/ConcertCard.vue'
import {
  Music,
  MapPin,
  CalendarDays,
  Calendar,
  CalendarX,
  Ticket,
  Users,
  BadgeCheck,
  Radio,
  Info,
  ChevronDown,
  BarChart3,
  Globe,
  Facebook,
  Twitter,
  Link as LinkIcon,
  ExternalLink,
  ArrowLeft,
  UserX,
  Loader2
} from 'lucide-vue-next'

const route = useRoute()
const artistsStore = useArtistsStore()

const artist = ref<any>(null)
const concerts = ref<any[]>([])
const loading = ref(true)
const loadingConcerts = ref(true)
const expanded = ref(false)

const MAX_BIO_LENGTH = 400

const artistImage = computed(() => {
  if (!artist.value) return null
  return artist.value.fanart_url || artist.value.thumbnail_url || artist.value.primary_image_url || artist.value.image_url
})

const artistBio = computed(() => {
  if (!artist.value) return ''
  return artist.value.biography || artist.value.description || ''
})

const displayedBio = computed(() => {
  if (expanded.value || artistBio.value.length <= MAX_BIO_LENGTH) {
    return artistBio.value
  }
  return artistBio.value.substring(0, MAX_BIO_LENGTH) + '...'
})

const showExpandButton = computed(() => artistBio.value.length > MAX_BIO_LENGTH)

const hasLinks = computed(() => {
  return artist.value?.website || artist.value?.facebook_url || artist.value?.twitter_handle
})

onMounted(async () => {
  try {
    artist.value = await artistsStore.fetchArtist(route.params.id as string)
  } catch (error) {
    console.error('Failed to load artist:', error)
  } finally {
    loading.value = false
  }

  try {
    const response = await api.get(`/api/v1/artists/${route.params.id}/concerts`)
    concerts.value = response.data.concerts
  } catch (error) {
    console.error('Failed to load concerts:', error)
  } finally {
    loadingConcerts.value = false
  }
})
</script>
