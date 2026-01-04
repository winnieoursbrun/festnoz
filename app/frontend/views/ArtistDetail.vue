<template>
  <div class="min-h-screen bg-gradient-to-b from-background to-muted/30">
    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center min-h-screen">
      <div class="text-center">
        <div class="h-12 w-12 animate-spin rounded-full border-4 border-primary border-t-transparent mx-auto mb-4"></div>
        <p class="text-muted-foreground">Loading artist...</p>
      </div>
    </div>

    <!-- Artist Content -->
    <template v-else-if="artist">
      <!-- Banner -->
      <div class="relative h-64 md:h-80 bg-gradient-to-br from-primary/20 via-purple-500/10 to-pink-500/10 overflow-hidden">
        <img
          v-if="artist.banner_url"
          :src="artist.banner_url"
          :alt="`${artist.name} banner`"
          class="w-full h-full object-cover"
        />
        <div class="absolute inset-0 bg-gradient-to-t from-background via-background/50 to-transparent"></div>
      </div>

      <div class="container mx-auto px-4">
        <!-- Artist Header -->
        <div class="relative -mt-32 pb-8">
          <div class="flex flex-col md:flex-row gap-6 md:gap-8">
            <!-- Artist Image -->
            <div class="flex-shrink-0">
              <Avatar class="w-40 h-40 md:w-48 md:h-48 ring-4 ring-background shadow-xl">
                <AvatarImage
                  v-if="artistImage"
                  :src="artistImage"
                  :alt="artist.name"
                  class="object-cover"
                />
                <AvatarFallback class="bg-gradient-to-br from-primary to-purple-600 text-6xl">
                  🎵
                </AvatarFallback>
              </Avatar>
            </div>

            <!-- Artist Info -->
            <div class="flex-1 pt-4 md:pt-20">
              <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
                <div>
                  <div class="flex items-center gap-3 flex-wrap mb-2">
                    <h1 class="text-3xl md:text-4xl font-bold">{{ artist.name }}</h1>
                    <Badge v-if="artist.is_enriched" variant="secondary">Verified</Badge>
                    <Badge v-if="artist.on_tour" class="bg-green-500/10 text-green-500 border-green-500/20">
                      On Tour
                    </Badge>
                  </div>
                  <p class="text-muted-foreground text-lg">
                    {{ artist.genre }}
                    <span v-if="artist.music_style"> · {{ artist.music_style }}</span>
                    <span v-if="artist.country"> · {{ artist.country }}</span>
                  </p>
                  <p v-if="artist.formed_year" class="text-sm text-muted-foreground mt-1">
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
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 pb-12">
          <!-- Left Column - About & Links -->
          <div class="lg:col-span-2 space-y-6">
            <!-- Biography -->
            <Card v-if="artistBio">
              <CardHeader>
                <CardTitle>About</CardTitle>
              </CardHeader>
              <CardContent>
                <p class="text-muted-foreground leading-relaxed whitespace-pre-line">
                  {{ displayedBio }}
                </p>
                <Button
                  v-if="showExpandButton"
                  variant="link"
                  @click="expanded = !expanded"
                  class="px-0 mt-2"
                >
                  {{ expanded ? 'Show less' : 'Read more' }}
                </Button>
              </CardContent>
            </Card>

            <!-- Upcoming Concerts -->
            <div>
              <div class="flex items-center justify-between mb-4">
                <h2 class="text-2xl font-bold">Upcoming Concerts</h2>
                <Badge variant="outline">{{ concerts.length }} shows</Badge>
              </div>

              <div v-if="loadingConcerts" class="flex items-center justify-center py-12">
                <div class="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
              </div>

              <Card v-else-if="concerts.length === 0" class="border-dashed">
                <CardContent class="flex flex-col items-center justify-center py-12">
                  <div class="text-4xl mb-2">📅</div>
                  <p class="text-muted-foreground">No upcoming concerts scheduled</p>
                </CardContent>
              </Card>

              <div v-else class="space-y-4">
                <ConcertCard
                  v-for="concert in concerts"
                  :key="concert.id"
                  :concert="concert"
                />
              </div>
            </div>
          </div>

          <!-- Right Column - Stats & Links -->
          <div class="space-y-6">
            <!-- Stats -->
            <Card>
              <CardHeader>
                <CardTitle>Stats</CardTitle>
              </CardHeader>
              <CardContent class="space-y-4">
                <div class="flex justify-between items-center">
                  <span class="text-muted-foreground">Followers</span>
                  <span class="text-2xl font-bold">{{ artist.followers_count || 0 }}</span>
                </div>
                <Separator />
                <div class="flex justify-between items-center">
                  <span class="text-muted-foreground">Upcoming Shows</span>
                  <span class="text-2xl font-bold">{{ artist.upcoming_concerts_count || 0 }}</span>
                </div>
              </CardContent>
            </Card>

            <!-- Links -->
            <Card v-if="hasLinks">
              <CardHeader>
                <CardTitle>Links</CardTitle>
              </CardHeader>
              <CardContent class="space-y-2">
                <Button v-if="artist.website" as-child variant="outline" class="w-full justify-start">
                  <a :href="artist.website" target="_blank">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mr-2"><circle cx="12" cy="12" r="10"/><path d="M2 12h20"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                    Website
                  </a>
                </Button>
                <Button v-if="artist.facebook_url" as-child variant="outline" class="w-full justify-start">
                  <a :href="artist.facebook_url" target="_blank">
                    <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>
                    Facebook
                  </a>
                </Button>
                <Button v-if="artist.twitter_handle" as-child variant="outline" class="w-full justify-start">
                  <a :href="`https://twitter.com/${artist.twitter_handle}`" target="_blank">
                    <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 24 24"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
                    Twitter
                  </a>
                </Button>
              </CardContent>
            </Card>

            <!-- Back Button -->
            <Button as-child variant="outline" class="w-full">
              <router-link to="/artists">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mr-2"><path d="m15 18-6-6 6-6"/></svg>
                Back to Artists
              </router-link>
            </Button>
          </div>
        </div>
      </div>
    </template>

    <!-- Error State -->
    <div v-else class="flex items-center justify-center min-h-screen">
      <Card class="max-w-md">
        <CardContent class="flex flex-col items-center justify-center py-12">
          <div class="text-6xl mb-4">😕</div>
          <h3 class="text-xl font-semibold mb-2">Artist not found</h3>
          <p class="text-muted-foreground text-center mb-6">
            We couldn't find the artist you're looking for
          </p>
          <Button as-child>
            <router-link to="/artists">Browse Artists</router-link>
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
import FollowButton from '../components/artists/FollowButton.vue'
import ConcertCard from '../components/concerts/ConcertCard.vue'

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
