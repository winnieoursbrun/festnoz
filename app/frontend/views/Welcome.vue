<template>
  <div class="relative min-h-screen overflow-hidden">
    <!-- Animated Background -->
    <div class="absolute inset-0 bg-gradient-to-br from-background via-primary/5 to-purple-500/10">
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_30%_20%,_var(--tw-gradient-stops))] from-primary/20 via-transparent to-transparent"></div>
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_70%_80%,_var(--tw-gradient-stops))] from-purple-500/20 via-transparent to-transparent"></div>
    </div>

    <!-- Hero Section -->
    <div class="relative container mx-auto px-4 py-20 md:py-32">
      <div class="flex flex-col items-center text-center max-w-5xl mx-auto">
        <!-- Animated Logo -->
        <div class="relative mb-12 group">
          <div class="absolute inset-0 bg-primary/30 blur-3xl rounded-full animate-pulse"></div>
          <div class="relative text-9xl md:text-[12rem] transition-transform group-hover:scale-110 duration-500">
            🎵
          </div>
        </div>

        <!-- Title with Gradient -->
        <h1 class="text-6xl md:text-8xl font-black tracking-tight mb-6 animate-in fade-in slide-in-from-bottom-4 duration-1000">
          <span class="bg-gradient-to-r from-primary via-purple-500 to-pink-500 bg-clip-text text-transparent">
            FestNoz
          </span>
        </h1>

        <!-- Subtitle -->
        <p class="text-2xl md:text-3xl text-foreground font-bold mb-4 animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-100">
          Discover Breton Music
        </p>

        <p class="text-xl md:text-2xl text-muted-foreground font-medium mb-12 animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-200">
          Follow Artists • Find Concerts • Never Miss a Show
        </p>

        <!-- Description -->
        <p class="text-lg md:text-xl text-muted-foreground/90 max-w-3xl mb-12 leading-relaxed animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-300">
          Your gateway to the vibrant world of Breton music. Track your favorite artists,
          discover upcoming concerts on an interactive map, and immerse yourself in the
          rich traditions of Celtic culture.
        </p>

        <!-- CTA Buttons -->
        <div class="flex flex-col sm:flex-row gap-4 mb-20 animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-400">
          <Button
            as-child
            size="lg"
            class="h-16 px-10 text-lg font-bold shadow-lg hover:shadow-xl transition-all group"
          >
            <router-link to="/signup" class="flex items-center gap-2">
              Get Started Free
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="transition-transform group-hover:translate-x-1">
                <path d="m9 18 6-6-6-6"/>
              </svg>
            </router-link>
          </Button>
          <Button
            as-child
            variant="outline"
            size="lg"
            class="h-16 px-10 text-lg font-semibold border-2 hover:border-primary/50 transition-all"
          >
            <router-link to="/login">
              Sign In
            </router-link>
          </Button>
        </div>

        <!-- Stats Grid -->
        <div class="grid grid-cols-3 gap-8 md:gap-20 mb-20 w-full max-w-3xl animate-in fade-in slide-in-from-bottom-4 duration-1000 delay-500">
          <div class="text-center group cursor-default">
            <div class="text-4xl md:text-5xl font-black bg-gradient-to-br from-primary to-primary/60 bg-clip-text text-transparent mb-2 transition-transform group-hover:scale-110 duration-300">
              50+
            </div>
            <div class="text-sm md:text-base text-muted-foreground font-medium">Artists</div>
          </div>
          <div class="text-center group cursor-default">
            <div class="text-4xl md:text-5xl font-black bg-gradient-to-br from-purple-500 to-purple-500/60 bg-clip-text text-transparent mb-2 transition-transform group-hover:scale-110 duration-300">
              200+
            </div>
            <div class="text-sm md:text-base text-muted-foreground font-medium">Concerts</div>
          </div>
          <div class="text-center group cursor-default">
            <div class="text-4xl md:text-5xl font-black bg-gradient-to-br from-pink-500 to-pink-500/60 bg-clip-text text-transparent mb-2 transition-transform group-hover:scale-110 duration-300">
              1K+
            </div>
            <div class="text-sm md:text-base text-muted-foreground font-medium">Music Lovers</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Features Section -->
    <div class="relative container mx-auto px-4 pb-32">
      <div class="max-w-6xl mx-auto">
        <!-- Section Header -->
        <div class="text-center mb-16">
          <h2 class="text-4xl md:text-5xl font-bold mb-4">
            Everything You Need
          </h2>
          <p class="text-xl text-muted-foreground">
            Powerful features to enhance your music discovery experience
          </p>
        </div>

        <!-- Features Grid -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <!-- Feature 1 -->
          <Card class="group relative overflow-hidden border-2 transition-all duration-500 hover:border-primary/50 hover:shadow-2xl hover:-translate-y-2">
            <div class="absolute inset-0 bg-gradient-to-br from-primary/0 to-primary/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
            <CardHeader class="relative space-y-4">
              <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-primary/20 to-primary/10 flex items-center justify-center text-4xl transition-transform group-hover:scale-110 group-hover:rotate-3 duration-500">
                🎭
              </div>
              <CardTitle class="text-2xl">Follow Artists</CardTitle>
              <CardDescription class="text-base leading-relaxed">
                Build your personal collection of Breton musicians and stay updated with their latest news and releases
              </CardDescription>
            </CardHeader>
            <CardContent class="relative">
              <div class="flex items-center text-sm font-medium text-primary opacity-0 group-hover:opacity-100 transition-opacity duration-500">
                Explore now
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="ml-1 transition-transform group-hover:translate-x-1">
                  <path d="m9 18 6-6-6-6"/>
                </svg>
              </div>
            </CardContent>
          </Card>

          <!-- Feature 2 -->
          <Card class="group relative overflow-hidden border-2 transition-all duration-500 hover:border-primary/50 hover:shadow-2xl hover:-translate-y-2">
            <div class="absolute inset-0 bg-gradient-to-br from-purple-500/0 to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
            <CardHeader class="relative space-y-4">
              <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-purple-500/20 to-purple-500/10 flex items-center justify-center text-4xl transition-transform group-hover:scale-110 group-hover:rotate-3 duration-500">
                🗺️
              </div>
              <CardTitle class="text-2xl">Interactive Map</CardTitle>
              <CardDescription class="text-base leading-relaxed">
                Explore concerts happening near you with our beautiful interactive map experience and location-based discovery
              </CardDescription>
            </CardHeader>
            <CardContent class="relative">
              <div class="flex items-center text-sm font-medium text-purple-500 opacity-0 group-hover:opacity-100 transition-opacity duration-500">
                View map
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="ml-1 transition-transform group-hover:translate-x-1">
                  <path d="m9 18 6-6-6-6"/>
                </svg>
              </div>
            </CardContent>
          </Card>

          <!-- Feature 3 -->
          <Card class="group relative overflow-hidden border-2 transition-all duration-500 hover:border-primary/50 hover:shadow-2xl hover:-translate-y-2">
            <div class="absolute inset-0 bg-gradient-to-br from-pink-500/0 to-pink-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
            <CardHeader class="relative space-y-4">
              <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-pink-500/20 to-pink-500/10 flex items-center justify-center text-4xl transition-transform group-hover:scale-110 group-hover:rotate-3 duration-500">
                🎫
              </div>
              <CardTitle class="text-2xl">Get Tickets</CardTitle>
              <CardDescription class="text-base leading-relaxed">
                Direct links to purchase tickets for upcoming shows from your favorite artists. Never miss an opportunity
              </CardDescription>
            </CardHeader>
            <CardContent class="relative">
              <div class="flex items-center text-sm font-medium text-pink-500 opacity-0 group-hover:opacity-100 transition-opacity duration-500">
                Find shows
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="ml-1 transition-transform group-hover:translate-x-1">
                  <path d="m9 18 6-6-6-6"/>
                </svg>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <footer class="relative border-t bg-card/50 backdrop-blur-sm">
      <div class="container mx-auto px-4 py-10">
        <div class="flex flex-col md:flex-row items-center justify-between gap-6 text-sm">
          <div class="flex items-center gap-2 text-muted-foreground">
            <span class="text-2xl">🎵</span>
            <span class="font-medium">Made with love for Breton music</span>
          </div>
          <div class="flex items-center gap-8">
            <p class="text-muted-foreground">© 2024 FestNoz</p>
            <div class="flex items-center gap-4">
              <a href="#" class="text-muted-foreground hover:text-primary transition-colors">Privacy</a>
              <a href="#" class="text-muted-foreground hover:text-primary transition-colors">Terms</a>
              <a href="#" class="text-muted-foreground hover:text-primary transition-colors">Contact</a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card'
</script>
