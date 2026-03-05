import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createPinia, setActivePinia } from 'pinia'
import AppHeader from '../AppHeader.vue'
import { useAuthStore } from '../../../stores/auth'

vi.mock('lucide-vue-next', () => ({
  Music2: { template: '<div class="icon-music2" />' },
  LayoutDashboard: { template: '<div class="icon-layout-dashboard" />' },
  Users: { template: '<div class="icon-users" />' },
  Map: { template: '<div class="icon-map" />' },
  Shield: { template: '<div class="icon-shield" />' },
  Settings: { template: '<div class="icon-settings" />' },
  LogOut: { template: '<div class="icon-logout" />' },
  Menu: { template: '<div class="icon-menu" />' },
  ChevronDown: { template: '<div class="icon-chevron-down" />' },
  Sparkles: { template: '<div class="icon-sparkles" />' },
}))

vi.mock('@/config', () => ({
  backendUrl: 'http://localhost:3000',
}))

vi.mock('@/components/ui/button', () => ({
  Button: { template: '<button @click="$emit(\'click\')"><slot /></button>', emits: ['click'] },
}))

vi.mock('@/components/ui/avatar', () => ({
  Avatar: { template: '<div class="avatar"><slot /></div>' },
  AvatarFallback: { template: '<span class="avatar-fallback"><slot /></span>' },
}))

vi.mock('@/components/ui/dropdown-menu', () => ({
  DropdownMenu: { template: '<div class="dropdown-menu"><slot /></div>' },
  DropdownMenuContent: { template: '<div class="dropdown-menu-content"><slot /></div>' },
  DropdownMenuItem: { template: '<div class="dropdown-menu-item" @click="$emit(\'click\')"><slot /></div>', emits: ['click'] },
  DropdownMenuLabel: { template: '<div class="dropdown-menu-label"><slot /></div>' },
  DropdownMenuSeparator: { template: '<hr />' },
  DropdownMenuTrigger: { template: '<div class="dropdown-menu-trigger"><slot /></div>' },
}))

vi.mock('@/components/ui/sheet', () => ({
  Sheet: { template: '<div class="sheet"><slot /></div>' },
  SheetClose: { template: '<div class="sheet-close"><slot /></div>' },
  SheetContent: { template: '<div class="sheet-content"><slot /></div>' },
  SheetHeader: { template: '<div class="sheet-header"><slot /></div>' },
  SheetTitle: { template: '<div class="sheet-title"><slot /></div>' },
  SheetTrigger: { template: '<div class="sheet-trigger"><slot /></div>' },
}))

describe('AppHeader', () => {
  let router: ReturnType<typeof createRouter>
  let pinia: ReturnType<typeof createPinia>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)

    router = createRouter({
      history: createMemoryHistory(),
      routes: [
        { path: '/', component: {} },
        { path: '/dashboard', component: {} },
        { path: '/artists', component: {} },
        { path: '/suggested-artists', component: {} },
        { path: '/map', component: {} },
        { path: '/admin', component: {} },
        { path: '/:pathMatch(.*)*', component: {} },
      ],
    })

    vi.clearAllMocks()
  })

  function mountComponent() {
    return mount(AppHeader, {
      global: {
        plugins: [router, pinia],
        directives: {
          'motion-fade-up': {},
        },
      },
    })
  }

  it('renders navigation links', () => {
    const authStore = useAuthStore()
    authStore.user = { id: 1, email: 'user@example.com', username: 'Testuser', admin: false } as any
    authStore.token = 'fake-token'

    const wrapper = mountComponent()
    const text = wrapper.text()
    expect(text).toContain('Dashboard')
    expect(text).toContain('Artists')
    expect(text).toContain('Map')
  })

  it('does not render Admin link when user is not admin', () => {
    const authStore = useAuthStore()
    authStore.user = { id: 1, email: 'user@example.com', username: 'Testuser', admin: false } as any

    const wrapper = mountComponent()
    expect(wrapper.text()).not.toContain('Admin')
  })

  it('renders Admin link when user is admin', () => {
    const authStore = useAuthStore()
    authStore.user = { id: 1, email: 'admin@example.com', username: 'Admin', admin: true } as any

    const wrapper = mountComponent()
    expect(wrapper.text()).toContain('Admin')
  })

  it('renders user menu with username when authenticated', () => {
    const authStore = useAuthStore()
    authStore.user = { id: 1, email: 'user@example.com', username: 'Testuser', admin: false } as any
    authStore.token = 'fake-token'

    const wrapper = mountComponent()
    expect(wrapper.text()).toContain('Testuser')
  })

  it('calls authStore.logout when logout is triggered', async () => {
    const authStore = useAuthStore()
    authStore.user = { id: 1, email: 'user@example.com', username: 'Testuser', admin: false } as any
    authStore.token = 'fake-token'
    authStore.logout = vi.fn().mockResolvedValue(undefined)

    // Mock location.href setter to prevent jsdom navigation errors
    Object.defineProperty(globalThis, 'location', {
      value: { href: '' },
      writable: true,
    })

    const wrapper = mountComponent()
    const logoutItems = wrapper.findAll('.dropdown-menu-item')
    const logoutItem = logoutItems.find(item => item.text().includes('Logout'))
    expect(logoutItem).toBeDefined()
    await logoutItem!.trigger('click')
    await flushPromises()

    expect(authStore.logout).toHaveBeenCalled()
  })
})
