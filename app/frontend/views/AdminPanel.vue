<template>
  <div class="min-h-screen bg-gradient-to-b from-background to-muted/30">
    <div class="container mx-auto px-4 py-8">
      <!-- Header -->
      <div class="mb-8">
        <div class="flex items-center gap-3 mb-2">
          <Badge variant="outline" class="text-amber-500 border-amber-500/50">Admin</Badge>
        </div>
        <h1 class="text-4xl font-bold mb-2">Admin Panel</h1>
        <p class="text-lg text-muted-foreground">Manage artists and concerts</p>
      </div>

      <!-- Tabs -->
      <Tabs v-model="activeTab" class="space-y-6">
        <TabsList class="grid w-full max-w-md grid-cols-2">
          <TabsTrigger value="artists" class="gap-2">
            <span>🎭</span> Artists
          </TabsTrigger>
          <TabsTrigger value="concerts" class="gap-2">
            <span>🎫</span> Concerts
          </TabsTrigger>
        </TabsList>

        <!-- Artists Tab -->
        <TabsContent value="artists" class="space-y-6">
          <Card>
            <CardHeader>
              <div class="flex items-center justify-between">
                <div>
                  <CardTitle>Artists</CardTitle>
                  <CardDescription>
                    {{ artistsStore.artists.length }} artists registered
                  </CardDescription>
                </div>
                <Button @click="openArtistForm()">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mr-2"><path d="M5 12h14"/><path d="M12 5v14"/></svg>
                  Add Artist
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Genre</TableHead>
                    <TableHead class="text-center">Followers</TableHead>
                    <TableHead class="text-center">Concerts</TableHead>
                    <TableHead class="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  <TableRow v-for="artist in artistsStore.artists" :key="artist.id">
                    <TableCell>
                      <div class="flex items-center gap-3">
                        <Avatar class="h-8 w-8">
                          <AvatarImage v-if="artist.thumbnail_url || artist.image_url" :src="artist.thumbnail_url || artist.image_url" />
                          <AvatarFallback>{{ artist.name.charAt(0) }}</AvatarFallback>
                        </Avatar>
                        <span class="font-medium">{{ artist.name }}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="secondary">{{ artist.genre || 'N/A' }}</Badge>
                    </TableCell>
                    <TableCell class="text-center">{{ artist.followers_count || 0 }}</TableCell>
                    <TableCell class="text-center">{{ artist.upcoming_concerts_count || 0 }}</TableCell>
                    <TableCell class="text-right">
                      <div class="flex justify-end gap-2">
                        <Button variant="ghost" size="sm" @click="openArtistForm(artist)">
                          Edit
                        </Button>
                        <Button variant="ghost" size="sm" class="text-destructive hover:text-destructive" @click="confirmDeleteArtist(artist)">
                          Delete
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <!-- Concerts Tab -->
        <TabsContent value="concerts" class="space-y-6">
          <Card>
            <CardHeader>
              <div class="flex items-center justify-between">
                <div>
                  <CardTitle>Concerts</CardTitle>
                  <CardDescription>
                    {{ concertsStore.concerts.length }} concerts scheduled
                  </CardDescription>
                </div>
                <Button @click="openConcertForm()">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mr-2"><path d="M5 12h14"/><path d="M12 5v14"/></svg>
                  Add Concert
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Title</TableHead>
                    <TableHead>Artist</TableHead>
                    <TableHead>Date</TableHead>
                    <TableHead>Location</TableHead>
                    <TableHead class="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  <TableRow v-for="concert in concertsStore.concerts" :key="concert.id">
                    <TableCell class="font-medium">{{ concert.title }}</TableCell>
                    <TableCell>{{ concert.artist?.name || 'N/A' }}</TableCell>
                    <TableCell>
                      <div class="text-sm">
                        <div>{{ formatDate(concert.starts_at) }}</div>
                        <div class="text-muted-foreground">{{ formatTime(concert.starts_at) }}</div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div class="text-sm">
                        <div>{{ concert.venue_name }}</div>
                        <div class="text-muted-foreground">{{ concert.city }}</div>
                      </div>
                    </TableCell>
                    <TableCell class="text-right">
                      <div class="flex justify-end gap-2">
                        <Button variant="ghost" size="sm" @click="openConcertForm(concert)">
                          Edit
                        </Button>
                        <Button variant="ghost" size="sm" class="text-destructive hover:text-destructive" @click="confirmDeleteConcert(concert)">
                          Delete
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>

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
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Are you sure?</AlertDialogTitle>
          <AlertDialogDescription>
            This action cannot be undone. This will permanently delete
            <span class="font-semibold">{{ itemToDelete?.name || itemToDelete?.title }}</span>.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel @click="itemToDelete = null">Cancel</AlertDialogCancel>
          <AlertDialogAction class="bg-destructive text-destructive-foreground hover:bg-destructive/90" @click="executeDelete">
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from '@/components/ui/table'
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
    } else if (deleteType.value === 'concert') {
      await concertsStore.deleteConcert(itemToDelete.value.id)
    }
  } catch (error) {
    console.error('Delete failed:', error)
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
