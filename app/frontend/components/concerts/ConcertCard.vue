<template>
  <Card class="p-6 hover:bg-accent/50 transition-all">
    <div class="flex flex-col md:flex-row gap-6">
      <!-- Date Badge -->
      <div class="flex-shrink-0 bg-primary rounded-lg p-4 text-center w-24">
        <div class="text-3xl font-bold text-primary-foreground">{{ day }}</div>
        <div class="text-sm text-primary-foreground/80">{{ month }}</div>
        <div class="text-xs text-primary-foreground/60">{{ year }}</div>
      </div>

      <!-- Concert Info -->
      <div class="flex-1">
        <div class="flex items-start justify-between mb-2">
          <div>
            <CardTitle class="text-xl mb-1">
              {{ concert.title }}
            </CardTitle>
            <p class="text-muted-foreground text-sm">
              {{ concert.artist.name }}
            </p>
          </div>
          <Badge v-if="concert.is_upcoming" variant="secondary" class="text-green-500">
            Upcoming
          </Badge>
          <Badge v-else variant="outline" class="text-muted-foreground">
            Past
          </Badge>
        </div>

        <p v-if="concert.description" class="text-muted-foreground text-sm mb-4 line-clamp-2">
          {{ concert.description }}
        </p>

        <!-- Details -->
        <div class="space-y-2 mb-4">
          <div class="flex items-center gap-2 text-muted-foreground text-sm">
            <span>📍</span>
            <span>{{ concert.venue_name }}, {{ concert.city }}, {{ concert.country }}</span>
          </div>
          <div class="flex items-center gap-2 text-muted-foreground text-sm">
            <span>🕐</span>
            <span>{{ startTime }} - {{ endTime }}</span>
          </div>
          <div v-if="concert.price" class="flex items-center gap-2 text-muted-foreground text-sm">
            <span>💰</span>
            <span>{{ formatPrice(concert.price) }} EUR</span>
          </div>
          <div v-if="concert.distance" class="flex items-center gap-2 text-muted-foreground text-sm">
            <span>🗺️</span>
            <span>{{ concert.distance }} km away</span>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex gap-2">
          <Button v-if="concert.ticket_url" as-child size="sm">
            <a :href="concert.ticket_url" target="_blank">
              🎫 Get Tickets
            </a>
          </Button>
          <Button
            variant="outline"
            size="sm"
            @click="$emit('view-on-map', concert)"
          >
            📍 View on Map
          </Button>
        </div>
      </div>
    </div>
  </Card>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Button } from '@/components/ui/button'
import { Card, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'

interface Concert {
  id: number
  title: string
  description?: string
  starts_at: string
  ends_at: string
  venue_name: string
  city: string
  country: string
  price?: number
  distance?: number
  ticket_url?: string
  is_upcoming?: boolean
  artist: {
    id: number
    name: string
  }
}

const props = defineProps<{
  concert: Concert
}>()

defineEmits<{
  (e: 'view-on-map', concert: Concert): void
}>()

const concertDate = computed(() => new Date(props.concert.starts_at))
const endDate = computed(() => new Date(props.concert.ends_at))

const day = computed(() => concertDate.value.getDate())
const month = computed(() => concertDate.value.toLocaleString('en-US', { month: 'short' }))
const year = computed(() => concertDate.value.getFullYear())

const startTime = computed(() => concertDate.value.toLocaleString('en-US', {
  hour: '2-digit',
  minute: '2-digit'
}))

const endTime = computed(() => endDate.value.toLocaleString('en-US', {
  hour: '2-digit',
  minute: '2-digit'
}))

function formatPrice(price: number): string {
  return Number(price).toFixed(2)
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
