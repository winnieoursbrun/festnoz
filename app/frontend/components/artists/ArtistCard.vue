<template>
  <Card class="group overflow-hidden hover-lift bg-card/50 border-border/50 transition-all duration-300">
    <!-- Artist Image -->
    <div class="relative h-44 bg-gradient-to-br from-primary/20 via-purple-600/20 to-pink-600/20 overflow-hidden">
      <img
        v-if="artistImage"
        :src="artistImage"
        :alt="artist.name"
        class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
      />
      <div v-else class="w-full h-full flex items-center justify-center">
        <div class="p-4 rounded-2xl bg-white/10 backdrop-blur-sm">
          <Music class="w-10 h-10 text-white/70" />
        </div>
      </div>

      <!-- Gradient overlay -->
      <div class="absolute inset-0 bg-gradient-to-t from-card via-transparent to-transparent opacity-60" />

      <!-- Badges -->
      <div class="absolute top-3 right-3 flex flex-col gap-2">
        <Badge
          v-if="artist.is_enriched"
          variant="secondary"
          class="bg-primary/80 text-white border-0 backdrop-blur-sm"
          title="Enriched with TheAudioDB data"
        >
          <BadgeCheck class="w-3 h-3" />
        </Badge>
        <Badge
          v-if="artist.on_tour"
          class="bg-green-500/80 text-white border-0 backdrop-blur-sm"
        >
          <Radio class="w-3 h-3 mr-1 animate-pulse" />
          Live
        </Badge>
      </div>
    </div>

    <!-- Artist Info -->
    <CardContent class="p-4">
      <div class="flex items-start justify-between gap-2 mb-3">
        <div class="flex-1 min-w-0">
          <CardTitle class="text-base font-semibold leading-tight line-clamp-1 group-hover:text-primary transition-colors">
            {{ artist.name }}
          </CardTitle>
          <p v-if="artist.genre" class="text-muted-foreground text-sm mt-0.5 flex items-center gap-1">
            <Music class="w-3 h-3" />
            {{ artist.genre }}
          </p>
        </div>
        <FollowButton :artist-id="artist.id" size="sm" />
      </div>

      <p v-if="artistDescription" class="text-muted-foreground text-xs mb-3 line-clamp-2 leading-relaxed">
        {{ artistDescription }}
      </p>

      <!-- Stats -->
      <div class="flex items-center gap-4 text-xs text-muted-foreground mb-4">
        <span class="flex items-center gap-1.5">
          <Users class="w-3.5 h-3.5 text-primary" />
          <span class="font-medium text-foreground">{{ artist.followers_count || 0 }}</span>
          followers
        </span>
        <span class="flex items-center gap-1.5">
          <Ticket class="w-3.5 h-3.5 text-purple-500" />
          <span class="font-medium text-foreground">{{ artist.upcoming_concerts_count || 0 }}</span>
          shows
        </span>
      </div>

      <!-- Actions -->
      <Button as-child class="w-full font-medium group/btn">
        <router-link :to="`/artists/${artist.id}`" class="flex items-center justify-center gap-2">
          View Profile
          <ArrowRight class="w-4 h-4 transition-transform group-hover/btn:translate-x-1" />
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
import { Music, Users, Ticket, ArrowRight, BadgeCheck, Radio } from 'lucide-vue-next'

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
