import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createPinia, setActivePinia } from 'pinia'
import ArtistCard from '../ArtistCard.vue'

vi.mock('lucide-vue-next', () => ({
  Music: { template: '<div class="icon-music" />' },
  Ticket: { template: '<div class="icon-ticket" />' },
  ArrowRight: { template: '<div class="icon-arrow-right" />' },
}))

vi.mock('@/components/ui/button', () => ({
  Button: { template: '<div><slot /></div>' },
}))

// Stub FollowButton to avoid needing full artists store setup
vi.mock('../FollowButton.vue', () => ({
  default: { template: '<div class="follow-button-stub" />' },
}))

describe('ArtistCard', () => {
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

  const baseArtist = {
    id: 1,
    name: 'Tri Yann',
    upcoming_concerts_count: 3,
  }

  function mountComponent(artistOverrides = {}) {
    return mount(ArtistCard, {
      props: { artist: { ...baseArtist, ...artistOverrides } },
      global: {
        plugins: [router, pinia],
      },
    })
  }

  it('renders artist name', () => {
    const wrapper = mountComponent()
    expect(wrapper.text()).toContain('Tri Yann')
  })

  it('renders image when artist.image_url is set', () => {
    const wrapper = mountComponent({ image_url: 'https://example.com/artist.jpg' })
    const img = wrapper.find('img')
    expect(img.exists()).toBe(true)
    expect(img.attributes('src')).toBe('https://example.com/artist.jpg')
  })

  it('renders primary_image_url over image_url', () => {
    const wrapper = mountComponent({
      primary_image_url: 'https://example.com/primary.jpg',
      image_url: 'https://example.com/fallback.jpg',
    })
    expect(wrapper.find('img').attributes('src')).toBe('https://example.com/primary.jpg')
  })

  it('renders fallback Music icon when no image is set', () => {
    const wrapper = mountComponent({ image_url: undefined, primary_image_url: undefined, thumbnail_url: undefined })
    expect(wrapper.find('img').exists()).toBe(false)
    expect(wrapper.find('.icon-music').exists()).toBe(true)
  })

  it('renders "See profile" link pointing to /artists/:id', () => {
    const wrapper = mountComponent()
    const link = wrapper.find('a[href="/artists/1"]')
    expect(link.exists()).toBe(true)
    expect(link.text()).toContain('See profile')
  })

  it('uses mobile-first aspect ratio with square from sm breakpoint', () => {
    const wrapper = mountComponent()
    const root = wrapper.find('.artist-card')

    expect(root.exists()).toBe(true)
    expect(root.classes()).toContain('aspect-[4/5]')
    expect(root.classes()).toContain('sm:aspect-square')
  })

  it('keeps desktop hover behavior classes on overlays', () => {
    const wrapper = mountComponent()

    const defaultOverlay = wrapper.find('.default-overlay')
    const hoverOverlay = wrapper.find('.hover-overlay')

    expect(defaultOverlay.exists()).toBe(true)
    expect(defaultOverlay.classes()).toContain('group-hover:opacity-0')

    expect(hoverOverlay.exists()).toBe(true)
    expect(hoverOverlay.classes()).toContain('translate-y-full')
    expect(hoverOverlay.classes()).toContain('group-hover:translate-y-0')
  })
})
