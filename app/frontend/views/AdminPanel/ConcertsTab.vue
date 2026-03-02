<template>
  <div v-motion-fade-up>
    <Card class="bg-card/50 border-border/50">
      <CardHeader>
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Ticket class="w-5 h-5 text-purple-500" />
              Concerts
            </CardTitle>
            <CardDescription class="mt-1">
              {{ concertsStore.concerts.length }} concerts scheduled
            </CardDescription>
          </div>
          <Button @click="$emit('edit-concert', null)" class="font-medium">
            <Plus class="w-4 h-4 mr-2" />
            Add Concert
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        <!-- Loading State -->
        <div v-if="concertsStore.loading" class="space-y-4">
          <div v-for="i in 5" :key="i" class="flex items-center gap-4 p-4 rounded-lg bg-background/50">
            <Skeleton class="w-16 h-16 rounded-lg" />
            <div class="flex-1 space-y-2">
              <Skeleton class="h-4 w-1/2" />
              <Skeleton class="h-3 w-1/3" />
            </div>
          </div>
        </div>

        <!-- Table -->
        <div v-else class="rounded-lg border border-border/50 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow class="bg-muted/30 hover:bg-muted/30">
                <TableHead>Concert</TableHead>
                <TableHead>Artist</TableHead>
                <TableHead>Date & Time</TableHead>
                <TableHead>Location</TableHead>
                <TableHead class="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow
                v-for="concert in concertsStore.concerts"
                :key="concert.id"
                class="hover:bg-accent/50 transition-colors"
              >
                <TableCell>
                  <span class="font-medium">{{ concert.title }}</span>
                </TableCell>
                <TableCell>
                  <span class="text-muted-foreground">{{ concert.artist?.name || 'N/A' }}</span>
                </TableCell>
                <TableCell>
                  <div class="flex items-center gap-2">
                    <div class="p-1.5 rounded-md bg-primary/10">
                      <Calendar class="w-3.5 h-3.5 text-primary" />
                    </div>
                    <div class="text-sm">
                      <div class="font-medium">{{ formatDate(concert.starts_at) }}</div>
                      <div class="text-muted-foreground text-xs">{{ formatTime(concert.starts_at) }}</div>
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <div class="flex items-center gap-2">
                    <div class="p-1.5 rounded-md bg-purple-500/10">
                      <MapPin class="w-3.5 h-3.5 text-purple-500" />
                    </div>
                    <div class="text-sm">
                      <div>{{ concert.venue_name }}</div>
                      <div class="text-muted-foreground text-xs">{{ concert.city }}</div>
                    </div>
                  </div>
                </TableCell>
                <TableCell class="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger as-child>
                      <Button variant="ghost" size="sm" class="h-8 w-8 p-0">
                        <MoreHorizontal class="w-4 h-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" class="w-40">
                      <DropdownMenuItem @click="$emit('edit-concert', concert)" class="cursor-pointer">
                        <Pencil class="w-4 h-4 mr-2" />
                        Edit
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem @click="$emit('delete-concert', concert)" class="cursor-pointer text-destructive focus:text-destructive">
                        <Trash2 class="w-4 h-4 mr-2" />
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { useConcertsStore } from '../../stores/concerts'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import { Ticket, Calendar, MapPin, Plus, MoreHorizontal, Pencil, Trash2 } from 'lucide-vue-next'
import { formatDate as formatDateUtil, formatTime as formatTimeUtil } from '@/lib/utils'

defineEmits<{
  'edit-concert': [concert: any]
  'delete-concert': [concert: any]
}>()

const concertsStore = useConcertsStore()

function formatDate(dateString: string): string {
  return formatDateUtil(dateString)
}

function formatTime(dateString: string): string {
  return formatTimeUtil(dateString)
}
</script>
