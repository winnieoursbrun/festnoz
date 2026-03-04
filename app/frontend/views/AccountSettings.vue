<template>
  <div class="min-h-screen">
    <div class="container mx-auto px-4 lg:px-8 py-8 lg:py-12 max-w-3xl space-y-6">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Account settings</h1>
        <p class="text-muted-foreground mt-1">Manage your profile, password, music accounts and account deletion.</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Profile</CardTitle>
          <CardDescription>Change your username.</CardDescription>
        </CardHeader>
        <CardContent class="space-y-4">
          <div class="space-y-2">
            <Label for="email">Email</Label>
            <Input id="email" :model-value="settings.email" disabled />
          </div>
          <div class="space-y-2">
            <Label for="username">Username</Label>
            <Input id="username" v-model="profileForm.username" />
          </div>
          <Button :disabled="savingProfile || loading" @click="updateProfile">
            {{ savingProfile ? 'Saving...' : 'Save profile' }}
          </Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Password</CardTitle>
          <CardDescription>Change your password and receive a security notification email.</CardDescription>
        </CardHeader>
        <CardContent class="space-y-4">
          <div class="space-y-2">
            <Label for="current-password">Current password</Label>
            <Input id="current-password" v-model="passwordForm.currentPassword" type="password" />
          </div>
          <div class="space-y-2">
            <Label for="new-password">New password</Label>
            <Input id="new-password" v-model="passwordForm.password" type="password" />
          </div>
          <div class="space-y-2">
            <Label for="new-password-confirmation">Confirm new password</Label>
            <Input id="new-password-confirmation" v-model="passwordForm.passwordConfirmation" type="password" />
          </div>
          <Button :disabled="savingPassword || loading" @click="updatePassword">
            {{ savingPassword ? 'Updating...' : 'Update password' }}
          </Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Music accounts</CardTitle>
          <CardDescription>Connect or disconnect your music providers.</CardDescription>
        </CardHeader>
        <CardContent class="flex items-center justify-between gap-4">
          <div>
            <p class="font-medium">Spotify</p>
            <p class="text-sm text-muted-foreground">
              {{ settings.spotifyConnected ? 'Connected' : 'Not connected' }}
            </p>
          </div>
          <div class="flex gap-2">
            <Button v-if="!settings.spotifyConnected" @click="connectSpotify">Connect Spotify</Button>
            <Button v-else variant="outline" :disabled="disconnectingSpotify" @click="disconnectSpotify">
              {{ disconnectingSpotify ? 'Disconnecting...' : 'Disconnect Spotify' }}
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card class="border-destructive/40">
        <CardHeader>
          <CardTitle class="text-destructive">Danger zone</CardTitle>
          <CardDescription>Delete your account permanently after email confirmation.</CardDescription>
        </CardHeader>
        <CardContent class="space-y-3">
          <p class="text-sm text-muted-foreground">
            We will send a confirmation link to your email. Your account is deleted only after clicking that link.
          </p>
          <Button variant="destructive" :disabled="requestingDeletion" @click="openDeleteDialog">
            Delete my account
          </Button>
        </CardContent>
      </Card>
    </div>

    <!-- Delete account confirmation dialog -->
    <Dialog v-model:open="showDeleteDialog">
      <DialogContent class="sm:max-w-md">
        <DialogHeader>
          <DialogTitle class="text-destructive">Delete account</DialogTitle>
          <DialogDescription>
            This action is permanent and cannot be undone. All your data will be erased.
            <br />
            Type your username <span class="font-semibold text-foreground">{{ settings.username }}</span> to confirm.
          </DialogDescription>
        </DialogHeader>
        <div class="space-y-2 py-2">
          <Label for="confirm-username">Username</Label>
          <Input
            id="confirm-username"
            v-model="deleteConfirmUsername"
            placeholder="Enter your username"
            autocomplete="off"
          />
        </div>
        <DialogFooter class="gap-2">
          <Button variant="outline" @click="closeDeleteDialog">Cancel</Button>
          <Button
            variant="destructive"
            :disabled="deleteConfirmUsername !== settings.username || requestingDeletion"
            @click="requestDeletion"
          >
            {{ requestingDeletion ? 'Sending...' : 'Delete my account' }}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { useAuthStore } from '../stores/auth'
