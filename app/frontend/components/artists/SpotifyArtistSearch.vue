<template>
  <Dialog v-model:open="open">
    <DialogTrigger as-child>
      <Button variant="outline" class="gap-2 border-green-500/30 text-green-400 hover:bg-green-500/10 hover:border-green-500/50">
        <svg viewBox="0 0 24 24" class="w-4 h-4 fill-current" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.66 0 12 0zm5.521 17.34c-.24.359-.66.48-1.021.24-2.82-1.74-6.36-2.101-10.561-1.141-.418.122-.779-.179-.899-.539-.12-.421.18-.78.54-.9 4.56-1.021 8.52-.6 11.64 1.32.42.18.479.659.301 1.02zm1.44-3.3c-.301.42-.841.6-1.262.3-3.239-1.98-8.159-2.58-11.939-1.38-.479.12-1.02-.12-1.14-.6-.12-.48.12-1.021.6-1.141C9.6 9.9 15 10.561 18.72 12.84c.361.181.54.78.241 1.2zm.12-3.36C15.24 8.4 8.82 8.16 5.16 9.301c-.6.179-1.2-.181-1.38-.721-.18-.601.18-1.2.72-1.381 4.26-1.26 11.28-1.02 15.721 1.621.539.3.719 1.02.419 1.56-.299.421-1.02.599-1.559.3z"/>
        </svg>
        Search Spotify
      </Button>
    </DialogTrigger>

    <DialogContent class="sm:max-w-[600px] max-h-[85vh] flex flex-col">
      <DialogHeader>
        <DialogTitle class="flex items-center gap-2">
          <svg viewBox="0 0 24 24" class="w-5 h-5 fill-green-400" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.66 0 12 0zm5.521 17.34c-.24.359-.66.48-1.021.24-2.82-1.74-6.36-2.101-10.561-1.141-.418.122-.779-.179-.899-.539-.12-.421.18-.78.54-.9 4.56-1.021 8.52-.6 11.64 1.32.42.18.479.659.301 1.02zm1.44-3.3c-.301.42-.841.6-1.262.3-3.239-1.98-8.159-2.58-11.939-1.38-.479.12-1.02-.12-1.14-.6-.12-.48.12-1.021.6-1.141C9.6 9.9 15 10.561 18.72 12.84c.361.181.54.78.241 1.2zm.12-3.36C15.24 8.4 8.82 8.16 5.16 9.301c-.6.179-1.2-.181-1.38-.721-.18-.601.18-1.2.72-1.381 4.26-1.26 11.28-1.02 15.721 1.621.539.3.719 1.02.419 1.56-.299.421-1.02.599-1.559.3z"/>
          </svg>
          Import from Spotify
        </DialogTitle>
        <DialogDescription>
          Search Spotify's catalog and import artists into FestNoz.
        </DialogDescription>
      </DialogHeader>

      <div class="relative mt-2">
        <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input
          v-model="query"
          @input="debouncedSearch"
          placeholder="Search for an artist..."
          class="pl-10"
          autofocus
        />
      </div>

      <div class="flex-1 overflow-y-auto space-y-2 mt-3 min-h-[200px]">
        <!-- Loading -->
        <div v-if="loading" class="flex items-center justify-center py-10">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
        </div>

        <!-- Idle -->
        <div v-else-if="!query" class="flex flex-col items-center justify-center py-10 text-muted-foreground">
          <Music class="w-10 h-10 mb-3 opacity-30" />
          <p class="text-sm">Type an artist name to search</p>
        </div>

        <!-- No results -->
        <div v-else-if="results.length === 0" class="flex flex-col items-center justify-center py-10 text-muted-foreground">
          <SearchX class="w-10 h-10 mb-3 opacity-30" />
          <p class="text-sm">No artists found for "{{ query }}"</p>
        </div>

        <!-- Results -->
        <div
          v-for="artist in results"
          :key="artist.spotify_id"
          class="flex items-center gap-3 p-3 rounded-lg border border-border/50 bg-card/50 hover:bg-card transition-colors"
        >
          <img
            v-if="artist.image_url"
            :src="artist.image_url"
            :alt="artist.name"
            class="w-12 h-12 rounded-full object-cover shrink-0"
          />
          <div v-else class="w-12 h-12 rounded-full bg-muted flex items-center justify-center shrink-0">
            <Music class="w-5 h-5 text-muted-foreground" />
          </div>

          <div class="flex-1 min-w-0">
            <p class="font-medium truncate">{{ artist.name }}</p>
            <p class="text-xs text-muted-foreground truncate">
              {{ artist.genres?.join(', ') || 'No genre' }}
              <span v-if="artist.followers" class="ml-2">· {{ formatFollowers(artist.followers) }} followers</span>
            </p>
          </div>

          <Badge v-if="artist.already_imported" variant="secondary" class="shrink-0 text-xs">
            <Check class="w-3 h-3 mr-1" />
            Imported
          </Badge>

          <Button
            v-else
            size="sm"
            :disabled="importing[artist.spotify_id]"
            @click="importArtist(artist)"
            class="shrink-0 gap-1.5"
          >
            <Loader2 v-if="importing[artist.spotify_id]" class="w-3.5 h-3.5 animate-spin" />
            <Download v-else class="w-3.5 h-3.5" />
            {{ importing[artist.spotify_id] ? 'Importing…' : 'Import' }}
          </Button>
        </div>
      </div>

      <p v-if="error" class="text-sm text-destructive mt-2">{{ error }}</p>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import api from '@/services/api'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { Search, SearchX, Music, Check, Download, Loader2 } from 'lucide-vue-next'

const emit = defineEmits<{ imported: [] }>()

const open = ref(false)
const query = ref('')
const results = ref<any[]>([])
const loading = ref(false)
const error = ref('')
const importing = reactive<Record<string, boolean>>({})

let searchTimeout: ReturnType<typeof setTimeout> | null = null

function debouncedSearch() {
  error.value = ''
  if (searchTimeout) clearTimeout(searchTimeout)
  if (!query.value.trim()) {
    results.value = []
    return
  }
  searchTimeout = setTimeout(searchSpotify, 350)
}

async function searchSpotify() {
  loading.value = true
  error.value = ''
  try {
    const resp = await api.get('/api/v1/artists/search_spotify', { params: { q: query.value.trim() } })
    results.value = resp.data.artists || []
  } catch (err: any) {
    error.value = err.response?.data?.message || err.response?.data?.error || 'Search failed'
    results.value = []
  } finally {
    loading.value = false
  }
}

async function importArtist(artist: any) {
  importing[artist.spotify_id] = true
  error.value = ''
  try {
    await api.post('/api/v1/artists/import_from_spotify', { spotify_id: artist.spotify_id })
    artist.already_imported = true
    emit('imported')
  } catch (err: any) {
    error.value = err.response?.data?.message || err.response?.data?.error || 'Import failed'
  } finally {
    importing[artist.spotify_id] = false
  }
}

function formatFollowers(count: number): string {
  if (count >= 1_000_000) return `${(count / 1_000_000).toFixed(1)}M`
  if (count >= 1_000) return `${(count / 1_000).toFixed(0)}K`
  return count.toString()
}
</script>
