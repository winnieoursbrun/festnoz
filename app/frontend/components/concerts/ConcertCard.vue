<template>
  <Card class="group overflow-hidden hover-lift bg-card/50 border-border/50 transition-all duration-300">
    <div class="flex flex-col md:flex-row">
      <!-- Date Badge -->
      <div class="flex-shrink-0 bg-gradient-to-br from-primary to-purple-600 p-4 md:p-5 flex md:flex-col items-center md:items-center justify-center gap-3 md:gap-1 md:w-24">
        <div class="text-3xl md:text-4xl font-bold text-white">{{ day }}</div>
        <div class="flex md:flex-col items-center gap-2 md:gap-0">
          <div class="text-sm font-medium text-white/90">{{ month }}</div>
          <div class="text-xs text-white/70">{{ year }}</div>
        </div>
      </div>

      <!-- Concert Info -->
      <CardContent class="flex-1 p-4 md:p-5">
        <div class="flex items-start justify-between gap-3 mb-3">
          <div class="min-w-0 flex-1">
            <CardTitle class="text-lg font-semibold leading-tight line-clamp-1 group-hover:text-primary transition-colors">
              {{ concert.title }}
            </CardTitle>
            <p class="text-muted-foreground text-sm mt-1 flex items-center gap-1.5">
              <Music class="w-3.5 h-3.5" />
              {{ concert.artist?.name }}
            </p>
          </div>
          <Badge
            v-if="concert.is_upcoming"
            class="flex-shrink-0 bg-green-500/10 text-green-400 border-green-500/20"
          >
            <Sparkles class="w-3 h-3 mr-1" />
            Upcoming
          </Badge>
          <Badge
            v-else
            variant="outline"
            class="flex-shrink-0 border-border/50 text-muted-foreground"
          >
            Past
          </Badge>
        </div>

        <p v-if="concert.description" class="text-muted-foreground text-sm mb-4 line-clamp-2 leading-relaxed">
          {{ concert.description }}
        </p>

        <!-- Details -->
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 mb-4">
          <div class="flex items-center gap-2 text-sm">
            <div class="p-1.5 rounded-md bg-purple-500/10">
              <MapPin class="w-3.5 h-3.5 text-purple-500" />
            </div>
            <span class="text-muted-foreground truncate">{{ concert.venue_name }}, {{ concert.city }}</span>
          </div>
          <div class="flex items-center gap-2 text-sm">
            <div class="p-1.5 rounded-md bg-primary/10">
              <Clock class="w-3.5 h-3.5 text-primary" />
            </div>
            <span class="text-muted-foreground">{{ startTime }} - {{ endTime }}</span>
          </div>
          <div v-if="concert.price" class="flex items-center gap-2 text-sm">
            <div class="p-1.5 rounded-md bg-green-500/10">
              <Banknote class="w-3.5 h-3.5 text-green-500" />
            </div>
            <span class="text-muted-foreground">{{ formatPrice(concert.price) }} EUR</span>
          </div>
          <div v-if="concert.distance" class="flex items-center gap-2 text-sm">
            <div class="p-1.5 rounded-md bg-pink-500/10">
              <Navigation class="w-3.5 h-3.5 text-pink-500" />
            </div>
            <span class="text-muted-foreground">{{ concert.distance }} km away</span>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex gap-2">
          <Button v-if="ticketUrl" as-child size="sm" :class="isTicketmaster ? 'bg-[#026CDF] hover:bg-[#025BB5] text-white font-medium' : 'font-medium'">
            <a :href="ticketUrl" target="_blank" class="flex items-center gap-2">
              <Ticket class="w-4 h-4" />
              {{ isTicketmaster ? 'Book on Ticketmaster' : 'Get Tickets' }}
            </a>
          </Button>
          <Button
            variant="outline"
            size="sm"
            @click="$emit('view-on-map', concert)"
            class="bg-background/50 font-medium group/btn"
          >
            <MapPin class="w-4 h-4 mr-2 group-hover/btn:text-primary transition-colors" />
            View on Map
          </Button>
        </div>
      </CardContent>
    </div>
  </Card>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Music, MapPin, Clock, Banknote, Navigation, Ticket, Sparkles } from 'lucide-vue-next'

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
  ticketmaster_id?: string
  ticketmaster_url?: string
  is_upcoming?: boolean
  artist?: {
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

// Prioritize Ticketmaster URL over generic ticket URL
const ticketUrl = computed(() => {
  return props.concert.ticketmaster_url || props.concert.ticket_url
})

const isTicketmaster = computed(() => {
  return Boolean(props.concert.ticketmaster_url)
})

function formatPrice(price: number): string {
  return Number(price).toFixed(2)
}
</script>

<style scoped>
.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
