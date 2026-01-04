<template>
  <Button
    @click="toggleFollow"
    :disabled="loading"
    :variant="isFollowing ? 'outline' : 'default'"
    :size="size"
    :class="[
      'transition-all duration-300 font-medium',
      isFollowing
        ? 'bg-green-500/10 text-green-400 border-green-500/30 hover:bg-green-500/20 hover:border-green-500/50'
        : 'hover:scale-105'
    ]"
  >
    <template v-if="loading">
      <Loader2 class="w-4 h-4 animate-spin" />
    </template>
    <template v-else-if="isFollowing">
      <Heart class="w-4 h-4 mr-1.5 fill-green-400" />
      Following
    </template>
    <template v-else>
      <Heart class="w-4 h-4 mr-1.5" />
      Follow
    </template>
  </Button>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useArtistsStore } from '../../stores/artists'
import { useAuthStore } from '../../stores/auth'
import { Button } from '@/components/ui/button'
import { Heart, Loader2 } from 'lucide-vue-next'
import { toast } from 'vue-sonner'

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
  if (!authStore.isAuthenticated) {
    toast.error('Please sign in to follow artists')
    return
  }

  loading.value = true
  try {
    if (isFollowing.value) {
      await artistsStore.unfollowArtist(props.artistId)
      toast.success('Unfollowed artist')
    } else {
      await artistsStore.followArtist(props.artistId)
      toast.success('Now following artist!')
    }
  } catch (error) {
    console.error('Follow toggle error:', error)
    toast.error('Something went wrong')
  } finally {
    loading.value = false
  }
}
</script>
