<template>
  <div class="group relative aspect-square overflow-hidden rounded-xl cursor-pointer bg-gradient-to-br from-primary/20 via-purple-600/20 to-pink-600/20">
    <!-- Artist Image -->
    <img
      v-if="artistImage"
      :src="artistImage"
      :alt="artist.name"
      class="w-full h-full object-cover"
    />
    <div v-else class="w-full h-full flex items-center justify-center">
      <div class="p-6 rounded-2xl bg-white/10 backdrop-blur-sm">
        <Music class="w-14 h-14 text-white/70" />
      </div>
    </div>

    <!-- Default overlay: name at bottom -->
    <div class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/70 to-transparent px-4 py-3 transition-opacity duration-300 group-hover:opacity-0">
      <p class="text-white font-semibold text-sm truncate">{{ artist.name }}</p>
    </div>

    <!-- Hover overlay: fixed-height panel sliding up from bottom -->
    <div class="absolute inset-x-0 bottom-0 h-36 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out">
      <div class="h-full bg-black/80 backdrop-blur-sm px-4 py-4 flex flex-col gap-3">
        <!-- Name + shows -->
        <div class="flex items-start justify-between gap-2">
          <div class="min-w-0">
            <p class="text-white font-semibold text-sm truncate">{{ artist.name }}</p>
            <span class="flex items-center gap-1 text-white/70 text-xs mt-0.5">
              <Ticket class="w-3 h-3" />
              {{ artist.upcoming_concerts_count || 0 }} shows
            </span>
          </div>
          <FollowButton :artist-id="artist.id" size="sm" />
        </div>

        <!-- Description -->
        <p v-if="artistDescription" class="text-white/70 text-xs line-clamp-2 leading-relaxed">
          {{ artistDescription }}
        </p>

        <!-- See profile -->
        <Button as-child size="sm" class="w-full font-medium group/btn">
          <router-link :to="`/artists/${artist.id}`" class="flex items-center justify-center gap-2">
            See profile
            <ArrowRight class="w-3.5 h-3.5 transition-transform group-hover/btn:translate-x-1" />
          </router-link>
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Button } from '@/components/ui/button'
import FollowButton from './FollowButton.vue'
import { Music, Ticket, ArrowRight } from 'lucide-vue-next'

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
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
