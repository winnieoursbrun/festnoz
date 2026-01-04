<template>
  <Card class="group overflow-hidden hover:shadow-md transition-all duration-200">
    <!-- Artist Image -->
    <div class="relative h-48 bg-gradient-to-br from-purple-600 to-indigo-600 overflow-hidden">
      <img
        v-if="artistImage"
        :src="artistImage"
        :alt="artist.name"
        class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
      />
      <div v-else class="w-full h-full flex items-center justify-center">
        <span class="text-6xl">🎵</span>
      </div>

      <!-- Enriched indicator -->
      <Badge
        v-if="artist.is_enriched"
        variant="secondary"
        class="absolute top-3 right-3"
        title="Enriched with TheAudioDB data"
      >
        ✓
      </Badge>
    </div>

    <!-- Artist Info -->
    <CardContent class="p-4">
      <div class="flex items-start justify-between gap-2 mb-2">
        <CardTitle class="text-lg leading-tight line-clamp-1">
          {{ artist.name }}
        </CardTitle>
        <FollowButton :artist-id="artist.id" size="sm" />
      </div>

      <p v-if="artist.genre" class="text-muted-foreground text-sm mb-2">
        {{ artist.genre }}
      </p>

      <p v-if="artistDescription" class="text-muted-foreground text-sm mb-3 line-clamp-2">
        {{ artistDescription }}
      </p>

      <!-- Stats -->
      <div class="flex items-center gap-4 text-xs text-muted-foreground mb-3">
        <span class="flex items-center gap-1">
          <span>👥</span> {{ artist.followers_count || 0 }} followers
        </span>
        <span class="flex items-center gap-1">
          <span>🎫</span> {{ artist.upcoming_concerts_count || 0 }} shows
        </span>
      </div>

      <!-- On Tour Badge -->
      <div v-if="artist.on_tour" class="mb-3">
        <Badge variant="outline" class="text-green-600 border-green-500/50 text-xs">
          🔴 On Tour
        </Badge>
      </div>

      <!-- Actions -->
      <Button as-child class="w-full">
        <router-link :to="`/artists/${artist.id}`">
          View Details
        </router-link>
      </Button>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import FollowButton from './FollowButton.vue'

interface Artist {
  id: number
  name: string
  genre?: string
  music_style?: string
  biography?: string
  description?: string
  primary_image_url?: string
  thumbnail_url?: string
  image_url?: string
  followers_count?: number
  upcoming_concerts_count?: number
  on_tour?: boolean
  is_enriched?: boolean
  facebook_url?: string
  twitter_handle?: string
  website?: string
}

const props = defineProps<{
  artist: Artist
}>()

const artistImage = computed(() => {
  return props.artist.primary_image_url || props.artist.thumbnail_url || props.artist.image_url
})

const artistDescription = computed(() => {
  return props.artist.biography || props.artist.description
})
</script>

<style scoped>
.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
