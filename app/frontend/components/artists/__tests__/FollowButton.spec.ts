import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createPinia, setActivePinia } from 'pinia'
import FollowButton from '../FollowButton.vue'
import { useArtistsStore } from '../../../stores/artists'
import { useAuthStore } from '../../../stores/auth'

vi.mock('lucide-vue-next', () => ({
  Heart: { template: '<div class="icon-heart" />' },
  Loader2: { template: '<div class="icon-loader2" />' },
}))

vi.mock('vue-sonner', () => ({
  toast: {
    error: vi.fn(),
    success: vi.fn(),
  },
}))

// Stub shadcn Button to render its default slot
vi.mock('@/components/ui/button', () => ({
  Button: { template: '<button @click="$emit(\'click\')"><slot /></button>', emits: ['click'] },
}))

describe('FollowButton', () => {
  let router: ReturnType<typeof createRouter>
  let pinia: ReturnType<typeof createPinia>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)

    router = createRouter({
      history: createMemoryHistory(),
      routes: [
        { path: '/', component: {} },
        { path: '/:pathMatch(.*)*', component: {} },
      ],
    })

    vi.clearAllMocks()
  })

  function mountComponent(artistId = 1) {
    return mount(FollowButton, {
      props: { artistId },
      global: {
        plugins: [router, pinia],
      },
    })
  }

  it('renders "Follow" when not following', () => {
    const artistsStore = useArtistsStore()
    artistsStore.isFollowing = vi.fn().mockReturnValue(false)

    const wrapper = mountComponent()
    expect(wrapper.text()).toContain('Follow')
  })

  it('renders "Following" when already following', () => {
    const artistsStore = useArtistsStore()
    artistsStore.isFollowing = vi.fn().mockReturnValue(true)

    const wrapper = mountComponent()
    expect(wrapper.text()).toContain('Following')
  })

  it('shows loading spinner during action', async () => {
    const artistsStore = useArtistsStore()
    artistsStore.isFollowing = vi.fn().mockReturnValue(false)
    // Delay resolution so loading state is observable
    artistsStore.followArtist = vi.fn().mockReturnValue(new Promise(() => {}))

    const authStore = useAuthStore()
    authStore.token = 'fake-token'

    const wrapper = mountComponent()
    await wrapper.find('button').trigger('click')

    expect(wrapper.find('.icon-loader2').exists()).toBe(true)
  })

  it('calls artistsStore.followArtist when clicking follow while authenticated', async () => {
    const artistsStore = useArtistsStore()
    artistsStore.isFollowing = vi.fn().mockReturnValue(false)
    artistsStore.followArtist = vi.fn().mockResolvedValue(undefined)

    const authStore = useAuthStore()
    authStore.token = 'fake-token'

    const wrapper = mountComponent(42)
    await wrapper.find('button').trigger('click')
    await flushPromises()

    expect(artistsStore.followArtist).toHaveBeenCalledWith(42)
  })

  it('shows toast error when clicking follow while not authenticated', async () => {
    const { toast } = await import('vue-sonner')

    const artistsStore = useArtistsStore()
    artistsStore.isFollowing = vi.fn().mockReturnValue(false)

    const authStore = useAuthStore()
    authStore.isAuthenticated = false

    const wrapper = mountComponent()
    await wrapper.find('button').trigger('click')

    expect(toast.error).toHaveBeenCalledWith('Please sign in to follow artists')
  })
})
