<template>
  <div class="min-h-screen flex">
    <!-- Left Panel - Form -->
    <div class="flex-1 flex items-center justify-center p-6 md:p-12 relative overflow-hidden">
      <!-- Background -->
      <div class="absolute inset-0 gradient-dark" />
      <div class="absolute top-0 right-0 w-[500px] h-[500px] gradient-glow opacity-30" />

      <div class="relative w-full max-w-md space-y-8">
        <!-- Header -->
        <div class="text-center space-y-4" v-motion-fade-up>
          <router-link to="/" class="inline-block group">
            <div class="relative">
              <div class="absolute inset-0 bg-primary/20 blur-2xl rounded-full group-hover:bg-primary/30 transition-all" />
              <div class="relative p-4 rounded-2xl bg-card/50 border border-border/50 backdrop-blur-sm transition-transform group-hover:scale-105 duration-300">
                <Music class="w-10 h-10 text-primary" />
              </div>
            </div>
          </router-link>
          <div class="space-y-2">
            <h1 class="text-3xl font-bold tracking-tight">Welcome back</h1>
            <p class="text-muted-foreground">Sign in to your FestNoz account</p>
          </div>
        </div>

        <!-- Error Alert -->
        <Alert
          v-if="authStore.error"
          variant="destructive"
          class="animate-fade-in"
          v-motion
          :initial="{ opacity: 0, y: -10 }"
          :enter="{ opacity: 1, y: 0 }"
        >
          <AlertCircle class="w-4 h-4" />
          <AlertDescription>{{ authStore.error }}</AlertDescription>
        </Alert>

        <!-- Form -->
        <form @submit.prevent="handleLogin" class="space-y-6">
          <Card
            class="border-border/50 bg-card/50 backdrop-blur-sm"
            v-motion
            :initial="{ opacity: 0, y: 20 }"
            :enter="{ opacity: 1, y: 0, transition: { delay: 100 } }"
          >
            <CardContent class="pt-6 space-y-5">
              <div class="space-y-2">
                <Label for="email" class="text-sm font-medium">Email address</Label>
                <div class="relative group">
                  <Mail class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                  <Input
                    id="email"
                    v-model="email"
                    type="email"
                    placeholder="you@example.com"
                    required
                    autocomplete="email"
                    class="h-11 pl-10 bg-background/50"
                  />
                </div>
              </div>

              <div class="space-y-2">
                <Label for="password" class="text-sm font-medium">Password</Label>
                <div class="relative group">
                  <Lock class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground group-focus-within:text-primary transition-colors" />
                  <Input
                    id="password"
                    v-model="password"
                    type="password"
                    placeholder="Enter your password"
                    required
                    autocomplete="current-password"
                    class="h-11 pl-10 bg-background/50"
                  />
                </div>
              </div>
            </CardContent>
          </Card>

          <Button
            type="submit"
            class="w-full h-12 font-semibold shadow-lg hover:shadow-primary/20 transition-all group"
            :disabled="authStore.loading"
            v-motion
            :initial="{ opacity: 0, y: 20 }"
            :enter="{ opacity: 1, y: 0, transition: { delay: 200 } }"
          >
            <span v-if="authStore.loading" class="flex items-center gap-2">
              <Loader2 class="w-4 h-4 animate-spin" />
              Signing in...
            </span>
            <span v-else class="flex items-center gap-2">
              Sign in
              <ArrowRight class="w-4 h-4 transition-transform group-hover:translate-x-1" />
            </span>
          </Button>
        </form>

        <!-- Divider -->
        <div
          class="relative"
          v-motion
          :initial="{ opacity: 0 }"
          :enter="{ opacity: 1, transition: { delay: 300 } }"
        >
          <div class="absolute inset-0 flex items-center">
            <span class="w-full border-t border-border/50" />
          </div>
          <div class="relative flex justify-center text-xs uppercase">
            <span class="bg-background px-3 text-muted-foreground">Or</span>
          </div>
        </div>

        <!-- Sign up link -->
        <Card
          class="border-dashed border-border/50 bg-transparent hover:border-primary/50 hover:bg-card/30 transition-all cursor-pointer"
          v-motion
          :initial="{ opacity: 0, y: 20 }"
          :enter="{ opacity: 1, y: 0, transition: { delay: 400 } }"
        >
          <CardContent class="p-5">
            <p class="text-center text-sm text-muted-foreground">
              Don't have an account?
              <router-link to="/signup" class="ml-1 font-semibold text-primary hover:underline inline-flex items-center gap-1 group">
                Create one
                <ChevronRight class="w-4 h-4 transition-transform group-hover:translate-x-0.5" />
              </router-link>
            </p>
          </CardContent>
        </Card>
      </div>
    </div>

    <!-- Right Panel - Decorative -->
    <div class="hidden lg:flex flex-1 items-center justify-center p-12 relative overflow-hidden">
      <!-- Gradient background -->
      <div class="absolute inset-0 bg-gradient-to-br from-primary via-purple-600 to-pink-600" />
      <div class="absolute inset-0 opacity-20">
        <div class="absolute top-1/4 left-1/4 w-64 h-64 bg-white rounded-full blur-3xl animate-pulse" />
        <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-white rounded-full blur-3xl animate-pulse" style="animation-delay: 1s" />
      </div>

      <div
        class="relative max-w-md text-white text-center space-y-8"
        v-motion
        :initial="{ opacity: 0, x: 30 }"
        :enter="{ opacity: 1, x: 0, transition: { delay: 200, duration: 500 } }"
      >
        <div class="p-6 rounded-3xl bg-white/10 border border-white/20 backdrop-blur-sm inline-block">
          <Music class="w-16 h-16" />
        </div>
        <div class="space-y-4">
          <h2 class="text-4xl font-bold leading-tight">Discover Breton Music</h2>
          <p class="text-lg text-white/80 leading-relaxed">
            Follow your favorite artists, find concerts near you, and never miss a festnoz again.
          </p>
        </div>

        <!-- Feature Pills -->
        <div class="flex flex-wrap gap-3 justify-center pt-4">
          <div class="flex items-center gap-2 px-4 py-2 rounded-full bg-white/15 backdrop-blur-sm border border-white/20 text-sm font-medium">
            <Users class="w-4 h-4" />
            50+ Artists
          </div>
          <div class="flex items-center gap-2 px-4 py-2 rounded-full bg-white/15 backdrop-blur-sm border border-white/20 text-sm font-medium">
            <Map class="w-4 h-4" />
            Interactive Map
          </div>
          <div class="flex items-center gap-2 px-4 py-2 rounded-full bg-white/15 backdrop-blur-sm border border-white/20 text-sm font-medium">
            <Ticket class="w-4 h-4" />
            Live Concerts
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Card, CardContent } from '@/components/ui/card'
import {
  Music,
  Mail,
  Lock,
  ArrowRight,
  ChevronRight,
  Loader2,
  AlertCircle,
  Users,
  Map,
  Ticket
} from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')

async function handleLogin() {
  try {
    await authStore.login(email.value, password.value)
    router.push('/dashboard')
  } catch (error) {
    console.error('Login failed:', error)
  }
}
</script>
