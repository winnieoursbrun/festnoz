<template>
  <Dialog :open="true" @update:open="(open) => !open && $emit('close')">
    <DialogContent class="max-w-2xl max-h-[90vh] overflow-y-auto">
      <DialogHeader>
        <DialogTitle>{{ user ? 'Edit User' : 'Add User' }}</DialogTitle>
      </DialogHeader>

      <!-- Error Message -->
      <Alert v-if="error" variant="destructive" class="mb-6">
        <AlertDescription>{{ error }}</AlertDescription>
      </Alert>

      <!-- Form -->
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <div class="space-y-2">
          <Label for="username">Username *</Label>
          <Input
            id="username"
            v-model="formData.username"
            type="text"
            required
            placeholder="Username (3-30 characters)"
            :disabled="!!user"
          />
          <p class="text-xs text-muted-foreground">
            Username cannot be changed after creation
          </p>
        </div>

        <div class="space-y-2">
          <Label for="email">Email *</Label>
          <Input
            id="email"
            v-model="formData.email"
            type="email"
            required
            placeholder="user@example.com"
          />
        </div>

        <div v-if="!user" class="space-y-2">
          <Label for="password">Password *</Label>
          <Input
            id="password"
            v-model="formData.password"
            type="password"
            :required="!user"
            placeholder="Enter password"
            autocomplete="new-password"
          />
          <p class="text-xs text-muted-foreground">
            Minimum 6 characters
          </p>
        </div>

        <div v-else class="space-y-2">
          <Label for="password">New Password (optional)</Label>
          <Input
            id="password"
            v-model="formData.password"
            type="password"
            placeholder="Leave blank to keep current password"
            autocomplete="new-password"
          />
          <p class="text-xs text-muted-foreground">
            Only fill if you want to change the password
          </p>
        </div>

        <div class="flex items-center space-x-2">
          <Checkbox
            id="admin"
            v-model="formData.admin"
          />
          <label
            for="admin"
            class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 cursor-pointer"
          >
            Administrator (Current: {{ formData.admin }})
          </label>
        </div>

        <div v-if="user" class="rounded-lg border border-border/50 p-4 space-y-2">
          <h4 class="text-sm font-medium">Account Information</h4>
          <div class="grid grid-cols-2 gap-2 text-sm">
            <div class="text-muted-foreground">Login Provider:</div>
            <div>{{ user.provider || 'Email' }}</div>
            <div class="text-muted-foreground">Followed Artists:</div>
            <div>{{ user.followed_artists_count || 0 }}</div>
            <div class="text-muted-foreground">Sign In Count:</div>
            <div>{{ user.sign_in_count || 0 }}</div>
            <div class="text-muted-foreground">Last Sign In:</div>
            <div>{{ user.last_sign_in_at ? formatDate(user.last_sign_in_at) : 'Never' }}</div>
          </div>
        </div>

        <!-- Buttons -->
        <DialogFooter class="gap-2">
          <Button type="button" variant="outline" @click="$emit('close')">
            Cancel
          </Button>
          <Button type="submit" :disabled="loading">
            {{ loading ? 'Saving...' : user ? 'Update User' : 'Create User' }}
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useUsersStore } from '../../stores/users'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Checkbox } from '@/components/ui/checkbox'
import { Alert, AlertDescription } from '@/components/ui/alert'
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle
} from '@/components/ui/dialog'
import { formatDate as formatDateUtil } from '@/lib/utils'

interface User {
  id?: number
  username: string
  email: string
  admin: boolean
  provider?: string
  followed_artists_count?: number
  sign_in_count?: number
  last_sign_in_at?: string
}

const props = defineProps<{
  user?: User | null
}>()

const emit = defineEmits<{
  close: []
  saved: []
}>()

const usersStore = useUsersStore()

const formData = ref({
  username: '',
  email: '',
  password: '',
  admin: false
})

const loading = ref(false)
const error = ref<string | null>(null)

function formatDate(dateString: string): string {
  return formatDateUtil(dateString)
}

onMounted(() => {
  if (props.user) {
    formData.value = {
      username: props.user.username,
      email: props.user.email,
      password: '',
      admin: props.user.admin
    }
  }
})

async function handleSubmit() {
  loading.value = true
  error.value = null

  try {
    const payload: any = {
      username: formData.value.username,
      email: formData.value.email,
      admin: formData.value.admin
    }

    // Only include password if it's provided
    if (formData.value.password) {
      payload.password = formData.value.password
    }

    console.log('Submitting user payload:', payload)

    if (props.user) {
      await usersStore.updateUser(props.user.id!, payload)
    } else {
      if (!formData.value.password) {
        error.value = 'Password is required for new users'
        loading.value = false
        return
      }
      await usersStore.createUser(payload)
    }
    emit('saved')
  } catch (err: any) {
    error.value = err.response?.data?.errors?.join(', ') || usersStore.error || 'Failed to save user'
  } finally {
    loading.value = false
  }
}
</script>
