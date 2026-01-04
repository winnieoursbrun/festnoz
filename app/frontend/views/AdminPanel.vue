<template>
  <div class="min-h-screen flex">
    <!-- Sidebar Navigation -->
    <aside
      class="w-64 border-r border-border/50 bg-card/30 backdrop-blur-sm hidden lg:block"
      v-motion
      :initial="{ opacity: 0, x: -20 }"
      :enter="{ opacity: 1, x: 0 }"
    >
      <div class="p-6">
        <div class="flex items-center gap-3 mb-8">
          <div class="p-2 rounded-xl bg-amber-500/10">
            <Shield class="w-6 h-6 text-amber-500" />
          </div>
          <div>
            <h2 class="font-bold">Admin Panel</h2>
            <p class="text-xs text-muted-foreground">Manage your data</p>
          </div>
        </div>

        <nav class="space-y-2">
          <button
            @click="activeTab = 'artists'"
            :class="[
              'w-full flex items-center gap-3 px-4 py-3 rounded-lg text-left transition-all',
              activeTab === 'artists'
                ? 'bg-primary text-primary-foreground'
                : 'hover:bg-accent text-muted-foreground hover:text-foreground'
            ]"
          >
            <Users class="w-5 h-5" />
            <span class="font-medium">Artists</span>
            <Badge variant="secondary" class="ml-auto text-xs">{{ artistsStore.artists.length }}</Badge>
          </button>
          <button
            @click="activeTab = 'concerts'"
            :class="[
              'w-full flex items-center gap-3 px-4 py-3 rounded-lg text-left transition-all',
              activeTab === 'concerts'
                ? 'bg-primary text-primary-foreground'
                : 'hover:bg-accent text-muted-foreground hover:text-foreground'
            ]"
          >
            <Ticket class="w-5 h-5" />
            <span class="font-medium">Concerts</span>
            <Badge variant="secondary" class="ml-auto text-xs">{{ concertsStore.concerts.length }}</Badge>
          </button>
        </nav>
      </div>

      <!-- Stats Summary -->
      <div class="p-6 border-t border-border/50">
        <h3 class="text-xs font-medium text-muted-foreground uppercase tracking-wider mb-4">Quick Stats</h3>
        <div class="space-y-3">
          <div class="flex items-center justify-between">
            <span class="text-sm text-muted-foreground">Total Artists</span>
            <span class="font-bold text-gradient-purple">{{ artistsStore.artists.length }}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-muted-foreground">Total Concerts</span>
            <span class="font-bold text-gradient">{{ concertsStore.concerts.length }}</span>
          </div>
        </div>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1">
      <!-- Mobile Header -->
      <div class="lg:hidden border-b border-border/50 bg-card/30 backdrop-blur-sm p-4">
        <div class="flex items-center gap-3 mb-4">
          <div class="p-2 rounded-xl bg-amber-500/10">
            <Shield class="w-5 h-5 text-amber-500" />
          </div>
          <h2 class="font-bold">Admin Panel</h2>
        </div>
        <div class="flex gap-2">
          <Button
            @click="activeTab = 'artists'"
            :variant="activeTab === 'artists' ? 'default' : 'outline'"
            size="sm"
            class="flex-1"
          >
            <Users class="w-4 h-4 mr-2" />
            Artists
          </Button>
          <Button
            @click="activeTab = 'concerts'"
            :variant="activeTab === 'concerts' ? 'default' : 'outline'"
            size="sm"
            class="flex-1"
          >
            <Ticket class="w-4 h-4 mr-2" />
            Concerts
          </Button>
        </div>
      </div>

      <div class="p-6 lg:p-8">
        <!-- Artists Tab -->
        <div v-if="activeTab === 'artists'" v-motion-fade-up>
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
                <Button @click="openArtistForm()" class="font-medium">
                  <Plus class="w-4 h-4 mr-2" />
                  Add Artist
                </Button>
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
                          <DropdownMenuContent align="end" class="w-40">
                            <DropdownMenuItem @click="openArtistForm(artist)" class="cursor-pointer">
                              <Pencil class="w-4 h-4 mr-2" />
                              Edit
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem @click="confirmDeleteArtist(artist)" class="cursor-pointer text-destructive focus:text-destructive">
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

        <!-- Concerts Tab -->
        <div v-if="activeTab === 'concerts'" v-motion-fade-up>
          <Card class="bg-card/50 border-border/50">
            <CardHeader>
              <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <CardTitle class="flex items-center gap-2">
                    <Ticket class="w-5 h-5 text-purple-500" />
                    Concerts
                  </CardTitle>
                  <CardDescription class="mt-1">
                    {{ concertsStore.concerts.length }} concerts scheduled
                  </CardDescription>
                </div>
                <Button @click="openConcertForm()" class="font-medium">
                  <Plus class="w-4 h-4 mr-2" />
                  Add Concert
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <!-- Loading State -->
              <div v-if="concertsStore.loading" class="space-y-4">
                <div v-for="i in 5" :key="i" class="flex items-center gap-4 p-4 rounded-lg bg-background/50">
                  <Skeleton class="w-16 h-16 rounded-lg" />
                  <div class="flex-1 space-y-2">
                    <Skeleton class="h-4 w-1/2" />
                    <Skeleton class="h-3 w-1/3" />
                  </div>
                </div>
              </div>

              <!-- Table -->
              <div v-else class="rounded-lg border border-border/50 overflow-hidden">
                <Table>
                  <TableHeader>
                    <TableRow class="bg-muted/30 hover:bg-muted/30">
                      <TableHead>Concert</TableHead>
                      <TableHead>Artist</TableHead>
                      <TableHead>Date & Time</TableHead>
                      <TableHead>Location</TableHead>
                      <TableHead class="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    <TableRow
                      v-for="concert in concertsStore.concerts"
                      :key="concert.id"
                      class="hover:bg-accent/50 transition-colors"
                    >
                      <TableCell>
                        <span class="font-medium">{{ concert.title }}</span>
                      </TableCell>
                      <TableCell>
                        <span class="text-muted-foreground">{{ concert.artist?.name || 'N/A' }}</span>
                      </TableCell>
                      <TableCell>
                        <div class="flex items-center gap-2">
                          <div class="p-1.5 rounded-md bg-primary/10">
                            <Calendar class="w-3.5 h-3.5 text-primary" />
                          </div>
                          <div class="text-sm">
                            <div class="font-medium">{{ formatDate(concert.starts_at) }}</div>
                            <div class="text-muted-foreground text-xs">{{ formatTime(concert.starts_at) }}</div>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div class="flex items-center gap-2">
                          <div class="p-1.5 rounded-md bg-purple-500/10">
                            <MapPin class="w-3.5 h-3.5 text-purple-500" />
                          </div>
                          <div class="text-sm">
                            <div>{{ concert.venue_name }}</div>
                            <div class="text-muted-foreground text-xs">{{ concert.city }}</div>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell class="text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger as-child>
                            <Button variant="ghost" size="sm" class="h-8 w-8 p-0">
                              <MoreHorizontal class="w-4 h-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end" class="w-40">
                            <DropdownMenuItem @click="openConcertForm(concert)" class="cursor-pointer">
                              <Pencil class="w-4 h-4 mr-2" />
                              Edit
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem @click="confirmDeleteConcert(concert)" class="cursor-pointer text-destructive focus:text-destructive">
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
      </div>
    </main>

    <!-- Artist Form Dialog -->
    <ArtistForm
      v-if="showArtistForm"
      :artist="editingArtist"
      @close="closeArtistForm"
      @saved="onArtistSaved"
    />

    <!-- Concert Form Dialog -->
    <ConcertForm
      v-if="showConcertForm"
      :concert="editingConcert"
      :artists="artistsStore.artists"
      @close="closeConcertForm"
      @saved="onConcertSaved"
    />

    <!-- Delete Confirmation Dialog -->
    <AlertDialog :open="!!itemToDelete" @update:open="(open) => !open && (itemToDelete = null)">
      <AlertDialogContent class="bg-card/95 backdrop-blur-sm border-border/50">
        <AlertDialogHeader>
          <AlertDialogTitle class="flex items-center gap-2">
            <AlertTriangle class="w-5 h-5 text-destructive" />
            Are you sure?
          </AlertDialogTitle>
          <AlertDialogDescription>
            This action cannot be undone. This will permanently delete
            <span class="font-semibold text-foreground">{{ itemToDelete?.name || itemToDelete?.title }}</span>.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel @click="itemToDelete = null" class="font-medium">Cancel</AlertDialogCancel>
          <AlertDialogAction class="bg-destructive text-destructive-foreground hover:bg-destructive/90 font-medium" @click="executeDelete">
            <Trash2 class="w-4 h-4 mr-2" />
            Delete
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useArtistsStore } from '../stores/artists'
import { useConcertsStore } from '../stores/concerts'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from '@/components/ui/table'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle
} from '@/components/ui/alert-dialog'
import ArtistForm from '../components/artists/ArtistForm.vue'
import ConcertForm from '../components/concerts/ConcertForm.vue'
import {
  Shield,
  Users,
  Ticket,
  Plus,
  Music,
  Calendar,
  MapPin,
  MoreHorizontal,
  Pencil,
  Trash2,
  AlertTriangle,
  BadgeCheck
} from 'lucide-vue-next'
import { toast } from 'vue-sonner'

