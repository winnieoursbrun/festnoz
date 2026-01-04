<template>
  <Dialog :open="true" @update:open="(open) => !open && $emit('close')">
    <DialogContent class="max-w-2xl max-h-[90vh] overflow-y-auto">
      <DialogHeader>
        <DialogTitle>{{ artist ? 'Edit Artist' : 'Add Artist' }}</DialogTitle>
      </DialogHeader>

      <!-- Error Message -->
      <Alert v-if="error" variant="destructive" class="mb-6">
        <AlertDescription>{{ error }}</AlertDescription>
      </Alert>

      <!-- Form -->
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <div class="space-y-2">
          <Label for="name">Name *</Label>
          <Input
            id="name"
            v-model="formData.name"
            type="text"
            required
            placeholder="Artist name"
          />
        </div>

        <div class="space-y-2">
          <Label for="genre">Genre *</Label>
          <Select v-model="formData.genre" required>
            <SelectTrigger>
              <SelectValue placeholder="Select genre" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="Breton Folk">Breton Folk</SelectItem>
              <SelectItem value="Traditional">Traditional</SelectItem>
              <SelectItem value="Breton Traditional">Breton Traditional</SelectItem>
              <SelectItem value="World Music">World Music</SelectItem>
              <SelectItem value="Celtic Rock">Celtic Rock</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="space-y-2">
          <Label for="description">Description</Label>
          <Textarea
            id="description"
            v-model="formData.description"
            rows="4"
            placeholder="Artist description..."
          />
        </div>

        <div class="space-y-2">
          <Label for="image_url">Image URL</Label>
          <Input
            id="image_url"
            v-model="formData.image_url"
            type="url"
            placeholder="https://example.com/image.jpg"
          />
        </div>

        <div class="space-y-2">
          <Label for="country">Country</Label>
          <Input
            id="country"
            v-model="formData.country"
            type="text"
            placeholder="France"
          />
        </div>

        <div class="space-y-2">
          <Label for="website">Website</Label>
          <Input
            id="website"
            v-model="formData.website"
            type="url"
            placeholder="https://example.com"
          />
        </div>

        <!-- Buttons -->
        <DialogFooter class="gap-2">
          <Button type="button" variant="outline" @click="$emit('close')">
            Cancel
          </Button>
          <Button type="submit" :disabled="loading">
            {{ loading ? 'Saving...' : artist ? 'Update Artist' : 'Create Artist' }}
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useArtistsStore } from '../../stores/artists'
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
  id?: number
  name: string
  genre: string
  description?: string
  image_url?: string
  country?: string
  website?: string
}

const props = defineProps<{
  artist?: Artist | null
}>()

const emit = defineEmits<{
  close: []
  saved: []
}>()

const artistsStore = useArtistsStore()

const formData = ref({
  name: '',
  genre: '',
  description: '',
  image_url: '',
  country: '',
  website: ''
})

const loading = ref(false)
const error = ref<string | null>(null)

onMounted(() => {
  if (props.artist) {
    formData.value = { ...props.artist }
  }
})

async function handleSubmit() {
  loading.value = true
  error.value = null

  try {
    if (props.artist) {
      await artistsStore.updateArtist(props.artist.id!, formData.value)
    } else {
      await artistsStore.createArtist(formData.value)
    }
    emit('saved')
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to save artist'
  } finally {
    loading.value = false
  }
}
</script>
