import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const routes = [
  {
    path: '/',
    name: 'Welcome',
    component: () => import('../views/Welcome.vue'),
    meta: { requiresGuest: true }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { requiresGuest: true }
  },
  {
    path: '/signup',
    name: 'Signup',
    component: () => import('../views/Signup.vue'),
    meta: { requiresGuest: true }
  },
  {
    path: '/auth/callback',
    name: 'AuthCallback',
    component: () => import('../views/AuthCallback.vue')
  },
  {
    path: '/auth/success',
    name: 'AuthSuccess',
    component: () => import('../views/AuthSuccess.vue')
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('../views/Dashboard.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/artists',
    name: 'Artists',
    component: () => import('../views/ArtistsList.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/artists/:id',
    name: 'ArtistDetail',
    component: () => import('../views/ArtistDetail.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/suggested-artists',
    name: 'SuggestedArtists',
    component: () => import('../views/SuggestedArtists.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/map',
    name: 'ConcertsMap',
    component: () => import('../views/ConcertsMap.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/admin',
    name: 'Admin',
    component: () => import('../views/AdminPanel.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guards
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const isAuthenticated = !!authStore.token
  const isAdmin = authStore.user?.admin

  if (to.meta.requiresAuth && !isAuthenticated) {
    next({ name: 'Login' })
  } else if (to.meta.requiresGuest && isAuthenticated) {
    next({ name: 'Dashboard' })
  } else if (to.meta.requiresAdmin && !isAdmin) {
    next({ name: 'Dashboard' })
  } else {
    next()
  }
})

export default router
