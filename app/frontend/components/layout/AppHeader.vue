<template>
  <header
    class="glass-dark border-b border-border/50 sticky top-0 z-50 transition-all duration-300"
    :class="{ 'shadow-lg shadow-primary/5': isScrolled }"
  >
    <div class="container mx-auto px-4 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <!-- Logo -->
        <router-link
          to="/dashboard"
          class="flex items-center gap-2 text-xl font-bold text-foreground hover:text-primary transition-colors group"
          v-motion-fade-up
        >
          <div class="p-2 rounded-lg bg-primary/10 group-hover:bg-primary/20 transition-colors">
            <Music2 class="w-5 h-5 text-primary" />
          </div>
          <span class="text-gradient-purple">FestNoz</span>
        </router-link>

        <!-- Desktop Navigation -->
        <nav class="hidden md:flex items-center gap-1" v-motion-fade-up>
          <router-link
            v-for="item in navItems"
            :key="item.to"
            :to="item.to"
            class="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-accent transition-all"
            active-class="!text-primary bg-primary/10"
          >
            <component :is="item.icon" class="w-4 h-4" />
            {{ item.label }}
          </router-link>
        </nav>

        <!-- Right Side -->
        <div class="flex items-center gap-3" v-motion-fade-up>
          <!-- User Menu -->
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" class="flex items-center gap-2 px-3">
                <Avatar class="h-8 w-8">
                  <AvatarFallback class="bg-primary/20 text-primary text-sm">
                    {{ userInitials }}
                  </AvatarFallback>
                </Avatar>
                <span class="hidden sm:block text-sm text-muted-foreground">
                  {{ authStore.user?.username }}
                </span>
                <ChevronDown class="w-4 h-4 text-muted-foreground" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" class="w-48">
              <DropdownMenuLabel class="font-normal">
                <div class="flex flex-col space-y-1">
                  <p class="text-sm font-medium">{{ authStore.user?.username }}</p>
                  <p class="text-xs text-muted-foreground">{{ authStore.user?.email }}</p>
                </div>
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuItem @click="handleLogout" class="text-destructive focus:text-destructive cursor-pointer">
                <LogOut class="w-4 h-4 mr-2" />
                Logout
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>

          <!-- Mobile Menu Button -->
          <Sheet>
            <SheetTrigger asChild>
              <Button variant="ghost" size="icon" class="md:hidden">
                <Menu class="w-5 h-5" />
              </Button>
            </SheetTrigger>
            <SheetContent side="right" class="w-72">
              <SheetHeader>
                <SheetTitle class="flex items-center gap-2">
                  <Music2 class="w-5 h-5 text-primary" />
                  <span class="text-gradient-purple">FestNoz</span>
                </SheetTitle>
              </SheetHeader>
              <nav class="flex flex-col gap-2 mt-8">
                <SheetClose asChild v-for="item in navItems" :key="item.to">
                  <router-link
                    :to="item.to"
                    class="flex items-center gap-3 px-4 py-3 rounded-lg text-foreground hover:bg-accent transition-colors"
                    active-class="bg-primary/10 text-primary"
                  >
                    <component :is="item.icon" class="w-5 h-5" />
                    {{ item.label }}
                  </router-link>
                </SheetClose>
              </nav>
              <div class="absolute bottom-8 left-6 right-6">
                <SheetClose asChild>
                  <Button
                    variant="outline"
                    class="w-full justify-start text-destructive hover:text-destructive"
                    @click="handleLogout"
                  >
                    <LogOut class="w-4 h-4 mr-2" />
                    Logout
                  </Button>
                </SheetClose>
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import {
  Sheet,
  SheetClose,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger
} from '@/components/ui/sheet'
import {
  Music2,
  LayoutDashboard,
  Users,
  Map,
  Shield,
  LogOut,
  Menu,
  ChevronDown,
  Sparkles
} from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()
const isScrolled = ref(false)

// Navigation items
const navItems = computed(() => {
  const items = [
    { to: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { to: '/artists', label: 'Artists', icon: Users },
    { to: '/suggested-artists', label: 'Suggested', icon: Sparkles },
    { to: '/map', label: 'Map', icon: Map }
  ]

  if (authStore.isAdmin) {
    items.push({ to: '/admin', label: 'Admin', icon: Shield })
  }

  return items
})

// User initials for avatar
const userInitials = computed(() => {
  const name = authStore.user?.username || ''
  return name.substring(0, 2).toUpperCase()
})

// Scroll handler
function handleScroll() {
  isScrolled.value = window.scrollY > 10
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

async function handleLogout() {
  await authStore.logout()
  router.push('/login')
}
</script>