const artistsStore = useArtistsStore()
const concertsStore = useConcertsStore()

const activeTab = ref('artists')
const showArtistForm = ref(false)
const showConcertForm = ref(false)
const editingArtist = ref<any>(null)
const editingConcert = ref<any>(null)
const itemToDelete = ref<any>(null)
const deleteType = ref<'artist' | 'concert' | null>(null)

function formatDate(dateString: string): string {
  return new Date(dateString).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}

function formatTime(dateString: string): string {
  return new Date(dateString).toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

function openArtistForm(artist: any = null) {
  editingArtist.value = artist
  showArtistForm.value = true
}

function closeArtistForm() {
  showArtistForm.value = false
  editingArtist.value = null
}

function onArtistSaved() {
  closeArtistForm()
  artistsStore.fetchArtists()
  toast.success('Artist saved successfully')
}

function openConcertForm(concert: any = null) {
  editingConcert.value = concert
  showConcertForm.value = true
}

function closeConcertForm() {
  showConcertForm.value = false
  editingConcert.value = null
}

function onConcertSaved() {
  closeConcertForm()
  concertsStore.fetchConcerts()
  toast.success('Concert saved successfully')
}

function confirmDeleteArtist(artist: any) {
  itemToDelete.value = artist
  deleteType.value = 'artist'
}

function confirmDeleteConcert(concert: any) {
  itemToDelete.value = concert
  deleteType.value = 'concert'
}

async function executeDelete() {
  if (!itemToDelete.value) return

  try {
    if (deleteType.value === 'artist') {
      await artistsStore.deleteArtist(itemToDelete.value.id)
      toast.success('Artist deleted')
    } else if (deleteType.value === 'concert') {
      await concertsStore.deleteConcert(itemToDelete.value.id)
      toast.success('Concert deleted')
    }
  } catch (error) {
    console.error('Delete failed:', error)
    toast.error('Failed to delete')
  } finally {
    itemToDelete.value = null
    deleteType.value = null
  }
}

onMounted(async () => {
  await Promise.all([
    artistsStore.fetchArtists(),
    concertsStore.fetchUpcomingConcerts()
  ])
})
</script>
