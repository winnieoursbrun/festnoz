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
          <button
            @click="activeTab = 'users'"
            :class="[
              'w-full flex items-center gap-3 px-4 py-3 rounded-lg text-left transition-all',
              activeTab === 'users'
                ? 'bg-primary text-primary-foreground'
                : 'hover:bg-accent text-muted-foreground hover:text-foreground'
            ]"
          >
            <Users class="w-5 h-5" />
            <span class="font-medium">Users</span>
            <Badge variant="secondary" class="ml-auto text-xs">{{ usersStore.users.length }}</Badge>
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
          <div class="flex items-center justify-between">
            <span class="text-sm text-muted-foreground">Total Users</span>
            <span class="font-bold text-gradient-purple">{{ usersStore.users.length }}</span>
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
          <Button
            @click="activeTab = 'users'"
            :variant="activeTab === 'users' ? 'default' : 'outline'"
            size="sm"
            class="flex-1"
          >
            <Users class="w-4 h-4 mr-2" />
            Users
          </Button>
        </div>
      </div>

      <div class="p-6 lg:p-8">
        <ArtistsTab
          v-if="activeTab === 'artists'"
          @edit-artist="openArtistForm"
          @delete-artist="confirmDeleteArtist"
        />
        <ConcertsTab
          v-if="activeTab === 'concerts'"
          @edit-concert="openConcertForm"
          @delete-concert="confirmDeleteConcert"
        />
        <UsersTab
          v-if="activeTab === 'users'"
          @edit-user="openUserForm"
          @delete-user="confirmDeleteUser"
        />
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

    <!-- User Form Dialog -->
    <UserForm
      v-if="showUserForm"
      :user="editingUser"
      @close="closeUserForm"
      @saved="onUserSaved"
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
            <span class="font-semibold text-foreground">{{ itemToDelete?.name || itemToDelete?.title || itemToDelete?.username }}</span>.
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
import { useArtistsStore } from '../../stores/artists'
import { useConcertsStore } from '../../stores/concerts'
import { useUsersStore } from '../../stores/users'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
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
import ArtistForm from '../../components/artists/ArtistForm.vue'
import ConcertForm from '../../components/concerts/ConcertForm.vue'
import UserForm from '../../components/users/UserForm.vue'
import ArtistsTab from './ArtistsTab.vue'
import ConcertsTab from './ConcertsTab.vue'
import UsersTab from './UsersTab.vue'
import { Shield, Users, Ticket, Trash2, AlertTriangle } from 'lucide-vue-next'
import { toast } from 'vue-sonner'

const artistsStore = useArtistsStore()
const concertsStore = useConcertsStore()
const usersStore = useUsersStore()

const activeTab = ref('artists')
const showArtistForm = ref(false)
const showConcertForm = ref(false)
const showUserForm = ref(false)
const editingArtist = ref<any>(null)
const editingConcert = ref<any>(null)
const editingUser = ref<any>(null)
const itemToDelete = ref<any>(null)
const deleteType = ref<'artist' | 'concert' | 'user' | null>(null)

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

function openUserForm(user: any = null) {
  editingUser.value = user
  showUserForm.value = true
}

function closeUserForm() {
  showUserForm.value = false
  editingUser.value = null
}

function onUserSaved() {
  closeUserForm()
  usersStore.fetchUsers()
  toast.success('User saved successfully')
}

function confirmDeleteUser(user: any) {
  itemToDelete.value = user
  deleteType.value = 'user'
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
    } else if (deleteType.value === 'user') {
      await usersStore.deleteUser(itemToDelete.value.id)
      toast.success('User deleted')
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
    concertsStore.fetchUpcomingConcerts(),
    usersStore.fetchUsers()
  ])
})
</script>