import { backendUrl } from '@/config'
import api from '../services/api'
import { toast } from 'vue-sonner'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

const authStore = useAuthStore()

const loading = ref(true)
const savingProfile = ref(false)
const savingPassword = ref(false)
const disconnectingSpotify = ref(false)
const requestingDeletion = ref(false)
const showDeleteDialog = ref(false)
const deleteConfirmUsername = ref('')

function openDeleteDialog() {
  showDeleteDialog.value = true
}

const settings = ref({
  email: '',
  username: '',
  spotifyConnected: false
})

const profileForm = ref({
  username: ''
})

const passwordForm = ref({
  currentPassword: '',
  password: '',
  passwordConfirmation: ''
})

onMounted(async () => {
  await fetchSettings()
})

async function fetchSettings() {
  loading.value = true
  try {
    const response = await api.get('/api/v1/account/settings')
    const user = response.data.user

    settings.value = {
      email: user.email,
      username: user.username,
      spotifyConnected: !!user.music_accounts?.spotify?.connected
    }
    profileForm.value.username = user.username
  } catch (error: any) {
    console.error(error)
    toast.error('Failed to load account settings')
  } finally {
    loading.value = false
  }
}

async function updateProfile() {
  savingProfile.value = true
  try {
    const response = await api.patch('/api/v1/account/settings/profile', {
      user: {
        username: profileForm.value.username
      }
    })

    const user = response.data.user
    settings.value.username = user.username
    authStore.user = { ...authStore.user, username: user.username }
    toast.success('Username updated')
  } catch (error: any) {
    const message = error?.response?.data?.errors?.[0] || 'Failed to update username'
    toast.error(message)
  } finally {
    savingProfile.value = false
  }
}

async function updatePassword() {
  if (passwordForm.value.password !== passwordForm.value.passwordConfirmation) {
    toast.error('Password confirmation does not match')
    return
  }

  savingPassword.value = true
  try {
    await api.patch('/api/v1/account/settings/password', {
      user: {
        current_password: passwordForm.value.currentPassword,
        password: passwordForm.value.password,
        password_confirmation: passwordForm.value.passwordConfirmation
      }
    })

    passwordForm.value.currentPassword = ''
    passwordForm.value.password = ''
    passwordForm.value.passwordConfirmation = ''
    toast.success('Password updated. Check your email for the security notification.')
  } catch (error: any) {
    const message = error?.response?.data?.errors?.[0] || 'Failed to update password'
    toast.error(message)
  } finally {
    savingPassword.value = false
  }
}

function connectSpotify() {
  globalThis.location.href = `${backendUrl}/api/auth/spotify?origin=/settings`
}

async function disconnectSpotify() {
  disconnectingSpotify.value = true
  try {
    const response = await api.delete('/api/v1/account/settings/music_accounts/spotify')
    settings.value.spotifyConnected = !!response.data.user.music_accounts?.spotify?.connected

    if (authStore.user) {
      authStore.user = {
        ...authStore.user,
        spotify_connected: settings.value.spotifyConnected,
        provider: response.data.user.provider
      }
    }

    toast.success('Spotify disconnected')
  } catch (error: any) {
    console.error(error)
    toast.error('Failed to disconnect Spotify')
  } finally {
    disconnectingSpotify.value = false
  }
}

function closeDeleteDialog() {
  showDeleteDialog.value = false
  deleteConfirmUsername.value = ''
}

watch(showDeleteDialog, (val) => {
  if (!val) deleteConfirmUsername.value = ''
})

async function requestDeletion() {
  requestingDeletion.value = true
  try {
    await api.post('/api/v1/account/deletion/request')
    toast.success('Confirmation email sent. Check your inbox to complete account deletion.')
    closeDeleteDialog()
  } catch (error: any) {
    console.error(error)
    toast.error('Failed to request account deletion')
  } finally {
    requestingDeletion.value = false
  }
}
</script>
