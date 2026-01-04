<template>
  <footer class="border-t border-border/50 mt-auto bg-card/50">
    <div class="container mx-auto px-4 lg:px-8 py-8">
      <div class="flex flex-col md:flex-row items-center justify-between gap-4">
        <!-- Logo & Copyright -->
        <div class="flex items-center gap-3">
          <div class="p-2 rounded-lg bg-primary/10">
            <Music2 class="w-4 h-4 text-primary" />
          </div>
          <div>
            <p class="text-sm font-medium text-foreground">FestNoz</p>
            <p class="text-xs text-muted-foreground">Track Artists, Catch Them Live</p>
          </div>
        </div>

        <!-- Made in Brittany -->
        <div class="flex items-center gap-2 text-sm text-muted-foreground">
          <span>Made with</span>
          <Heart class="w-4 h-4 text-destructive fill-destructive animate-pulse" />
          <span>in Brittany</span>
        </div>

        <!-- Year -->
        <p class="text-xs text-muted-foreground">
          &copy; {{ currentYear }} FestNoz
        </p>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Music2, Heart } from 'lucide-vue-next'

const currentYear = computed(() => new Date().getFullYear())
</script>
