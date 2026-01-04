<template>
  <div class="min-h-screen flex">
    <!-- Left Panel - Decorative -->
    <div class="hidden lg:flex flex-1 bg-gradient-to-br from-primary via-purple-600 to-pink-600 items-center justify-center p-12 relative overflow-hidden">
      <!-- Animated Background Pattern -->
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-1/3 right-1/3 w-72 h-72 bg-white rounded-full blur-3xl animate-pulse"></div>
        <div class="absolute bottom-1/3 left-1/3 w-96 h-96 bg-white rounded-full blur-3xl animate-pulse delay-1000"></div>
      </div>

      <div class="relative max-w-lg text-white text-center space-y-8 animate-in fade-in slide-in-from-left-8 duration-1000">
        <div class="text-9xl animate-bounce">🎭</div>
        <div class="space-y-4">
          <h2 class="text-5xl font-bold leading-tight">Join the Community</h2>
          <p class="text-xl text-white/90 leading-relaxed">
            Connect with thousands of Breton music enthusiasts and discover amazing artists across Brittany and beyond.
          </p>
        </div>

        <!-- Feature Pills -->
        <div class="flex flex-wrap gap-3 justify-center pt-4">
          <div class="px-4 py-2 rounded-full bg-white/20 backdrop-blur-sm border border-white/30 text-sm font-medium">
            🎵 Free Forever
          </div>
          <div class="px-4 py-2 rounded-full bg-white/20 backdrop-blur-sm border border-white/30 text-sm font-medium">
            ⚡ Instant Access
          </div>
          <div class="px-4 py-2 rounded-full bg-white/20 backdrop-blur-sm border border-white/30 text-sm font-medium">
            🌟 All Features
          </div>
        </div>
      </div>
    </div>

    <!-- Right Panel - Form -->
    <div class="flex-1 flex items-center justify-center p-6 md:p-12 relative overflow-hidden">
      <!-- Animated Background -->
      <div class="absolute inset-0 bg-gradient-to-br from-background via-primary/5 to-transparent"></div>
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_20%_80%,_var(--tw-gradient-stops))] from-primary/10 via-transparent to-transparent"></div>

      <div class="relative w-full max-w-md space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-1000">
        <!-- Header -->
        <div class="text-center space-y-4">
          <router-link to="/" class="inline-block group">
            <div class="relative">
              <div class="absolute inset-0 bg-primary/20 blur-2xl rounded-full group-hover:bg-primary/30 transition-all"></div>
              <div class="relative text-5xl transition-transform group-hover:scale-110 duration-300">🎵</div>
            </div>
          </router-link>
          <div class="space-y-2">
            <h1 class="text-4xl font-bold tracking-tight">Create your account</h1>
            <p class="text-lg text-muted-foreground">Join FestNoz and start discovering</p>
          </div>
        </div>

        <!-- Error Alert -->
        <Alert v-if="authStore.error" variant="destructive" class="animate-in fade-in slide-in-from-top-2 duration-500">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mr-2">
            <circle cx="12" cy="12" r="10"/>
            <path d="m15 9-6 6"/>
            <path d="m9 9 6 6"/>
          </svg>
          <AlertDescription>
            <ul v-if="Array.isArray(authStore.error)" class="list-disc list-inside space-y-1">
              <li v-for="(err, index) in authStore.error" :key="index">{{ err }}</li>
            </ul>
            <span v-else>{{ authStore.error }}</span>
          </AlertDescription>
        </Alert>

        <!-- Form -->
        <form @submit.prevent="handleSignup" class="space-y-6">
          <Card class="border-2 shadow-lg">
            <CardContent class="pt-6 space-y-5">
              <div class="space-y-2">
                <Label for="username" class="text-base font-semibold">Username</Label>
                <div class="relative group">
                  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary transition-colors">
                    <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/>
                    <circle cx="12" cy="7" r="4"/>
                  </svg>
                  <Input
                    id="username"
                    v-model="username"
                    type="text"
                    placeholder="Choose a username"
                    required
                    autocomplete="username"
                    class="h-12 pl-10 border-2 focus:border-primary transition-all"
                  />
                </div>
              </div>

              <div class="space-y-2">
                <Label for="email" class="text-base font-semibold">Email address</Label>
                <div class="relative group">
                  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary transition-colors">
                    <rect width="20" height="16" x="2" y="4" rx="2"/>
                    <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/>
                  </svg>
                  <Input
                    id="email"
                    v-model="email"
                    type="email"
                    placeholder="you@example.com"
                    required
                    autocomplete="email"
                    class="h-12 pl-10 border-2 focus:border-primary transition-all"
                  />
                </div>
              </div>

              <div class="space-y-2">
                <Label for="password" class="text-base font-semibold">Password</Label>
                <div class="relative group">
                  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary transition-colors">
                    <rect width="18" height="11" x="3" y="11" rx="2" ry="2"/>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                  </svg>
                  <Input
                    id="password"
                    v-model="password"
                    type="password"
                    placeholder="Create a password"
                    required
                    minlength="6"
                    autocomplete="new-password"
                    class="h-12 pl-10 border-2 focus:border-primary transition-all"
                  />
                </div>
                <p class="text-xs text-muted-foreground flex items-center gap-1">
                  <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"/>
                    <path d="M12 16v-4"/>
                    <path d="M12 8h.01"/>
                  </svg>
                  Must be at least 6 characters
                </p>
              </div>

              <div class="space-y-2">
                <Label for="password_confirmation" class="text-base font-semibold">Confirm password</Label>
                <div class="relative group">
                  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary transition-colors">
                    <path d="M21 2 3 22"/>
                    <path d="m16 16-4-4 4-4"/>
                  </svg>
                  <Input
                    id="password_confirmation"
                    v-model="passwordConfirmation"
                    type="password"
                    placeholder="Confirm your password"
                    required
                    minlength="6"
                    autocomplete="new-password"
                    class="h-12 pl-10 border-2 focus:border-primary transition-all"
                  />
                </div>
              </div>
            </CardContent>
          </Card>

          <Button
            type="submit"
            class="w-full h-14 text-base font-bold shadow-lg hover:shadow-xl transition-all group"
            :disabled="authStore.loading"
          >
            <span v-if="authStore.loading" class="flex items-center gap-2">
              <span class="h-5 w-5 animate-spin rounded-full border-2 border-current border-t-transparent"></span>
              Creating account...
            </span>
            <span v-else class="flex items-center gap-2">
              Create account
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="transition-transform group-hover:translate-x-1">
                <path d="m9 18 6-6-6-6"/>
              </svg>
            </span>
          </Button>
        </form>

        <div class="relative">
          <div class="absolute inset-0 flex items-center">
            <span class="w-full border-t-2"></span>
          </div>
          <div class="relative flex justify-center text-xs uppercase">
            <span class="bg-background px-3 text-muted-foreground font-medium">Or</span>
          </div>
        </div>

        <!-- Sign in link -->
        <Card class="border-2 border-dashed hover:border-primary/50 transition-all">
          <CardContent class="p-6">
            <p class="text-center text-muted-foreground">
              Already have an account?
              <router-link to="/login" class="ml-2 font-bold text-primary hover:underline inline-flex items-center gap-1 group">
                Sign in
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="transition-transform group-hover:translate-x-1">
                  <path d="m9 18 6-6-6-6"/>
                </svg>
              </router-link>
            </p>
          </CardContent>
        </Card>
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

const router = useRouter()
const authStore = useAuthStore()

const username = ref('')
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')

async function handleSignup() {
  try {
    await authStore.signup(username.value, email.value, password.value, passwordConfirmation.value)
    router.push('/dashboard')
  } catch (error) {
    console.error('Signup failed:', error)
  }
}
</script>
