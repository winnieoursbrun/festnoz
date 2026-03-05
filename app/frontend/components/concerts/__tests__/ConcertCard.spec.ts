import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import { createPinia, setActivePinia } from 'pinia'
import ConcertCard from '../ConcertCard.vue'

vi.mock('lucide-vue-next', () => ({
  Music: { template: '<div class="icon-music" />' },
  MapPin: { template: '<div class="icon-map-pin" />' },
  Clock: { template: '<div class="icon-clock" />' },
  Banknote: { template: '<div class="icon-banknote" />' },
  Navigation: { template: '<div class="icon-navigation" />' },
  Ticket: { template: '<div class="icon-ticket" />' },
  Sparkles: { template: '<div class="icon-sparkles" />' },
}))

vi.mock('@/components/ui/button', () => ({
  Button: { template: '<div><slot /></div>' },
}))

vi.mock('@/components/ui/card', () => ({
  Card: { template: '<div class="card"><slot /></div>' },
  CardContent: { template: '<div class="card-content"><slot /></div>' },
  CardTitle: { template: '<div class="card-title"><slot /></div>' },
}))

vi.mock('@/components/ui/badge', () => ({
  Badge: { template: '<span class="badge"><slot /></span>' },
}))

describe('ConcertCard', () => {
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

  const baseConcert = {
    id: 1,
    title: 'Noz Breizh Festival',
    starts_at: '2026-06-15T20:00:00Z',
    ends_at: '2026-06-15T23:00:00Z',
    venue_name: 'Parc du Thabor',
    city: 'Rennes',
    country: 'France',
    is_upcoming: true,
    artist: { id: 1, name: 'Tri Yann' },
  }

  function mountComponent(concertOverrides = {}) {
    return mount(ConcertCard, {
      props: { concert: { ...baseConcert, ...concertOverrides } },
      global: {
        plugins: [router, pinia],
      },
    })
  }

  it('renders concert title', () => {
    const wrapper = mountComponent()
    expect(wrapper.text()).toContain('Noz Breizh Festival')
  })

  it('renders venue and city', () => {
    const wrapper = mountComponent()
    expect(wrapper.text()).toContain('Parc du Thabor')
    expect(wrapper.text()).toContain('Rennes')
  })

  it('renders "Upcoming" badge when is_upcoming is true', () => {
    const wrapper = mountComponent({ is_upcoming: true })
    expect(wrapper.text()).toContain('Upcoming')
  })

  it('renders "Past" badge when is_upcoming is false', () => {
    const wrapper = mountComponent({ is_upcoming: false })
    expect(wrapper.text()).toContain('Past')
  })

  it('renders price when present', () => {
    const wrapper = mountComponent({ price: 15 })
    expect(wrapper.text()).toContain('15.00')
    expect(wrapper.text()).toContain('EUR')
  })

  it('does not render price section when price is absent', () => {
    const wrapper = mountComponent({ price: undefined })
    expect(wrapper.find('.icon-banknote').exists()).toBe(false)
  })

  it('renders ticket button when ticket_url is present', () => {
    const wrapper = mountComponent({ ticket_url: 'https://tickets.example.com' })
    const link = wrapper.find('a[href="https://tickets.example.com"]')
    expect(link.exists()).toBe(true)
    expect(link.text()).toContain('Get Tickets')
  })

  it('renders Ticketmaster button when ticketmaster_url is present', () => {
    const wrapper = mountComponent({ ticketmaster_url: 'https://ticketmaster.com/event/123' })
    const link = wrapper.find('a[href="https://ticketmaster.com/event/123"]')
    expect(link.exists()).toBe(true)
    expect(link.text()).toContain('Book on Ticketmaster')
  })

  it('does not render ticket button when no ticket url', () => {
    const wrapper = mountComponent({ ticket_url: undefined, ticketmaster_url: undefined })
    expect(wrapper.find('a[target="_blank"]').exists()).toBe(false)
  })
})
