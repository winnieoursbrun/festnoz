<template>
  <div
    class="group relative aspect-square overflow-hidden rounded-xl cursor-pointer bg-gradient-to-br from-green-900/20 via-green-800/10 to-transparent border border-dashed border-green-500/20 opacity-60 hover:opacity-100 transition-opacity duration-300"
    :class="{ 'pointer-events-none opacity-40': importing }"
  >
    <!-- Artist Image (blurred/muted) -->
    <img
      v-if="artist.image_url"
      :src="artist.image_url"
      :alt="artist.name"
      class="w-full h-full object-cover brightness-50"
    />
    <div v-else class="w-full h-full flex items-center justify-center bg-green-950/30">
      <div class="p-6 rounded-2xl bg-white/5 backdrop-blur-sm">
        <Music class="w-14 h-14 text-green-400/40" />
      </div>
    </div>

    <!-- Spotify badge top-right -->
    <div class="absolute top-2 right-2 flex items-center gap-1 bg-black/60 backdrop-blur-sm rounded-full px-2 py-1">
      <svg viewBox="0 0 24 24" class="w-3 h-3 fill-green-400" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.66 0 12 0zm5.521 17.34c-.24.359-.66.48-1.021.24-2.82-1.74-6.36-2.101-10.561-1.141-.418.122-.779-.179-.899-.539-.12-.421.18-.78.54-.9 4.56-1.021 8.52-.6 11.64 1.32.42.18.479.659.301 1.02zm1.44-3.3c-.301.42-.841.6-1.262.3-3.239-1.98-8.159-2.58-11.939-1.38-.479.12-1.02-.12-1.14-.6-.12-.48.12-1.021.6-1.141C9.6 9.9 15 10.561 18.72 12.84c.361.181.54.78.241 1.2zm.12-3.36C15.24 8.4 8.82 8.16 5.16 9.301c-.6.179-1.2-.181-1.38-.721-.18-.601.18-1.2.72-1.381 4.26-1.26 11.28-1.02 15.721 1.621.539.3.719 1.02.419 1.56-.299.421-1.02.599-1.559.3z"/>
      </svg>
      <span class="text-[10px] text-green-400 font-medium">Spotify</span>
    </div>

    <!-- Default overlay: name at bottom -->
    <div class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/70 to-transparent px-4 py-3 transition-opacity duration-300 group-hover:opacity-0">
      <p class="text-white/70 font-semibold text-sm truncate">{{ artist.name }}</p>
    </div>

    <!-- Hover overlay -->
    <div class="absolute inset-x-0 bottom-0 h-36 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out">
      <div class="h-full bg-black/85 backdrop-blur-sm px-4 py-4 flex flex-col gap-3">
        <div class="min-w-0">
          <p class="text-white font-semibold text-sm truncate">{{ artist.name }}</p>
          <p class="text-white/50 text-xs truncate mt-0.5">{{ artist.genres?.join(', ') || 'Unknown genre' }}</p>
        </div>

        <p v-if="artist.followers" class="text-white/40 text-xs">
          {{ formatFollowers(artist.followers) }} Spotify followers
        </p>

        <Button
          size="sm"
          class="w-full font-medium gap-2 bg-green-600 hover:bg-green-500 text-white border-0"
          :disabled="importing"
          @click.stop="doImport"
        >
          <Loader2 v-if="importing" class="w-3.5 h-3.5 animate-spin" />
          <Download v-else class="w-3.5 h-3.5" />
          {{ importing ? 'Importing…' : 'Import artist' }}
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '@/services/api'
import { Button } from '@/components/ui/button'
import { Music, Download, Loader2 } from 'lucide-vue-next'

const props = defineProps<{
  artist: {
    spotify_id: string
    name: string
    genres?: string[]
    image_url?: string
    followers?: number
    popularity?: number
  }
}>()

const emit = defineEmits<{ imported: [] }>()
const importing = ref(false)

async function doImport() {
  importing.value = true
  try {
    await api.post('/api/v1/artists/import_from_spotify', { spotify_id: props.artist.spotify_id })
    emit('imported')
  } finally {
    importing.value = false
  }
}

function formatFollowers(count: number): string {
  if (count >= 1_000_000) return `${(count / 1_000_000).toFixed(1)}M`
  if (count >= 1_000) return `${(count / 1_000).toFixed(0)}K`
  return count.toString()
}
</script>
