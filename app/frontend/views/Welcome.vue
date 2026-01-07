<template>
  <div class="relative min-h-screen overflow-hidden">
    <!-- Animated Background -->
    <div class="absolute inset-0">
      <div class="absolute inset-0 gradient-dark" />
      <div class="absolute top-0 left-1/4 w-[600px] h-[600px] gradient-glow opacity-40" />
      <div class="absolute bottom-0 right-1/4 w-[500px] h-[500px] gradient-glow opacity-30" />
      <!-- Floating decorative elements -->
      <div class="absolute top-20 left-10 w-2 h-2 rounded-full bg-primary/50 animate-float" style="animation-delay: 0s" />
      <div class="absolute top-40 right-20 w-3 h-3 rounded-full bg-purple-500/50 animate-float" style="animation-delay: 0.5s" />
      <div class="absolute bottom-40 left-1/4 w-2 h-2 rounded-full bg-pink-500/50 animate-float" style="animation-delay: 1s" />
      <div class="absolute top-1/3 right-1/3 w-4 h-4 rounded-full bg-primary/30 animate-float" style="animation-delay: 1.5s" />
    </div>

    <!-- Hero Section -->
    <div class="relative container mx-auto px-4 lg:px-8 py-20 md:py-32">
      <div class="flex flex-col items-center text-center max-w-5xl mx-auto">
        <!-- Animated Logo -->
        <div class="relative mb-10" v-motion-scale>
          <div class="absolute inset-0 bg-primary/20 blur-3xl rounded-full animate-pulse-glow" />
          <div class="relative p-6 rounded-3xl bg-card/50 border border-border/50 backdrop-blur-sm">
            <Music class="w-20 h-20 md:w-28 md:h-28 text-primary" />
          </div>
        </div>

        <!-- Title with Gradient -->
        <h1
          class="text-5xl sm:text-6xl md:text-8xl font-black tracking-tight mb-6"
          v-motion-fade-up
        >
          <span class="text-gradient">FestNoz</span>
        </h1>

        <!-- Subtitle -->
        <p
          class="text-xl sm:text-2xl md:text-3xl text-foreground font-bold mb-4"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 100 } }"
        >
          Discover Breton Music
        </p>

        <p
          class="text-base sm:text-lg md:text-xl text-muted-foreground font-medium mb-8 flex items-center gap-3 flex-wrap justify-center"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 200 } }"
        >
          <span class="flex items-center gap-2">
            <Users class="w-5 h-5 text-primary" />
            Follow Artists
          </span>
          <Separator orientation="vertical" class="h-5 hidden sm:block" />
          <span class="flex items-center gap-2">
            <MapPin class="w-5 h-5 text-purple-500" />
            Find Concerts
          </span>
          <Separator orientation="vertical" class="h-5 hidden sm:block" />
          <span class="flex items-center gap-2">
            <Ticket class="w-5 h-5 text-pink-500" />
            Never Miss a Show
          </span>
        </p>

        <!-- Description -->
        <p
          class="text-base md:text-lg text-muted-foreground max-w-2xl mb-10 leading-relaxed"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 300 } }"
        >
          Your gateway to the vibrant world of Breton music. Track your favorite artists,
          discover upcoming concerts on an interactive map, and immerse yourself in the
          rich traditions of Celtic culture.
        </p>

        <!-- CTA Buttons -->
        <div
          class="flex flex-col sm:flex-row gap-4 mb-16"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 400 } }"
        >
          <Button
            as-child
            size="lg"
            class="h-14 px-8 text-base font-bold shadow-lg hover:shadow-primary/25 hover:shadow-xl transition-all group"
          >
            <a href="/api/auth/signup" class="flex items-center gap-2">
              Get Started Free
              <ArrowRight class="w-5 h-5 transition-transform group-hover:translate-x-1" />
            </a>
          </Button>
          <Button
            as-child
            variant="outline"
            size="lg"
            class="h-14 px-8 text-base font-semibold border-2 hover:bg-accent transition-all"
          >
            <a href="/api/auth/login" class="flex items-center gap-2">
              <LogIn class="w-5 h-5" />
              Sign In
            </a>
          </Button>
        </div>

        <!-- Stats Grid -->
        <div
          class="grid grid-cols-3 gap-6 md:gap-16 w-full max-w-2xl"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 500 } }"
        >
          <div class="text-center group cursor-default">
            <div class="text-3xl sm:text-4xl md:text-5xl font-black text-gradient-purple mb-2 transition-transform group-hover:scale-110 duration-300">
              50+
            </div>
            <div class="text-xs sm:text-sm text-muted-foreground font-medium">Artists</div>
          </div>
          <div class="text-center group cursor-default">
            <div class="text-3xl sm:text-4xl md:text-5xl font-black text-gradient mb-2 transition-transform group-hover:scale-110 duration-300">
              200+
            </div>
            <div class="text-xs sm:text-sm text-muted-foreground font-medium">Concerts</div>
          </div>
          <div class="text-center group cursor-default">
            <div class="text-3xl sm:text-4xl md:text-5xl font-black text-gradient-purple mb-2 transition-transform group-hover:scale-110 duration-300">
              1K+
            </div>
            <div class="text-xs sm:text-sm text-muted-foreground font-medium">Music Lovers</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Features Section -->
    <div class="relative container mx-auto px-4 lg:px-8 pb-24">
      <div class="max-w-5xl mx-auto">
        <!-- Section Header -->
        <div
          class="text-center mb-12"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :visibleOnce="{ opacity: 1, y: 0 }"
        >
          <h2 class="text-3xl md:text-4xl font-bold mb-3">
            Everything You Need
          </h2>
          <p class="text-lg text-muted-foreground">
            Powerful features to enhance your music discovery
          </p>
        </div>

        <!-- Features Grid -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <!-- Feature 1 -->
          <Card
            class="group relative overflow-hidden hover-lift bg-card/50 border-border/50"
            v-motion
            :initial="{ opacity: 0, y: 30 }"
            :visibleOnce="{ opacity: 1, y: 0, transition: { delay: 100 } }"
          >
            <div class="absolute inset-0 bg-gradient-to-br from-primary/0 to-primary/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
            <CardHeader class="relative space-y-4">
              <div class="w-14 h-14 rounded-2xl bg-primary/10 flex items-center justify-center transition-transform group-hover:scale-110 duration-300">
                <Users class="w-7 h-7 text-primary" />
              </div>
              <CardTitle class="text-xl">Follow Artists</CardTitle>
              <CardDescription class="text-sm leading-relaxed">
                Build your personal collection of Breton musicians and stay updated with their latest news
              </CardDescription>
            </CardHeader>
          </Card>

          <!-- Feature 2 -->
          <Card
            class="group relative overflow-hidden hover-lift bg-card/50 border-border/50"
            v-motion
            :initial="{ opacity: 0, y: 30 }"
            :visibleOnce="{ opacity: 1, y: 0, transition: { delay: 200 } }"
          >
            <div class="absolute inset-0 bg-gradient-to-br from-purple-500/0 to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
            <CardHeader class="relative space-y-4">
              <div class="w-14 h-14 rounded-2xl bg-purple-500/10 flex items-center justify-center transition-transform group-hover:scale-110 duration-300">
                <Map class="w-7 h-7 text-purple-500" />
              </div>
              <CardTitle class="text-xl">Interactive Map</CardTitle>
              <CardDescription class="text-sm leading-relaxed">
                Explore concerts happening near you with our beautiful interactive map and location discovery
              </CardDescription>
            </CardHeader>
          </Card>

          <!-- Feature 3 -->
          <Card
            class="group relative overflow-hidden hover-lift bg-card/50 border-border/50"
            v-motion
            :initial="{ opacity: 0, y: 30 }"
            :visibleOnce="{ opacity: 1, y: 0, transition: { delay: 300 } }"
          >
            <div class="absolute inset-0 bg-gradient-to-br from-pink-500/0 to-pink-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
            <CardHeader class="relative space-y-4">
              <div class="w-14 h-14 rounded-2xl bg-pink-500/10 flex items-center justify-center transition-transform group-hover:scale-110 duration-300">
                <Ticket class="w-7 h-7 text-pink-500" />
              </div>
              <CardTitle class="text-xl">Get Tickets</CardTitle>
              <CardDescription class="text-sm leading-relaxed">
                Direct links to purchase tickets for upcoming shows from your favorite artists
              </CardDescription>
            </CardHeader>
          </Card>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <footer class="relative border-t border-border/50 bg-card/30 backdrop-blur-sm">
      <div class="container mx-auto px-4 lg:px-8 py-8">
        <div class="flex flex-col md:flex-row items-center justify-between gap-4 text-sm">
          <div class="flex items-center gap-3 text-muted-foreground">
            <div class="p-2 rounded-lg bg-primary/10">
              <Music class="w-4 h-4 text-primary" />
            </div>
            <span class="font-medium">Made with love for Breton music</span>
          </div>
          <div class="flex items-center gap-6">
            <p class="text-muted-foreground">&copy; {{ currentYear }} FestNoz</p>
            <div class="flex items-center gap-4">
              <a href="#" class="text-muted-foreground hover:text-primary transition-colors">Privacy</a>
              <a href="#" class="text-muted-foreground hover:text-primary transition-colors">Terms</a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import {
  Music,
  Users,
  MapPin,
  Map,
  Ticket,
  ArrowRight,
  LogIn
} from 'lucide-vue-next'

const currentYear = computed(() => new Date().getFullYear())
</script>
