<template>
  <Dialog :open="true" @update:open="(open) => !open && $emit('close')">
    <DialogContent class="max-w-2xl max-h-[90vh] overflow-y-auto">
      <DialogHeader>
        <DialogTitle>{{ concert ? 'Edit Concert' : 'Add Concert' }}</DialogTitle>
      </DialogHeader>

      <!-- Error Message -->
      <Alert v-if="error" variant="destructive" class="mb-6">
        <AlertDescription>{{ error }}</AlertDescription>
      </Alert>

      <!-- Form -->
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <div class="space-y-2">
          <Label for="artist">Artist *</Label>
          <Select v-model="formData.artist_id" required>
            <SelectTrigger>
              <SelectValue placeholder="Select artist" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem v-for="artist in artists" :key="artist.id" :value="String(artist.id)">
                {{ artist.name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="space-y-2">
          <Label for="title">Title *</Label>
          <Input
            id="title"
            v-model="formData.title"
            type="text"
            required
            placeholder="Concert title"
          />
        </div>

        <div class="space-y-2">
          <Label for="description">Description</Label>
          <Textarea
            id="description"
            v-model="formData.description"
            rows="3"
            placeholder="Concert description..."
          />
        </div>

        <!-- Date and Time -->
        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <Label for="starts_at">Starts At *</Label>
            <Input
              id="starts_at"
              v-model="formData.starts_at"
              type="datetime-local"
              required
            />
          </div>
          <div class="space-y-2">
            <Label for="ends_at">Ends At *</Label>
            <Input
              id="ends_at"
              v-model="formData.ends_at"
              type="datetime-local"
              required
            />
          </div>
        </div>

        <!-- Location -->
        <div class="space-y-2">
          <Label for="venue_name">Venue Name *</Label>
          <Input
            id="venue_name"
            v-model="formData.venue_name"
            type="text"
            required
            placeholder="Venue name"
          />
        </div>

        <div class="space-y-2">
          <Label for="address">Address</Label>
          <Input
            id="address"
            v-model="formData.address"
            type="text"
            placeholder="Street address"
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <Label for="city">City *</Label>
            <Input
              id="city"
              v-model="formData.city"
              type="text"
              required
              placeholder="City"
            />
          </div>
          <div class="space-y-2">
            <Label for="country">Country *</Label>
            <Input
              id="country"
              v-model="formData.country"
              type="text"
              required
              placeholder="Country"
            />
          </div>
        </div>

        <!-- Coordinates -->
        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <Label for="latitude">Latitude *</Label>
            <Input
              id="latitude"
              v-model.number="formData.latitude"
              type="number"
              step="0.000001"
              required
              placeholder="48.8566"
            />
          </div>
          <div class="space-y-2">
            <Label for="longitude">Longitude *</Label>
            <Input
              id="longitude"
              v-model.number="formData.longitude"
              type="number"
              step="0.000001"
              required
              placeholder="2.3522"
            />
          </div>
        </div>

        <!-- Price and Ticket URL -->
        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <Label for="price">Price (EUR)</Label>
            <Input
              id="price"
              v-model.number="formData.price"
              type="number"
              step="0.01"
              placeholder="25.00"
            />
          </div>
          <div class="space-y-2">
            <Label for="ticket_url">Ticket URL</Label>
            <Input
              id="ticket_url"
              v-model="formData.ticket_url"
              type="url"
              placeholder="https://tickets.example.com"
            />
          </div>
        </div>

        <!-- Buttons -->
        <DialogFooter class="gap-2">
          <Button type="button" variant="outline" @click="$emit('close')">
            Cancel
          </Button>
          <Button type="submit" :disabled="loading">
            {{ loading ? 'Saving...' : concert ? 'Update Concert' : 'Create Concert' }}
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useConcertsStore } from '../../stores/concerts'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Alert, AlertDescription } from '@/components/ui/alert'
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle
} from '@/components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select'

interface Artist {
  id: number
  name: string
}

interface Concert {
  id?: number
  title: string
  description?: string
  starts_at: string
  ends_at: string
  venue_name: string
  address?: string
  city: string
  country: string
  latitude: number
  longitude: number
  price?: number
  ticket_url?: string
  artist: Artist
}

const props = defineProps<{
  concert?: Concert | null
  artists: Artist[]
}>()

const emit = defineEmits<{
  close: []
  saved: []
}>()

const concertsStore = useConcertsStore()

const formData = ref({
  artist_id: '',
  title: '',
  description: '',
  starts_at: '',
  ends_at: '',
  venue_name: '',
  address: '',
  city: '',
  country: '',
  latitude: null as number | null,
  longitude: null as number | null,
  price: null as number | null,
  ticket_url: ''
})

const loading = ref(false)
const error = ref<string | null>(null)

onMounted(() => {
  if (props.concert) {
    formData.value = {
      artist_id: String(props.concert.artist.id),
      title: props.concert.title,
      description: props.concert.description || '',
      starts_at: formatDatetime(props.concert.starts_at),
      ends_at: formatDatetime(props.concert.ends_at),
      venue_name: props.concert.venue_name,
      address: props.concert.address || '',
      city: props.concert.city,
      country: props.concert.country,
      latitude: props.concert.latitude,
      longitude: props.concert.longitude,
      price: props.concert.price || null,
      ticket_url: props.concert.ticket_url || ''
    }
  }
})

function formatDatetime(datetime: string): string {
  const date = new Date(datetime)
  return date.toISOString().slice(0, 16)
}

async function handleSubmit() {
  loading.value = true
  error.value = null

  try {
    const data = {
      ...formData.value,
      artist_id: Number(formData.value.artist_id)
    }
    if (props.concert) {
      await concertsStore.updateConcert(props.concert.id!, data)
    } else {
      await concertsStore.createConcert(data)
    }
    emit('saved')
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to save concert'
  } finally {
    loading.value = false
  }
}
</script>
