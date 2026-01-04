<template>
  <Button
    @click="toggleFollow"
    :disabled="loading"
    :variant="isFollowing ? 'outline' : 'default'"
    :size="size"
    :class="isFollowing ? 'text-green-500 border-green-500/50' : ''"
  >
    <span v-if="!loading">{{ isFollowing ? '✓ Following' : '+ Follow' }}</span>
    <span v-else>...</span>
  </Button>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useArtistsStore } from '../../stores/artists'
import { useAuthStore } from '../../stores/auth'
import { Button } from '@/components/ui/button'

const props = withDefaults(defineProps<{
  artistId: number
  size?: 'sm' | 'default' | 'lg'
}>(), {
  size: 'default'
})

const artistsStore = useArtistsStore()
const authStore = useAuthStore()
const loading = ref(false)

const isFollowing = computed(() => artistsStore.isFollowing(props.artistId))

async function toggleFollow() {
  if (!authStore.isAuthenticated) return

  loading.value = true
  try {
    if (isFollowing.value) {
      await artistsStore.unfollowArtist(props.artistId)
    } else {
      await artistsStore.followArtist(props.artistId)
    }
  } catch (error) {
    console.error('Follow toggle error:', error)
  } finally {
    loading.value = false
  }
}
</script>
