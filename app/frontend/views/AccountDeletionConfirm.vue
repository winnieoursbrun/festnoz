<template>
  <div class="min-h-screen flex items-center justify-center p-6">
    <Card class="w-full max-w-lg">
      <CardHeader>
        <CardTitle>Confirm account deletion</CardTitle>
        <CardDescription>This action is permanent and cannot be undone.</CardDescription>
      </CardHeader>
      <CardContent class="space-y-4">
        <p v-if="!token" class="text-sm text-destructive">Invalid confirmation link. Missing token.</p>
        <p v-else class="text-sm text-muted-foreground">
          Click confirm to permanently delete your account.
        </p>

        <div class="flex gap-2">
          <Button variant="destructive" :disabled="!token || deleting || deleted" @click="confirmDeletion">
            {{ deleting ? 'Deleting...' : deleted ? 'Account deleted' : 'Confirm deletion' }}
          </Button>
          <Button variant="outline" @click="goHome">Cancel</Button>
        </div>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'
import api from '../services/api'
import { toast } from 'vue-sonner'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

const route = useRoute()

const deleting = ref(false)
const deleted = ref(false)

const token = computed(() => (route.query.token as string) || '')

async function confirmDeletion() {
  deleting.value = true
  try {
    await api.post('/api/v1/account/deletion/confirm', { token: token.value })
    localStorage.removeItem('authToken')
    deleted.value = true
    toast.success('Your account has been deleted')

    setTimeout(() => {
      goHome()
    }, 1200)
  } catch (error: any) {
    const message = error?.response?.data?.error || 'Invalid or expired confirmation link'
    toast.error(message)
  } finally {
    deleting.value = false
  }
}

function goHome() {
  globalThis.location.href = '/'
}
</script>
