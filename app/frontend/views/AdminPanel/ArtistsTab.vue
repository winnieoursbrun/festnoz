<template>
  <div v-motion-fade-up>
    <Card class="bg-card/50 border-border/50">
      <CardHeader>
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Users class="w-5 h-5 text-primary" />
              Artists
            </CardTitle>
            <CardDescription class="mt-1">
              {{ artistsStore.artists.length }} artists registered
            </CardDescription>
          </div>
          <div class="flex flex-col gap-2 items-end">
            <div class="flex gap-2">
              <Button @click="handleFetchAllEvents" variant="outline" class="font-medium" :disabled="fetchingAllEvents">
                <Calendar class="w-4 h-4 mr-2" />
                {{ fetchingAllEvents ? 'Enqueueing...' : 'Fetch All Events' }}
              </Button>
              <Button @click="$emit('edit-artist', null)" class="font-medium">
                <Plus class="w-4 h-4 mr-2" />
                Add Artist
              </Button>
            </div>
            <Transition
              enter-active-class="transition-all duration-300"
              enter-from-class="opacity-0 scale-y-0"
              enter-to-class="opacity-100 scale-y-100"
              leave-active-class="transition-all duration-300"
              leave-from-class="opacity-100 scale-y-100"
              leave-to-class="opacity-0 scale-y-0"
            >
              <div v-if="fetchProgress > 0" class="w-full min-w-48 origin-top">
                <Progress :model-value="fetchProgress" class="h-1.5" />
                <p class="text-xs text-muted-foreground mt-1 text-right">
                  {{ fetchProgress < 100 ? 'Enqueueing jobs…' : 'Jobs enqueued!' }}
                </p>
              </div>
            </Transition>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <!-- Loading State -->
        <div v-if="artistsStore.loading" class="space-y-4">
          <div v-for="i in 5" :key="i" class="flex items-center gap-4 p-4 rounded-lg bg-background/50">
            <Skeleton class="w-10 h-10 rounded-full" />
            <div class="flex-1 space-y-2">
              <Skeleton class="h-4 w-1/3" />
              <Skeleton class="h-3 w-1/4" />
            </div>
          </div>
        </div>

        <!-- Table -->
        <div v-else class="rounded-lg border border-border/50 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow class="bg-muted/30 hover:bg-muted/30">
                <TableHead>Artist</TableHead>
                <TableHead>Genre</TableHead>
                <TableHead class="text-center">Followers</TableHead>
                <TableHead class="text-center">Concerts</TableHead>
                <TableHead class="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow
                v-for="artist in artistsStore.artists"
                :key="artist.id"
                class="hover:bg-accent/50 transition-colors"
              >
                <TableCell>
                  <div class="flex items-center gap-3">
                    <Avatar class="h-10 w-10 ring-2 ring-border/50">
                      <AvatarImage v-if="artist.thumbnail_url || artist.image_url" :src="artist.thumbnail_url || artist.image_url" />
                      <AvatarFallback class="bg-primary/10 text-primary">
                        {{ artist.name.charAt(0) }}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <span class="font-medium">{{ artist.name }}</span>
                      <p v-if="artist.is_enriched" class="text-xs text-muted-foreground flex items-center gap-1">
                        <BadgeCheck class="w-3 h-3 text-primary" />
                        Verified
                      </p>
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary" class="bg-purple-500/10 text-purple-400 border-purple-500/20">
                    <Music class="w-3 h-3 mr-1" />
                    {{ artist.genre || 'N/A' }}
                  </Badge>
                </TableCell>
                <TableCell class="text-center">
                  <span class="font-medium">{{ artist.followers_count || 0 }}</span>
                </TableCell>
                <TableCell class="text-center">
                  <span class="font-medium">{{ artist.upcoming_concerts_count || 0 }}</span>
                </TableCell>
                <TableCell class="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger as-child>
                      <Button variant="ghost" size="sm" class="h-8 w-8 p-0">
                        <MoreHorizontal class="w-4 h-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" class="w-48">
                      <DropdownMenuItem @click="$emit('edit-artist', artist)" class="cursor-pointer">
                        <Pencil class="w-4 h-4 mr-2" />
                        Edit
                      </DropdownMenuItem>
                      <DropdownMenuItem @click="handleFetchEvents(artist)" class="cursor-pointer">
                        <Calendar class="w-4 h-4 mr-2" />
                        Fetch Events
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem @click="$emit('delete-artist', artist)" class="cursor-pointer text-destructive focus:text-destructive">
                        <Trash2 class="w-4 h-4 mr-2" />
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref, onUnmounted } from 'vue'
import { useArtistsStore } from '../../stores/artists'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Skeleton } from '@/components/ui/skeleton'
import { Progress } from '@/components/ui/progress'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import {
  Users, Music, Calendar, Plus, MoreHorizontal, Pencil, Trash2, BadgeCheck
} from 'lucide-vue-next'
import { toast } from 'vue-sonner'

const emit = defineEmits<{
  'edit-artist': [artist: any]
  'delete-artist': [artist: any]
}>()

const artistsStore = useArtistsStore()
const fetchingAllEvents = ref(false)
const fetchProgress = ref(0)
let progressInterval: ReturnType<typeof setInterval> | null = null

onUnmounted(() => {
  if (progressInterval) clearInterval(progressInterval)
})

async function handleFetchAllEvents() {
  fetchingAllEvents.value = true
  fetchProgress.value = 0

  progressInterval = setInterval(() => {
    if (fetchProgress.value < 70) {
      fetchProgress.value = Math.min(fetchProgress.value + 5, 70)
    } else if (fetchProgress.value < 90) {
      fetchProgress.value = Math.min(fetchProgress.value + 1, 90)
    }
  }, 80)

  try {
    const result = await artistsStore.fetchAllArtistEvents()
    if (progressInterval) clearInterval(progressInterval)
    fetchProgress.value = 100
    toast.success(`Enqueued event fetching for ${result.count} artists`)
    setTimeout(() => { fetchProgress.value = 0 }, 1500)
  } catch (error) {
    if (progressInterval) clearInterval(progressInterval)
    fetchProgress.value = 0
    console.error('Failed to enqueue event fetching:', error)
    toast.error('Failed to enqueue event fetching')
  } finally {
    fetchingAllEvents.value = false
    progressInterval = null
  }
}

async function handleFetchEvents(artist: any) {
  const loadingToast = toast.loading(`Fetching events for ${artist.name}...`)

  try {
    const result = await artistsStore.fetchEventsForArtist(artist.id)
    toast.dismiss(loadingToast)

    if (result.created > 0) {
      toast.success(`Successfully fetched ${result.created} out of ${result.total} events from Ticketmaster`)
    } else if (result.total === 0) {
      toast.info(`No events found for ${artist.name} on Ticketmaster`)
    } else {
      toast.warning(`Found ${result.total} events but none were new`)
    }

    if (result.errors && result.errors.length > 0) {
      console.warn('Some events failed to import:', result.errors)
    }
  } catch (error) {
    toast.dismiss(loadingToast)
    console.error('Failed to fetch events:', error)
    toast.error('Failed to fetch events from Ticketmaster')
  }
}
</script>
