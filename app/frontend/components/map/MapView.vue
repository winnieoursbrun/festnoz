<template>
  <div ref="mapContainer" class="w-full h-full"></div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import L from 'leaflet'

const props = defineProps({
  center: {
    type: Array,
    required: true
  },
  zoom: {
    type: Number,
    default: 13
  },
  concerts: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['concert-click'])

const mapContainer = ref(null)
let map = null
let markers = []

onMounted(() => {
  initMap()
})

onUnmounted(() => {
  if (map) {
    map.remove()
  }
})

watch(() => props.center, (newCenter) => {
  if (map && newCenter) {
    map.setView(newCenter, props.zoom)
  }
})

watch(() => props.concerts, () => {
  updateMarkers()
}, { deep: true })

function initMap() {
  if (!mapContainer.value) return

  // Initialize map
  map = L.map(mapContainer.value).setView(props.center, props.zoom)

  // Add OpenStreetMap tiles
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 19
  }).addTo(map)

  // Add user location marker
  const userIcon = L.divIcon({
    html: '<div style="background: #3b82f6; width: 16px; height: 16px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);"></div>',
    className: '',
    iconSize: [16, 16],
    iconAnchor: [8, 8]
  })

  L.marker(props.center, { icon: userIcon })
    .addTo(map)
    .bindPopup('<div style="text-align: center; padding: 4px;"><strong>You are here</strong></div>')

  // Add concert markers
  updateMarkers()
}

function updateMarkers() {
  if (!map) return

  // Remove existing markers
  markers.forEach(marker => map.removeLayer(marker))
  markers = []

  // Add new markers for each concert
  props.concerts.forEach(concert => {
    const concertIcon = L.divIcon({
      html: `
        <div style="
          background: linear-gradient(135deg, #9333ea 0%, #7c3aed 100%);
          width: 32px;
          height: 32px;
          border-radius: 50%;
          border: 3px solid white;
          box-shadow: 0 4px 6px rgba(0,0,0,0.3);
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 16px;
          cursor: pointer;
          transition: transform 0.2s;
        " onmouseover="this.style.transform='scale(1.2)'" onmouseout="this.style.transform='scale(1)'">
          🎵
        </div>
      `,
      className: '',
      iconSize: [32, 32],
      iconAnchor: [16, 16],
      popupAnchor: [0, -16]
    })

    const marker = L.marker([concert.latitude, concert.longitude], {
      icon: concertIcon
    }).addTo(map)

    // Create popup content
    const popupContent = `
      <div style="min-width: 200px; padding: 8px;">
        <h3 style="margin: 0 0 8px 0; font-size: 16px; font-weight: bold; color: #1f2937;">
          ${concert.title}
        </h3>
        <p style="margin: 0 0 4px 0; font-size: 14px; color: #6b7280;">
          ${concert.artist.name}
        </p>
        <p style="margin: 0 0 4px 0; font-size: 12px; color: #9ca3af;">
          📍 ${concert.venue_name}
        </p>
        <p style="margin: 0 0 8px 0; font-size: 12px; color: #9ca3af;">
          📅 ${new Date(concert.starts_at).toLocaleDateString()}
        </p>
        ${concert.distance ? `<p style="margin: 0 0 8px 0; font-size: 12px; color: #9ca3af;">🗺️ ${concert.distance} km away</p>` : ''}
        <button
          onclick="window.dispatchEvent(new CustomEvent('concert-clicked', { detail: ${JSON.stringify(concert).replace(/"/g, '&quot;')} }))"
          style="
            background: #9333ea;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 500;
            width: 100%;
          "
          onmouseover="this.style.background='#7c3aed'"
          onmouseout="this.style.background='#9333ea'"
        >
          View Details
        </button>
      </div>
    `

    marker.bindPopup(popupContent, {
      maxWidth: 300,
      className: 'concert-popup'
    })

    markers.push(marker)
  })

  // Fit bounds to show all markers if there are concerts
  if (props.concerts.length > 0) {
    const bounds = L.latLngBounds(
      props.concerts.map(c => [c.latitude, c.longitude])
    )
    // Include user location in bounds
    bounds.extend(props.center)
    map.fitBounds(bounds, { padding: [50, 50], maxZoom: 12 })
  }
}

// Listen for custom concert-clicked events from popup buttons
onMounted(() => {
  window.addEventListener('concert-clicked', handleConcertClick)
})

onUnmounted(() => {
  window.removeEventListener('concert-clicked', handleConcertClick)
})

function handleConcertClick(event) {
  emit('concert-click', event.detail)
}
</script>

<style>
.concert-popup .leaflet-popup-content-wrapper {
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}

.concert-popup .leaflet-popup-tip {
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
</style>
